################################################################################
# Earthworm Docker Sandbox: a Docker tool for learning, testing, running and
# developing Earthworm System within enclosed environments.
#
# Copyright (C) 2020  Matteo Quintiliani - INGV - Italy
# Mail bug reports and suggestions to matteo.quintiliani [at] ingv.it
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
################################################################################

# Include variables from file Makefile.env
include Makefile.env

# Current version of this tool
EDS_VERSION=0.20.1

###########################################################
# Do not edit this file but set variables in Makefile.env
###########################################################

ifndef DOCKER_NAMESPACE
	DOCKER_NAMESPACE_EXT =
else
	DOCKER_NAMESPACE_EXT = $(DOCKER_NAMESPACE)/
endif

# Set optional Docker Namespace
# DOCKER_NAMESPACE = earthworm_docker_sandbox

# Set Docker Image Name
DOCKER_IMAGE_NAME ?= ew-sandbox

# Docker Image Version depends on EW_SVN_BRANCH and EW_SVN_REVISION
DOCKER_IMAGE_VERSION = `echo \`echo $(EW_SVN_BRANCH) | sed -e 's/[\.\/\@]/_/g'\`\`echo $(EW_SVN_REVISION) | sed -e 's/\([0-9]\)/_r\1/'\``

# Set Default Docker Container Name. It depends on DOCKER_IMAGE_VERSION and EW_ENV.
DOCKER_CONTAINER_NAME ?= $(DOCKER_IMAGE_NAME).$(DOCKER_IMAGE_VERSION).$(EW_ENV)

# Set namespace image name and version
NS_IMAGE_NAME = $(DOCKER_NAMESPACE_EXT)$(DOCKER_IMAGE_NAME)
NS_IMAGE_NAME_VERSION = $(NS_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)

# Default options for 'docker run' and 'docker exec': interactive, tty and not detached
OPT_RUN_I = -i
OPT_RUN_T = -t
OPT_RUN_D =

# Compute EW_ENV_DIR
EW_ENV_DIR=$(EW_ENV_MAINDIR)/$(EW_ENV)

# Compute EW_ENV_MAINDIR_ABSPATH and EW_ENV_COMPLETE_PATH that is base on EW_ENV
EW_ENV_MAINDIR_ABSPATH=`cd $(EW_ENV_MAINDIR) && pwd`
EW_ENV_COMPLETE_PATH=$(EW_ENV_MAINDIR_ABSPATH)/$(EW_ENV)

# Docker EW_RUN_DIR
DOCKER_EW_RUN_DIR=/opt/ew_env

# Set Default Volume Mounts
DOCKER_VOLUMES = \
	-v  $(EW_ENV_COMPLETE_PATH)/:$(DOCKER_EW_RUN_DIR)/
	# -v  $(EW_ENV_COMPLETE_PATH)/params:$(DOCKER_EW_RUN_DIR)/params \
	# -v  $(EW_ENV_COMPLETE_PATH)/log:$(DOCKER_EW_RUN_DIR)/log \
	# -v  $(EW_ENV_COMPLETE_PATH)/data:$(DOCKER_EW_RUN_DIR)/data

# Set default User and Group id from current user
# If UID and/or GID are equal to zero then new user and/or group are created into the Docker Container
ENV_UID=$(shell id -u)
ENV_GID=$(shell id -g)
# ENV_UID=0
# ENV_GID=0

# Set Docker running user
DOCKER_USER = --user $(ENV_UID):$(ENV_GID)

# Set additional Docker environment variables
DOCKER_ENV_COMPLETE = \
	$(DOCKER_ENV) \
	-e EW_ENV=$(EW_ENV) \
	-e EW_INSTALL_INSTALLATION=$(EW_INSTALL_INSTALLATION)

.PHONY: \
	build build_all \
	version \
	list_ew_env list_images list_containers \
	create_ew_env_from_scratch \
	create_ew_env_from_another \
	create_ew_env_from_zip_url \
	create_ew_env_from_git_repository \
	create_ew_env_from_memphis_test \
	create_ew_env_from_ingv_test \
	create_ew_env_from_ingv_runconfig_branch \
	ew_run_bash ew_run_screen \
	ew_exec_bash ew_exec_screen \
	ew_status ew_sniffrings_all ew_tail_all_logs \
	ew_startstop_bash \
	ew_startstop_screen \
	ew_startstop_screen_handling_exit \
	ew_startstop_detached \
	ew_stop_container \
	ew_pau \
	create_tank \
	ew_dangerous_clean_log \
	ew_dangerous_clean_ws \
	help _help \
	doc \
	push shell rm release test

BUILD_SOURCES = \
				./Dockerfile \
				./Makefile.env
				# ./entrypoint.sh

