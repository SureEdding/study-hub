#!/bin/bash
# Verify Ballot Contract

ROPSTEN_ADDRESS=0x44C6181F3Eb377E39e66F31740707BE458A5eAC6
RINKEBY_ADDRESS=0x44C6181F3Eb377E39e66F31740707BE458A5eAC6
npx hardhat verify --constructor-args scripts/verify.js $RINKEBY_ADDRESS --network rinkeby 