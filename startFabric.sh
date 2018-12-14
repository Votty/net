#!/bin/bash

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Exit on first error, print all commands.
set -e

Usage() {
	echo ""
	echo "Usage: ./startFabric.sh [-d || --dev]"
	echo ""
	echo "Options:"
	echo -e "\t-d or --dev: (Optional) enable fabric development mode"
	echo ""
	echo "Example: ./startFabric.sh"
	echo ""
	exit 1
}

Parse_Arguments() {
	while [ $# -gt 0 ]; do
		case $1 in
			--help)
				HELPINFO=true
				;;
            --dev | -d)
				FABRIC_DEV_MODE=true
				;;
		esac
		shift
	done
}

Parse_Arguments $@

if [ "${HELPINFO}" == "true" ]; then
    Usage
fi

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "${FABRIC_DEV_MODE}" == "true" ]; then
    DOCKER_FILE="${DIR}"/composer/docker-compose-dev.yml
else
    DOCKER_FILE="${DIR}"/composer/docker-compose.yml
fi

docker-compose -f "${DOCKER_FILE}" down
docker-compose -f "${DOCKER_FILE}" up -d ca.init.votty.net peers.votty.net d1.init.votty.net votty-db

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue
export FABRIC_START_TIMEOUT=3
echo "sleeping for ${FABRIC_START_TIMEOUT} seconds to wait for fabric to complete start up"
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
docker exec d1.init.votty.net peer channel create -o peers.votty.net:7050 -c votty -f /etc/hyperledger/configtx/composer-channel.tx

echo
echo
echo
echo
printf "SEX"
echo
echo
echo
echo


# Join peer0.org1.example.com to the channel.
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@init.votty.net/msp" d1.init.votty.net peer channel join -b votty.block

if [ "${FABRIC_DEV_MODE}" == "true" ]; then
    echo "Fabric Network started in chaincode development mode"
else
	echo "Fabric Network started in chaincode product mode"
fi