EW_ENV_LOG = $(EW_ENV_DIR)/log
EW_ENV_WS = $(EW_ENV_DIR)/data/waveservers

EW_SVN_BRANCH_BUILD_LIST="tags/ew_7.7_release \
tags/ew_7.8_release \
tags/ew_7.9_release \
tags/ew_7.10_release"

EW_SVN_REVISION_BUILD_LIST="8028 \
8136"

SEPLINE="======================================================================"
SEPLONGLINE="==========================================================================="
HELP_EW_ENV="ew_test1"
HELP_EW_ENV_2="ew_test2"

help:
	@make _help EW_ENV=ew_help \
		| less

_help:
	@echo "$(SEPLONGLINE)"
	@make version
	@echo "\
$(SEPLONGLINE)\n\
\n\
Syntax: make  [ EW_ENV=<ew_env_subdir_name> ]  <command>\n\
\n\
Current main variable values:\n\
    EW_ENV=$(EW_ENV)\n\
    EW_ENV_MAINDIR=$(EW_ENV_MAINDIR)\n\
    EW_ENV_DIR=$(EW_ENV_DIR)\n\
\n\
Earthworm Environment:\n\
    - name is defined by EW_ENV\n\
    - directory is in EW_ENV_MAINDIR with name EW_ENV\n\
    - directory path is EW_ENV_DIR\n\
\n\
An Earthworm Environment Directory must contain the following subdirectories:\n\
    - params: contains Earthworm configuration files (EW_PARAMS variable).\n\
    - log:    where Earthworm log files are written (EW_LOG variable).\n\
    - data:   where additional files are read and written\n\
              by Earthworm modules (EW_DATA_DIR variable).\n\
\n\
$(SEPLINE)\n\
General commands:\n\
$(SEPLINE)\n\
\n\
    help:       display this help.\n\
    build:      build docker image using 'Dockerfile' and 'Makefile.env'.\n\
    build_all:  build docker images using 'Dockerfile' for:\n\
                  * branches in EW_SVN_BRANCH_BUILD_LIST=\n\
`for B in "$(EW_SVN_BRANCH_BUILD_LIST)"; do echo "                          - $${B}"; done` \n\
                  * revisions in EW_SVN_REVISION_BUILD_LIST=\n\
`for R in "$(EW_SVN_REVISION_BUILD_LIST)"; do echo "                          - $${R}"; done` \n\
\n\
    list_ew_env:     list available Earthworm Environments (refer to EW_ENV_MAINDIR).\n\
    list_images:     list available Earthworm Docker Sandbox images \n\
                     wrap 'docker images' matching name '$(DOCKER_IMAGE_NAME)*'.\n\
    list_containers: list available Earthworm Docker Sandbox containers\n\
                     wrap 'docker ps' containers matching name '$(DOCKER_IMAGE_NAME)*'.\n\
\n\
$(SEPLINE)\n\
Creating Earthworm Environments with name EW_ENV:\n\
$(SEPLINE)\n\
\n\
    create_ew_env_from_scratch: create an Earthworm Environment from scratch.\n\
                                (Create an empty environment).\n\
    create_ew_env_from_another: create an Earthworm Environment from another.\n\
                                (Duplicate environment from EW_ENV_FROM).\n\
\n\
    create_ew_env_from_zip_url: download and prepare configuration and data\n\
                                from zip url file.\n\
\n\
    create_ew_env_from_git_repository: create Earthworm Environment having main\n\
                                       directory from a branch of a git repository.\n\
\n\
    create_ew_env_from_memphis_test: shortcut based on create_ew_env_from_zip_url for\n\
                                     creating an Earthworm Environment from Memphis Test.\n\
    create_ew_env_from_ingv_test:    shortcut based on create_ew_env_from_zip_url for\n\
                                     creating an Earthworm Environment from INGV Test.\n\
\n\
    create_ew_env_from_ingv_runconfig_branch: shortcut based on create_ew_env_from_git_repository\n\
                               for creating an Earthworm Environment from INGV git repository.\n\
\n\
    Examples:\n\
              make create_ew_env_from_scratch EW_ENV=$(HELP_EW_ENV) \n\
              make create_ew_env_from_another EW_ENV_FROM=$(HELP_EW_ENV) EW_ENV=$(HELP_EW_ENV_2) \n\
\n\
              make create_ew_env_from_zip_url \ \n\
                   ZIP_URL=http://www.isti2.com/ew/distribution/memphis_test.zip \ \n\
                   CREATE_EW_ENV_SUBDIRS=\"\" \ \n\
                   MAP_EW_ENV_SUBDIRS=\"memphis/params memphis/log memphis/data\" \ \n\
                   EW_ENV=memphis_test1\n\
\n\
              make create_ew_env_from_git_repository \ \n\
                   GIT_REP=git@gitlab.rm.ingv.it:earthworm/run_configs.git \ \n\
                   GIT_BRANCH=develop \ \n\
                   CREATE_EW_ENV_SUBDIRS="log data" \ \n\
                   MAP_EW_ENV_SUBDIRS="run_realtime/params" \ \n\
                   EW_ENV=ingv_test1\n\
\n\
$(SEPLINE)\n\
Creating tankfiles:\n\
$(SEPLINE)\n\
\n\
    create_tank:  launch script 'create_tank_from_ot_lat_lon_radius.sh'.\n\
                  Pass arguments to create_tank_from_ot_lat_lon_radius.sh by ARGS variable.\n\
\n\
    Example: make create_tank ARGS=\"2017-01-01T00:00:00 10 30 42 13 0.3 ~/ew_data\"\n\
\n\
$(SEPLINE)\n\
Deleting files: (POTENTIALLY DANGEROUS)\n\
$(SEPLINE)\n\
\n\
    ew_dangerous_clean_log: delete all files within docker host\n\
                            log directory ($(EW_ENV_LOG)).\n\
    ew_dangerous_clean_ws:  delete all files within docker host\n\
                            waveserver directories ($(EW_ENV_WS)).\n\
\n\
$(SEPLINE)\n\
Start/Stop Earthworm Docker Sandbox Containers:\n\
$(SEPLINE)\n\
\n\
    ew_run_bash:     run interactive bash shell in a new docker container.\n\
                     You can optionally run command passed by ARGS variable.\n\
    ew_run_screen:   run interactive screen shell in a new docker container.\n\
                     You can optionally run command passed by ARGS variable.\n\
\n\
    ew_startstop_bash:     run 'startstop' in an interactive bash shell\n\
                           in a new docker container for current EW_ENV.\n\
    ew_startstop_screen:   run 'startstop' in an interactive screen shell\n\
                           in a new docker container for current EW_ENV.\n\
    ew_startstop_detached: run 'startstop' in detached mode\n\
                           in a new docker container for current EW_ENV.\n\
\n\
    ew_stop_container:     stop and remove the running docker container [detached or not].\n\
\n\
    ew_startstop_screen_handling_exit: run 'startstop' in detached mode\n\
                            in a new docker container for current EW_ENV.\n\
                            Pass arguments to ew_check_process_status.sh by ARGS variable\n\
\n\
    Examples:\n\
              make EW_ENV=$(HELP_EW_ENV) ew_run_bash\n\
              make EW_ENV=$(HELP_EW_ENV) ew_run_bash ARGS=\"df -h\"\n\
              make EW_ENV=$(HELP_EW_ENV) ew_run_screen\n\
              make EW_ENV=$(HELP_EW_ENV) ew_run_screen ARGS=\"df -h\"\n\
\n\
              make EW_ENV=$(HELP_EW_ENV) ew_startstop_bash\n\
              make EW_ENV=$(HELP_EW_ENV) ew_startstop_screen\n\
              make EW_ENV=$(HELP_EW_ENV) ew_startstop_detached\n\
\n\
              make EW_ENV=$(HELP_EW_ENV) ew_stop_container\n\
\n\
              make EW_ENV=$(HELP_EW_ENV) ew_startstop_screen_handling_exit ARGS=\"tankplayer.d nopau\"\n\
              make EW_ENV=$(HELP_EW_ENV) ew_startstop_screen_handling_exit ARGS=\"tankplayer.d pau\"\n\
\n\
$(SEPLINE)\n\
Executing commands within running Earthworm Docker Sandbox Containers:\n\
$(SEPLINE)\n\
\n\
    ew_exec_bash:      run a new bash shell within the running docker container.\n\
                       You can optionally run command passed by ARGS variable.\n\
    ew_exec_screen:    run a new screen shell within the running docker container.\n\
                       You can optionally run command passed by ARGS variable.\n\
\n\
    ew_status:         run 'status' in the Earthworm running docker container.\n\
    ew_pau:            run 'pau' in the Earthworm running docker container.\n\
\n\
    ew_sniffrings_all:    run 'sniffrings' for all rings and messages except for TYPE_TRACEBUF*.\n\
    ew_tail_all_logs:     exec tail and follow all log files within\n\
                          EW_LOG directory ($(DOCKER_EW_RUN_DIR)/log).\n\
    ew_status_tankplayer: output tankplayer process status.\n\
\n\
    Examples:\n\
              make EW_ENV=$(HELP_EW_ENV) ew_exec_bash\n\
              make EW_ENV=$(HELP_EW_ENV) ew_exec_bash ARGS=\"ps aux\"\n\
              make EW_ENV=$(HELP_EW_ENV) ew_exec_bash ARGS=\"status\"\n\
              make EW_ENV=$(HELP_EW_ENV) ew_status\n\
              make EW_ENV=$(HELP_EW_ENV) ew_pau\n\
              make EW_ENV=$(HELP_EW_ENV) ew_sniffrings_all\n\
              make EW_ENV=$(HELP_EW_ENV) ew_tail_all_logs\n\
\n\
$(SEPLINE)\n\
License\n\
$(SEPLINE)\
"
	@make license

