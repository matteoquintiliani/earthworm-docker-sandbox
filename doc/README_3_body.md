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
  - **git** - [https://git-scm.com/](https://git-scm.com/)
  - **unzip** - depends on your system

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

To get familiar with this tool we will use the Memphis test configuration available from [http://www.isti2.com/ew/distribution/memphis_test.zip](http://www.isti2.com/ew/distribution/memphis_test.zip).

  - Change directory to Earthworm Docker Sandbox.

```sh
$ cd /<somewhere_in_your_disk>/earthworm-docker-sandbox
```

  - Build the default Earthworm Docker Sandbox image.

```sh
$ make build
```

If all went well you can list the Earthworm Docker Sandbox image.

```sh
$ make list_images
```

```
docker images ew-sandbox
REPOSITORY          TAG                    IMAGE ID            CREATED             SIZE
ew-sandbox          trunk_r8136            cb78c92612f0        25 hours ago        856MB
```

  - Create if not exists the directory defined in `EW_ENV_MAINDIR`. In that directory will be stored and referenced all Earthworm Environments. Default directory is `~/ew_envs`.

```sh
$ mkdir ~/ew_envs
```
  - List available Earthworm Environments. First time the list should be empty.

```sh
$ make list_ew_env
```

  - Create your first Earthworm Environment (read details in section below) from Memphis test available online. The memphis file zip already contains directory `params`, `log` and `data`, by variable `MAP_EW_ENV_SUBDIRS` we create symbolic links in the main directory of the Earthworm Environment called `memphis_test1`.

```sh
$ make create_ew_env_from_zip_url \
       ZIP_URL=http://www.isti2.com/ew/distribution/memphis_test.zip \
       CREATE_EW_ENV_SUBDIRS="" \
       MAP_EW_ENV_SUBDIRS="memphis/params memphis/log memphis/data" \
       EW_ENV=memphis_test1
```

  - List of the Earthworm Environments. You should now see `memphis_test1`.

```sh
$ make list_ew_env
```

```sh
Available Earthworm Environments:

  - memphis_test1

```

  - Run `startstop` in an interactive bash shell within the Earthworm Environment `memphis_test1` just created.

```sh
$ make EW_ENV=memphis_test1 \
     EW_INSTALL_INSTALLATION=INST_MEMPHIS \
     ew_startstop_bash
```

You will see the interactive output from the Earthworm `startstop` process.

  - From a different terminal prompt of your host, list the running Earthworm Docker Sandbox Container:

```sh
$ make list_containers
docker ps -f name='ew-sandbox*'
```

a possible output:

```sh
CONTAINER ID        IMAGE                    COMMAND                   CREATED             STATUS              PORTS               NAMES
5c4241577326        ew-sandbox:trunk_r8136   "/bin/bash -c 'CMD=\"…"   5 seconds ago       Up 5 seconds                            ew-sandbox.trunk_r8136.memphis_test1
```

  - Launch a bash shell within the Earthworm Docker Sandbox Container previously started on the Earthworm Environment `memphis_test1`.

```sh
$ make EW_ENV=memphis_test1 ew_exec_bash
```


The Earthworm Docker Sandbox Container shell prompt will be shown:

```sh
f74b689cb1ed:/opt/ew_env [ew:memphis_test1] $
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

## Building Docker Image

Building the Earthworm Docker Sandbox images is based on:

1. Local files `Dockerfile`, `Makefile`  and `Makefile.env`
1. Online official Earthworm Subversion Repository `svn://svn.isti.com/earthworm`
1. Optional: online `ew2openapi` git repository [https://gitlab.rm.ingv.it/earthworm/ew2openapi/](https://gitlab.rm.ingv.it/earthworm/ew2openapi/)

- Build the image with current variables in `Makefile.env`:

```sh
$ make build
```

### Compiling specific Earthworm versions

Default settings get the latest Earthworm Subversion revision tested by this tool from the main branch `svn://svn.isti.com/earthworm/trunk` and compile all Earthworm sources.

Branch and revision involved in the docker image building process are defined in variables `EW_SVN_BRANCH` and `EW_CO_SVN_REVISION`. You can compile a specific Earthworm version changing those values.

- `EW_SVN_BRANCH`:

```sh
# Set Earthworm Subversion Branch. Default is 'trunk'
# EW_SVN_BRANCH must be defined and not empty.
# You can set custom main directories
# (e.g. 'tags/ew_7.10_release', 'branches/cosmos', etc.)
EW_SVN_BRANCH = trunk
# EW_SVN_BRANCH = tags/ew_7.10_release
```
- `EW_CO_SVN_REVISION`:

```sh
# Set optional Earthworm Revision.
# If it is empty that stands for last available revision of the EW_SVN_BRANCH
# You can set custom subversion revision 'NNN' where NNN is the revision number
# EW_SVN_REVISION =
# Latest Earthworm Subversion revision tested by this tool
EW_SVN_REVISION = 8136
```

Changelog of Earthworm subversion revisions are available from the following URL: [http://earthworm.isti.com/trac/earthworm/log/](http://earthworm.isti.com/trac/earthworm/log/)).

If you want to compile a previous version of Earthworm you can set variables `EW_SVN_BRANCH` and/or `EW_SVN_REVISION`. For example:

```sh
make EW_SVN_REVISION=8068 build
```

or

```sh
make EW_SVN_BRANCH=tags/ew_7.10_release EW_SVN_REVISION= build
```

Caveat: you might need to change `Doxyfile` in order to fix properly the section where Earthworm is compiled and/or basing your build on a different and/or older docker linux image.

Using the current `Doxyfile` you should be able to successfully compile all major revisions. In particular, by the following command:

```sh
$ make build_all
```

you can create the docker images for the following Earthworm revisions:

  - `EW_SVN_REVISION=8136` Subversion revision @8136, 64-bit version. (From revision @8068 \[*ew_7.10\_release*\] to the last one, all consistent revisions should be successfully compiled), 64-bit version.
  - `EW_SVN_BRANCH=tags/ew_7.10_release EW_SVN_REVISION=` (svn revision @8068 - 2019/08/17), 64-bit version.
  - `EW_SVN_BRANCH=tags/ew_7.9_release EW_SVN_REVISION=` (svn revision @6859 - 2016/10/28), 32-bit version.
  - `EW_SVN_BRANCH=tags/ew_7.8_relase EW_SVN_REVISION=` (svn revision @6404 - 2015/06/25), 32-bit version.
  - `EW_SVN_BRANCH=tags/ew_7.7_relase EW_SVN_REVISION=` (svn revision @5961 - 2013/09/19), 32-bit version.

Caveat:  arm architecture is available only since ew 7.10.


When you build an Earthworm Docker Sandbox image, default name is `ew-sandbox` and tag is built by the values of `EW_SVN_BRANCH` and `EW_SVN_REVISION` variables.

List available Earthworm Docker Sandbox images.

```sh
$ make list_images
docker images ew-sandbox
```

An example of the output is:

```
REPOSITORY          TAG                    IMAGE ID            CREATED             SIZE
ew-sandbox          trunk_r8136            57d200416fdc        12 minutes ago      1.13GB
ew-sandbox          trunk_r8028            c932a0ace575        54 minutes ago      1.13GB
ew-sandbox          tags_ew_7_10_release   79865ee1affb        About an hour ago   917MB
ew-sandbox          tags_ew_7_9_release    0f08896bac47        2 hours ago         862MB
ew-sandbox          tags_ew_7_8_release    5f36eaff12f6        2 hours ago         841MB
ew-sandbox          tags_ew_7_7_release    59ad5d0b3193        2 hours ago         839MB
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

This directory structure is the same used in Earthworm Memphis Test bundled zip file available at [http://www.isti2.com/ew/distribution/memphis_test.zip](http://www.isti2.com/ew/distribution/memphis_test.zip).

You can list all available Earthworm Environments on your machine by:

```sh
$ make list_ew_env
```

Previous command depends on variable `EW_ENV_MAINDIR` which must be set with the path of the main directory containing all Earthworm Environment directories. Default is the directory `ew_envs` in the home user directory (`EW_ENV_MAINDIR=~/ew_envs`).

By default, subdirectories `params`, `log` and `data` are mounted within the Earthworm Docker Sandbox under the container directory  `EW_RUN_DIR`, which is `/opt/ew_env`.

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

##### Create an Earthworm Environment from a zip file

You can create Earthworm Environments starting from online zip files.

Example for creating an Earthwom Environment with name `my_test_env` from an online zip file:

```sh
$ make create_ew_env_from_zip_url \
     ZIP_URL=http://www.isti2.com/ew/distribution/memphis_test.zip \
     MAP_EW_ENV_SUBDIRS="memphis/params memphis/log memphis/data" \
     EW_ENV=memphis_test1
```

*Read below description of  `MAP_EW_ENV_SUBDIRS` and `CREATE_EW_ENV_SUBDIRS`.*

##### Create an Earthworm Environment from a git repository

You can create Earthworm Environments starting from git repositories.

Example for creating an Earthwom Environment with name `my_test_env` from a git repository:

```sh
$ make create_ew_env_from_git_repository \
     GIT_REP=git@gitlab.rm.ingv.it:earthworm/run_configs.git \
     GIT_BRANCH=tankplayer \
     CREATE_EW_ENV_SUBDIRS="" \
     MAP_EW_ENV_SUBDIRS="run_realtime/params log data" \
     EW_ENV=ingv_test1
```

Variable `GIT_BRANCH` is optional.

*Read below description of  `MAP_EW_ENV_SUBDIRS` and `CREATE_EW_ENV_SUBDIRS`.*

#####  Description of variables  `MAP_EW_ENV_SUBDIRS` and `CREATE_EW_ENV_SUBDIRS`

If the subdirectories `params`, `log` and `data` do not exist then you can not be able to run the Earthworm Environment. If those directories reside in different paths in zip file or git repository, you can optionally map by symbolic links the Earthworm Environment subdirectories by variable `MAP_EW_ENV_SUBDIRS`. If they do not exist, you can even create subdirectories as needed declaring the paths within variable `CREATE_EW_ENV_SUBDIRS`. Order to use is `"params log data"`.

## Running Earthworm Docker Sandbox Container

It is possible to launch only one Docker Container at a time on a single Earthworm Environment.

All commands will be executed within the container for the Earthworm Environment declared by the variable `EW_ENV` which is usually passed to command line on run-time:

An example for running commands within the Earthworm Docker Sandbox Container for a specific Earthworm Environment looks like:

```sh
$ make  EW_ENV=<earthworm_environment_name>  <command>
```

Name of the Earthworm Docker Sandbox Container is built by default in the variable `DOCKER_CONTAINER_NAME` in the following way:

```sh
# Set Docker Image Name
DOCKER_IMAGE_NAME ?= ew-sandbox

# Docker Image Version depends on EW_SVN_BRANCH and EW_SVN_REVISION
DOCKER_IMAGE_VERSION = `echo \`echo $(EW_SVN_BRANCH) | sed -e 's/[\.\/\@]/_/g'\`\`echo $(EW_SVN_REVISION) | sed -e 's/\([0-9]\)/_r\1/'\``

# Set Default Docker Container Name. It depends on DOCKER_IMAGE_VERSION and EW_ENV.
DOCKER_CONTAINER_NAME ?= $(DOCKER_IMAGE_NAME).$(DOCKER_IMAGE_VERSION).$(EW_ENV)
```

This tool prevents launching multiple Earthworm Docker Sandbox Container on the same Earthworm Environment.

There are two main groups of commands:

1. Launching commands and start/stop containers (based on `docker run`, `docker stop` and `docker rm`).
2. Executing commands inside already running containers (based on `docker exec`).

##### Start/Stop Earthworm Docker Sandbox Containers

The following  `make` commands based on `docker run` are used to start new docker container on an Earthworm Envinronment.

Start a new docker container within an interactive shell:

  - `ew_run_bash`:   run an interactive bash shell in a new docker container. You can optionally run command passed by ARGS variable.

  - `ew_run_screen`: run an interactive screen shell in a new docker container. You can optionally run command passed by ARGS variable.

Examples:

```sh
$ make EW_ENV=ew_test1 ew_run_bash
$ make EW_ENV=ew_test1 ew_run_bash ARGS="df -h"
$ make EW_ENV=ew_test1 ew_run_screen
$ make EW_ENV=ew_test1 ew_run_screen ARGS="df -h"
```

Start a container by implicitly launching the Earthworm command `startstop`:

  - `ew_startstop_bash`:   run 'startstop' in an interactive bash shell in a new docker container for current EW_ENV.
  - `ew_startstop_screen`: run 'startstop' in an interactive screen shell in a new docker container for current EW_ENV.
  - `ew_startstop_detached`:  run 'startstop' in detached mode in a new docker container for current EW_ENV.
  - `ew_startstop_screen_handling_exit`: run 'startstop' in detached mode in a new docker container for current EW_ENV. Pass arguments to ew_check_process_status.sh by ARGS variable.

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
$ make EW_ENV=memphis_test1 EW_INSTALL_INSTALLATION=INST_MEMPHIS \
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


  - `ew_exec_bash`: run a new interactive bash shell within the running docker container. You can optionally run command passed by ARGS variable.
  - `ew_exec_screen`: run a new interactive screen shell within the running docker container. You can optionally run command passed by ARGS variable.

Examples:

```sh
$ make EW_ENV=ew_test1 ew_exec_bash
$ make EW_ENV=ew_test1 ew_exec_bash ARGS="status"
$ make EW_ENV=ew_test1 ew_exec_bash ARGS="ps aux"
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
  - <u>Repeated executions of the same tankfiles by `tankplayer` when you also use `wave_server` module that stores waveforms to a persistent directory</u>. If you are running `wave_server` module within your Earthworm Environments which it is processing the waveforms read by `tankplayer` module, probably you will have to have delete all tank files generated by `wave_server` between one Earthworm Environment execution and the next one. For example, for a memphis test environment you may need to run `rm ~/ew_envs/memphis_test1/data/wave_serverV_tank/*`.
  - <u>User and Group ID on Linux system</u>.  `Dockerfile` adds a new user `ew` and a new group `ew` within the Docker image. When you build and run the image the User ID and Group ID are automatically mapped with the current user and group in the host. This allows you to run docker container as non-root user and to write with the appropriate privileges within the Earthworm Environment directories `params`, `log`and `data`.

