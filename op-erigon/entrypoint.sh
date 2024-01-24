#!/bin/sh

DATADIR="/home/op-erigon/.local/share/"
PRELOADED_DATA_FILE=/mainnet_data.tar.gz

# Configuration defined in https://github.com/testinprod-io/op-erigon#readme

# Tx pool gossip is disabled as it is not supported yet
# Max peers set to 0 to disable peer discovery (will be enabled in the future for snap sync)

if [ "$_DAPPNODE_GLOBAL_OP_ENABLE_HISTORICAL_RPC" = "true" ]; then
  echo "[INFO - entrypoint] Enabling historical RPC"
  EXTRA_OPTs="$EXTRA_OPTs --rollup.historicalrpc $HISTORICAL_RPC_URL"
fi

# If $DATA_DIR is not empty, then erigon is already initialized
if [ -d "${DATADIR}/database" ]; then
  echo "[INFO - entrypoint] Database already exists, skipping initialization"
else

  echo "[INFO - entrypoint] Database does not exist, initializing erigon..."

  # Before starting the download, check if a partial file exists.
  if [ -f "$PRELOADED_DATA_FILE" ]; then
    echo "[WARNING - entrypoint] Found a partial preloaded data file. Removing it..."
    rm -f $PRELOADED_DATA_FILE
  fi

  echo "[INFO - entrypoint] Downloading preloaded data. This can take hours..."

  # Start the download.
  wget -O $PRELOADED_DATA_FILE https://op-erigon-backup.mainnet.testinprod.io
  if [ $? -ne 0 ]; then
    echo "[ERROR - entrypoint] Failed to download preloaded data."
    exit 1
  fi

  echo "[INFO - entrypoint] Decompressing preloaded data. This can take a while..."
  tar -zxvf $PRELOADED_DATA_FILE -C $DATADIR # /database is created here, as the preloaded data file is database/chaindata.
  if [ $? -ne 0 ]; then
    echo "[ERROR - entrypoint] Failed to decompress preloaded data."
    rm -f $PRELOADED_DATA_FILE # Remove the faulty file
    exit 1
  fi

  echo "[INFO - entrypoint] Removing preloaded data file. Not needed anymore."
  rm -rf $PRELOADED_DATA_FILE
fi

echo "[INFO - entrypoint] Starting Erigon"
exec erigon --datadir=${DATADIR}/database \
  --rollup.sequencerhttp=${SEQUENCER_HTTP_URL} \
  --rollup.disabletxpoolgossip=true \
  --maxpeers=0 \
  --nodiscover \
  --http.addr=0.0.0.0 \
  --http.port=8545 \
  --http.corsdomain='*' \
  --http.vhosts='*' \
  --ws \
  --private.api.addr=0.0.0.0:9090 \
  --metrics \
  --metrics.addr=0.0.0.0 \
  --metrics.port=6060 \
  --port=${P2P_PORT} \
  --authrpc.jwtsecret=/config/jwtsecret.hex \
  --authrpc.addr=0.0.0.0 \
  --authrpc.vhosts='*' \
  --authrpc.port=8551 \
  --chain=op-mainnet \
  ${EXTRA_OPTs}