version:
	@echo "\
Earthworm Docker Sandbox $(EDS_VERSION) Copyright (C) 2020  Matteo Quintiliani\
"

license:
	@echo "\
Earthworm Docker Sandbox: a Docker tool for learning, testing, running and\n\
developing Earthworm System within enclosed environments.\n\
\n\
Copyright (C) 2020  Matteo Quintiliani - INGV - Italy\n\
Mail bug reports and suggestions to matteo.quintiliani [at] ingv.it\n\
\n\
This program is free software: you can redistribute it and/or modify\n\
it under the terms of the GNU General Public License as published by\n\
the Free Software Foundation, either version 3 of the License, or\n\
(at your option) any later version.\n\
\n\
This program is distributed in the hope that it will be useful,\n\
but WITHOUT ANY WARRANTY; without even the implied warranty of\n\
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n\
GNU General Public License for more details.\n\
\n\
You should have received a copy of the GNU General Public License\n\
along with this program.  If not, see <https://www.gnu.org/licenses/>.\
"

license_short:
	@make version
	@echo "\
This program comes with ABSOLUTELY NO WARRANTY; for details type 'make license'.\n\
This is free software, and you are welcome to redistribute it\n\
under certain conditions; type 'make license' for details.\
"

check_docker_variables:
	@if [ -z "$(DOCKER_IMAGE_NAME)" ]; then echo "ERROR: DOCKER_IMAGE_NAME must be defined. Exit."; exit 1; fi
	@if [ -z "$(DOCKER_IMAGE_VERSION)" ]; then echo "ERROR: DOCKER_IMAGE_VERSION must be defined. Exit."; exit 1; fi
	@if [ -z "$(DOCKER_CONTAINER_NAME)" ]; then echo "ERROR: DOCKER_CONTAINER_NAME must be defined. Exit."; exit 1; fi
	@if [ -z "$(NS_IMAGE_NAME)" ]; then echo "ERROR: NS_IMAGE_NAME must be defined. Exit."; exit 1; fi
	@if [ -z "$(NS_IMAGE_NAME_VERSION)" ]; then echo "ERROR: NS_IMAGE_NAME_VERSION must be defined. Exit."; exit 1; fi

