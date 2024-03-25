---
sidebar_position: 3
hide_title: True
---

<br></br>

## `burla.remote_parallel_map`

Run an arbitrary python function on many computers at the same time.

```python
remote_parallel_map(
  function_,
  inputs,
  parallelism=-1,
  func_cpu=1,
  func_ram=1,
  func_gpu=None,
  verbose=False,
  dockerfile=None,
  packages=None,
  api_key=None,
)
```

Run provided `function_` on each item in `inputs` at the same time, in the cloud, each on a separate CPU, up to 4000 CPUs. If more than 4000 inputs are provided, inputs are queued and processed sequentially on each worker.

By default, the local python environment is cloned on all remote machines. To prevent this pass <code>packages=[]</code>.

<table>
    <tbody>
        <tr>
            <th colspan="2" style={{ textAlign: 'left' }}><strong>Parameters</strong></th>
        </tr>
        <tr>
            <td><strong>Name</strong></td>
            <td><strong>Description</strong></td>
        </tr>
        <tr>
            <td style={{ verticalAlign: 'top' }}><code>function_</code></td>
            <td>
                <p><code>Callable</code></p>
                <p>Python function. Must have single input argument, eg: <code>function_(inputs[0])</code> does not raise an exception.</p>
            </td>
        </tr>
        <tr>
            <td style={{ verticalAlign: 'top' }}><code>inputs</code></td>
            <td>
                <p><code>Iterable[Any]</code></p>
                <p>Iterable of elements passable to <code>function_</code>.</p>
            </td>
        </tr>
        <tr>
            <td style={{ verticalAlign: 'top' }}><code>parallelism</code></td>
            <td>
                <p><code>int</code></p>
                <p>(Optional) Target number of <code>function_</code> instances running in parallel. Set to <code>-1</code> for maximum: <code>min(4000, len(inputs))</code>.</p>
            </td>
        </tr>
        <tr>
            <td style={{ verticalAlign: 'top' }}><code>func_cpu</code></td>
            <td>
                <p><code>int</code></p>
                <p>(Optional) Number of CPU's available to every instance of <code>function_</code>. The maximum possible value is <code>96</code>.</p>
            </td>
        </tr>
        <tr>
            <td style={{ verticalAlign: 'top' }}><code>func_ram</code></td>
            <td>
                <p><code>int</code></p>
                <p>(Optional) Amount of RAM (GB) available to every instance of <code>function_</code>. The maximum possible value is <code>360</code>.</p>
            </td>
        </tr>
        <tr>
            <td style={{ verticalAlign: 'top' }}><code>func_gpu</code></td>
            <td>
                <p><code>Literal["A100"]</code></p>
                <p>(Optional) GPU available to every instance of <code>function_</code>. If <code>func_gpu</code> is not <code>None</code> maximum <code>parallelism</code> is reduced to <code>100</code>.</p>
            </td>
        </tr>
        <tr>
            <td style={{ verticalAlign: 'top' }}><code>verbose</code></td>
            <td>
                <p><code>bool</code></p>
                <p>(Optional) Set to <code>False</code> to prevent status indicator from being displayed.</p>
            </td>
        </tr>
        <tr>
            <td style={{ verticalAlign: 'top' }}><code>dockerfile</code></td>
            <td>
                <p><code>Union[str, pathlib.Path]</code></p>
                <p>(Optional) Path to dockerfile. If present, and never seen before, a docker image is built, and all instances of <code>function_</code> are run in this image. If present, and seen before, the previously built image is used to maintain low latency. If <code>None</code>, Burla reverts to default behaivior, which is to clone the local python environment on all remote machines.</p>
            </td>
        </tr>
        <tr>
            <td style={{ verticalAlign: 'top' }}><code>packages</code></td>
            <td>
                <p><code>Iterable[str]</code></p>
                <p>(Optional) Iterable containing names of pipy packages to install in environments where <code>function_</code> is run. This argument will override the default behaivior, which is to clone the local python environment on all remote machines.</p>
            </td>
        </tr>
        <tr>
            <td style={{ verticalAlign: 'top' }}><code>api_key</code></td>
            <td>
                <p><code>str</code></p>
                <p>(Optional) API key, for use in deployment environments where <code>burla login</code> cannot be run.</p>
            </td>
        </tr>
    </tbody>
</table>

<table>
    <tbody>
        <tr>
            <th colspan="2" style={{ textAlign: 'left' }}><strong>Returns</strong></th>
        </tr>
        <tr>
            <td><strong>Type</strong></td>
            <td><strong>Description</strong></td>
        </tr>
        <tr>
            <td style={{ verticalAlign: 'top' }}><code>List</code></td>
            <td>
                <p>List of objects returned by <code>function_</code>. This list is not ordered.</p>
            </td>
        </tr>
    </tbody>
</table>

---

Questions?  
[Schedule a call with us](https://cal.com/jakez/burla/), or [email us](mailto:jake@burla.dev). We're always happy to talk.
