## Earthworm System

Earthworm is the most widely used seismic data acquisition and automatic earthquake processing software for regional seismic networks. Operates on Linux, Solaris, Mac OS X, and Windows.

Earthworm documentation: [http://www.earthwormcentral.org](http://www.earthwormcentral.org)

Earthworm developer web pages hosted by ISTI: [http://earthworm.isti.com/trac/earthworm/](http://earthworm.isti.com/trac/earthworm/)

## Dependencies

#### Operating systems

  - **Linux / Unix-like**: this tool is designed to work on all Unix-like operating systems and CPU architectures (*32-bit/64bit, i386, x386, amd386, arm, ...*) supported by the Earthworm version you want to use.
  - **Mac OS X**: this tool has been successfully tested on Mac OS X.
  - **Windows**: this tool has been  successfully tested on Widows by WSL (Windows Subsystem for Linux).

#### Required software

  - **Docker** - [https://www.docker.com/](https://www.docker.com/)
    - For Windows:
      - Install or upgrade your [WSL to the version 2](https://docs.microsoft.com/en-us/windows/wsl/wsl2-install).
      - Install the [docker for windows](https://docs.docker.com/docker-for-windows/).
      - Complete [these steps](https://docs.docker.com/docker-for-windows/wsl-tech-preview/) to complete the Docker WSL backend.
  - **GNU Make** - [https://www.gnu.org/software/make/](https://www.gnu.org/software/make/)
  - **GNU Bash**  [https://www.gnu.org/software/bash/](https://www.gnu.org/software/bash/)
  - **sed** - GNU version is available at [https://www.gnu.org/software/sed/](https://www.gnu.org/software/sed/)
  - **grep** - GNU version is available at [https://www.gnu.org/software/grep/](https://www.gnu.org/software/grep/)
  - **find** in *findutils* - GNU version is available at [https://www.gnu.org/software/findutils/](https://www.gnu.org/software/findutils/)
  - **tee** in *coreutils* - [https://www.gnu.org/software/coreutils/](https://www.gnu.org/software/coreutils/)
  - **wget** - [https://www.gnu.org/software/wget/](https://www.gnu.org/software/wget/)
  - **tar** - [https://www.gnu.org/software/tar/](https://www.gnu.org/software/tar/)
  - **unzip** - depends on your system
  - **git** - [https://git-scm.com/](https://git-scm.com/)

## Short Help

This tool is entirely based on `docker`, `make`, `bash` and other utilities like `sed`, `grep`, `find`, `wget`, etc.

Before using it, make sure you have properly installed all those packages specified in section "Required software".

For a quick start, a very short help is:

```sh
Syntax: make  [ EW_ENV=<ew_env_subdir_name> ]  <command>

Current main variable values:
    EW_ENV=ew_help
    EW_ENV_MAINDIR=~/ew_envs
    EW_ENV_DIR=~/ew_envs/ew_help

Earthworm Environment:
    - name is defined by EW_ENV
    - directory is in EW_ENV_MAINDIR with name EW_ENV
    - directory path is EW_ENV_DIR

An Earthworm Environment Directory must contain the following subdirectories:
    - params: contains Earthworm configuration files (EW_PARAMS variable)
    - log:    where Earthworm log files are written (EW_LOG variable)
    - data:   where additional files are read and written
              by Earthworm modules (EW_DATA_DIR variable)
```

More detailed help information is reported in section "Complete Help" which is the output of the following command:

```sh
make help
```

## Quick start and first test

Get ready to get your first Earthworm Environment running in a Docker container by this tool.

![ew_sandbox_quick_and_start_1](./images/ew_sandbox_quick_and_start_1.png)

  - Get Earthworm Docker Sandbox and change directory.

```sh
$ git clone https://github.com/matteoquintiliani/earthworm-docker-sandbox.git
$ cd earthworm-docker-sandbox
```

  - Check the availability of all necessary commands.

```sh
$ make check_required_commands
```

  - Build the default Earthworm Docker Sandbox image.

```sh
$ make [ EW_GIT_REF=... ] build
```

If all went well you can list the Earthworm Docker Sandbox image.

```sh
$ make list_images
```

```
docker images ew-sandbox
ew-sandbox   d561670a                                   3eb4215024b1   About a minute ago   881MB
ew-sandbox   v7.7                                       c38a0b5c94b6   5 minutes ago        812MB
ew-sandbox   v7.8                                       c3ffdda522f2   7 minutes ago        815MB
ew-sandbox   v7.9                                       d01d18de2ffe   8 minutes ago        823MB
ew-sandbox   v7.10                                      bacc3eb93754   10 minutes ago       869MB
ew-sandbox   master                                     296b153fb2c0   42 minutes ago       1.1GB
```

![ew_sandbox_quick_and_start_2](./images/ew_sandbox_quick_and_start_2.png)

  - Create if not exists the directory defined in `EW_ENV_MAINDIR`. In that directory will be stored and referenced all Earthworm Environments. Default directory is `~/ew_envs`.

```sh
$ mkdir ~/ew_envs
```
  - List available Earthworm Environments. First time the list should be empty.

```sh
$ make list_ew_env
```

To get familiar with this tool we will use the Memphis test configuration. It already contains the Earthworm configuration directory `params`, the log directory `log` and the directory for reading and writing `data`.

The Memphis test that we will use is available from two different sources:

  1. zip file in the URL [http://www.earthwormcentral.org/distribution/memphis_test.zip](http://www.earthwormcentral.org/distribution/memphis_test.zip)
  2. git repository available at [https://github.com/matteoquintiliani/memphis_test](https://github.com/matteoquintiliani/memphis_test)

  - Create your first Earthworm Environment from Memphis test available online in a zip file. By variable `MAP_EW_ENV_SUBDIRS` we create symbolic links in the main directory of the Earthworm Environment that we will call `memphis_test_zip`.

```sh
$ make create_ew_env_from_zip_url \
       ZIP_URL=http://www.earthwormcentral.org/distribution/memphis_test.zip \
       CREATE_EW_ENV_SUBDIRS="" \
       MAP_EW_ENV_SUBDIRS="memphis/params memphis/log memphis/data" \
       EW_ENV=memphis_test_zip
```

- List of the Earthworm Environments. You should now see `memphis_test_zip`.

```sh
$ make list_ew_env
```

```sh
Available Earthworm Environments:
  - memphis_test_zip
```

  - Create your second Earthworm Environment containing the Memphis test but in this case obtained by a git repository. For that we will give the name of `memphis_test_git`,

```sh
$ make create_ew_env_from_git_repository \
       GIT_REP=https://github.com/matteoquintiliani/earthworm-memphis-test.git \
       GIT_BRANCH=master \
       EW_ENV=memphis_test_git
```

  - List of the Earthworm Environments. You should now see `memphis_test_zip` and `memphis_test_git`.

```sh
$ make list_ew_env
```

```sh
Available Earthworm Environments:
  - memphis_test_zip
  - memphis_test_git
```

  - Check the Earthworm Environment within an Earthworm Docker Sandbox Container.

```sh
$ make EW_ENV=memphis_test_zip check_operation
```

![ew_sandbox_quick_and_start_3](./images/ew_sandbox_quick_and_start_3.png)

  - Run `startstop` in an interactive bash shell within the Earthworm Environment `memphis_test_zip` just created.

```sh
$ make EW_ENV=memphis_test_zip \
     EW_INSTALL_INSTALLATION=INST_MEMPHIS \
     ew_startstop_bash
```

You will see the interactive output from the Earthworm `startstop` process.

  - From a different terminal prompt of your host, list the running Earthworm Docker Sandbox Container.

```sh
$ make list_containers
docker ps -f name='ew-sandbox*'
```

a possible output:

```sh
CONTAINER ID   IMAGE               COMMAND                  CREATED              STATUS              PORTS     NAMES
82301f4b9733   ew-sandbox:master   "/bin/bash -i -c '. ~/.…"   17 seconds ago       Up 16 seconds                 ew-sandbox.master.isti_course_1
c8b3aa55f837   ew-sandbox:v7.10    "/bin/bash -i -c '. ~/.…"   About a minute ago   Up About a minute             ew-sandbox.v7.10.memphis_test_git
```

  - Launch a bash shell within the Earthworm Docker Sandbox Container previously started on the Earthworm Environment `memphis_test_zip`.

```sh
$ make EW_ENV=memphis_test_zip ew_exec_bash
```


The Earthworm Docker Sandbox Container shell prompt will be shown.

```sh
f74b689cb1ed:/opt/ew_env [ew:memphis_test_zip] $
```

From that shell prompt within the docker container,  you can now execute Earthworm commands (e.g. `status`, `sniffwave`, `sniffrings`, `pau`, etc.) and browse files.

## Configuration

All configuration variables can be set within the file `Makefile.env` or passed as argument at run-time to command `make`.

It is convenient to set all the variables, except for `EW_ENV` (or variables for creating the Earthworm Environments), within the file `Makefile.env` .

Usually, the variabile `EW_ENV` is passed as an argument to the command `make`. Example:

```sh
Syntax: make  EW_ENV=ew_default  <command>
```

The variables passed as arguments override the values defined in the `Makefile.env` file.

##### Check the availability of all necessary commands.

```sh
$ make check_required_commands
```

## Building Docker Image

Building the Earthworm Docker Sandbox images is based on:

1. Local files `Dockerfile`, `Makefile`  and `Makefile.env`
1. Online official Earthworm Git Repository `https://gitlab.com/seismic-software/earthworm.git`
1. Optional: online `ew2openapi` git repository [https://gitlab.rm.ingv.it/earthworm/ew2openapi/](https://gitlab.rm.ingv.it/earthworm/ew2openapi/)

- Build the image with current variables in `Makefile.env`:

```sh
$ make build
```

### Compiling specific Earthworm versions

Default settings get the latest Earthworm commit from the master branch `https://gitlab.com/seismic-software/earthworm.git` and compile all Earthworm sources.

Docker image building process is based on variables `EW_GIT_REP` and `EW_GIT_REF`.

`EW_GIT_REP` define the git repository url.

```sh
# Change Earthworm Git Repository
# EW_GIT_REP=https://gitlab.com/seismic-software/earthworm.git
```

`EW_GIT_REF` can define branch names, tags or commit SHA. Default is the 'master' branch.

```sh
# Set branch names, tags or commit SHA.
# If EW_GIT_REF is empty, then default is 'master'.
# EW_GIT_REF = master
```

Logs of Earthworm commits in 'master' branch are available from the following URL: [https://gitlab.com/seismic-software/earthworm/-/commits/master](https://gitlab.com/seismic-software/earthworm/-/commits/master)). You can also see other commits switching on different branches.

If you want to compile a different version of Earthworm than 'master' branch, then you can set variables `EW_GIT_REF` by command line, for example:

```sh
# different branch name
make EW_GIT_REF=branch_name build
```

or

```sh
# by tag name
make EW_GIT_REF=v7.10 build
```

or

```sh
# by commit SHA
make EW_GIT_REF=d561670a build
```

To obtain a list of possibile value of `EW_GIT_REF` based on git branch or tag names you can run the following command:

```sh
$ make ls-remote
```

A possible output:

```
22691e3	HEAD
5d5ec26	branch: 7-add-fileplayer-dump-option  url: https://gitlab.com/seismic-software/earthworm/-/tree/7-add-fileplayer-dump-option
5f2e445	branch: macos_build                   url: https://gitlab.com/seismic-software/earthworm/-/tree/macos_build
22691e3	branch: master                        url: https://gitlab.com/seismic-software/earthworm/-/tree/master
53be010	branch: mastersvn                     url: https://gitlab.com/seismic-software/earthworm/-/tree/mastersvn
16aeb95	tag   : v7.1                          url: https://gitlab.com/seismic-software/earthworm/-/tags/v7.1
206e1ec	tag   : v7.2                          url: https://gitlab.com/seismic-software/earthworm/-/tags/v7.2
24bfcee	tag   : v7.3                          url: https://gitlab.com/seismic-software/earthworm/-/tags/v7.3
69a41e5	tag   : v7.4                          url: https://gitlab.com/seismic-software/earthworm/-/tags/v7.4
23fc2d6	tag   : v7.5                          url: https://gitlab.com/seismic-software/earthworm/-/tags/v7.5
8ca81f8	tag   : v7.6                          url: https://gitlab.com/seismic-software/earthworm/-/tags/v7.6
f79f367	tag   : v7.7                          url: https://gitlab.com/seismic-software/earthworm/-/tags/v7.7
b6b4c77	tag   : v7.8                          url: https://gitlab.com/seismic-software/earthworm/-/tags/v7.8
7f5a12d	tag   : v7.9                          url: https://gitlab.com/seismic-software/earthworm/-/tags/v7.9
1eeff33	tag   : v7.10                         url: https://gitlab.com/seismic-software/earthworm/-/tags/v7.10
```

Caveat: you might need to change `Doxyfile` in order to fix properly the section where Earthworm is compiled and/or basing your build on a different and/or older docker linux image.

Using the current `Doxyfile` you should be able to successfully compile all Earthworm major versions. In particular, by the following command:

```sh
$ make build_all
```

you can create the docker images for the following Earthworm commits:

  - `EW_GIT_REF=d561670a` Git commit SHA *d561670a*, 64-bit version. (From *f2d20702* [*v7.10*\] to the last one, all consistent commits should be successfully compiled), 64-bit version.
  - `EW_GIT_REF=v7.10` (Git commit SHA *f2d20702* - 2019/08/21), 64-bit version.
  - `EW_GIT_REF=v7.9` (Git commit SHA *f657ae17* - 2016/10/31), 32-bit version.
  - `EW_GIT_REF=v7.8` (Git commit SHA *b6b4c774* - 2015/06/25), 32-bit version.
  - `EW_GIT_REF=v7.7` (Git commit SHA *f79f3675* - 2013/09/19), 32-bit version.

Caveat:  arm architecture is available only since Earthworm v7.10.


When you build an Earthworm Docker Sandbox image, default name is `ew-sandbox` and tag is built by the values of `EW_GIT_REF` variable.

List available Earthworm Docker Sandbox images.

```sh
$ make list_images
docker images ew-sandbox
```

An example of the output is:

```
REPOSITORY   TAG                                        IMAGE ID       CREATED              SIZE
ew-sandbox   d561670a                                   3eb4215024b1   About a minute ago   881MB
ew-sandbox   v7.7                                       c38a0b5c94b6   5 minutes ago        812MB
ew-sandbox   v7.8                                       c3ffdda522f2   7 minutes ago        815MB
ew-sandbox   v7.9                                       d01d18de2ffe   8 minutes ago        823MB
ew-sandbox   v7.10                                      bacc3eb93754   10 minutes ago       869MB
ew-sandbox   master                                     296b153fb2c0   42 minutes ago       1.1GB
```

### Compiling Earthworm modules

Default settings compile all Earthworm modules. You could optionally choose to compile only specific modules by setting variable `ARG_SELECTED_MODULE_LIST` in `Makefile.env`. Example:

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

Moreover, you can also enable compilation for additional modules `ew2moledb` and `ew2openapi` by the variables `ARG_ADDITIONAL_MODULE_EW2MOLEDB=yes` and `ARG_ADDITIONAL_MODULE_EW2OPENAPI=yes` respectively.

## Creating Earthworm Environments


An **Earthworm Environment** is a directory that must contain the following subdirectories:

  - `params`: contains Earthworm configuration files (`EW_PARAMS` variable)
  - `log`: where Earthworm log files are written (`EW_LOG` variable)
  - `data`: where additional files are read and written by Earthworm modules (`EW_DATA_DIR` variable)

This directory structure is the same used in Earthworm Memphis Test bundled zip file available at [http://www.earthwormcentral.org/distribution/memphis_test.zip](http://www.earthwormcentral.org/distribution/memphis_test.zip).

You can list all available Earthworm Environments on your machine by:

```sh
$ make list_ew_env
```

Previous command depends on variable `EW_ENV_MAINDIR` which must be set with the path of the main directory containing all Earthworm Environment directories. Default is the directory `ew_envs` in the home user directory (`EW_ENV_MAINDIR=~/ew_envs`).

By default, the host Earthworm Environment directory (where reside the subdirectories `params`, `log` and `data`) is mounted at run-time within the Earthworm Docker Sandbox Container under the directory  `EW_RUN_DIR`, which is `/opt/ew_env`.

You can create as many Earthworm Environments as you want using one of the following command.

##### Create an empty Earthworm Environment

You can create Earthworm Environments from scratch containing only empty subdirectories `params`, `log` and `params` by a command like this:

```sh
$ make EW_ENV=my_test_env create_ew_env_from_scratch
```

where `EW_ENV` is the name of the Earthworm Enviroment to create.

Then you can create and manage files on your own in the Earthworm Environment running a shell in a docker container by a command like this:

```sh
$ make EW_ENV=my_test_env ew_run_bash
```

##### Duplicate an Earthworm Environment

You can duplicate an Earthworm Environment starting from an existing one by:

```sh
make create_ew_env_from_another EW_ENV_FROM=ew_test1 EW_ENV=ew_test2
```

##### Copy files to an Earthworm Environment

```sh
make EW_ENV_FROM=ew_test1 cp SRC_PATH=...  DEST_PATH=...
```

Variable `SRC_PATH` is the host local file or directory and `DEST_PATH` is the docker container path.

##### Create an Earthworm Environment from a zip file

You can create Earthworm Environments starting from online zip files.

Example for creating an Earthwom Environment from an online zip file:

```sh
$ make create_ew_env_from_zip_url \
     ZIP_URL=http://www.earthwormcentral.org/distribution/memphis_test.zip \
     MAP_EW_ENV_SUBDIRS="memphis/params memphis/log memphis/data" \
     EW_ENV=memphis_test_zip
```

*Read below description of  `MAP_EW_ENV_SUBDIRS` and `CREATE_EW_ENV_SUBDIRS`.*

##### Create an Earthworm Environment from a git repository

You can create Earthworm Environments starting from git repositories.

Examples for creating an Earthwom Environment from a git repository:

```sh
$ make create_ew_env_from_git_repository \
       GIT_REP=https://github.com/matteoquintiliani/earthworm-memphis-test.git \
       GIT_BRANCH=master \
       EW_ENV=memphis_test_git
```

```sh
$ make create_ew_env_from_git_repository \
     GIT_REP=git@gitlab.rm.ingv.it:earthworm/run_configs.git \
     GIT_BRANCH=tankplayer \
     CREATE_EW_ENV_SUBDIRS="log data" \
     MAP_EW_ENV_SUBDIRS="run_realtime/params" \
     EW_ENV=ingv_test_git
```

Variable `GIT_BRANCH` is optional.

*Read below description of  `MAP_EW_ENV_SUBDIRS` and `CREATE_EW_ENV_SUBDIRS`.*

#####  Description of variables  `MAP_EW_ENV_SUBDIRS` and `CREATE_EW_ENV_SUBDIRS`

If the subdirectories `params`, `log` and `data` do not exist then you can not be able to run the Earthworm Environment. If those directories reside in different paths in zip file or git repository, you can optionally map by symbolic links the Earthworm Environment subdirectories by variable `MAP_EW_ENV_SUBDIRS`. If they do not exist, you can even create subdirectories as needed declaring the paths within variable `CREATE_EW_ENV_SUBDIRS`. Order to use is `"params log data"`.

##### Initialize Earthworm Environment

It may be useful to initialize an Earthworm Environment by running a script within the docker container and/or copying files inside it.

Example:

```sh
make EW_ENV=my_test_env create_ew_env_from_scratch

make EW_ENV=my_test_env cp SRC_PATH=./init_script_earthworm_docker_sandbox.sh  DEST_PATH=/opt/ew_env

make EW_ENV=my_test_env ew_run_bash CMD="./init_script_earthworm_docker_sandbox.sh"
```

## Running Earthworm Docker Sandbox Container

It is possible to launch only one Docker Container at a time on a single Earthworm Environment.

All commands will be executed within the container for the Earthworm Environment declared by the variable `EW_ENV` which is usually passed to command line on run-time:

An example for running commands within the Earthworm Docker Sandbox Container for a specific Earthworm Environment looks like:

```sh
$ make EW_ENV=... [ EW_GIT_REF=... ] ew_[run|startstop]_[bash|screen|detached]
```

Name of the Earthworm Docker Sandbox Container is built by default in the variable `DOCKER_CONTAINER_NAME` in the following way:

```sh
# Set Docker Image Name
DOCKER_IMAGE_NAME ?= ew-sandbox
# Docker Image Version depends on EW_GIT_REF
DOCKER_IMAGE_VERSION = $(shell echo $(EW_GIT_REF))
# Set Default Docker Container Name. It depends on DOCKER_IMAGE_VERSION and EW_ENV.
DOCKER_CONTAINER_NAME ?= $(DOCKER_IMAGE_NAME).$(DOCKER_IMAGE_VERSION).$(EW_ENV)
```

![ew_sandbox_run_example](./images/ew_sandbox_run_example.png)

This tool prevents launching multiple Earthworm Docker Sandbox Container on the same Earthworm Environment.

There are two main groups of commands:

1. Launching commands and start/stop containers (based on `docker run`, `docker stop` and `docker rm`).
2. Executing commands inside already running containers (based on `docker exec`).

##### Check operation within an Earthworm Environment by a Docker Sandbox Container

Before starting to use an Earthworm Environment, or if something goes wrong, it may be useful to properly check that the basic functions are working within an Earthworm Docker Sandbox Container.

Launching `make check_operation` a series of general purpose commands is executed within an Earthworm Environment in order to verify the correct basic functioning.

An example:

```sh
$ make EW_ENV=my_test_env check_operation
```

##### Start/Stop Earthworm Docker Sandbox Containers

The following  `make` commands based on `docker run` are used to start new docker container on an Earthworm Envinronment.

Start a new docker container within an interactive shell:

  - `ew_run_bash`:   run an interactive bash shell in a new docker container. You can optionally run command passed by CMD variable.

  - `ew_run_screen`: run an interactive screen shell in a new docker container. You can optionally run command passed by CMD variable.

Examples:

```sh
$ make EW_ENV=ew_test1 ew_run_bash
$ make EW_ENV=ew_test1 ew_run_bash CMD="df -h"
$ make EW_ENV=ew_test1 ew_run_screen
$ make EW_ENV=ew_test1 ew_run_screen CMD="df -h"
```

Start a new docker container in detached mode:

  - `ew_run_detached`: run a new docker container in detached mode. You can optionally run command passed by CMD variable. If no command is passed, the container remains active until it is stopped.

Examples:

```sh
$ make EW_ENV=ew_test1 ew_run_detached
$ make EW_ENV=ew_test1 ew_run_detached CMD="startstop"
```

Start a container by implicitly launching the Earthworm command `startstop`:

  - `ew_startstop_bash`:   run 'startstop' in an interactive bash shell in a new docker container for current EW_ENV.
  - `ew_startstop_screen`: run 'startstop' in an interactive screen shell in a new docker container for current EW_ENV.
  - `ew_startstop_detached`:  run 'startstop' in detached mode in a new docker container for current EW_ENV.
  - `ew_startstop_screen_handling_exit`: run 'startstop' in detached mode in a new docker container for current EW_ENV. Pass arguments to `ew_check_process_status.sh` by ARGS variable.

Running commands in a `bash` you will have only one shell available for that container at time. To run another shell within the same running container you can use commands in the group based on `docker exec `.

Using `screen` you can create as many shell as you want inside the same container.

Examples:

```sh
$ make EW_ENV=ew_test1 ew_startstop_bash
$ make EW_ENV=ew_test1 ew_startstop_screen
$ make EW_ENV=ew_test1 ew_startstop_detached
```

Moreover, when running a container by `ew_startstop_screen_handling_exit` you can pass arguments to the script `ew_check_process_status.sh` which can monitor an Earthworm module that when it is no longer alive then it can stop all Earthworm and exit from docker container.

Example for running Earthworm within an Earthworm Environment and quit docker container when `tankplayer.d` is no longer alive:

```sh
$ make EW_ENV=memphis_test_zip EW_INSTALL_INSTALLATION=INST_MEMPHIS \
       ew_startstop_screen_handling_exit ARGS="tankplayer.d pau"
```

Usually, a running Earthworm Docker Sandbox Container will end and be automatically removed once the command with which it was created ends. If for any reason you want to stop and remove the running container you can use:

- `ew_stop_container`:  stop and remove the running docker container [detached or not].

Previous command is based on `docker stop` and `docker rm`.

```sh
$ make EW_ENV=ew_test1 ew_stop_container
```

##### Executing commands within running Earthworm Docker Sandbox Containers

The following  `make` commands based on `docker exec` are used to launch commands in a running Earthworm Docker Sandbox Container on an Earthworm Envinronment.


  - `ew_exec_bash`: run a new interactive bash shell within the running docker container. You can optionally run command passed by CMD variable.
  - `ew_exec_screen`: run a new interactive screen shell within the running docker container. You can optionally run command passed by CMD variable.

Examples:

```sh
$ make EW_ENV=ew_test1 ew_exec_bash
$ make EW_ENV=ew_test1 ew_exec_bash CMD="status"
$ make EW_ENV=ew_test1 ew_exec_bash CMD="ps aux"
```

Shortcuts for running commands within running Earthworm Docker Sandbox Containers:

  - `ew_status`: run 'status' in the Earthworm running docker container.
  - `ew_pau`: run 'pau' in the Earthworm running docker container.
  - `ew_sniffrings_all`: run 'sniffrings' for all rings and messages except for TYPE_TRACEBUF*.
  - `ew_tail_all_logs`: exec tail and follow all log files within EW_LOG directory (/opt/earthworm/log).

Examples:

```sh
$ make EW_ENV=ew_test1 ew_status
$ make EW_ENV=ew_test1 ew_pau
$ make EW_ENV=ew_test1 ew_sniffrings_all
$ make EW_ENV=ew_test1 ew_tail_all_logs
```

## Caveats

  - <u>CPU Architecture Dependent</u>. When you build `Dockerfile`, the Earthworm Environment Shell Configuration File ( `ew_linux.bash` or `ew_linux_arm.sh`) is automatically selected depending if your system is based on ARM or not.
  - <u>Repeated executions of the same tankfiles by `tankplayer` when you also use `wave_server` module that stores waveforms to a persistent directory</u>. If you are running `wave_server` module within your Earthworm Environments which it is processing the waveforms read by `tankplayer` module, probably you will have to have delete all tank files generated by `wave_server` between one Earthworm Environment execution and the next one. For example, for a memphis test environment you may need to run `rm ~/ew_envs/memphis_test_zip/data/wave_serverV_tank/*`.
  - <u>User and Group ID on Linux system</u>.  `Dockerfile` adds a new user `ew` and a new group `ew` within the Docker image. When you build and run the image the User ID and Group ID are automatically mapped with the current user and group in the host. This allows you to run docker container as non-root user and to write with the appropriate privileges within the Earthworm Environment directories `params`, `log`and `data`.

