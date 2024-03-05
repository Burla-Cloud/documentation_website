---
sidebar_position: 2
hide_title: True
---

<br></br>

#### Burla is currently under devlopment and is not ready to be used.

To join our mailing list go to [burla.dev](https://burla.dev/).  
If you have any questions, email me at: jake@burla.dev, or [join us on Discord](https://discord.gg/xSuJukdS9b).

## Getting Started

Burla has two deployment options:

1. [Fully-Managed](#getting-started-fully-managed)

   - Your code runs on Burla's webservers in Burla's cloud.

2. [Self-Managed](#getting-started-self-managed)

   - Your code runs on your webservers in your cloud, (currently GCP-only).

Once setup on one of the above two options, [try running our quickstart](#quickstart)!

### Getting Started: Fully-Managed

To install Burla on your machine run:

1. `pip install burla`
2. `burla login`

The `burla login` command will open a google login window in your browser.  
If your popup protection is good, you may need to enter the url printed in the terminal in your browser.

Once logged in, you'll officially have a Burla account, and can jump strait to the [quickstart](#quickstart).

### Getting Started: Self-Managed (GCP-only)

Unfortunately, Burla is currently deployable only in Google-Cloud.  
We're working hard to make Burla available on other cloud providers, to see our roadmap, check out our [Discord](https://discord.gg/xSuJukdS9b).

#### First, ensure you're authenticated with google cloud.

Burla expects users to be logged in using [Application-Default-Credentials](https://cloud.google.com/docs/authentication/provide-credentials-adc).  
After installing google cloud's CLI, this only takes one command:

1. [Install the gcloud CLI.](https://cloud.google.com/sdk/docs/install)
2. Authorize your machine: `gcloud application-default login`

#### Once setup on GCP, deploy Burla.

To deploy the Burla webservice and associated infastructure in your google cloud project run:

1. `pip install burla`
2. `burla login`
3. `burla deploy gcp`

This will create the following resources in your google cloud project:

- A Firestore database instance.
- An webservice running in Google Cloud Run.
- A Cloud Storage Bucket.
- An Artifact Registry repository.

All resources are by default accessible only from inside your google cloud project.  
For the `deploy` command to work, your user account will need permissions to access following services:

- Compute Engine: `Compute Admin`
- Firestore: `Cloud Datastore User`
- Cloud Storage: `Storage Admin`
- Artifact Registry: `Artifact Registry Administrator`
- Cloud Run: `Cloud Run Admin`
- Cloud Logging: `logging.logEntries.create`

### Quickstart

Here's a quick tutorial to get started with Burla:

1. If you haven't yet, in your terminal, run `pip install burla`, then run `burla login`.  
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

To learn more about `remote_parallel_map` see our [overview](https://docs.burla.dev) or [API reference](https://docs.burla.dev/API-Reference).

---

Any questions?  
[Schedule a call with us](https://cal.com/jakez/burla/), or [email us](mailto:jake@burla.dev). We're always happy to talk.
