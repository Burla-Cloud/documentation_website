---
sidebar_position: 3
hide_title: True
---

<br></br>

## `burla`

### Description

The Burla Command Line Interface serves two purposes:

1. Provide the ability to authenticate with Burla cloud: `burla login`
2. Provide the ability to manage files in Burla cloud: <code>burla nas &lt;command&gt; <strong>[</strong>options<strong>]</strong></code>

The global arg `--help` can be placed after any command or command group to see CLI documentation.

---

## `burla login`

#### Authenticate with Burla cloud.

### Description

Obtains access credentials for your user account via a web-based (OAuth2) authorization flow.  
When this command completes successfully, an auth-token is saved in the text file `burla_credentials.json`. This file is stored in your operating systems recommended user data directory which is determined using the [appdirs](https://github.com/ActiveState/appdirs) python package.

This auth-token is refreshed each time the `burla login` authorization flow is completed.

## `burla nas <command>`

#### Manage files stored in Burla cloud.

Commands:

- `burla nas upload`
- `burla nas download`
- `burla nas cd`
- `burla nas ls`
- `burla nas rm`

### Description

By default, the folder `nas` (network attached storage) appears in the python working directory of all computers executing a user submitted function.  
The filesystem in this folder is persistent and network-linked. This means:

- Any files written to it will appear in the `nas` folder of all other computers running as a part of that particular call to `remote_parallel_map`.
- After the call to `remote_parallel_map` is over the files will persist, and be accessable through this interface.
- Any files uploaded through this interface will appear in the `nas` folder for any subsequent `remote_parallel_map` calls.

### `burla nas upload`

Upload files to the persistent filesystem belonging to the current account.

`burla nas upload` [<code><i>SOURCE</i></code>] [<code><i>DESTINATION</i></code>] [`--recursive`]

##### POSITIONAL ARGUMENTS

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<code><i>SOURCE</i></code>]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Path to local file or folder to upload.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<code><i>DESTINATION</i></code>]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Remote filesystem path within which `source` will be uploaded.

##### FLAGS

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[`--recursive`]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Recursively copy the contents of any directories that match the source path expression.

### `burla nas download`

Download files from the persistent filesystem belonging to the current account.

`burla nas download` [<code><i>SOURCE</i></code>] [<code><i>DESTINATION</i></code>] [`--recursive`]

##### POSITIONAL ARGUMENTS

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<code><i>SOURCE</i></code>]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Path to file or folder in remote filesystem.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<code><i>DESTINATION</i></code>]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Local path within which `source` will be downloaded.

##### FLAGS

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[`--recursive`]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Recursively copy the contents of any directories that match the source path expression.

### `burla nas ls`

List files and folders inside provided `path`.

`burla nas ls` [<code><i>PATH</i></code>]

##### POSITIONAL ARGUMENTS

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<code><i>PATH</i></code>]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Path to list contents of.

### `burla nas rm`

Remove file or folder from remote filesystem.

`burla nas rm` [<code><i>PATH</i></code>] [`--recursive`]

##### POSITIONAL ARGUMENTS

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<code><i>PATH</i></code>]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Path to remote file or folder to remove.

##### FLAGS

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[`--recursive`]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Recursively remove the contents of any directories within provided <code><i>PATH</i></code>.

---

Questions?  
[Schedule a call with us](https://cal.com/jakez/burla/), or [email us](mailto:jake@burla.dev). We're always happy to talk.