check_ew_env_variables:
	@if [ -z "$(EW_ENV)" ]; then echo "ERROR: EW_ENV must be defined. (example: make EW_ENV=$(HELP_EW_ENV) <command>). Exit."; echo "SUGGESTION: run 'make list_ew_env' to see available Earthworm Environments."; make list_ew_env; exit 1; fi
	@if [ -z "$(EW_ENV_MAINDIR)" ]; then echo "ERROR: EW_ENV_MAINDIR must be defined. Exit."; exit 1; fi
	@if [ -z "$(EW_ENV_DIR)" ]; then echo "ERROR: EW_ENV_DIR must be defined. Exit."; exit 1; fi

check_zip_url_variables:
	@if [ -z "$(ZIP_URL)" ]; then echo "ERROR: ZIP_URL must be defined. Exit."; exit 1; fi
	@if [ -z "$(CREATE_EW_ENV_SUBDIRS)" ]; then echo "WARNING: CREATE_EW_ENV_SUBDIRS variable not defined."; echo "         Make sure that params, log and data directories are available in main directory."; fi
	@if [ -z "$(MAP_EW_ENV_SUBDIRS)" ]; then echo "WARNING: MAP_EW_ENV_SUBDIRS variable not defined."; echo "         Make sure that params, log and data directories are available in main directory."; fi

check_git_variables:
	@if [ -z "$(GIT_REP)" ]; then echo "ERROR: GIT_REP must be defined. Exit."; exit 1; fi
	@if [ -z "$(GIT_BRANCH)" ]; then echo "ERROR: GIT_BRANCH must be defined. Exit."; exit 1; fi

check_ew_env_subdirs:
	@if [ ! -e $(EW_ENV_MAINDIR) ]; then echo "ERROR: directory $(EW_ENV_MAINDIR) for EW_ENV_MAINDIR not found. Exit."; exit 9; fi
	@if [ ! -e $(EW_ENV_DIR) ]; then echo "ERROR: directory $(EW_ENV_DIR) not found. Exit."; exit 9; fi
	@if [ ! -e $(EW_ENV_DIR)/params ]; then echo "ERROR: directory $(EW_ENV_DIR)/params not found. Exit."; exit 9; fi
	@if [ ! -e $(EW_ENV_DIR)/log ]; then echo "ERROR: directory $(EW_ENV_DIR)/log not found. Exit."; exit 9; fi
	@if [ ! -e $(EW_ENV_DIR)/data ]; then echo "ERROR: directory $(EW_ENV_DIR)/data not found. Exit."; exit 9; fi

