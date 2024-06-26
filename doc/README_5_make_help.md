
### Complete Help

```
===========================================================================
Earthworm Docker Sandbox 2.2.0 Copyright (C) 2020-2023  Matteo Quintiliani
===========================================================================

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
    - params: contains Earthworm configuration files (EW_PARAMS variable).
    - log:    where Earthworm log files are written (EW_LOG variable).
    - data:   where additional files are read and written
              by Earthworm modules (EW_DATA_DIR variable).

======================================================================
General commands:
======================================================================

    help:       display this help.
    ls-remote:  list references in the Earthworm git remote repository:n                https://gitlab.com/seismic-software/earthworm.git.
    build:      build docker image using 'Dockerfile' and 'Makefile.env'.
    build_all:  build docker images using 'Dockerfile' for:
                 * branches in EW_GIT_REF_BUILD_LIST=
                    - d561670a
                    - v7.10
                    - v7.9
                    - v7.8
                    - v7.7 

    list_ew_env:     list available Earthworm Environments (refer to EW_ENV_MAINDIR).
    list_images:     list available Earthworm Docker Sandbox images 
                     wrap 'docker images' matching name 'ew-sandbox*'.
    list_containers: list available Earthworm Docker Sandbox containers
                     wrap 'docker ps' containers matching name 'ew-sandbox*'.

    check_required_commands: check the availability of all necessary commands.

======================================================================
Creating Earthworm Environments with name EW_ENV:
======================================================================

    create_ew_env_from_scratch: create an Earthworm Environment from scratch.
                                (Create an empty environment).
    create_ew_env_from_another: create an Earthworm Environment from another.
                                (Duplicate environment from EW_ENV_FROM).

    create_ew_env_from_zip_url: download and prepare configuration and data
                                from zip url file.

    create_ew_env_from_git_repository: create Earthworm Environment having main
                                       directory from a branch of a git repository.

    create_ew_env_from_memphis_test: shortcut based on create_ew_env_from_zip_url for
                                     creating an Earthworm Environment from Memphis Test.
    create_ew_env_from_ingv_test:    shortcut based on create_ew_env_from_zip_url for
                                     creating an Earthworm Environment from INGV Test.

    create_ew_env_from_ingv_runconfig_branch: shortcut based on create_ew_env_from_git_repository
                               for creating an Earthworm Environment from INGV git repository.

    cp: copy files to an Earthworm Environment by running or executing a Docker Container.
                               Based on 'tar' and variables SRC_PATH and DEST_PATH.

    Examples:
              make create_ew_env_from_scratch EW_ENV=ew_test1 
              make create_ew_env_from_another EW_ENV_FROM=ew_test1 EW_ENV=ew_test2 

              make EW_ENV=ew_test1  cp  SRC_PATH=mymodule.d  DEST_PATH=./params/

              make create_ew_env_from_zip_url \ 
                   ZIP_URL=http://www.earthwormcentral.org/distribution/memphis_test.zip \ 
                   CREATE_EW_ENV_SUBDIRS="" \ 
                   MAP_EW_ENV_SUBDIRS="memphis/params memphis/log memphis/data" \ 
                   EW_ENV=memphis_test_zip

              make create_ew_env_from_git_repository \ 
                   GIT_REP=https://github.com/matteoquintiliani/earthworm-memphis-test.git \ 
                   GIT_BRANCH=master \ 
                   CREATE_EW_ENV_SUBDIRS="" \ 
                   MAP_EW_ENV_SUBDIRS= \ 
                   EW_ENV=memphis_test_git

              make create_ew_env_from_git_repository \ 
                   GIT_REP=git@gitlab.rm.ingv.it:earthworm/run_configs.git \ 
                   GIT_BRANCH=tankplayer \ 
                   CREATE_EW_ENV_SUBDIRS="log data" \ 
                   MAP_EW_ENV_SUBDIRS=run_realtime/params \ 
                   EW_ENV=ingv_test1

======================================================================
Creating tankfiles:
======================================================================

    create_tank:  launch script 'create_tank_from_ot_lat_lon_radius.sh'.
                  Pass arguments to create_tank_from_ot_lat_lon_radius.sh by ARGS variable.

    Example: make create_tank ARGS="2017-01-01T00:00:00 10 30 42 13 0.3 ~/ew_data"

======================================================================
Deleting files: (POTENTIALLY DANGEROUS)
======================================================================

    ew_dangerous_clean_log: delete all files within docker host
                            log directory (~/ew_envs/ew_help/log).
    ew_dangerous_clean_ws:  delete all files within docker host
                            waveserver directories (~/ew_envs/ew_help/data/waveservers).

======================================================================
Check operation within an Earthworm Environment by a Docker Sandbox Container:
======================================================================

    check_operation: run a series of general purpose commands within an Earthworm Environment
                   in order to verify the correct basic functioning.

======================================================================
Start/Stop Earthworm Docker Sandbox Containers:
======================================================================

    ew_run_bash:     run interactive bash shell in a new docker container.
                     You can optionally run command passed by CMD variable.
    ew_run_screen:   run interactive screen shell in a new docker container.
                     You can optionally run command passed by CMD variable.
    ew_run_detached: run a new docker container in detached mode.
                     You can optionally run command passed by CMD variable.
                     If no command is passed, the container remains active until it is stopped.

    ew_startstop_bash:     run 'startstop' in an interactive bash shell
                           in a new docker container for current EW_ENV.
    ew_startstop_screen:   run 'startstop' in an interactive screen shell
                           in a new docker container for current EW_ENV.
    ew_startstop_detached: run 'startstop' in detached mode
                           in a new docker container for current EW_ENV.

    ew_stop_container:     stop and remove the running docker container [detached or not].

    ew_startstop_screen_handling_exit: run 'startstop' in detached mode
                            in a new docker container for current EW_ENV.
                            Pass arguments to ew_check_process_status.sh by ARGS variable

    Examples:
              make EW_ENV=ew_test1 ew_run_bash
              make EW_ENV=ew_test1 ew_run_bash CMD="df -h"
              make EW_ENV=ew_test1 ew_run_screen
              make EW_ENV=ew_test1 ew_run_screen CMD="df -h"
              make EW_ENV=ew_test1 ew_run_detached
              make EW_ENV=ew_test1 ew_run_detached CMD="startstop"

              make EW_ENV=ew_test1 ew_startstop_bash
              make EW_ENV=ew_test1 ew_startstop_screen
              make EW_ENV=ew_test1 ew_startstop_detached

              make EW_ENV=ew_test1 ew_stop_container

              make EW_ENV=ew_test1 ew_startstop_screen_handling_exit ARGS="tankplayer.d nopau"
              make EW_ENV=ew_test1 ew_startstop_screen_handling_exit ARGS="tankplayer.d pau"

======================================================================
Executing commands within running Earthworm Docker Sandbox Containers:
======================================================================

    ew_exec_bash:      run a new bash shell within the running docker container.
                       You can optionally run command passed by CMD variable.
    ew_exec_screen:    run a new screen shell within the running docker container.
                       You can optionally run command passed by CMD variable.

    ew_status:         run 'status' in the Earthworm running docker container.
    ew_pau:            run 'pau' in the Earthworm running docker container.

    ew_sniffrings_all:    run 'sniffrings' for all rings and messages except for TYPE_TRACEBUF*.
    ew_tail_all_logs:     exec tail and follow all log files within
                          EW_LOG directory (/opt/ew_env/log).
    ew_status_tankplayer: output tankplayer process status.

    Examples:
              make EW_ENV=ew_test1 ew_exec_bash
              make EW_ENV=ew_test1 ew_exec_bash CMD="ps aux"
              make EW_ENV=ew_test1 ew_exec_bash CMD="status"
              make EW_ENV=ew_test1 ew_status
              make EW_ENV=ew_test1 ew_pau
              make EW_ENV=ew_test1 ew_sniffrings_all
              make EW_ENV=ew_test1 ew_tail_all_logs

======================================================================
License
======================================================================
Earthworm Docker Sandbox: a Docker tool for learning, testing, running and
developing Earthworm System within enclosed environments.

Copyright (C) 2020-2023  Matteo Quintiliani - INGV - Italy
Mail bug reports and suggestions to matteo.quintiliani [at] ingv.it

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```

