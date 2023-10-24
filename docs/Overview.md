---
slug: /
sidebar_position: 1
hide_title: True
---

<br></br>
<img src="/img/logo-2.png" width="200" height="100"/>

## Welcome to Burla

#### Burla is, incredibly simple, completely serverless, cluster compute software.

With Burla, anyone can scale python code over thousands of computers in the cloud, quickly create large GPU clusters, provision very large VMs, or attach high-speed network disks. All with zero setup, and just one function call.

#### Here's how it works:

Burla is a python package that only has one function: `remote_parallel_map`.  
`remote_parallel_map` only requires two arguments:

1. Any python function:

```python
def my_function(my_input):
  ...
```

2. A list of inputs:

```python
my_inputs = [1, 2, 3, ...]
```

Then `remote_parallel_map` can be called like:

```python
from burla import remote_parallel_map
remote_parallel_map(my_function, my_inputs)
```

When run, `remote_parallel_map` calls `my_function` on every input in `my_inputs`, at the same time, each on a separate computer in the cloud. Like this:

![servers](/img/rpm.png)

After each function has finished running, `remote_parallel_map` returns a list containing any values returned by the provided function for each function call. Like this:

```python
from burla import remote_parallel_map

def my_function(my_input):
    return my_input * 10

my_inputs = [1, 2, 3]

results = remote_parallel_map(my_function, my_inputs)
print(results)
```

Prints:

```python
[10, 20, 30]
```

## Try it out!

Burla is incredibly simple to get up and running, here's a quick tutorial: 

1. In your terminal run `pip install burla`, then run `burla login`.  
   `burla login` will create an account for you if you don't have one & authorize you to make calls to `remote_parallel_map`.

2. Run the example below!  
   This example calls a simple function on 1000 different inputs, at the same time, each on a separate computer.  
   Without Burla, this code could take up to 16 Hours to finish!

```python
from burla import remote_parallel_map
from time import sleep

my_inputs = list(range(1000))
​
def my_function(my_input):
    sleep(60) # <- Pretend this is some complex code!
    print(f"Processed Input #{my_input}")
​
remote_parallel_map(my_function, my_inputs)
```

This quickstart is also available as a [Google CoLab Notebook](https://colab.research.google.com/drive/107O6ftN73nMedp3vESHWRcxFmiM59SVl?usp=sharing) in case you run into any issues!

#### Read more about the features and limitations of `remote_parallel_map` [here](https://docs.burla.dev/API-Docs/).
