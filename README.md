# Etcd-Test use cases for Origin

## Test setup

Populate N projects, where each project has a single deployment config.

## How to run tests

Start etcd with defaults:

$ etcd

To populate:

```
export STATS_LABEL="large"
export TOTAL_PROJECTS=1000000
time ./populate.sh
```

To view metrics:

At every MEM_INTERVAL number of projects, etcd memory and snapshot sizes are recorded.

By default, MEM_INTERVAL was 10000 to align closely with etcd snapshot interval.

```
cd stats/large
cat etcd.${NUM_PROJECT}.memory
cat etcd.${NUM_PROJECT}.snapshot
```

## Test results

See docs