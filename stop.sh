#!/bin/bash

killall -9 polkadot
killall -9 substrate-relay
pkill -9 -f 'rococo-to-wococo-messages-generator.sh'
