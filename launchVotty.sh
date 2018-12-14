#!/bin/bash

# Exit on first error
set -e

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

# clean the keystore
rm -rf ./hfc-key-store

docker-compose -f ./composer/docker-compose.yml up -d votty-cli

docker exec -e "CORE_PEER_LOCALMSPID=InitPeerMSP" -e "CORE_PEER_MSPCONFIGPATH=/peer/crypto/peerOrganizations/init.votty.net/users/Admin@init.votty.net/msp" votty-cli peer chaincode install -n votty-chaincode -v 1.0 -p "/peer/cc/chaincode/Vapp" -l "node"

#docker exec -e "CORE_PEER_LOCALMSPID=InitPeerMSP" -e "CORE_PEER_MSPCONFIGPATH=/peer/crypto/peerOrganizations/init.votty.net/users/Admin@init.votty.net/msp" votty-cli peer chaincode install -n fabcar -v 1.0 -p "/peer/fabcar" -l "node"

echo "Successfully installed Chaincode!"

docker exec -e "CORE_VM_DOCKER_ATTACHSTDOUT=true" -e "CORE_PEER_LOCALMSPID=InitPeerMSP" -e "CORE_PEER_MSPCONFIGPATH=/peer/crypto/peerOrganizations/init.votty.net/users/Admin@init.votty.net/msp" votty-cli peer chaincode instantiate -o peers.votty.net:7050 -C votty -n votty-chaincode -l "node" -v 1.0 -c '{"Args":[""]}' -P "OR ('InitPeerMSP.member')"

#docker exec -e "CORE_PEER_LOCALMSPID=InitPeerMSP" -e "CORE_PEER_MSPCONFIGPATH=/peer/crypto/peerOrganizations/init.votty.net/users/Admin@init.votty.net/msp" votty-cli peer chaincode instantiate -o peers.votty.net:7050 -C votty -n fabcar -l "node" -v 1.0 -c '{"Args":[""]}' -P "OR ('InitPeerMSP.member')"

echo "Successfully instantiated Chaincode!"