check_for_building: check_docker_variables $(BUILD_SOURCES)
	@if [ -z "$(EW_SVN_BRANCH)" ]; then echo "ERROR: EW_SVN_BRANCH must be defined and not empty. Exit."; exit 1; fi

check_for_creating: check_docker_variables check_ew_env_variables
	@if [ -e $(EW_ENV_DIR) ]; then echo "ERROR: directory $(EW_ENV_DIR) already exists. Exit."; exit 9; fi

check_container_is_running:
	@CONTAINER_ID=$$(docker ps -q -f name="$(DOCKER_CONTAINER_NAME)") \
		   && if [ ! -n "$${CONTAINER_ID}" ]; then echo "ERROR: container $(DOCKER_CONTAINER_NAME) is not running. Exit."; exit 9; fi

check_container_is_not_running_on_the_same_ew_env:
	@CONTAINER_ID=$$(docker ps -q  -f name=".*\.$(EW_ENV)") \
		   && if [ -n "$${CONTAINER_ID}" ]; then echo "ERROR: container $${CONTAINER_ID} is already running on the same EW_ENV=$(EW_ENV). Exit."; docker ps -f name=".*\.$(EW_ENV)"; exit 9; fi

check_container_is_not_running:
	@CONTAINER_ID=$$(docker ps -q -f name="$(DOCKER_CONTAINER_NAME)") \
		   && if [ -n "$${CONTAINER_ID}" ]; then echo "ERROR: container $(DOCKER_CONTAINER_NAME) is already running. Exit."; exit 9; fi

check_for_running: license_short check_docker_variables check_ew_env_variables check_ew_env_subdirs check_container_is_not_running check_container_is_not_running_on_the_same_ew_env

check_for_executing: license_short check_docker_variables check_ew_env_variables check_ew_env_subdirs check_container_is_running

list_ew_env:
	@if [ ! -e $(EW_ENV_MAINDIR) ]; then echo "ERROR: directory $(EW_ENV_MAINDIR) for EW_ENV_MAINDIR not found. Exit."; exit 9; fi
	@cd $(EW_ENV_MAINDIR) \
		&& echo "Available Earthworm Environments: " \
		&& echo "" \
		&& find . -mindepth 1 -maxdepth 1 -type d | sed -e "s/^[./]*/  - /" | sort \
		&& echo ""

list_images: check_for_building
	docker images $(DOCKER_IMAGE_NAME)

list_containers: check_for_building
	docker ps -f name='$(DOCKER_IMAGE_NAME)*'

build: check_for_building
	# Build docker image
	docker build -t $(NS_IMAGE_NAME_VERSION) \
		--build-arg EW_INSTALL_INSTALLATION=$(EW_INSTALL_INSTALLATION) \
		--build-arg ENV_UID=$(ENV_UID) \
		--build-arg ENV_GID=$(ENV_GID) \
		--build-arg EW_SVN_BRANCH=$(EW_SVN_BRANCH)  \
		--build-arg EW_SVN_REVISION=$(EW_SVN_REVISION) \
		--build-arg EW_ARCHITECTURE=$(EW_ARCHITECTURE) \
		--build-arg ARG_SELECTED_MODULE_LIST=$(ARG_SELECTED_MODULE_LIST) \
		--build-arg ARG_ADDITIONAL_MODULE_EW2MOLEDB=$(ARG_ADDITIONAL_MODULE_EW2MOLEDB) \
		--build-arg ARG_ADDITIONAL_MODULE_EW2OPENAPI=$(ARG_ADDITIONAL_MODULE_EW2OPENAPI) \
		-f Dockerfile . \
		2>&1 | tee build_$(DOCKER_IMAGE_VERSION).log

CARRIAGE_RETURN=""

ew_run_bash: check_for_running
	docker run $(DOCKER_USER) --rm $(OPT_RUN_I) $(OPT_RUN_T) $(OPT_RUN_D) $(DOCKER_NETWORK) --name $(DOCKER_CONTAINER_NAME) $(DOCKER_PORTS) $(DOCKER_VOLUMES) $(DOCKER_ENV_COMPLETE) $(NS_IMAGE_NAME_VERSION) \
		/bin/bash -c 'CMD="$(ARGS)" && CMD=$${CMD:-bash} && . ~/.bashrc && $${CMD}'

