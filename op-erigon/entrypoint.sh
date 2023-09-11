#!/bin/sh

DATA_DIR=/data

# Configuration defined in https://github.com/testinprod-io/op-erigon#readme

# Tx pool gossip is disabled as it is not supported yet
# Max peers set to 0 to disable peer discovery (will be enabled in the future for snap sync)

if [ "$ENABLE_HISTORICAL_RPC" = "true" ]; then
  echo "[INFO - entrypoint] Enabling historical RPC"
  EXTRA_FLAGS="--rollup.historicalrpc $HISTORICAL_RPC_URL"
fi

# If $DATA_DIR is not empty, then erigon is already initialized
if [ "$(ls -A $DATA_DIR)" ]; then
  echo "[INFO - entrypoint] Database already exists, skipping initialization"
else
  echo "[INFO - entrypoint] $DATA_DIR is empty, initializing geth..."

  echo "[INFO - entrypoint] Initializing geth from preloaded data"
  echo "[INFO - entrypoint] Downloading preloaded data from $PRELOADED_DATA_URL. This can take hours..."
  mkdir -p $DATA_DIR

  wget -O /mainnet_data.tar.gz https://op-erigon-backup.mainnet.testinprod.io

  echo "[INFO - entrypoint] Decompressing preloaded data. This can take a while..."
  tar -zxvf /mainnet_data.tar.gz -C $DATA_DIR

  rm -rf /mainnet_data.tar.gz
fi

echo "[INFO - entrypoint] Starting Erigon"
exec erigon --datadir=${DATADIR} \
  --rollup.sequencerhttp=${SEQUENCER_HTTP_URL} \
  --rollup.disabletxpoolgossip=true \
  --nodiscover \
  --maxpeers 0 \
  --http.addr=0.0.0.0 \
  --http.port=8545 \
  --http.corsdomain="*" \
  --http.vhosts="*" \
  --ws \
  --private.api.addr=0.0.0.0:9090 \
  --metrics \
  --metrics.addr=0.0.0.0 \
  --metrics.port=6060 \
  --pprof \
  --pprof.addr=0.0.0.0 \
  --pprof.port=6061 \
  --port=${P2P_PORT} \
  --authrpc.jwtsecret=/config/jwtsecret.hex \
  --authrpc.addr 0.0.0.0 \
  --authrpc.vhosts=* \
  --authrpc.port=8551 \
  --chain=optimism-mainnet \
  ${EXTRA_FLAGS}
