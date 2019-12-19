################################################################################
# Earthworm Docker Sandbox: a Docker tool for learning, testing and running
# Earthworm System within enclosed environments.
################################################################################
# Matteo Quintiliani - Istituto Nazionale di Geofisica e Vulcanologia - Italy
# Mail bug reports and suggestions to matteo.quintiliani [at] ingv.it
################################################################################

# Include variables from file Makefile.env
include Makefile.env

###########################################################
# Do not edit this file but set variables in Makefile.env
###########################################################

ifndef DOCKER_NAMESPACE
	DOCKER_NAMESPACE_EXT =
else
	DOCKER_NAMESPACE_EXT = $(DOCKER_NAMESPACE)/
endif

DOCKER_IMAGE_NAME ?= me-image
DOCKER_IMAGE_VERSION ?= latest
DOCKER_CONTAINER_NAME ?= me-container
DOCKER_CONTAINER_INSTANCE ?= default
DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME ?= $(DOCKER_CONTAINER_NAME)-$(DOCKER_CONTAINER_INSTANCE)

NS_IMAGE_NAME = $(DOCKER_NAMESPACE_EXT)$(DOCKER_IMAGE_NAME)
NS_IMAGE_NAME_VERSION = $(NS_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)

.PHONY: build push shell run start stop rm release test

BUILD_SOURCES = \
				./Dockerfile \
				./Makefile.env
				# ./entrypoint.sh

EW_ENV_LOG = $(EW_ENV_DIR)/log
EW_ENV_WS = $(EW_ENV_DIR)/data/waveservers

help:
	@echo "\n\
Earthworm Docker Sandbox 0.2.0\n\
Matteo Quintiliani - Istituto Nazionale di Geofisica e Vulcanologia - Italy\n\
Mail bug reports and suggestions to matteo.quintiliani [at] ingv.it\n\
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
     - params: contains Earthworm configuration files (EW_PARAMS variable)\n\
     - log: where log file are written (EW_LOG variable)\n\
     - data: where additional files are read and written (EW_DATA_DIR variable)\n\
\n\
 Available commands:\n\
\n\
     help:         display this help\n\
     build:        build Dockerfile\n\
\n\
     ew_env_list:  list available Earthworm Environments\n\
\n\
  - Commands for running/stopping a new docker container:\n\
\n\
     bash:   run bash shell in a new docker container\n\
     screen: run screen shell in a new docker container\n\
\n\
     start:  run new docker container as daemon\n\
     stop:   stop the running docker container [daemon]\n\
\n\
  - Commands executed on running docker container:\n\
\n\
     exec:       run bash shell in the running docker container\n\
     ps:         output 'docker ps' of running docker container\n\
     sniffrings: sniffrings all rings except message TYPE_TRACEBUF and TYPE_TRACEBUF2\n\
     logtail:    exec tail and follow log files in EW_LOG directory (/opt/earthworm/log)\n\
\n\
     status_tankplayer:   output tankplayer process status\n\
\n\
  - Commands for running/stopping Earthworm in docker container:\n\
\n\
     run_ew_in_bash:   run Earthworm by bash in a new docker container\n\
     run_ew_in_screen: run Earthworm by screen in a new docker container\n\
                       Pass arguments to ew_check_process_status.sh by ARGS variable\n\