ew_run_screen: check_for_running
	@echo $(ARGS)
	docker run $(DOCKER_USER) --rm $(OPT_RUN_I) $(OPT_RUN_T) $(OPT_RUN_D) $(DOCKER_NETWORK) --name $(DOCKER_CONTAINER_NAME) $(DOCKER_PORTS) $(DOCKER_VOLUMES) $(DOCKER_ENV_COMPLETE) $(NS_IMAGE_NAME_VERSION) \
	bash -c "( \
		screen -d -m -S ew -s /bin/bash \
		&& screen -p 0 -S ew -X stuff \"$(ARGS)$(CARRIAGE_RETURN)\" \
		&& screen -r \
	)"

# docker run $(DOCKER_USER) --rm $(OPT_RUN_I) $(OPT_RUN_T) $(OPT_RUN_D) $(DOCKER_NETWORK) --name $(DOCKER_CONTAINER_NAME) $(DOCKER_PORTS) $(DOCKER_VOLUMES) $(DOCKER_ENV_COMPLETE) $(NS_IMAGE_NAME_VERSION) \
	# bash -c "(screen -d -m -S ew -s /bin/bash && screen -r)"

ew_exec_bash: check_for_executing
	docker exec $(OPT_RUN_I) $(OPT_RUN_T) $(OPT_RUN_D) $(DOCKER_CONTAINER_NAME) \
		/bin/bash -c 'CMD="$(ARGS)" && CMD=$${CMD:-bash} && . ~/.bashrc && $${CMD}'

ew_exec_screen: check_for_executing
	docker exec $(OPT_RUN_I) $(OPT_RUN_T) $(OPT_RUN_D) $(DOCKER_CONTAINER_NAME) \
	bash -c "( \
		screen -d -m -S ew -s /bin/bash \
		&& screen -p 0 -S ew -X stuff \"$(ARGS)$(CARRIAGE_RETURN)\" \
		&& screen -r \
	)"

ew_startstop_bash: check_for_running
	make ew_run_bash ARGS="startstop"

ew_startstop_screen: check_for_running
	make ew_run_screen ARGS="startstop"

ew_startstop_screen_handling_exit: check_for_running
	docker run $(DOCKER_USER) --rm $(OPT_RUN_I) $(OPT_RUN_T) $(OPT_RUN_D) $(DOCKER_NETWORK) --name $(DOCKER_CONTAINER_NAME) $(DOCKER_PORTS) $(DOCKER_VOLUMES) $(DOCKER_ENV_COMPLETE) $(NS_IMAGE_NAME_VERSION) \
	bash -c "( \
		screen -d -m -S ew -s /bin/bash \
		&& screen -S ew -X screen \
		&& screen -S ew -X screen \
		&& screen -p 0 -S ew -X stuff \"startstop $(CARRIAGE_RETURN)\" \
		&& screen -p 1 -S ew -X stuff \"sleep 2 && cd log && /opt/scripts/ew_sniff_all_rings_except_tracebuf_message.sh | tee sniffrings.log $(CARRIAGE_RETURN)\" \
		&& screen -p 2 -S ew -X stuff \"/opt/scripts/ew_check_process_status.sh $(ARGS) $(CARRIAGE_RETURN)\" \
		&& screen -r \
	)"

ew_startstop_detached: check_for_running
	make ew_run_bash ARGS="startstop" OPT_RUN_D=-d

ew_stop_container: check_for_executing
	docker stop $(DOCKER_CONTAINER_NAME)
	docker container rm $(DOCKER_CONTAINER_NAME)

ew_status: check_for_executing
	make EW_ENV="$(EW_ENV)" ew_exec_bash ARGS="status"

ew_pau: check_for_executing
	@echo
	@bash -c '(read -p "WARNING: Are you sure you stop Earthworm ? [Y/n] " -n 1 -r \
		&& echo "" \
		&& if [[ $$REPLY =~ ^[Y]$$ ]]; then \
		make EW_ENV="$(EW_ENV)" ew_exec_bash ARGS="pau"; \
		else \
		echo "Nothing has been done."; \
		fi)'

ew_status_tankplayer: check_for_executing
	make EW_ENV="$(EW_ENV)" ew_exec_bash ARGS="/opt/scripts/ew_check_process_status.sh"; \

ew_sniffrings_all: check_for_executing
	docker exec $(OPT_RUN_I) $(OPT_RUN_T) $(OPT_RUN_D) $(DOCKER_CONTAINER_NAME) /bin/bash -c '\
		. ~/.bashrc \
		&& echo $${RING_LIST} \
		&& sniffrings $$(/opt/scripts/ew_get_rings_list.sh) verbose 2>&1 | grep -v "TYPE_TRACEBUF" \
		'

