#!/bin/bash

set -e

POLKADOT_REPO_PATH=../polkadot
BRIDGES_REPO_PATH=../parity-bridges-common

SKIP_WASM_BUILD=
SKIP_POLKADOT_BUILD=
# following two variables must be changed at once: either to ("", "debug") or to ("--release", "release")
BUILD_TYPE=--release
BUILD_FOLDER=release
