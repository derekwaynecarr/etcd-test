#!/bin/bash

# Scenario:
#  Adds N projects, where each project has a project scoped deploymentConfig
#  Intended to illustrate memory usage of etcd at large numbers of nodes in a directory
#  And large numbers of directories with a single node.
# 
# Prerequisite:
#  Ensure etcd is running.
#
# Usage instructions:
# STATS_LABEL="small" TOTAL_PROJECTS=10 ./populate-origin.sh
# Populate 10 projects, and output results in ./stats/small/

# Global variables
ETCD="http://127.0.0.1:4001"
SALT=$RANDOM
LOG_INTERVAL=${LOG_INTERVAL-"10000"}
MEM_INTERVAL=${MEM_INTERVAL-"100000"}
STATS_LABEL=${STATS_LABEL-"default"}
TOTAL_PROJECTS=${TOTAL_PROJECTS-"10"}

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
NUM_PROJECT=0
KEY_PROJECT_DIR="/projects"
KEY_DEPLOYMENT_CONFIG_DIR="/deployments"

echo "Begin population"
while [ $NUM_PROJECT -lt $TOTAL_PROJECTS ]; do
  
  # create a project
  PROJECT_ID="project_${SALT}_${NUM_PROJECT}"
  KEY_PATH="${KEY_PROJECT_DIR}/${PROJECT_ID}"
  curl -silent -L $ETCD/v2/keys/$KEY_PATH -XPUT -d value="$(cat data/project.json)" >/dev/null

  # create a deployment config
  DEPLOYMENT_CONFIG_ID="redisslave-config"
  KEY_PATH="${KEY_DEPLOYMENT_CONFIG_DIR}/${PROJECT_ID}/${DEPLOYMENT_CONFIG_ID}"
  curl -silent -L $ETCD/v2/keys/$KEY_PATH -XPUT -d value="$(cat data/deploymentConfig.json)" >/dev/null

  if [ $(($NUM_PROJECT%$LOG_INTERVAL)) == 0 ]; then
    echo "Populated ${NUM_PROJECT} projects"
  fi    

  if [ $(($NUM_PROJECT%$MEM_INTERVAL)) == 0 ]; then
    echo "Output stats for etcd at ${NUM_PROJECT}"
    cat /proc/$PID_ETCD/status > $STATS_DIR/etcd.${NUM_PROJECT}.memory
    ls -lsh default.etcd/snap > $STATS_DIR/etcd.${NUM_PROJECT}.snapshot
  fi
  let NUM_PROJECT=NUM_PROJECT+1
done

echo "Populated ${NUM_PROJECT} projects"
echo "Output stats for etcd at ${NUM_PROJECT}"
cat /proc/$PID_ETCD/status > $STATS_DIR/etcd.${NUM_PROJECT}.memory
ls -lsh default.etcd/snap > $STATS_DIR/etcd.${NUM_PROJECT}.snapshot
echo "Done"
