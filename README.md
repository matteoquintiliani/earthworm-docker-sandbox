# Earthworm Docker Sandbox

A Docker tool for learning, testing and running Earthworm System within enclosed environments.

## Earthworm System

Earthworm is the most widely used seismic data acquisition and automatic earthquake processing software for regional seismic networks. Operates on Linux, Solaris, Mac OS X, and Windows.

Earthworm documentation: [http://www.earthwormcentral.org](http://www.earthwormcentral.org)

Earthworm developer web pages hosted by ISTI: [http://earthworm.isti.com/trac/earthworm/](http://earthworm.isti.com/trac/earthworm/)

## Dependencies

  - Docker
  - GNU Make
  - bash
  - sed
  - grep
  - find
  - wget

This tool works on all Unix-like operating system. It has not been tested on Windows yet. Any feedback will be very appreciated.

## Help

Very short help:

```
 Syntax: make  [ EW_ENV=<ew_env_subdir_name> ]  <command>

 Current main variable values:
     EW_ENV=ew_default
     EW_ENV_MAINDIR=~/ew_envs
     EW_ENV_DIR=~/ew_envs/ew_default

 Earthworm Environment:
     - name is defined by EW_ENV
     - directory is in EW_ENV_MAINDIR with name EW_ENV
     - directory path is EW_ENV_DIR
```

Detailed help information running:

```sh
make help
```



## Configuration

All configuration variables can be set within the file `Makefile.env` or passed as argument at run-time to command `make`.

It is convenient to set all the variables, except for `EW_ENV`, within the `Makefile.env` file.

Usually, the variabile `EW_ENV` is passed as an argument to the command `make`. Example:

```sh
Syntax: make  EW_ENV=ew_default  <command>
```

The variables passed as arguments override the values defined in the `Makefile.env` file.

## Build Docker Image

Default:

```sh
make build
```

### Compile Earthworm modules

Default settings compile all Earthworm modules from last revision in the main Subversion directory from `svn://svn.isti.com/earthworm/trunk`.

You can choose to compile only specific modules by setting variable `ARG_SELECTED_MODULE_LIST` in `Makefile.env`. Example:

```sh
ARG_SELECTED_MODULE_LIST=" \
reporting/statmgr \
reporting/diskmgr \
reporting/copystatus \
...
...
...
seismic_processing/pick_ew \
seismic_processing/pick_FP \
seismic_processing/binder_ew \
"
```

**N.B.** In any case, `libsrc` and all modules in `system_control` and `diagnostic_tools` will be compiled.

Moreover, you can also choose to compile a particolar Subversion directory or revision. Example:

```sh
# You can set custom main directories (e.g. 'tags/ew_7.10_release', 'branches/cosmos', etc.)
EW_SVN_BRANCH = trunk
# EW_SVN_BRANCH = tags/ew_7.10_release

# Set optional Earthworm Revision. If it is empty that stands for last revision of the EW_SVN_BRANCH
# You can set custom subversion revision 'NNN' where NNN is the revision number
EW_SVN_REVISION =
# EW_SVN_REVISION = 8104
```

## Creating Earthworm Environments


An **Earthworm Environment** is a directory that must contain the following subdirectories:

  - `params`: contains Earthworm configuration files (`EW_PARAMS` variable)
  - `log`: where Earthworm log files are written (`EW_LOG` variable)
  - `data`: where additional files are read and written by Earthworm modules (`EW_DATA_DIR` variable)

This directory structure is the same used in Earthworm Memphis Test bundled zip file available at [http://www.isti2.com/ew/distribution/memphis_test.zip](http://www.isti2.com/ew/distribution/memphis_test.zip).

You can list all available Earthworm Environments on your machine by:

```sh
make ew_env_list
```

It depends on variable `EW_ENV_MAINDIR` which must be set with the path of the main directory containing all Earthworm Environment directories. Default is the directory `ew_envs` in the home user directory (`EW_ENV_MAINDIR=~/ew_envs`).

You can create Earthworm Environments on your own by creating and managing file within subdirectories `params`, `log` and `params`. Morevoer, you can create as many Earthworm Environments as you want starting from the same zip file or git repository.

Remember, if the subdirectories `params`, `log` and `data` do not exist then you can not be able to run the Earthworm Environment. If they reside in different paths, you can optionally map by symbolic links the Earthworm Environment subdirectories by variable `MAP_EW_ENV_SUBDIRS`. If they do not exist, you can even create subdirectories as needed declaring the paths within variable `CREATE_EW_ENV_SUBDIRS`.

Example for zip file:

```sh
make create_ew_env_from_zip_url \
     ZIP_URL=http://www.isti2.com/ew/distribution/memphis_test.zip \
     MAP_EW_ENV_SUBDIRS="memphis/params memphis/log memphis/data" \
     EW_ENV=my_test_env
```

Example for git repository:

```sh
make create_ew_env_from_git_repository \
     GIT_REP=git@gitlab.rm.ingv.it:earthworm/run_configs.git \
     GIT_BRANCH=develop \
     CREATE_EW_ENV_SUBDIRS="log data" \
     MAP_EW_ENV_SUBDIRS="run_realtime/params log data" \
     EW_ENV=my_test_env
```

Variable `GIT_BRANCH` is optional.

Changing value for `EW_ENV` you can create 

## Running Earthworm Environments

Main `make` commands for running and/or stopping Earthworm Envinronments within a docker container are:

  - `bash`:   run bash shell in a new docker container
  - `screen`: run screen shell in a new docker container
  - `start`:  run new docker container as daemon
  - `stop`:   stop the running docker container [daemon]

Command example for running bash within the `myew_envs` Earthworm Environment:

```sh
make EW_ENV=myew_envs bash
```

Default setting allows you to run a single docker container for each Earthworm Environments. It depends on variable `DOCKER_CONTAINER_NAME`: 

```sh
DOCKER_CONTAINER_NAME ?= ew-sandbox-$(DOCKER_IMAGE_VERSION)-$(EW_ENV)
```

Main `make` commands for executing processes within running Earthworm Environment docker containers:


  - `exec`:       run bash shell in the running docker container
  - `ps`:         output 'docker ps' of running docker container
  - `sniffrings`: sniffrings all rings except message TYPE_TRACEBUF and TYPE_TRACEBUF2
  - `logtail`:    exec tail and follow log files in EW_LOG directory (/opt/earthworm/log)

Command example for executing a `bash` shell within the `myew_envs` Earthworm Environment:

```sh
make EW_ENV=myew_envs exec
```


## Author

Matteo Quintiliani - Istituto Nazionale di Geofisica e Vulcanologia - Italy

Mail bug reports and suggestions to *matteo.quintiliani [at] ingv.it*

