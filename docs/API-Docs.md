---
sidebar_position: 2
hide_title: True
---

<br></br>

# API Reference

Burla is a python package with only one function (really!). Here is the API-Documentation for this function:

---

## burla.remote_parallel_map

**burla.remote_parallel_map(function_, inputs, parallelism=-1, func_cpu=1, func_ram=1, func_gpu=0, verbose=True, image=None)**

Runs provided `function_` on each item in `inputs` at the same time, in the cloud, each on a separate CPU, up to 4000 CPUs. If more than 4000 inputs are provided, inputs are queued and processed progressively. When run, expect this function to be in the _preparing_ state for at least 3 minutes.

### Parameters:

- **function_ : Callable**
  - Python function. Must have single input argument, eg: `function_(inputs[0])` does not raise an exception.
  - Input & return value data types cannot be any of: _frame_ (not DataFrame those are ok!), _generator_, _traceback_.

- **inputs : List**
  - List containing elements passable to `function_`.
  - Element data types can be anything except: _frame_ (not DataFrame those are ok!), _generator_, _traceback_.

- **parallelism : Int, default: -1**
  - Number of calls to `function_` running in parallel.
  - Set to -1 for maximum (4000 or len(inputs), whichever is greater).

- **func_cpu : Int, default: 1**
  - CPU allocated for every individual call to `function_`, max 96.

- **func_ram : Int, default: 1**
  - RAM allocated for every individual call to `function_`, max 624.

- **func_gpu : Int, default: 0**
  - GPUs (Nvidia Tesla-T4s) allocated for every individual call to `function_`, max 4.

- **verbose : bool, default: True**
  - Optional, verbosity, if False status indicator is not displayed.

- **image : Optional[str], default: None**
  - Optional, URI of a publicly accessible docker image. If None, Burla will attempt to copy and install the local environment on all remote machines.

- **packages : Optional[List[str]], default: None**
  - Optional, list of pip packages to install on machines where `function_` will run, If this is used packages will not be automatically detected and installed.

- **api_key : Optional[str], default: None**
  - Optional, api_key, for use in situations where `burla` is deployed inside backend services, please email jake@burla.dev to have an api-key issued.

### Returns:
- **List** :
  - Outputs returned by `function_` for every input in `inputs`, ordering of this list will not match the order of `inputs`.
  
  

---

We know you may have additional questions about how `remote_parallel_map` works and we're working hard to add content that may answer these questions.  
For now the best we can do is recommend you [schedule a call with us](https://cal.com/jakez/burla/), or [shoot us an email](mailto:jake@burla.dev)! We're always happy to talk.
