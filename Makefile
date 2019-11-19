# Include variables from file Makefile.env
include Makefile.env

###########################################################
# Do not edit this file but set variables in Makefile.env
###########################################################

# NS ?= me
ifndef NS
	NS_EXT =
else
	NS_EXT = $(NS)/
endif

IMAGE_NAME ?= me-image
VERSION ?= latest
CONTAINER_NAME ?= me-container
CONTAINER_INSTANCE ?= default

NS_IMAGE_NAME = $(NS_EXT)$(IMAGE_NAME)
NS_IMAGE_NAME_VERSION = $(NS_IMAGE_NAME):$(VERSION)

.PHONY: build push shell run start stop rm release test

BUILD_SOURCES = \
				./Dockerfile 
				# ./entrypoint.sh

MAINDIR_LOGDIR = $(MAINDIR_TEST)/log
MAINDIR_WSDIR = $(MAINDIR_TEST)/data/waveservers

help:
	@echo ""
	@echo "Earthworm Docker Sandbox 0.2.0"
	@echo "Matteo Quintiliani - Istituto Nazionale di Geofisica e Vulcanologia - Italy"
	@echo "Mail bug reports and suggestions to <matteo.quintiliani@ingv.it>."
	@echo ""
	@echo "  Syntax: make <command>"
	@echo ""
	@echo "  Available commands:"
	@echo ""
	@echo "          help:   display this help"
	@echo "          build:  build Dockerfile"
	@echo ""
	@echo "      --- Commands for running/stopping a new docker container:"
	@echo ""
	@echo "          bash:   run bash shell in a new docker container"
	@echo "          screen: run screen shell in a new docker container"
	@echo ""
	@echo "          start:  run new docker container as daemon"
	@echo "          stop:   stop the running docker container [daemon]"
	@echo ""
	@echo "      --- Commands executed on running docker container:"
	@echo ""
	@echo "          exec:       run bash shell in the running docker container"
	@echo "          ps:         output 'docker ps' of running docker container"
	@echo "          sniffrings: sniffrings all rings except message TYPE_TRACEBUF and TYPE_TRACEBUF2"
	@echo "          logtail:    exec tail and follow log files in EW_LOG directory (/opt/earthworm/log)"
	@echo ""
	@echo "          status_tankplayer:   output tankplayer process status"
	@echo ""
	@echo "      --- Commands for running/stopping Earthworm in docker container:"
	@echo ""
	@echo "          run_ew_in_bash:   run Earthworm by bash in a new docker container"
	@echo "          run_ew_in_screen: run Earthworm by screen in a new docker container"
	@echo "                            Pass arguments by ARGS variable to ew_check_process_status.sh"
	@echo "                            Examples: make run_ew_in_screen ARGS=\"tankplayer.d nopau\""
	@echo "                                      make run_ew_in_screen ARGS=\"tankplayer.d pau\""
	@echo "          status:           run 'status' in the Earthworm running docker container"
	@echo "          pau:              run 'pau' in the Earthworm running docker container"
	@echo ""
	@echo "      --- Commands for creating tankplayer data test:"
	@echo ""
	@echo "          data_create_memphis_test:   download and prepare data for Memphis Test"
	@echo "          data_create_ingv_test:      download and prepare data for INGV Test"
	@echo ""
	@echo "          create_tank:  launch script create_tank_from_ot_lat_lon_radius.sh"
	@echo "                        Pass arguments by ARGS variable "
	@echo "                        Example: make create_tank ARGS=\"2017-01-01T00:00:00 10 30 42 13 0.3 ../data\""
	@echo ""
	@echo "      --- Commands for deleting files: (VERY DANGEROUS)"
	@echo ""
	@echo "          clean_ew_log:               delete all files within log directory ($(MAINDIR_LOGDIR))"
	@echo "          clean_ew_ws:                delete all files within waveserver directories ($(MAINDIR_WSDIR))"
	@echo ""

build: $(BUILD_SOURCES)
	# Build docker image
	docker build -t $(NS_IMAGE_NAME_VERSION) --build-arg EW_INSTALL_INSTALLATION=$(EW_INSTALL_INSTALLATION) --build-arg ENV_UID=$(ENV_UID) --build-arg ENV_GID=$(ENV_GID) -f Dockerfile .

bash:
	docker run $(DOCKER_USER) --rm -it --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION) /bin/bash

