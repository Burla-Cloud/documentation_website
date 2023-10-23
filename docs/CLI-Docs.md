---
sidebar_position: 3
hide_title: True
---
<br></br>

# CLI Reference

Burla comes with a CLI that makes it possible to authenticate and manage data stored in a persistent network disk.  
Here is the documentation:

---

## > burla

### Name
**burla** - authenticate & manage files in network storage

### Synopsis
`burla` GROUP | COMMAND

### Description
The **burla** CLI provides authentication (the `login` command), and the ability to manage files in network attached storage (the `nas` command group).

### Global Flags
`--help, -h`  
Print documentation for current command group and exit.

### Groups
GROUP is one of the following:
- **nas**

### Commands
COMMAND is one of the following:
- ### login  

  Authorize the current machine to call `remote_parallel_map`.  
  Launches Google OAuth2 login flow. Creates **burla** user account if one does not exist.

---

## > burla nas

### Name
**burla nas** - Manage files in a network disk attached to all machines created with `remote_parallel_map`.

### Synopsis
`burla nas` COMMAND [burla_wide_command...]

### Description
The **burla nas** command group allows users to upload/download/manage files stored in a network disk that is always attached to all machines created with `remote_parallel_map`. This disk is always mounted at `/workspace` (the python executable's working directory) in every call to `remote_parallel_map`.

### Commands
COMMAND is one of the following:

- ### upload [local_file_or_folder] [remote_folder] [--recurse]  

  Uploads `local_file_or_folder` to `remote_folder`.  
  If `remote_folder` is not specified, current remote working directory is used instead.  
  If local folder is being uploaded `--recurse` flag must be used.  

  **POSITIONAL ARGUMENTS**  
  [local_file_or_folder]  
  - Local path to a file or folder.  

  [remote_folder]  
  - Path inside network disk to upload `local_file_or_folder` to.  
    Defaults to current remote working directory (run `burla nas ls` to view).  

  **FLAGS**  
  [--recurse]  
  - Recursively upload all files contained in `local_file_or_folder`.

- ### download [remote_file_or_folder] [local_folder] [--recurse]  

  Downloads local `remote_file_or_folder` to `local_folder`.  
  If `local_folder` is not specified, current working directory is used instead.  
  If remote folder is being downloaded `--recurse` flag must be used.  

  **POSITIONAL ARGUMENTS**  
  [remote_file_or_folder]  
  - Path inside network disk pointing to file or folder.  
  [local_folder]  
  - Path to local folder inside which `remote_file_or_folder` will be downloaded.  
    Defaults to current working directory.  
  
  **FLAGS**  
  [--recurse]  
  - Recursively download all files contained in `remote_file_or_folder`.

- ### cd [remote_folder]  

  Navigates from current remote working directory to `remote_folder`.  
  Displays `<current_network_disk> <new_current_remote_working_directory>`  

  **POSITIONAL ARGUMENTS**  
  [remote_folder]
  - Path inside network disk pointing to folder

- ### ls  

  Displays `<current_network_disk> <current_remote_working_directory>`  
  Displays tab-separated list of all files/folders in current remote working directory.

---

We know you may have additional questions about how the network disk works and we're working hard to add content that may answer these questions.  
For now the best we can do is recommend you [schedule a call with us](https://cal.com/jakez/burla/), or [shoot us an email](mailto:jake@burla.dev)! We're always happy to talk.