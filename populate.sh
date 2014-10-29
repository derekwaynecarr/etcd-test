#!/bin/bash

# Populate an etcd repository for memory testing
ETCD="http://127.0.0.1:4001"
SALT=$RANDOM
LOG_INTERVAL=5000
TOTAL_PROJECTS=${TOTAL_PROJECTS-"10"}
NUM_PROJECT=0
KEY_PROJECT_DIR="/projects"
KEY_DEPLOYMENT_CONFIG_DIR="/deployments"

echo "Begin population"
while [ $NUM_PROJECT -lt $TOTAL_PROJECTS ]; do
  
  # create a project
  PROJECT_JSON='{ 
    "id": "${PROJECT_ID}", 
    "kind": "Project", 
    "apiVersion": "v1beta1", 
    "displayName": "Hello ${PROJECT_ID}", 
    "description": "This is an example project", 
    "labels": 
      {"name": "hello-openshift-project"}
    }'    
  PROJECT_ID="project_${SALT}_${NUM_PROJECT}"
  KEY_PATH="${KEY_PROJECT_DIR}/${PROJECT_ID}"
  curl -silent -L $ETCD/v2/keys/$KEY_PATH -XPUT -d value="$PROJECT_JSON" >/dev/null

  # create a deployment config
  DEPLOYMENT_CONFIG_JSON='{
    "id": "redisslave-config",
    "kind": "DeploymentConfig",
    "apiVersion": "v1beta1",
    "triggerPolicy": "manual",
    "template": {
      "strategy": {
        "type": "CustomPod",
        "customPod": {
          "image": "127.0.0.1:5000/openshift/kube-deploy"
        }
    },
    "controllerTemplate": {
      "replicas": 2,
      "replicaSelector": {
        "name": "redisslave"
      },
      "podTemplate": {
        "desiredState": {
          "manifest": {
            "version": "v1beta1",
            "id": "redisSlaveController",
            "containers": [
              {
                "name": "slave",
                "image": "brendanburns/redis-slave",
                "env": [
                  {
                    "name": "REDIS_PASSWORD",
                    "value": "secret"
                  }
                ],
                "ports": [
                  {
                    "containerPort": 6379
                  }
                ]
              }
            ]
          }
        },
        "labels": {
          "name": "redisslave"
        }
      }
    }
  }
}'

  DEPLOYMENT_CONFIG_ID="redisslave-config"
  KEY_PATH="${KEY_DEPLOYMENT_CONFIG_DIR}/${PROJECT_ID}/${DEPLOYMENT_CONFIG_ID}"
  curl -silent -L $ETCD/v2/keys/$KEY_PATH -XPUT -d value="$DEPLOYMENT_CONFIG_JSON" >/dev/null

  if [ $(($NUM_PROJECT%$LOG_INTERVAL)) == 0 ]; then
    echo "Populated ${NUM_PROJECT} projects"
  fi    
  let NUM_PROJECT=NUM_PROJECT+1
done
echo "Populated ${NUM_PROJECT} projects"
echo "Done"



