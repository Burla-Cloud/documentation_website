---
sidebar_position: 4
hide_title: True
---

<br></br>

# Example: Massively Parallel Inference with Mistral-7B


This is a quick tutorial showing how to perform parallel inference with Mistral-7B on a cluster with hundreds of GPUs (Nvidia Tesla-T4's).  
This tutorial can be adapted to use any LLM from HuggingFace.  
This tutorial is also available as a [Google CoLab notebook](https://colab.research.google.com/drive/1I7t5QeNQT0RACJ_FcitWdYTvtGbmBj_3?usp=sharing).

### 1. Install the latest version of Burla from PyPI.

Burla is an extremely simple to use cluster compute tool.  
In this tutorial we'll use it to create a cluster with around ~200 GPU's.  
Currently the limit-per-cluster is 300 GPUs but this can be increased if you email jake@burla.dev!  
Here's how you install Burla:

```bash
pip install burla
```

### 2. Register/Login with Burla, so you're authorized to create & manage compute clusters.

This command will launch a new window where you can quickly create a Burla account by logging in with Google.  
Be sure to click the link this command prints in case your popup blocker blocks this!  

Once you've created an account, you'll be allowed to quickly provision compute clusters with Burla!  
(Don't worry about the cost, Burla offers 1000 free GPU-hours to all new accounts)

```bash
burla login
```

### 3. Download an LLM from HuggingFace.

This command will download Mistral-7B-OpenOrca from HuggingFace into a local file.  
This LLM is around 4GB in size.

```bash
curl -L -O https://huggingface.co/TheBloke/Mistral-7B-OpenOrca-GGUF/resolve/main/mistral-7b-openorca.Q4_K_M.gguf
```

### 4. Upload your LLM into a network attached disk inside Burla's cloud.

This command will automatically create a network attached disk inside your Burla account if you do not have one.  
Network storage is free throughout the free trial period.

After creating a network attached disk, any files/folders in the disk will automatically appear in the `/workspace` directory of every node in any cluster you create using Burla.  

Expect this command to take a few minutes to upload your LLM.

```bash
burla nas upload mistral-7b-openorca.Q4_K_M.gguf
```

Once uploaded, you should be able to see your LLM in the root directory of your network disk:

```bash
burla nas ls
```
Should display something like:
```
jake@burla.dev / % 
mistral-7b-openorca.Q4_K_M.gguf
```

### 5. Download some questions to ask the LLM.

The following bash command will download a csv file from github containing 200 generic questions about different topics. 

```bash
curl -O https://gist.githubusercontent.com/JacobZuliani/dbbd91a671afca7e8221b0362c02ed68/raw/ec92aef2267ad2d52d686eb2970592de31bd1ac6/LLM_Questions.csv
```

Load the csv file of questions into a list.

```python
import pandas as pd 
questions = pd.read_csv("LLM_Questions.csv")["Questions"].tolist()
```

### 6. Write some code to make a prediction.

#### First define a function that formats a question into a prompt using Chat Markup Languange ([ChatML](https://github.com/openai/openai-python/blob/main/chatml.md)).
Mistral-7B expects all prompts to be formatted in ChatML.

```python
def question_to_prompt(question):
    """Format question into a prompt using Chat Markup Languange (ChatML)"""
    return (
        "<|im_start|>system\n"
        "You are MistralOrca, a large language model trained by Alignment Lab AI. "
        "Write out your reasoning step-by-step, "
        "be as concise as possible, "
        "and be sure to be sure you get the right answers!\n"
        "<|im_end|>\n"
        "<|im_start|>user\n"
        "How are you?<|im_end|>\n"
        "<|im_start|>assistant\n"
        "I am doing well!<|im_end|>\n"
        "<|im_start|>user\n"
        f"{question}<|im_end|>\n"
        "<|im_start|>assistant"
    )
```

#### Second define a function that answers a question using Mistral-7B
- This functions expects a GPU to be available (`gpu_layers=50`).  
- We import `ctransformers` inside the function in case your local machine does not have this package installed.  
(since this will run on a remote cluster that does have it installed)
- We return both the question and answer in the same object to keep them together since the order of results will not match the order of the inputs after they are processed by the cluster.
- The default python working directory in the cluster is `/workspace`, this is the same directory the LLM was uploaded to. This means the file can be referenced by simply using it's filename as the path.
```python
def answer_question(question):
    from ctransformers import AutoModelForCausalLM

    llm = AutoModelForCausalLM.from_pretrained(
        model_path_or_repo_id="mistral-7b-openorca.Q4_K_M.gguf",
        gpu_layers=50,
        max_new_tokens=512,
        stop=["<|im_end|>"]
    )
    return {"question": question, "answer": llm(question_to_prompt(question))}
```

### 7. Call `answer_question`, on every item in `questions`, in parallel using a cluster with ~200 GPUs.

Every call to `answer_question` will run on it's own separate virtual machine.  
Below we pass `func_gpu=1` so that each virtual machine has one GPU.  
We also pass `func_ram=8`, if < 8G of ram is allocated to a single function call, this function will run out of memory.

By default any python packages installed locally will be installed in every VM in the cluster. However, because your local machine might not have the GPU version of `ctransformers` installed (unless your machine has a GPU) we manually specify that `packages=["ctransformers[cuda]"]` to ensure all remote machines have the GPU version of `ctransformers`, since this might be different from the version on your local machine.

```python
from burla import remote_parallel_map

questions_to_answers = remote_parallel_map(
    function_=answer_question,
    inputs=questions,
    func_gpu=1,
    func_ram=8,
    packages=["ctransformers[cuda]"],
)
```

`questions_to_answers` will be a list containing ~200 dictionaries.  
We can view an answer from our LLM like this:

```python
question_0 = questions_to_answers[0]["question"]
answer_0 = questions_to_answers[0]["answer"]
print(f"Question:\n{question_0}\n\nAnswer:\n{answer_0}")
```

Which prints:

```
Question:
Implement a Python function to compute the Fibonacci numbers.

Answer:

 Here is an example implementation of the Fibonacci function in Python:

```python
def fibonacci(n):
    if n <= 1:
        return n
    
    return fibonacci(n-1) + fibonacci(n-2)
```

This function computes the nth Fibonacci number, and can be used with the following input arguments: `fibonacci(0), fibonacci(1), ...`, as an example. The function returns the corresponding Fibonacci number for each input argument.
```