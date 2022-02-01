#!/bin/bash

. ./prelude.sh

mkdir bin || true
mkdir data || true
mkdir logs || true
rm -rf data/rococo-alice.db
rm -rf data/rococo-bob.db
rm -rf data/wococo-alice.db
rm -rf data/wococo-bob.db
rm -rf logs/*

. ./build-polkadot-node.sh
. ./build-substrate-relay.sh

###############################################################################
### Rococo chain startup ######################################################
###############################################################################

RUST_LOG=runtime=trace,runtime::bridge=trace
export RUST_LOG

# start Rococo nodes
./run-with-log.sh rococo-alice "./bin/polkadot\
	--chain=rococo-dev
	--alice\
	--base-path=data/rococo-alice.db\
	--bootnodes=/ip4/127.0.0.1/tcp/30334/p2p/12D3KooWSEpHJj29HEzgPFcRYVc5X3sEuP3KgiUoqJNCet51NiMX\
	--node-key=79cf382988364291a7968ae7825c01f68c50d679796a8983237d07fe0ccf363b\
	--port=30333\
	--prometheus-port=9615\
	--rpc-port=9933\
	--ws-port=9944\
	--execution=Native\
	--rpc-cors=all\
	--unsafe-rpc-external\
	--unsafe-ws-external"&
./run-with-log.sh rococo-bob "./bin/polkadot\
	--chain=rococo-dev
	--bob\
	--base-path=data/rococo-bob.db\
	--bootnodes=/ip4/127.0.0.1/tcp/30333/p2p/12D3KooWMF6JvV319a7kJn5pqkKbhR3fcM2cvK5vCbYZHeQhYzFE\
	--node-key=4f9d0146dd9b7b3bf5a8089e3880023d1df92057f89e96e07bb4d8c2ead75bbd\
	--port=30334\
	--prometheus-port=9616\
	--rpc-port=9934\
	--ws-port=9945\
	--execution=Native\
	--rpc-cors=all\
	--unsafe-rpc-external\
	--unsafe-ws-external"&

###############################################################################
### Woocco chain startup ######################################################
###############################################################################

RUST_LOG=runtime=trace,runtime::bridge=trace
export RUST_LOG

# start Wococo nodes
./run-with-log.sh wococo-alice "./bin/polkadot\
	--chain=wococo-dev
	--alice\
	--base-path=data/wococo-alice.db\
	--bootnodes=/ip4/127.0.0.1/tcp/30336/p2p/12D3KooWHTYUAtF6ry4mrYTufzLfDSJ725mYc85rSKFzuFkXEvFT\
	--node-key=79cf382988364291a7968ae7825c01f68c50d679796a8983237d07fe0ccf363c\
	--port=30335\
	--prometheus-port=9617\
	--rpc-port=9935\
	--ws-port=9946\
	--execution=Native\
	--rpc-cors=all\
	--unsafe-rpc-external\
	--unsafe-ws-external"&
./run-with-log.sh wococo-bob "./bin/polkadot\
	--chain=wococo-dev
	--bob\
	--base-path=data/wococo-bob.db\
	--bootnodes=/ip4/127.0.0.1/tcp/30335/p2p/12D3KooWKWnNktXrugMMYa4NFB18qxwF49rABJgHiLGJq7uVfs5E\
	--node-key=79cf382988364291a7968ae7825c01f68c50d679796a8983237d07fe0ccf363d\
	--port=30336\
	--prometheus-port=9618\
	--rpc-port=9936\
	--ws-port=9947\
	--execution=Native\
	--rpc-cors=all\
	--unsafe-rpc-external\
	--unsafe-ws-external"&

###############################################################################
### Headers+messages relay startup ############################################
###############################################################################

RUST_LOG=bridge=trace
export RUST_LOG

ROCOCO_HOST=127.0.0.1
ROCOCO_PORT=9944
WOCOCO_HOST=127.0.0.1
WOCOCO_PORT=9946
RELAY_BINARY_PATH=./bin/substrate-relay

# initialize Rococo -> Wococo headers bridge
./run-with-log.sh initialize-rococo-to-wococo "$RELAY_BINARY_PATH\
	init-bridge rococo-to-wococo\
	--source-host=$ROCOCO_HOST\
	--source-port=$ROCOCO_PORT\
	--target-host=$WOCOCO_HOST\
	--target-port=$WOCOCO_PORT\
	--target-signer=//Alice\
	--target-version-mode=Auto"&

# initialize Wococo -> Rococo headers bridge
./run-with-log.sh initialize-wococo-to-rococo "$RELAY_BINARY_PATH\
	init-bridge wococo-to-rococo\
	--source-host=$WOCOCO_HOST\
	--source-port=$WOCOCO_PORT\
	--target-host=$ROCOCO_HOST\
	--target-port=$ROCOCO_PORT\
	--target-signer=//Alice\
	--target-version-mode=Auto"&

# start rococo-wococo headers+messages relay
./run-with-log.sh relay-rococo-wococo "$RELAY_BINARY_PATH\
	relay-headers-and-messages rococo-wococo\
	--create-relayers-fund-accounts\
	--relayer-mode=altruistic\
	--rococo-host=$ROCOCO_HOST\
	--rococo-port=$ROCOCO_PORT\
	--rococo-signer=//Alice\
	--rococo-version-mode=Auto\
	--wococo-host=$WOCOCO_HOST\
	--wococo-port=$WOCOCO_PORT\
	--wococo-signer=//Alice\
	--wococo-version-mode=Auto\
	--lane=00000000\
	--lane=00000001\
	--prometheus-port=9700"&

###############################################################################
### Generate messages #########################################################
###############################################################################

# start generating Rococo -> Wococo messages
./run-with-log.sh \
	rococo-to-wococo-messages-generator\
	./rococo-to-wococo-messages-generator.sh&
