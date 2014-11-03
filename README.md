# Etcd-Test Scenarios

## Background

This is a set of suites used to evaluate etcd at large scales of nodes.

## Key Take-aways

At large numbers of nodes, etcd appears to scale close to a 13 : 1 memory to disk usage ratio independent of key value size.

Start-up time is pretty good even at large numbers of nodes, and seems to scale more with node size than data size.

Garbage collection in Go needs to be better analyzed, obvious plateaus at 10k intervals in etcd.

It's possible binary storage in etcd could help, but it appears that it could only help us get closer to the measured 13:1 ratio.

## View results

| Scenario | Results |
| --- | --- |
| 200k nodes in a directory | link |
| 200k nodes in a directory with 0 byte values | link |
| 200k directories each with a single node | link |
| 1 million projects in origin with 1 deployment | link |

## Scenario: Large numbers of nodes in a single directory

This scenario creates a large number of nodes in a single directory and captures the memory usage of the process.

Start etcd with defaults:

```
$ rm -fr default.etcd
$ etcd
```

Run the script:

```
$ export MEM_INTERVAL=10000
$ export STATS_LABEL=nodes-in-dir-200k
$ export TOTAL_NODES=200000
$ ./populate-nodes-in-dir.sh
```

This will populate 200k nodes in a single etcd directory and capture memory usage of process after each 10k nodes.

To view the stats and snapshots, look here:

```
$ cd stats/$STATS_LABEL/
$ ll -a
$ cat etcd.200000.memory
$ cat etcd.200000.snapshot
```
## Scenario: Large numbers of directories each with a single node

This scenario creates a large number of directories, where each directory has a single node.

Start etcd with defaults:

```
$ rm -fr default.etcd
$ etcd
```

Run the script:

```
$ export MEM_INTERVAL=10000
$ export STATS_LABEL=nodes-span-dir-200k
$ export TOTAL_NODES=200000
$ ./populate-nodes-span-dir.sh
```

This will populate 200k directory nodes where each node has a single value node.

To view the stats and snapshots, look here:

```
$ cd stats/$STATS_LABEL/
$ ll -a
$ cat etcd.200000.memory
$ cat etcd.200000.snapshot
```

## Scenario: Origin scenario

This scenario simulates operating Origin style use cases at largest scales.

It creates N projects that are all rooted under a common parent directory.

For each project, it creates a single deploymentConfig that is each rooted under its own parent directory.

As a result, this test blends the two prior scenarios, and simulates a small subset of planned Origin resources.

Intended to inform decision making on etcd at largest scales.

Start etcd with defaults:

```
$ rm -fr default.etcd
$ etcd
```

Run the script:

```
$ export MEM_INTERVAL=10000
$ export STATS_LABEL=origin-1mill
$ export TOTAL_PROJECTS=1000000
$ ./populate-origin.sh
```

This will populate 200k projects and deployment configs.

To view the stats and snapshots, look here:

```
$ cd stats/$STATS_LABEL/
$ ll -a
$ cat etcd.200000.memory
$ cat etcd.200000.snapshot
```