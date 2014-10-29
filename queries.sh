#!/bin/bash

# Prerequisite:
#  Ensure etcd is running and populated.
#
# Usage instructions:
# STATS_LABEL="large" ./queries.sh
# Execute project and deployment queries, and output results in ./stats/large/query_results

# Global variables
ETCD="http://127.0.0.1:4001"

# Ensure etcd is running
PID_ETCD=$(pidof etcd)
if [ -z "$PID_ETCD" ]; then
  echo "Etcd is not running"
  exit 1
fi
echo "PID etcd: $PID_ETCD"

# Ensure we have a stats directory for this run
STATS_LABEL=${STATS_LABEL-"default"}
STATS_DIR="stats/${STATS_LABEL}"
mkdir -p $STATS_DIR

# How many times to attempt each request
TOTAL_RUN=3
NUM_RUN=0

echo "Begin queries"
while [ $NUM_RUN -lt $TOTAL_RUN ]; do  
  
  echo "List all projects"
  time curl -silent -L $ETCD/v2/keys/projects >/dev/null

  echo "List all deployments (recursive)"
  time curl -silent -L $ETCD/v2/keys/deployments?recursive=true >/dev/null  

  let NUM_RUN=NUM_RUN+1
done > ${STATS_DIR}/query_results
echo "Done"
