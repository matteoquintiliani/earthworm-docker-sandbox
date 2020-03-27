
### Complete Help

```
Earthworm Docker Sandbox 0.9.0
Matteo Quintiliani - Istituto Nazionale di Geofisica e Vulcanologia - Italy
Mail bug reports and suggestions to matteo.quintiliani [at] ingv.it

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
    - log: where Earthworm log files are written (EW_LOG variable)
    - data: where additional files are read and written by Earthworm modules (EW_DATA_DIR variable)

General commands:

    help:         display this help
    build:        build Dockerfile
    build_all:    build Dockerfile for the following branches and revision: 

                  EW_SVN_BRANCH_BUILD_LIST=
                                           tags/ew_7.7_release
                                           tags/ew_7.8_release
                                           tags/ew_7.9_release
                                           tags/ew_7.10_release 

                  EW_SVN_REVISION_BUILD_LIST=8028 8136  

    ew_env_list:  list available Earthworm Environments
    image_list:   list available Earthworm Docker Sandbox images 

Commands for running/stopping a new docker container:

    bash:   run bash shell in a new docker container
    screen: run screen shell in a new docker container

    start:  run new docker container as daemon
    stop:   stop the running docker container [daemon]

Commands executed on running docker container:

    exec:       run bash shell in the running docker container
    ps:         output 'docker ps' of running docker container
    sniffrings: sniffrings all rings except message TYPE_TRACEBUF and TYPE_TRACEBUF2
    logtail:    exec tail and follow log files in EW_LOG directory (/opt/earthworm/log)

    status_tankplayer:   output tankplayer process status

Commands for running/stopping Earthworm in docker container:

    run_ew_in_bash:   run Earthworm by bash in a new docker container
    run_ew_in_screen: run Earthworm by screen in a new docker container
                      Pass arguments to ew_check_process_status.sh by ARGS variable

            Examples: make run_ew_in_screen EW_ENV=myew_test ARGS="tankplayer.d nopau"
                      make run_ew_in_screen EW_ENV=myew_test ARGS="tankplayer.d pau"

    status:           run 'status' in the Earthworm running docker container
    pau:              run 'pau' in the Earthworm running docker container

Commands for creating Earthworm Environment:

    create_ew_env_from_scratch:   create an Earthworm Environment from scratch
                                  (create an empty environment)
    create_ew_env_from_another:   create an Earthworm Environment from another
                                  (duplicate environment from EW_ENV_FROM)

            Example: make create_ew_env_from_another EW_ENV_FROM=myenv1 EW_ENV=myenv2 \ 

    create_ew_env_from_zip_url:   download and prepare configuration and data from zip url file

            Example: make create_ew_env_from_zip_url \ 
                          ZIP_URL=http://www.isti2.com/ew/distribution/memphis_test.zip \ 
                          CREATE_EW_ENV_SUBDIRS="" \ 
                          MAP_EW_ENV_SUBDIRS="memphis/params memphis/log memphis/data" \ 
                          EW_ENV=my_test_env

    create_ew_env_memphis_test:   short cut based on create_ew_env_from_zip_url for Memphis Test
    create_ew_env_ingv_test:      short cut based on create_ew_env_from_zip_url for INGV Test

    create_ew_env_from_git_repository:
                  create Earthworm Environment having main directory from a branch of a git repository

            Example: make create_ew_env_from_git_repository \ 
                          GIT_REP=git@gitlab.rm.ingv.it:earthworm/run_configs.git \ 
                          GIT_BRANCH=develop \ 
                          CREATE_EW_ENV_SUBDIRS=log data \ 
                          MAP_EW_ENV_SUBDIRS=run_realtime/params \ 
                          EW_ENV=my_test_env

    create_ew_env_from_ingv_runconfig_branch:
                  short cut based on create_ew_env_from_git_repository for INGV Git Repository

Commands for creating tankfiles:

    create_tank:  launch script create_tank_from_ot_lat_lon_radius.sh
                  Pass arguments to create_tank_from_ot_lat_lon_radius.sh by ARGS variable

            Example: make create_tank ARGS="2017-01-01T00:00:00 10 30 42 13 0.3 ~/ew_data"

Commands for deleting files: (VERY DANGEROUS)

    clean_ew_log: delete all files within log directory (~/ew_envs/ew_help/log)
    clean_ew_ws:  delete all files within waveserver directories (~/ew_envs/ew_help/data/waveservers)
```