ew_tail_all_logs: check_for_running
	docker exec $(OPT_RUN_I) $(OPT_RUN_T) $(OPT_RUN_D) $(DOCKER_CONTAINER_NAME) /bin/bash -c 'tail -f `find $(DOCKER_EW_RUN_DIR)/log -name "*.log"`'

create_ew_env_from_scratch: check_for_creating
	@mkdir -p $(EW_ENV_MAINDIR) \
		&& cd $(EW_ENV_MAINDIR) \
		&& mkdir $(EW_ENV_DIR) \
		&& cd $(EW_ENV_DIR) \
		&& mkdir params \
		&& mkdir log \
		&& mkdir data

EW_ENV_FROM_DIR=$(EW_ENV_MAINDIR)/$(EW_ENV_FROM)
create_ew_env_from_another: check_for_creating
	@if [ -z "$(EW_ENV_FROM)" ]; then echo "ERROR: EW_ENV_FROM must be defined. (example: make create_ew_env_from_another EW_ENV_FROM=$(HELP_EW_ENV) EW_ENV=$(HELP_EW_ENV_2)). Exit."; echo "SUGGESTION: run 'make list_ew_env' to see available Earthworm Environments."; make list_ew_env; exit 1; fi
	@if [ ! -e $(EW_ENV_FROM_DIR) ]; then echo "ERROR: source directory $(EW_ENV_FROM_DIR) not found. Exit."; exit 9; fi
	@cp -vR $(EW_ENV_FROM_DIR) $(EW_ENV_DIR) \
		&& echo "Earthworm Environment \"$(EW_ENV_DIR)\" from \"$(EW_ENV_FROM_DIR)\" has been successfully created."

create_ew_env_from_zip_url: check_for_creating check_zip_url_variables
	@echo "Trying to get zip file from $(ZIP_URL) ..."
	@mkdir -p $(EW_ENV_MAINDIR) \
		&& BASENAME_ZIP_URL="`basename $(ZIP_URL)`" \
		&& cd $(EW_ENV_MAINDIR) \
		&& if [ ! -f "$${BASENAME_ZIP_URL}" ]; then wget -N $(ZIP_URL); fi \
		&& unzip -q "$${BASENAME_ZIP_URL}" -d $(EW_ENV_DIR) \
		&& cd $(EW_ENV_DIR) \
		&& for CUR_DIR in $(CREATE_EW_ENV_SUBDIRS); do echo "Creating directory $${CUR_DIR} ..."; if [ ! -d "$${CUR_DIR}" ]; then mkdir -p "$${CUR_DIR}"; else echo "ERROR: directory $${CUR_DIR} already exists."; fi; done \
		&& for CUR_DIR in $(MAP_EW_ENV_SUBDIRS); do echo "Mapping directory $${CUR_DIR} ..."; if [ -d "$${CUR_DIR}" ]; then ln -s "$${CUR_DIR}"; else echo "ERROR: directory $${CUR_DIR} not found."; fi; done \
		&& echo "Earthworm Environment \"$(EW_ENV_DIR)\" based on $(ZIP_URL) has been successfully created."

# Short cut based on create_ew_env_from_zip_url for creating memphis_test Earthworm Environment
create_ew_env_from_memphis_test:
	make EW_ENV=$(EW_ENV) create_ew_env_from_zip_url ZIP_URL=http://www.isti2.com/ew/distribution/memphis_test.zip MAP_EW_ENV_SUBDIRS="memphis/params memphis/log memphis/data"

# Short cut based on create_ew_env_from_zip_url for creating INGV test Earthworm Environment
create_ew_env_from_ingv_test:
	make EW_ENV=$(EW_ENV) create_ew_env_from_zip_url ZIP_URL=http://ads.int.ingv.it/~ads/earthworm/ew_envs/tankplayer_ew_maindir.zip MAP_EW_ENV_SUBDIRS="tankplayer_ew_maindir/params tankplayer_ew_maindir/log tankplayer_ew_maindir/data"

create_ew_env_from_git_repository: check_for_creating check_git_variables
	@echo "Trying to create Earthworm Environment \"$(EW_ENV)\" from git repository $(GIT_REP) and branch $(GIT_BRANCH) ..."
	@cd $(EW_ENV_MAINDIR) \
		&& git clone --recursive $(GIT_REP) $(EW_ENV_DIR) \
		&& cd $(EW_ENV_DIR) \
		&& git checkout $(GIT_BRANCH) \
		&& for CUR_DIR in $(CREATE_EW_ENV_SUBDIRS); do echo "Creating directory $${CUR_DIR} ..."; if [ ! -d "$${CUR_DIR}" ]; then mkdir -p "$${CUR_DIR}"; else echo "ERROR: directory $${CUR_DIR} already exists."; fi; done \
		&& for CUR_DIR in $(MAP_EW_ENV_SUBDIRS); do echo "Mapping directory $${CUR_DIR} ..."; if [ -d "$${CUR_DIR}" ]; then ln -s "$${CUR_DIR}"; else echo "WARNING: directory $${CUR_DIR} not found."; echo "Make $${CUR_DIR} ..."; mkdir $${CUR_DIR}; fi; done \
		&& echo "Earthworm Environment \"$(EW_ENV_DIR)\" from branch $(GIT_BRANCH) in $(GIT_REP) has been successfully created."