screen:
	docker run $(DOCKER_USER) --rm -it --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION) bash -c "(screen -d -m -S ew -s /bin/bash && screen -r)"

run:
	docker run $(DOCKER_USER) --rm -it --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION)

exec:
	docker exec -it $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) /bin/bash

CARRIAGE_RETURN=""

run_ew_in_bash:
	docker run $(DOCKER_USER) --rm -it --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION) \
	bash -c ". ~/.bashrc && startstop"

run_ew_in_screen:
	@echo $(ARGS)
	docker run $(DOCKER_USER) --rm -it --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION) \
	bash -c "( \
		screen -d -m -S ew -s /bin/bash \
		&& screen -S ew -X screen \
		&& screen -S ew -X screen \
		&& screen -p 0 -S ew -X stuff \"startstop $(CARRIAGE_RETURN)\" \
		&& screen -p 1 -S ew -X stuff \"cd log && sniffrings HYPO_RING,PICK_RING,TRIG_RING,GMEW_RING verbose 2>&1 | tee sniffrings.log $(CARRIAGE_RETURN)\" \
		&& screen -p 2 -S ew -X stuff \"/opt/earthworm/scripts/ew_check_process_status.sh $(ARGS) $(CARRIAGE_RETURN)\" \
		&& screen -r \
	)"

status:
	docker exec -it $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) \
		bash -c ". ~/.bashrc && status"

pau:
	@echo
	@read -p "WARNING: Are you sure you stop Earthworm ? [Y/n] " -n 1 -r \
		&& echo "" \
		&& if [[ $$REPLY =~ ^[Y]$$ ]]; then \
		docker exec -it $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) bash -c ". ~/.bashrc && pau"; \
		else \
		echo "Nothing has been done."; \
		fi

status_tankplayer:
	docker exec -it $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) \
		bash -c ". ~/.bashrc && /opt/earthworm/scripts/ew_check_process_status.sh"

start:
	docker run $(DOCKER_USER) -d --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION)

stop:
	docker stop $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)
	docker container rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

ps:
	docker ps -f name=$(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

sniffrings:
	docker exec -it $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) /bin/bash -c '\
		. ~/.bashrc \
		&& echo $${RING_LIST} \
		&& sniffrings $$(/opt/earthworm/scripts/ew_get_rings_list.sh) verbose 2>&1 | grep -v "TYPE_TRACEBUF" \
		'

logtail:
	docker exec -it $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) /bin/bash -c 'tail -f `find /opt/earthworm/log -name "*.log"`'

push:
	docker push $(NS_IMAGE_NAME_VERSION)

rm:
	docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

release: build
	make push -e VERSION=$(VERSION)

data_create_memphis_test:
	mkdir -p ../data && cd ../data && wget -N http://www.isti2.com/ew/distribution/memphis_test.zip && unzip memphis_test.zip && rm -f memphis_test.zip

data_create_ingv_test:
	mkdir -p ../data && cd ../data && wget -N http://ads.int.ingv.it/~ads/earthworm/data/tankplayer_ew_maindir.zip && unzip tankplayer_ew_maindir.zip && rm -f tankplayer_ew_maindir.zip && mkdir -p tankplayer_ew_testdir && rsync -av --delete tankplayer_ew_maindir/* tankplayer_ew_testdir/

create_tank:
	@echo $(ARGS)
	./create_tank_from_ot_lat_lon_radius/create_tank_from_ot_lat_lon_radius.sh $(ARGS)

clean_ew_log:
	@echo
	@find $(MAINDIR_LOGDIR) -type f
	@read -p "WARNING: Are you sure you want to delete all files in $(MAINDIR_LOGDIR)? [Y/n] " -n 1 -r \
		&& echo "" \
		&& if [[ $$REPLY =~ ^[Y]$$ ]]; then \
			find $(MAINDIR_LOGDIR) -type f -exec rm {} \; ; \
		else \
			echo "Nothing has been deleted."; \
		fi

clean_ew_ws:
	@echo
	@find $(MAINDIR_WSDIR) -type f
	@read -p "WARNING: Are you sure you want to delete all files in $(MAINDIR_WSDIR)? [Y/n] " -n 1 -r \
		&& echo "" \
		&& if [[ $$REPLY =~ ^[Y]$$ ]]; then \
			find $(MAINDIR_WSDIR) -type f -exec rm {} \; ; \
		else \
			echo "Nothing has been deleted."; \
		fi

clean:
