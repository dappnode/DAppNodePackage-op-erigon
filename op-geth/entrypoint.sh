#!/bin/sh

DATA_DIR=/data

# Configuration defined in https://community.optimism.io/docs/developers/bedrock/node-operator-guide/#configuring-op-geth

# Tx pool gossip is disabled as it is not supported yet
# Max peers set to 0 to disable peer discovery (will be enabled in the future for snap sync)
# TODO: Should we add --http.api and --ws.api flags?

if [ "$ENABLE_HISTORICAL_RPC" = "true" ]; then
  echo "[INFO - entrypoint] Enabling historical RPC"
  EXTRA_FLAGS="--rollup.historicalrpc $HISTORICAL_RPC_URL --gcmode archive"
else
  echo "[INFO - entrypoint] Historical RPC is disabled"
  EXTRA_FLAGS="--gcmode full"
fi

# If $DATA_DIR is not empty, then geth is already initialized
if [ "$(ls -A $DATA_DIR)" ]; then
  echo "[INFO - entrypoint] Database already exists, skipping initialization"
else
  echo "[INFO - entrypoint] $DATA_DIR is empty, initializing geth..."

  # If GENESIS_MODE is set to GenesisFile (non case sensitive), then geth will be initialized from it
  if [ "$GENESIS_MODE" = "GenesisFile" ]; then
    echo "[INFO - entrypoint] Initializing geth from genesis file"
    geth --datadir=$DATA_DIR init /config/genesis.json
  else
    echo "[INFO - entrypoint] Initializing geth from preloaded data"
    echo "[INFO - entrypoint] Downloading preloaded data from $PRELOADED_DATA_URL. This can take hours..."
    mkdir -p $DATA_DIR
    wget -O /preloaded-mainnet-data/mainnet-bedrock.tar.zst https://datadirs.optimism.io/mainnet-bedrock.tar.zst
    echo "[INFO - entrypoint] Decompressing preloaded data. This can take a while..."
    zstd -d --stdout /preloaded-mainnet-data/mainnet-bedrock.tar.zst | tar xvf - -C $DATA_DIR
    rm -rf /preloaded-mainnet-data
    EXTRA_FLAGS="--datadir.ancient $DATA_DIR/geth/chaindata/ancient"
  fi

fi

echo "[INFO - entrypoint] Starting Geth"
exec geth --datadir $DATA_DIR \
  --rollup.sequencerhttp $SEQUENCER_HTTP_URL \
  --rollup.disabletxpoolgossip \
  --ws \
  --ws.port 8546 \
  --ws.addr 0.0.0.0 \
  --ws.origins "*" \
  --http \
  --http.port 8545 \
  --http.addr 0.0.0.0 \
  --http.vhosts "*" \
  --http.corsdomain "*" \
  --authrpc.addr 0.0.0.0 \
  --authrpc.port 8551 \
  --authrpc.vhosts "*" \
  --authrpc.jwtsecret /config/jwtsecret.hex \
  --verbosity 3 \
  --nodiscover \
  --maxpeers 0 \
  --syncmode full \
  --networkid=10 \
  ${EXTRA_FLAGS}