# Short cut based on create_ew_env_from_git_repository for creating Earthworm Environment from INGV Git Repositories
create_ew_env_from_ingv_runconfig_branch:
	make EW_ENV=$(EW_ENV) create_ew_env_from_git_repository GIT_REP=git@gitlab.rm.ingv.it:earthworm/run_configs.git GIT_BRANCH=$(GIT_BRANCH) MAP_EW_ENV_SUBDIRS="run_realtime/params log data"

create_tank:
	@echo $(ARGS)
	./create_tank_from_ot_lat_lon_radius/create_tank_from_ot_lat_lon_radius.sh $(NS_IMAGE_NAME_VERSION) $(ARGS)

ew_dangerous_clean_log: check_for_running
	@echo
	@find $(EW_ENV_LOG) -type f
	@read -p "WARNING: Are you sure you want to delete all files in $(EW_ENV_LOG)? [Y/n] " -n 1 -r \
		&& echo "" \
		&& if [[ $$REPLY =~ ^[Y]$$ ]]; then \
			find $(EW_ENV_LOG) -type f -exec rm {} \; ; \
		else \
			echo "Nothing has been deleted."; \
		fi

ew_dangerous_clean_ws: check_for_running
	@echo
	@find $(EW_ENV_WS) -type f
	@read -p "WARNING: Are you sure you want to delete all files in $(EW_ENV_WS)? [Y/n] " -n 1 -r \
		&& echo "" \
		&& if [[ $$REPLY =~ ^[Y]$$ ]]; then \
			find $(EW_ENV_WS) -type f -exec rm {} \; ; \
		else \
			echo "Nothing has been deleted."; \
		fi

doc:
	make version > doc/README_2_version.md
	echo "" > doc/README_5_make_help.md
	echo "### Complete Help" >> doc/README_5_make_help.md
	echo "" >> doc/README_5_make_help.md
	echo '```' >> doc/README_5_make_help.md
	make help >> doc/README_5_make_help.md
	echo '```' >> doc/README_5_make_help.md
	echo "" >> doc/README_5_make_help.md
	echo "" > doc/README_7_license.md
	echo "### License" >> doc/README_7_license.md
	echo "" >> doc/README_7_license.md
	make license >> doc/README_7_license.md
	echo "" >> doc/README_7_license.md
	cat doc/README_*.md > README.md

build_all:
	for EW_SVN_BRANCH_BUILD in `echo $(EW_SVN_BRANCH_BUILD_LIST)`; do \
		echo "Building $${EW_SVN_BRANCH_BUILD} ..."; \
		make EW_SVN_BRANCH=$${EW_SVN_BRANCH_BUILD} EW_SVN_REVISION= ARG_ADDITIONAL_MODULE_EW2MOLEDB=no ARG_ADDITIONAL_MODULE_EW2OPENAPI=no build ; \
	done \
	&& \
	for EW_SVN_REVISION_BUILD in `echo $(EW_SVN_REVISION_BUILD_LIST)`; do \
		echo "Building $${EW_SVN_REVISION_BUILD} ..."; \
		make EW_SVN_REVISION=$${EW_SVN_REVISION_BUILD} build ; \
	done

push: check_for_building
	docker push $(NS_IMAGE_NAME_VERSION)

rm: check_for_building
	docker rm $(DOCKER_CONTAINER_NAME)

release: build
	make push -e DOCKER_IMAGE_VERSION=$(DOCKER_IMAGE_VERSION)

clean:
	@echo

# Remap more used old commands for backward compatibility
WARN_MSG_DEPRECATED_CMD="WARNING: this command is deprecated. Use the following."
ew_env_list:
	@echo $(WARN_MSG_DEPRECATED_CMD)
	make list_ew_env

image_list:
	@echo $(WARN_MSG_DEPRECATED_CMD)
	make list_images

bash:
	@echo $(WARN_MSG_DEPRECATED_CMD)
	make ew_run_bash

screen:
	@echo $(WARN_MSG_DEPRECATED_CMD)
	make ew_run_screen

run_ew_in_bash:
	@echo $(WARN_MSG_DEPRECATED_CMD)
	make ew_startstop_bash

run_ew_in_screen:
	@echo $(WARN_MSG_DEPRECATED_CMD)
	make ew_startstop_screen_handling_exit
