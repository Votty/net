#!/bin/bash

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

# clean the keystore
rm -rf ./hfc-key-store

export VERSION=(expr $VERSION + 1);

docker exec -e "CORE_PEER_LOCALMSPID=InitPeerMSP" -e "CORE_PEER_MSPCONFIGPATH=/peer/crypto/peerOrganizations/init.votty.net/users/Admin@init.votty.net/msp" votty-cli peer chaincode install -n votty-chaincode -v $VERSION -p "/peer/cc/chaincode/Vapp" -l "node"

echo "Successfully installed Chaincode!"

docker exec -e "CORE_VM_DOCKER_ATTACHSTDOUT=true" -e "CORE_PEER_LOCALMSPID=InitPeerMSP" -e "CORE_PEER_MSPCONFIGPATH=/peer/crypto/peerOrganizations/init.votty.net/users/Admin@init.votty.net/msp" votty-cli peer chaincode upgrade -o peers.votty.net:7050 -C votty -n votty-chaincode -l "node" -v $VERSION -c '{"Args":[""]}' -P "OR ('InitPeerMSP.member')"

echo "Successfully instantiated Chaincode version" $VERSION "!" 
echo -ne '\007'
