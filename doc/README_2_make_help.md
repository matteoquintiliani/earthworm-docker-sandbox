
### Complete Help

```
make _help EW_ENV=ew_help
Earthworm Docker Sandbox 0.10.0
=====================================================

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

=====================================================
General commands:
=====================================================

    help:       display this help
    build:      build docker image using 'Dockerfile' and 'Makefile.env'
    build_all:  build docker images using 'Dockerfile' for:
                  * branches in EW_SVN_BRANCH_BUILD_LIST=
                          - tags/ew_7.7_release
                          - tags/ew_7.8_release
                          - tags/ew_7.9_release
                          - tags/ew_7.10_release 
                  * revisions in EW_SVN_REVISION_BUILD_LIST=
                          - 8028
                          - 8136 

    list_ew_env:     list available Earthworm Environments (refer to EW_ENV_MAINDIR)
    list_images:     list available Earthworm Docker Sandbox images 
                     wrap 'docker images' matching name 'ew-sandbox*' 
    list_containers: list available Earthworm Docker Sandbox containers
                     wrap 'docker ps' containers matching name 'ew-sandbox*' 

=====================================================
Creating Earthworm Environments with name EW_ENV:
=====================================================

    create_ew_env_from_scratch: create an Earthworm Environment from scratch
                                (create an empty environment)
    create_ew_env_from_another: create an Earthworm Environment from another
                                (duplicate environment from EW_ENV_FROM)

    create_ew_env_from_zip_url: download and prepare configuration and data
                                from zip url file

    create_ew_env_from_git_repository: create Earthworm Environment having main
                                  directory from a branch of a git repository

    create_ew_env_from_memphis_test: shortcut based on create_ew_env_from_zip_url
                                  for creating an Earthworm Environment from Memphis Test
    create_ew_env_from_ingv_test:    shortcut based on create_ew_env_from_zip_url
                                  for creating an Earthworm Environment from INGV Test

    create_ew_env_from_ingv_runconfig_branch: shortcut based on create_ew_env_from_git_repository
                               for creating an Earthworm Environment from INGV git repository

    Examples:
              make create_ew_env_from_scratch EW_ENV=ew_test1 
              make create_ew_env_from_another EW_ENV_FROM=ew_test1 EW_ENV=ew_test2 

              make create_ew_env_from_zip_url \ 
                   ZIP_URL=http://www.isti2.com/ew/distribution/memphis_test.zip \ 
                   CREATE_EW_ENV_SUBDIRS="" \ 
                   MAP_EW_ENV_SUBDIRS="memphis/params memphis/log memphis/data" \ 
                   EW_ENV=memphis_test1

              make create_ew_env_from_git_repository \ 
                   GIT_REP=git@gitlab.rm.ingv.it:earthworm/run_configs.git \ 
                   GIT_BRANCH=develop \ 
                   CREATE_EW_ENV_SUBDIRS=log data \ 
                   MAP_EW_ENV_SUBDIRS=run_realtime/params \ 
                   EW_ENV=ingv_test1

=====================================================
Creating tankfiles:
=====================================================

    create_tank:  launch script create_tank_from_ot_lat_lon_radius.sh
                  Pass arguments to create_tank_from_ot_lat_lon_radius.sh by ARGS variable

    Example: make create_tank ARGS="2017-01-01T00:00:00 10 30 42 13 0.3 ~/ew_data"

=====================================================
Deleting files: (POTENTIALLY DANGEROUS)
=====================================================

    ew_dangerous_clean_log: delete all files within log directory (~/ew_envs/ew_help/log)
    ew_dangerous_clean_ws:  delete all files within waveserver directories (~/ew_envs/ew_help/data/waveservers)

=====================================================
Running/Stopping Earthworm Docker Sandbox container:
=====================================================

    ew_run_bash:   run interactive bash shell in a new docker container
                   you can optionally run command passed by ARGS variable
    ew_run_screen: run interactive screen shell in a new docker container
                   you can optionally run command passed by ARGS variable

    ew_startstop_in_bash:   run 'startstop' in an interactive bash shell
                            in a new docker container for current EW_ENV
    ew_startstop_in_screen: run 'startstop' in an interactive screen shell
                            in a new docker container for current EW_ENV
    ew_startstop_detached:  run 'startstop' in detached mode
                            in a new docker container for current EW_ENV

    ew_stop_container:      stop and remove the running docker container [detached or not]

    ew_startstop_in_screen_handling_exit: run 'startstop' in detached mode
                            in a new docker container for current EW_ENV
                            Pass arguments to ew_check_process_status.sh by ARGS variable

    Examples:
              make EW_ENV=ew_test1 ew_run_bash
              make EW_ENV=ew_test1 ew_run_bash ARGS="df -h"
              make EW_ENV=ew_test1 ew_run_screen
              make EW_ENV=ew_test1 ew_run_screen ARGS="df -h"

              make EW_ENV=ew_test1 ew_startstop_in_bash
              make EW_ENV=ew_test1 ew_startstop_in_screen"
              make EW_ENV=ew_test1 ew_startstop_detached

              make EW_ENV=ew_test1 ew_stop_container

              make EW_ENV=ew_test1 ew_startstop_in_screen_handling_exit ARGS="tankplayer.d nopau"
              make EW_ENV=ew_test1 ew_startstop_in_screen_handling_exit ARGS="tankplayer.d pau"

=====================================================
Executing commands within running Earthworm Docker Sandbox containers:
=====================================================

    ew_exec_bash:      run a new bash shell within the running docker container
                       you can optionally run command passed by ARGS variable
    ew_exec_screen:    run a new screen shell within the running docker container
                       you can optionally run command passed by ARGS variable

    ew_status:         run 'status' in the Earthworm running docker container
    ew_pau:            run 'pau' in the Earthworm running docker container

    ew_sniffrings_all:    run 'sniffrings' for all rings and messages except for TYPE_TRACEBUF*
    ew_tail_all_logs:     exec tail and follow all log files within
                          EW_LOG directory (/opt/earthworm/log)
    ew_status_tankplayer: output tankplayer process status

    Examples:
              make EW_ENV=ew_test1 ew_exec_bash
              make EW_ENV=ew_test1 ew_exec_bash ARGS="ps aux"
              make EW_ENV=ew_test1 ew_status
              make EW_ENV=ew_test1 ew_pau
              make EW_ENV=ew_test1 ew_sniffrings_all
              make EW_ENV=ew_test1 ew_tail_all_logs

===========================================================================
Matteo Quintiliani - Istituto Nazionale di Geofisica e Vulcanologia - Italy
Mail bug reports and suggestions to matteo.quintiliani [at] ingv.it

```

