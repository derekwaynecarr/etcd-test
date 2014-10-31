#!/bin/bash

# Prerequisite:
#  Ensure etcd is running.
#
# Usage instructions:
# STATS_LABEL="small" TOTAL_NODES=10 LOG_INTERVAL=1 MEM_INTERVAL=10 RESOURCE="data/project.json" ./populate.sh

# Global variables
ETCD="http://127.0.0.1:4001"
SALT=$RANDOM
LOG_INTERVAL=${LOG_INTERVAL-"10000"}
MEM_INTERVAL=${MEM_INTERVAL-"100000"}
STATS_LABEL=${STATS_LABEL-"default"}
TOTAL_NODES=${TOTAL_NODES-"10"}
RESOURCE=${RESOURCE-"data/project.json"}

# Ensure etcd is running
PID_ETCD=$(pidof etcd)
if [ -z "$PID_ETCD" ]; then
  echo "Etcd is not running"
  exit 1
fi
echo "PID etcd: $PID_ETCD"

# Ensure we have a stats directory for this run
STATS_DIR="stats/${STATS_LABEL}"
mkdir -p $STATS_DIR

# Counters
NUM_NODE=0
KEY_NODE_DIR="/nodes"

echo "Begin population"
while [ $NUM_NODE -lt $TOTAL_NODES ]; do
  
  # create a node in a directory
  NODE_DIR_ID="node_${SALT}_${NUM_NODES}"
  NODE_ID="node_${NUM_NODES}"
  KEY_PATH="${KEY_NODE_DIR}/${NODE_DIR_ID}/${NODE_ID}"
  curl -silent -L $ETCD/v2/keys/$KEY_PATH -XPUT -d value="$(cat $RESOURCE)" >/dev/null

  if [ $(($NUM_NODE%$LOG_INTERVAL)) == 0 ]; then
    echo "Populated ${NUM_NODE} nodes"
  fi    

  if [ $(($NUM_NODE%$MEM_INTERVAL)) == 0 ]; then
    echo "Output stats for etcd at ${NUM_NODE}"
    cat /proc/$PID_ETCD/status > $STATS_DIR/etcd.${NUM_NODE}.memory
    ls -lsh default.etcd/snap > $STATS_DIR/etcd.${NUM_NODE}.snapshot
  fi
  let NUM_NODE=NUM_NODE+1
done

echo "Populated ${NUM_NODE} nodes"
echo "Output stats for etcd at ${NUM_NODE}"
cat /proc/$PID_ETCD/status > $STATS_DIR/etcd.${NUM_NODE}.memory
ls -lsh default.etcd/snap > $STATS_DIR/etcd.${NUM_NODE}.snapshot
echo "Done"
