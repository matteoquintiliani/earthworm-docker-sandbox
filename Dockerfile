################################################################################
# Earthworm Docker Sandbox: a Docker tool for learning, testing and running
# Earthworm System within enclosed environments.
################################################################################
# Matteo Quintiliani - Istituto Nazionale di Geofisica e Vulcanologia - Italy
# Mail bug reports and suggestions to matteo.quintiliani [at] ingv.it
################################################################################

FROM debian:buster-slim

LABEL maintainer="Matteo Quintiliani <matteo.quintiliani@ingv.it>"

# Main variables
ENV INITRD No
ENV FAKE_CHROOT 1
ENV DEBIAN_FRONTEND=noninteractive

ENV EW_INSTALL_HOME="/opt"
ENV EW_INSTALL_VERSION="earthworm"
ENV EW_INSTALL_BITS=64
ENV EW_RUN_DIR="${EW_INSTALL_HOME}/${EW_INSTALL_VERSION}"

# Set bash as shell
SHELL ["/bin/bash", "-c"]

# Set 'root' pwd
RUN echo root:toor | chpasswd

# Install necessary packages
RUN apt-get clean \
		&& apt-get update \
		&& apt-get install -y \
			procps \
			less \
			vim \
			subversion \
			git \
			make \
			gcc \
			gfortran \
			screen \
		&& apt-get clean

# Set .bashrc for root user
RUN echo "" >> /root/.bashrc \
     && echo "##################################" >> /root/.bashrc \
     && echo "alias ll='ls -l --color'" >> /root/.bashrc \
     && echo "" >> /root/.bashrc \
     && echo "export LC_ALL=\"C\"" >> /root/.bashrc \
     && echo "" >> /root/.bashrc \
	 && echo "export EW_INSTALL_HOME=\"${EW_INSTALL_HOME}\"" >> /root/.bashrc \
	 && echo "export EW_INSTALL_VERSION=\"${EW_INSTALL_VERSION}\"" >> /root/.bashrc \
	 && echo "export EW_INSTALL_BITS=${EW_INSTALL_BITS}" >> /root/.bashrc \
	 && echo "export EW_RUN_DIR=\"${EW_INSTALL_HOME}/${EW_INSTALL_VERSION}\"" >> /root/.bashrc \
     && echo "" >> /root/.bashrc \
     && echo "caption always" >> /root/.screenrc \
	 && echo "caption string '%{+b b}%H: %{= .W.} %{b}%D %d-%M %{r}%c %{k}%?%F%{.B.}%?%2n%? [%h]%? (%w)'" >> /root/.screenrc

# Set default working directory
WORKDIR ${EW_INSTALL_HOME}

# Default Earthworm Subversion Branch is 'trunk'
ARG EW_SVN_BRANCH=trunk
# Default Earthworm Subversion Revision is empty, that stands for last revision of EW_SVN_BRANCH
ARG EW_SVN_REVISION=

# Checkout necessary Earthworm repository directories
RUN \
		if [ -z ${EW_SVN_REVISION} ]; \
		then EW_CO_SVN_REVISION=; \
		else EW_CO_SVN_REVISION=@${EW_SVN_REVISION}; \
		fi \
		&& svn checkout svn://svn.isti.com/earthworm/${EW_SVN_BRANCH}${EW_CO_SVN_REVISION} ${EW_RUN_DIR} \
		&& cp ${EW_RUN_DIR}/environment/earthworm.d ${EW_RUN_DIR}/environment/earthworm_global.d ${EW_RUN_DIR}/params/

# Temporary fix for cosmos0putaway.c
RUN \
		sed -i'.bak' -e 's/COSMOSLINELEN/5000/g' ${EW_RUN_DIR}/src/libsrc/util/cosmos0putaway.c

# Require compiling at least 'libsrc', 'system_control' and 'diagnostic_tools'
ENV REQUIRED_GROUP_MODULE_LIST=" \
libsrc \
system_control \
diagnostic_tools \
"

