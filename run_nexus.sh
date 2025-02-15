#!/bin/sh

# curl -O https://raw.githubusercontent.com/c-jy/nexus/refs/heads/main/run_nexus.sh && chmod +x run_nexus.sh && nohup ./run_nexus.sh &

NEXUS_HOME=$HOME/.nexus
REPO_PATH=$NEXUS_HOME/network-api

(cd $REPO_PATH/clients/cli && cargo run --release --bin prover -- 34.30.84.32)