\n\
                       Examples: make run_ew_in_screen ARGS=\"tankplayer.d nopau\"\n\
                                 make run_ew_in_screen ARGS=\"tankplayer.d pau\"\n\
\n\
     status:           run 'status' in the Earthworm running docker container\n\
     pau:              run 'pau' in the Earthworm running docker container\n\
\n\
  - Commands for creating Earthworm Environment based on tankplayer configuration and data test:\n\
\n\
     create_ew_env_memphis_test:   download and prepare configuration and data for Memphis Test\n\
     create_ew_env_ingv_test:      download and prepare configuration and data for INGV Test\n\
\n\
  - Commands for creating Earthworm Environment based on git repository:\n\
\n\
     create_ew_env_from_git_repository:\n\
                   create Earthworm Environment having main directory from a branch of a git repository\n\
\n\
                   Example: make create_ew_env_from_git_repository \ \n\
                                 GIT_REP=git@gitlab.rm.ingv.it:earthworm/run_configs.git \ \n\
                                 GIT_BRANCH=develop \ \n\
                                 EW_ENV=my_test_env\n\
\n\
     create_ew_env_from_ingv_runconfig_branch:\n\
                   Like command 'create_ew_env_from_git_repository' and moreover,\n\
                   set subdirectories params,log and data from ingv repository 'earthworm/run_configs'\n\
\n\
                   Example: make create_ew_env_from_ingv_runconfig_branch \ \n\
                                 GIT_REP=git@gitlab.rm.ingv.it:earthworm/run_configs.git \ \n\
                                 GIT_BRANCH=hew10 \ \n\
                                 EW_ENV=hew10_testdir\n\
\n\
  - Commands for creating tankfiles:\n\
\n\
     create_tank:  launch script create_tank_from_ot_lat_lon_radius.sh\n\
                   Pass arguments to create_tank_from_ot_lat_lon_radius.sh by ARGS variable\n\
\n\
                   Example: make create_tank ARGS=\"2017-01-01T00:00:00 10 30 42 13 0.3 ~/ew_data\"\n\
\n\
  - Commands for deleting files: (VERY DANGEROUS)\n\
\n\
     clean_ew_log: delete all files within log directory ($(EW_ENV_LOG))\n\
     clean_ew_ws:  delete all files within waveserver directories ($(EW_ENV_WS))\n\
"

check_docker_variables:
	@if [ -z "$(DOCKER_IMAGE_NAME)" ]; then echo "ERROR: DOCKER_IMAGE_NAME must be defined. Exit."; exit 1; fi
	@if [ -z "$(DOCKER_IMAGE_VERSION)" ]; then echo "ERROR: DOCKER_IMAGE_VERSION must be defined. Exit."; exit 1; fi
	@if [ -z "$(DOCKER_CONTAINER_NAME)" ]; then echo "ERROR: DOCKER_CONTAINER_NAME must be defined. Exit."; exit 1; fi
	@if [ -z "$(DOCKER_CONTAINER_INSTANCE)" ]; then echo "ERROR: DOCKER_CONTAINER_INSTANCE must be defined. Exit."; exit 1; fi
	@if [ -z "$(NS_IMAGE_NAME)" ]; then echo "ERROR: NS_IMAGE_NAME must be defined. Exit."; exit 1; fi
	@if [ -z "$(NS_IMAGE_NAME_VERSION)" ]; then echo "ERROR: NS_IMAGE_NAME_VERSION must be defined. Exit."; exit 1; fi

check_ew_env_variables:
	@if [ -z "$(EW_ENV)" ]; then echo "ERROR: EW_ENV must be defined. (example: make EW_ENV=myenv <command>). Exit."; echo "SUGGESTION: run 'make ew_env_list' to see available Earthworm Environments."; make ew_env_list; exit 1; fi
	@if [ -z "$(EW_ENV_MAINDIR)" ]; then echo "ERROR: EW_ENV_MAINDIR must be defined. Exit."; exit 1; fi
	@if [ -z "$(EW_ENV_DIR)" ]; then echo "ERROR: EW_ENV_DIR must be defined. Exit."; exit 1; fi

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

check_for_creating: check_docker_variables check_ew_env_variables
	@if [ -e $(EW_ENV_DIR) ]; then echo "ERROR: directory $(EW_ENV_DIR) already exists. Exit."; exit 9; fi

check_for_running: check_docker_variables check_ew_env_variables check_ew_env_subdirs build

ew_env_list:
	@if [ ! -e $(EW_ENV_MAINDIR) ]; then echo "ERROR: directory $(EW_ENV_MAINDIR) for EW_ENV_MAINDIR not found. Exit."; exit 9; fi
	@cd $(EW_ENV_MAINDIR) \
		&& echo "Available Earthworm Environments: " \
		&& echo "" \
		&& find . -depth 1 -type d | sed -e "s/^[./]*/  - /" | sort \
		&& echo ""