# Compile required group modules
RUN \
		. ${EW_RUN_DIR}/environment/ew_linux.bash \
		&& for GROUP_MODULE in ${REQUIRED_GROUP_MODULE_LIST}; do \
			echo "=== Compiling required group module ${GROUP_MODULE} ..." && \
			cd ${EW_RUN_DIR}/src && \
			if [ ! -d ${GROUP_MODULE} ]; then echo "ERROR: ${GROUP_MODULE} not found. Exit."; exit 1; fi && \
			cd ${GROUP_MODULE} && \
			if [ -f makefile.unix ]; then make -f makefile.unix; else make unix; fi \
		done;

# Default ARG_SELECTED_MODULE_LIST is empty. Compile all Earthworm modules. Otherwise only in ARG_SELECTED_MODULE_LIST.
ARG ARG_SELECTED_MODULE_LIST=

# Compile modules
RUN \
		. ${EW_RUN_DIR}/environment/ew_linux.bash \
		&& if [ -z "${ARG_SELECTED_MODULE_LIST}" ]; \
		then cd ${EW_RUN_DIR}/src &&  make unix; \
		else for MODULE in ${ARG_SELECTED_MODULE_LIST}; do \
			echo "=== Compiling ${MODULE} ..." && \
			DIRNAME_MODULE="`dirname ${MODULE}`" && \
			BASENAME_MODULE="`basename ${MODULE}`" && \
			cd ${EW_RUN_DIR}/src && \
			if [ ! -d ${DIRNAME_MODULE} ]; then echo "ERROR: module directory ${DIRNAME_MODULE} not found. Exit."; exit 1; fi && \
			cd ${DIRNAME_MODULE} && \
			cd ${BASENAME_MODULE} && \
			make -f makefile.unix; \
		done; \
		fi;

##########################################################
# Compile ew2openapi
##########################################################
RUN apt-get clean \
		&& apt-get update \
		&& apt-get install -y \
			libcurl4-openssl-dev \
			cmake \
			dh-autoreconf \
		&& apt-get clean

RUN \
		cd ${EW_RUN_DIR} \
		&& git clone --recursive https://gitlab.rm.ingv.it/earthworm/ew2openapi.git

COPY ./random_seed.patch ${EW_RUN_DIR}/ew2openapi/json-c/
COPY ./ew2openapi.patch ${EW_RUN_DIR}/ew2openapi/

RUN \
		. ${EW_RUN_DIR}/environment/ew_linux.bash \
		&& cd ${EW_RUN_DIR}/ew2openapi \
		&& cd ./rabbitmq-c \
		&& mkdir build \
		&& cd build \
		&& cmake -DENABLE_SSL_SUPPORT=OFF .. \
		&& cmake --build . \
		&& cd ${EW_RUN_DIR}/ew2openapi \
		&& cd ./json-c \
		&& patch < random_seed.patch \
		&& sh autogen.sh \
		&& ./configure --prefix=`pwd`/build \
		&& make \
		&& make install \
		&& cd ${EW_RUN_DIR}/ew2openapi \
		&& patch -p1 < ew2openapi.patch \
		&& make -f makefile.unix static
##########################################################

# Create EW_LOG
RUN \
	mkdir ${EW_RUN_DIR}/log

# Set default working directory
WORKDIR ${EW_RUN_DIR}

# Set User and Group variabls
ENV GROUP_NAME=ew
ENV USER_NAME=ew
ENV HOMEDIR_USER=/home/${USER_NAME}

# Set default User and Group id from arguments
# If UID and/or GID are equal to zero then new user and/or group are created
ARG ENV_UID=0
ARG ENV_GID=0

RUN echo ENV_UID=${ENV_UID}
RUN echo ENV_GID=${ENV_GID}

RUN \
		if [ ${ENV_UID} -eq 0 ] || [ ${ENV_GID} -eq 0 ]; \
		then \
			echo ""; \
			echo "WARNING: when passing UID or GID equal to zero, new user and/or group are created."; \
			echo "         On Linux, if you run docker image by different UID or GID you could not able to write in docker mount data directory."; \
			echo ""; \
		fi

