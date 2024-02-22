---
slug: /
sidebar_position: 1
hide_title: True
---

<br></br>

<img src="/img/logo_new.png" alt="burla_logo" title="Burla" width="20%" height="auto" />

#### Burla is a python package that makes it easy to run code on (lots of) other computers.

In Burla, <ins>there is only one function</ins>: `remote_parallel_map`.  
This function requires just two arguments, here's how it works:

```python
from burla import remote_parallel_map

# Arg 1: Any python function:
def my_function(my_input):
    ...

# Arg 2: List of inputs for `my_function`
my_inputs = [1, 2, 3, ...]

# Calls `my_function` on every input in `my_inputs`, in parallel, each on a separate computer in the cloud.
remote_parallel_map(my_function, my_inputs)
```

- Burla is **fast** and **scalable**.  
  Code starts running within <u>1 second</u>, on up to <u>1000 CPU's</u>.
- Burla is **free and open source software**.  
  We offer managed service to help pay for development.
- Burla is **easy to install**.  
  Setup in your cloud with one command, try our managed service with two commands.
- Burla **supports GPU's**.  
  Just add one argument: `remote_parallel_map(my_function, my_inputs, gpu="A100")`
- Burla supports **custom Docker images**.  
  Just add one argument: `remote_parallel_map(my_function, my_inputs, dockerfile="./Dockerfile")`  
  Containers are cached to keep latency below 1 second.
- Burla will **automatically clone your python env**.  
  Local python environments are quickly cloned on remote machines.  
  Python environments are cached to keep latency below 1 second.
- Developing code remotely with Burla **feels like local development**.  
  Errors on raised on remote computers are re-raised locally.  
  stdout/stderr is streamed back to your local machine in real-time.
- Burla offers **simple network storage**.  
  Remote machines are attached to the same fast, persistent, network disk.  
  Manage files in your disk through a simple CLI: `> burla nas upload / download / ls / rm ...`

**Burla is currently under devlopment and is not ready to be used.**  
To join our mailing list go to [burla.dev](https://burla.dev/).  
If you have any questions, email me at: jake@burla.dev
