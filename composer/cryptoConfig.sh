#!/bin/bash

rm -rf crypto-config
cryptogen generate --config=./crypto-config.yaml

if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
else
    echo "Change docker-compose.yml!!"
    echo $(basename $(ls -1 crypto-config/peerOrganizations/init.votty.net/ca/*_sk))
fi

export FABRIC_CFG_PATH=$PWD

configtxgen -profile ComposerOrdererGenesis -outputBlock ./composer-genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

configtxgen -profile ComposerChannel -outputCreateChannelTx ./composer-channel.tx -channelID votty
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