# Check if GID already exists
RUN cat /etc/group
RUN \
		if [ ${ENV_GID} -eq 0 ]; \
		then \
			addgroup --system ${GROUP_NAME}; \
		elif grep -q -e "[^:][^:]*:[^:][^:]*:${ENV_GID}:.*$" /etc/group; \
		then \
			GROUP_NAME_ALREADY_EXISTS=$(grep  -e "[^:][^:]*:[^:][^:]*:${ENV_GID}:.*$" /etc/group | cut -f 1 -d':'); \
			echo "GID ${ENV_GID} already exists with group name ${GROUP_NAME_ALREADY_EXISTS}"; \
			groupmod -n ${GROUP_NAME} ${GROUP_NAME_ALREADY_EXISTS}; \
		else \
			echo "GID ${ENV_GID} does not exist"; \
			addgroup --gid ${ENV_GID} --system ${GROUP_NAME}; \
		fi

# Check if UID already exists
RUN cat /etc/passwd
RUN \
		if [ ${ENV_UID} -eq 0 ]; \
		then \
			useradd --system -d ${HOMEDIR_USER} -g ${GROUP_NAME} -s /bin/bash ${USER_NAME}; \
		elif grep -q -e "[^:][^:]*:[^:][^:]*:${ENV_UID}:.*$" /etc/passwd; \
		then \
			USER_NAME_ALREADY_EXISTS=$(grep  -e "[^:][^:]*:[^:][^:]*:${ENV_UID}:.*$" /etc/passwd | cut -f 1 -d':'); \
			echo "UID ${ENV_UID} already exists with user name ${USER_NAME_ALREADY_EXISTS}"; \
			usermod -d ${HOMEDIR_USER} -g ${ENV_GID} -l ${USER_NAME} ${USER_NAME_ALREADY_EXISTS}; \
		else \
			echo "UID ${ENV_UID} does not exist"; \
			useradd --system -u ${ENV_UID} -d ${HOMEDIR_USER} -g ${ENV_GID} -G ${GROUP_NAME} -s /bin/bash ${USER_NAME}; \
		fi
			# adduser -S -h ${HOMEDIR_USER} -G ${GROUP_NAME} -s /bin/bash ${USER_NAME}; \
			# adduser --uid ${ENV_UID} --home ${HOMEDIR_USER} --gid ${ENV_GID} --shell /bin/bash ${USER_NAME}; \

RUN mkdir ${HOMEDIR_USER}

RUN mkdir -p ${EW_RUN_DIR}/OUTPUT
RUN mkdir -p ${EW_RUN_DIR}/scripts

COPY ./scripts/ew_get_rings_list.sh ${EW_RUN_DIR}/scripts
COPY ./scripts/ew_sniff_all_rings_except_tracebuf_message.sh ${EW_RUN_DIR}/scripts
COPY ./scripts/ew_check_process_status.sh ${EW_RUN_DIR}/scripts

##########################################################
# RUN apt-get clean \
#		&& apt-get update \
#		&& apt-get install -y \
#			mariadb-client-10.3
##########################################################

RUN chown -R ${USER_NAME}:${GROUP_NAME} ${EW_RUN_DIR}

# Set EW_INSTALL_INSTALLATION and EW_INST_ID
ARG EW_INSTALL_INSTALLATION="INST_UNKNOWN"
RUN \
	 echo "export EW_INSTALL_INSTALLATION=\"${EW_INSTALL_INSTALLATION}\"" >> /root/.bashrc \
	 && echo "export EW_INSTALLATION=\"${EW_INSTALL_INSTALLATION}\"" >> /root/.bashrc \
	 && echo "export EW_INST_ID=\"${EW_INSTALL_INSTALLATION}\"" >> /root/.bashrc \
	 && echo "" >> /root/.bashrc \
	 && echo ". ${EW_RUN_DIR}/environment/ew_linux.bash" >> /root/.bashrc \
	 && echo "" >> /root/.bashrc

RUN cp /root/.bashrc ${HOMEDIR_USER}/
RUN cp /root/.screenrc ${HOMEDIR_USER}/

RUN chown -R ${USER_NAME}:${GROUP_NAME} ${HOMEDIR_USER}

USER ${USER_NAME}:${GROUP_NAME}
