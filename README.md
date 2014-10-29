# Etcd-Test use cases for Origin

## Test setup

Populate N projects, where each project has a single deployment config.

## How to run tests

Start with defaults:

$ etcd

To populate:

```
export TOTAL_PROJECTS=1000000
time ./populate.sh
```

To gather metrics:


## Test results

### Etcd 0.4.5

N=1000000

| Metric | Value |
| ---- | ---- |
| Time to populate | ? |
| Time to list all projects (Avg) | ? |
| Time to list all deployments (Avg) | ? |
| Time to watch projects (initial) | ? |
| Time to watch deployments (initial) | ? |
| Etcd Mem Usage | ? |
| Etcd Snapshot size | ? |
| Etcd Log size | ? |
| Etcd start-up time | ? |

