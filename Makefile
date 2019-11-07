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

build: $(BUILD_SOURCES)
	# Build docker image
	docker build -t $(NS_IMAGE_NAME_VERSION) --build-arg EW_INSTALL_INSTALLATION=$(EW_INSTALL_INSTALLATION) --build-arg ENV_UID=$(ENV_UID) --build-arg ENV_GID=$(ENV_GID) -f Dockerfile .

push:
	docker push $(NS_IMAGE_NAME_VERSION)

exec:
	docker exec -it $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) /bin/bash

logtail:
	docker exec -it $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) /bin/bash -c 'tail -f `find /usr/local/tomcat -name "*.log"`'

shell:
	docker run --rm -it --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION) bash

run:
	docker run --rm -it --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION)

screen:
	docker run --rm -it --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION) bash -c "(screen -d -m -S ew -s /bin/bash && screen -r)"

CARRIAGE_RETURN=""

screen_complex:
	docker run --rm -it --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION) \
	bash -c "( \
		screen -d -m -S ew -s /bin/bash \
		&& screen -S ew -X screen \
		&& screen -p 0 -S ew -X stuff \"startstop $(CARRIAGE_RETURN)\" \
		&& screen -p 1 -S ew -X stuff \"cd log && sniffrings HYPO_RING,PICK_RING,TRIG_RING,GMEW_RING verbose 2>&1 | tee sniffrings.log $(CARRIAGE_RETURN)\" \
		&& screen -r \
	)"

start:
	docker run -d --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS_IMAGE_NAME_VERSION)

stop:
	docker stop $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)
	docker container rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

status:
	docker ps -f name=$(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

rm:
	docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

release: build
	make push -e VERSION=$(VERSION)

test:
	./test_docker.sh

memphis_data:
	mkdir -p ../data && cd ../data && wget -N http://www.isti2.com/ew/distribution/memphis_test.zip && unzip memphis_test.zip && rm -f memphis_test.zip

ingv_data:
	mkdir -p ../data && cd ../data && wget -N http://ads.int.ingv.it/~ads/earthworm/data/tankplayer_ew_maindir.zip && unzip tankplayer_ew_maindir.zip && rm -f tankplayer_ew_maindir.zip && mkdir -p tankplayer_ew_testdir && rsync -av --delete tankplayer_ew_maindir/* tankplayer_ew_testdir/

default: build

clean:
