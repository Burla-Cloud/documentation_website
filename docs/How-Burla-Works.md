---
sidebar_position: 5
hide_title: True
---

### How Burla works.

This document gives a breif overview of the major Burla components, how they interact, and what actually happens when a request is submitted.  
Contents:

1. [TLDR / Overview](#tldr--overview)
2. [What happens _before_ a call to `remote_parallel_map`](#what-happens-before-a-call-to-remote_parallel_map)
3. [What happens _during_ a call to `remote_parallel_map`](#what-happens-during-a-call-to-remote_parallel_map)
4. [What happens _after_ a call to `remote_parallel_map`](#what-happens-after-a-call-to-remote_parallel_map)

##### Disclaimers:

_To prevent staleness this document only explains things unlikely to change in the near future._  
_We're aware we've committed a couple architecture no-no's, and understand the implications._

Last Updated: 4/9/24

### TLDR / Overview:

#### Components:

Burla has four major components:

1. [Burla](https://github.com/burla-cloud/burla)  
   The python package (the client).
2. [main_service](https://github.com/burla-cloud/main_service)  
   Service representing a single cluster, manages nodes, routes requests to node_services.
3. [node_service](https://github.com/burla-cloud/node_service)  
   Service running on each node, manages containers, routes requests to container_services.
4. [container_service](https://github.com/burla-cloud/container_service)  
   Service running inside each container, executes user submitted functions.

The three services read/write to the same central Google Cloud Firestore DB.

#### Functionality:

- Burla clusters are multi-tenant.
- Nodes in a Burla cluster are single-tenant.
- Burla is able to start executing user-submitted code quickly (< 1 sec) because every possible container-environment that a user may want to run code inside is kept running at all times.
  - In the default ("standby") state, one instance of every possible container is kept running per-CPU.
    This means if there are 100 possible containers and every node has 96 CPUs, each node will have 9600 containers running at all times, each bound to their own unique port.
- When a request comes in, work is routed to the correct containers where it starts running, then all unnecessary containers are quickly killed and restarted after the request has completed.

### What happens _before_ a call to `remote_parallel_map`:

Somebody somewhere started a Burla cluster:

- This could have been us starting our fully managed cluster.
- Or it could be someone else self-hosting Burla.

Either way the process is the same, here's how a cluster is started:

#### 1. Define the "standby" cluster-state

"Standby" refers to the state of the cluster when it is waiting for incoming requests.  
More specifically it refers to a set of nodes that should be left doing nothing (on standby).

If a request comes in, it will be handled first by these nodes, then by new additional nodes if necessary. This is one reason Burla is able begin executing user-submitted code quickly.

The "standby" state is defined in some location the [main_service](https://github.com/burla-cloud/main_service) is aware of (currently a specific document in the cluster's google cloud firestore database).

This definition specifies things like:

- How many nodes should be left waiting for requests?
- What kind of nodes? (num cpus? gpus? disk/networking/other config?).
- What docker containers should be left running on each node?

Container definitions are comprised of: a docker image URI, and a python version / entrypoint command.  
Two types of containers that can be defined:

1. **Default containers** (where code runs if the `dockerfile` arg is not passed to `remote_parallel_map`)  
   These work with any python virtual-environment, venv's can be quickly swapped per-request.
2. **Custom containers** (user-submitted containers)  
   These work only with virtual-environments already baked into the container (currently).

Standby definitions are optional.  
If a [main_service](https://github.com/burla-cloud/main_service) instance receives a request (someone called `remote_parallel_map`) and no standby definition is set, it will simply start VM's as needed to complete the request. Requests like this will take a few minutes to begin instead of ~1 second since vm's need to be cold-booted.

#### 2. Entering "standby" (starting nodes)

Once "standby" is defined, the [main_service](https://github.com/burla-cloud/main_service) must be instructed to enter this state.  
(currently through a POST request to `/restart_cluster`)

When called, virtual machines are started as needed to match the definition.  
This is what happens when a node is started:

1. An instance of the [node_service](https://github.com/burla-cloud/node_service) is downloaded and started on the vm.
2. The [node_service](https://github.com/burla-cloud/node_service) reads the "standby" definition to figure out what containers it needs to start.
3. The node service starts one instance of every specified container **per CPU**.  
   In typical deployments this is frequently thousands of containers per node. For example, assume we have 96CPUs, 100 custom containers, and 5 default containers (one per python-version), this would be 96 \* 105 = 10,080 containers per node, all running a webservice bound to a unique port.  
   The reason we run one per CPU is so we can quickly modify the number of CPU's available to each container by killing certain ones when a request is received.

The [node_service](https://github.com/burla-cloud/node_service) is responsible for (in addition to other things) starting containers on open ports.  
Every container, even user-submitted ones, already have an instance of the [container_service](https://github.com/burla-cloud/container_service) installed inside them (detailed later).

### What happens _during_ a call to `remote_parallel_map`:

#### 1. The [main_service](https://github.com/burla-cloud/main_service) receives a request:

From some client (python-package) to execute some function, across some array of inputs, using some specific hardware resources.

#### 2. The client (the python package) uploads inputs & the function, directly to GCS.

#### 3. Additional nodes are started:

The [main_service](https://github.com/burla-cloud/main_service) calculates, of the currently running nodes, which are compatible with with the current request? Any additional nodes necessary to reach the specified level of parallelism are started immediately. In addition, more nodes are started such that, the cluster has the same number-of/type-of nodes sitting on standby as it did before the request came in. This is to ensure that, if a new request comes in while the current one is being processed, new nodes will be ready and unoccupied so the new request can be executed quickly.

Here is a breif example:

- Standby definition requests 5, 96-CPU nodes be running at all times.
- Cluster currently is in standby: 5, 96-CPU nodes are on and ready.
- Request is received to execute some function on 1000 inputs in parallel.
  - 5 \* 96 = 480 cpus -> 1000 - 480 = 520 more cpus needed -> ceil(520 / 96) = 6
  - 6 more 96 cpu vm's needed to execute the function with a parallelism of 1000.
  - +5 more 96-CPU nodes need to be started "to maintain standby": 6 + 5 = 11.
- [main_service](https://github.com/burla-cloud/main_service) will begin executing the function on 480 CPUS.
- [main_service](https://github.com/burla-cloud/main_service) will start 11 new nodes in the background.
- The first 6 new nodes that are ready will be assigned to this job.

#### 4. Python or Docker environments are constructed/replicated if necessary.

- If a custom docker-container was specified:  
   The [container_service](https://github.com/burla-cloud/container_service) is installed inside it, the container is added to the standby definition, and then the container is downloaded and started on all nodes in the cluster.  
   This container-setup process only happens the first time Burla sees a new container. Afterwards, requests begin executing within 1-second once again.

- If a new python environment is detected:  
   (and a custom docker-container was **not** specified)  
   All never-before-seen python-package/versions are installed in the default container, in parallel, inside a separate backend service. Once installed, any installed/compiled package/versions are uploaded to GCS.

At this point:

- Any custom-submitted containers are currently running on every Node, waiting for requests.
- Any python package/version a user may need is sitting (in it's compiled, default-container compatible state) inside GCS.

#### 5. The [main service](https://github.com/burla-cloud/main_service) forewards the request to the appropriate nodes.

Effectively: A single request is sent to the node service of every node we wish to assign to this job. Nodes are single tenant, so once they receive this request, they cannot work on any other job until this one is done.

#### 6. [Node services](https://github.com/burla-cloud/node_service), once receiving a request:

1.  Mount python environments if necessary:  
    Any installed python-packages are quickly network-linked using [GCS FUSE](https://github.com/GoogleCloudPlatform/gcsfuse) to a directory in the node's filesystem. Then this directory is then mounted into relevant containers as a volume.
2.  Foreward requests to correct containers:
    A request is sent to every relevant [container_service](https://github.com/burla-cloud/container_service) telling it to start work on a specific job.
3.  Kill unnecessary containers.  
    All containers that are not required are killed. This is how Burla is able to quickly satisfy requests to execute functions with custom resource requirements. For example if a user requests 32CPUs per function and nodes are 96-CPU machines, 93/96 containers are killed.

#### 7. [Container services](https://github.com/burla-cloud/container_service), once receiving a request:

Download the function from GCS, and begin popping inputs from the queue to run through the function.  
 Anything sent to stdout is sent to the firestore database where the [main_service](https://github.com/burla-cloud/main_service) grabs it and sends it to the client.  
 Any errors thrown are also sent to the main service which forewards them to the client.

### What happens _after_ a call to `remote_parallel_map`:

Once the queue of inputs (being processed by indivual [container services](https://github.com/burla-cloud/container_service)) has emptied, the [main_service](https://github.com/burla-cloud/main_service) simply kills all nodes that were assigned to that job.  
Because the [main_service](https://github.com/burla-cloud/main_service) has been maintaining the set of nodes that should be on standby there should already be new nodes running, ready to replace the ones that will be killed.