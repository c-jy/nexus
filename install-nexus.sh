#!/bin/sh

# ps -ef | grep "monitor_nexus" | awk '{print $2}' | sudo xargs kill -9
# ps -ef | grep "nexus-prover" | awk '{print $2}' | sudo xargs kill -9
# curl -O wget https://raw.githubusercontent.com/c-jy/nexus/refs/heads/main/install-nexus.sh && chmod +x install-nexus.sh && sudo nohup ./install-nexus.sh &


# Parse command line arguments
PROVER_ID=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --prover-id) PROVER_ID="$2"; shift 2;;
        *) echo "Unknown parameter: $1"; exit 1;;
    esac
done

sudo apt update
sudo apt install --no-upgrade build-essential pkg-config libssl-dev git-all -y

# Set auto mode
export NONINTERACTIVE=true
# Auto install rust, -y means auto accept all prompts
rustc --version || curl https://sh.rustup.rs -sSf | sh -s -- -y
. "$HOME/.cargo/env"
# Add these lines: Update rust to latest version
source "$HOME/.cargo/env"
rustup default stable
rustup update

NEXUS_HOME=$HOME/.nexus
GREEN='\033[1;32m'
ORANGE='\033[1;33m'
NC='\033[0m'

# Auto create prover-id directory
mkdir -p $NEXUS_HOME

# Generate or use provided prover-id
if [ -n "$PROVER_ID" ]; then
    echo "$PROVER_ID" > $NEXUS_HOME/prover-id
elif [ ! -f "$NEXUS_HOME/prover-id" ]; then
    RANDOM_PROVER_ID=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 28)
    echo "$RANDOM_PROVER_ID" > $NEXUS_HOME/prover-id
fi

# Check and install git
git --version 2>&1 >/dev/null
GIT_IS_AVAILABLE=$?
if [ $GIT_IS_AVAILABLE != 0 ]; then
    apt-get update && apt-get install -y git
fi

# Install protoc
REQUIRED_PROTOC="3.15.8"
if command -v protoc &> /dev/null; then
    INSTALLED_PROTOC=$(protoc --version | cut -d' ' -f2)
    if [ "$INSTALLED_PROTOC" = "$REQUIRED_PROTOC" ]; then
        echo "protoc $REQUIRED_PROTOC is already installed"
    else
        echo "Installing protoc $REQUIRED_PROTOC..."
        apt-get update && apt-get install -y unzip
        curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v$REQUIRED_PROTOC/protoc-$REQUIRED_PROTOC-linux-x86_64.zip
        unzip -o protoc-$REQUIRED_PROTOC-linux-x86_64.zip -d /usr/local
        chmod +x /usr/local/bin/protoc
        rm protoc-$REQUIRED_PROTOC-linux-x86_64.zip
    fi
else
    echo "Installing protoc $REQUIRED_PROTOC..."
    apt-get update && apt-get install -y unzip
    curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v$REQUIRED_PROTOC/protoc-$REQUIRED_PROTOC-linux-x86_64.zip
    unzip -o protoc-$REQUIRED_PROTOC-linux-x86_64.zip -d /usr/local
    chmod +x /usr/local/bin/protoc
    rm protoc-$REQUIRED_PROTOC-linux-x86_64.zip
fi

REPO_PATH=$NEXUS_HOME/network-api
if [ -d "$REPO_PATH" ]; then
    echo "$REPO_PATH exists. Updating.";
    (cd $REPO_PATH && git stash save && git fetch --tags)
else
    mkdir -p $NEXUS_HOME
    (cd $NEXUS_HOME && git clone https://github.com/nexus-xyz/network-api)
fi

# Auto checkout latest tag
(cd $REPO_PATH && git -c advice.detachedHead=false checkout $(git rev-list --tags --max-count=1))

# Run program
(cd $REPO_PATH/clients/cli && cargo run --release --bin prover -- 34.30.84.32)