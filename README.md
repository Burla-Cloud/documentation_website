## Documentation

This repo contains code for Burla's documentation website: [docs.burla.dev](https://docs.burla.dev)  
This website is built using [Docusaurus 2](https://docusaurus.io/).

### Local Development

```
$ make dev
```

This command starts a local development server and opens up a browser window.  
Most changes are reflected live without having to restart the server.

### Build

```
$ make image
```

This command generates static content, packages into a container, and uploads the container to Google Artifact Registry.

### Deployment

These commands deploy the most recently pushed container in Artifact Registry to Google Cloud Run.

```
$  make deploy-test
```

Will deploy the docs website to https://burla-docs-y66ufvpuua-uc.a.run.app

or:

```
$  make deploy-prod
```

Will deploy the docs website to https://docs.burla.dev