build: check_for_building
	# Build docker image
	docker build -t $(NS_IMAGE_NAME_VERSION) \
		--build-arg EW_INSTALL_INSTALLATION=$(EW_INSTALL_INSTALLATION) \
		--build-arg ENV_UID=$(ENV_UID) \
		--build-arg ENV_GID=$(ENV_GID) \
		--build-arg EW_SVN_BRANCH=$(EW_SVN_BRANCH)  \
		--build-arg EW_SVN_REVISION=$(EW_SVN_REVISION) \
		--build-arg ARG_SELECTED_MODULE_LIST=$(ARG_SELECTED_MODULE_LIST) \
		-f Dockerfile .

bash: check_for_running
	docker run $(DOCKER_USER) --rm -it $(DOCKER_NETWORK) --name $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION) /bin/bash

screen: check_for_running
	docker run $(DOCKER_USER) --rm -it $(DOCKER_NETWORK) --name $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION) bash -c "(screen -d -m -S ew -s /bin/bash && screen -r)"

run: check_for_running
	docker run $(DOCKER_USER) --rm -it $(DOCKER_NETWORK) --name $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION)

exec: check_for_running
	docker exec -it $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME) /bin/bash

bash_args: check_for_running
	docker run $(DOCKER_USER) --rm -it $(DOCKER_NETWORK) --name $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION) /bin/bash -c ". ~/.bashrc && $(ARGS)"

CARRIAGE_RETURN=""

run_ew_in_bash: check_for_running
	docker run $(DOCKER_USER) --rm -it $(DOCKER_NETWORK) --name $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION) \
	bash -c ". ~/.bashrc && startstop"

run_ew_in_screen: check_for_running
	@echo $(ARGS)
	docker run $(DOCKER_USER) --rm -it $(DOCKER_NETWORK) --name $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION) \
	bash -c "( \
		screen -d -m -S ew -s /bin/bash \
		&& screen -S ew -X screen \
		&& screen -S ew -X screen \
		&& screen -p 0 -S ew -X stuff \"startstop $(CARRIAGE_RETURN)\" \
		&& screen -p 1 -S ew -X stuff \"sleep 2 && cd log && /opt/earthworm/scripts/ew_sniff_all_rings_except_tracebuf_message.sh | tee sniffrings.log $(CARRIAGE_RETURN)\" \
		&& screen -p 2 -S ew -X stuff \"/opt/earthworm/scripts/ew_check_process_status.sh $(ARGS) $(CARRIAGE_RETURN)\" \
		&& screen -r \
	)"

status: check_for_running
	docker exec -it $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME) \
		bash -c ". ~/.bashrc && status"

pau: check_for_running
	@echo
	@read -p "WARNING: Are you sure you stop Earthworm ? [Y/n] " -n 1 -r \
		&& echo "" \
		&& if [[ $$REPLY =~ ^[Y]$$ ]]; then \
		docker exec -it $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME) bash -c ". ~/.bashrc && pau"; \
		else \
		echo "Nothing has been done."; \
		fi

status_tankplayer: check_for_running
	docker exec -it $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME) \
		bash -c ". ~/.bashrc && /opt/earthworm/scripts/ew_check_process_status.sh"

start: check_for_running
	docker run $(DOCKER_USER) -d $(DOCKER_NETWORK) --name $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION)

stop: check_for_running
	docker stop $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME)
	docker container rm $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME)

ps: check_for_running
	docker ps -f name=$(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME)

sniffrings: check_for_running
	docker exec -it $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME) /bin/bash -c '\
		. ~/.bashrc \
		&& echo $${RING_LIST} \
		&& sniffrings $$(/opt/earthworm/scripts/ew_get_rings_list.sh) verbose 2>&1 | grep -v "TYPE_TRACEBUF" \
		'

logtail: check_for_running
	docker exec -it $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME) /bin/bash -c 'tail -f `find /opt/earthworm/log -name "*.log"`'

push: check_for_building
	docker push $(NS_IMAGE_NAME_VERSION)

rm: check_for_building
	docker rm $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME)

release: build
	make push -e DOCKER_IMAGE_VERSION=$(DOCKER_IMAGE_VERSION)

create_ew_env_memphis_test: check_for_creating
	@mkdir -p $(EW_ENV_MAINDIR) \
		&& cd $(EW_ENV_MAINDIR) \
		&& if [ ! -f memphis_test.zip ]; then wget -N http://www.isti2.com/ew/distribution/memphis_test.zip; fi \
		&& unzip memphis_test.zip -d $(EW_ENV_DIR) \
		&& cd $(EW_ENV_DIR) \
		&& mv memphis/* . \
		&& rmdir memphis \
		&& docker run $(DOCKER_USER) --rm -it $(DOCKER_NETWORK) --name $(DOCKER_CONTAINER_COMPLETE_INSTANCE_NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION) /bin/bash -c "cd params && sed -i'.bak' -e "s/EW_INST_ID/EW_INSTALLATION/g" *.desc" \
		&& echo "Earthworm Environment \"$(EW_ENV_DIR)\" based on Memphis Test has been successfully created."

create_ew_env_ingv_test: check_for_creating
	@mkdir -p $(EW_ENV_MAINDIR) \
		&& cd $(EW_ENV_MAINDIR) \
		&& if [ ! -f tankplayer_ew_maindir.zip ]; then wget -N http://ads.int.ingv.it/~ads/earthworm/ew_envs/tankplayer_ew_maindir.zip; fi \
		&& unzip tankplayer_ew_maindir.zip -d $(EW_ENV_DIR) \
		&& cd $(EW_ENV_DIR) \
		&& mv tankplayer_ew_maindir/* . \
		&& rmdir tankplayer_ew_maindir \
		&& echo "Earthworm Environment \"$(EW_ENV_DIR)\" based on INGV Test has been successfully created."

create_ew_env_from_git_repository: check_for_creating check_git_variables
	@echo "Trying to create Earthworm Environment \"$(EW_ENV)\" from git repository $(GIT_REP) and branch $(GIT_BRANCH) ..."
	@cd $(EW_ENV_MAINDIR) \
		&& git clone --recursive --single-branch --branch $(GIT_BRANCH) $(GIT_REP) $(EW_ENV_DIR) \
		&& cd $(EW_ENV_DIR) \
		&& echo "Earthworm Environment \"$(EW_ENV_DIR)\" from branch $(GIT_BRANCH) in $(GIT_REP) has been successfully created."

create_ew_env_from_ingv_runconfig_branch: create_ew_env_from_git_repository
	@cd $(EW_ENV_MAINDIR) \
		&& cd $(EW_ENV_DIR) \
		&& ln -s run_realtime/params \
		&& mkdir log \
		&& mkdir data

create_tank:
	@echo $(ARGS)
	./create_tank_from_ot_lat_lon_radius/create_tank_from_ot_lat_lon_radius.sh $(NS_IMAGE_NAME_VERSION) $(ARGS)

clean_ew_log: check_for_running
	@echo
	@find $(EW_ENV_LOG) -type f
	@read -p "WARNING: Are you sure you want to delete all files in $(EW_ENV_LOG)? [Y/n] " -n 1 -r \
		&& echo "" \
		&& if [[ $$REPLY =~ ^[Y]$$ ]]; then \
			find $(EW_ENV_LOG) -type f -exec rm {} \; ; \
		else \
			echo "Nothing has been deleted."; \
		fi

clean_ew_ws: check_for_running
	@echo
	@find $(EW_ENV_WS) -type f
	@read -p "WARNING: Are you sure you want to delete all files in $(EW_ENV_WS)? [Y/n] " -n 1 -r \
		&& echo "" \
		&& if [[ $$REPLY =~ ^[Y]$$ ]]; then \
			find $(EW_ENV_WS) -type f -exec rm {} \; ; \
		else \
			echo "Nothing has been deleted."; \
		fi

clean:
