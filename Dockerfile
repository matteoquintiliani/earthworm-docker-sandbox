# Dockerfile for running Earthworm on Memphis Test
# http://www.isti2.com/ew/distribution/memphis_test.zip

# FROM ubuntu:14.04.1
FROM debian:buster-slim

# Authors: Matteo Quintiliani

LABEL maintainer="Matteo Quintiliani <matteo.quintiliani@ingv.it>"

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

# Set .bashrc
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
	 && echo ". ${EW_RUN_DIR}/environment/ew_linux.bash" >> /root/.bashrc \
     && echo "" >> /root/.bashrc \
     && echo "caption always" >> /root/.screenrc \
	 && echo "caption string '%{+b b}%H: %{= .W.} %{b}%D %d-%M %{r}%c %{k}%?%F%{.B.}%?%2n%? [%h]%? (%w)'" >> /root/.screenrc

# Set default working directory
WORKDIR ${EW_INSTALL_HOME}

# Checkout necessary Earthworm repository directories
RUN \
		svn checkout --depth empty svn://svn.isti.com/earthworm/trunk ${EW_RUN_DIR} \
		&& cd ${EW_RUN_DIR} \
		&& svn update --set-depth infinity include  \
		&& svn update --set-depth infinity lib \
		&& svn update --set-depth empty bin \
		&& svn update --set-depth infinity environment \
		&& svn update --set-depth infinity params \
		&& svn update --set-depth empty src \
		&& svn update --set-depth infinity src/libsrc \
		&& cp ${EW_RUN_DIR}/environment/earthworm.d ${EW_RUN_DIR}/environment/earthworm_global.d ${EW_RUN_DIR}/params/

# Temporary fix for cosmos0putaway.c
RUN \
		sed -i'.bak' -e 's/COSMOSLINELEN/5000/g' ${EW_RUN_DIR}/src/libsrc/util/cosmos0putaway.c

# Compile Earthworm libraries
RUN \
		. ${EW_RUN_DIR}/environment/ew_linux.bash \
		&& cd ${EW_RUN_DIR}/src/libsrc \
		&& make -f makefile.unix

# Compile system_control
RUN \
		. ${EW_RUN_DIR}/environment/ew_linux.bash \
		&& cd ${EW_RUN_DIR} \
		&& cd src \
		&& svn up system_control \
		&& cd system_control \
		&& make unix

ENV MODULE_LIST=" \
reporting/statmgr \
reporting/diskmgr \
reporting/copystatus \
seismic_processing/pick_ew \
seismic_processing/binder_ew \
seismic_processing/eqproc \
seismic_processing/eqbuf \
seismic_processing/eqcoda \
seismic_processing/eqverify \
seismic_processing/eqassemble \
seismic_processing/hyp2000 \
seismic_processing/hyp2000_mgr \
seismic_processing/localmag \
seismic_processing/gmew \
seismic_processing/carlstatrig \
seismic_processing/carlsubtrig \
seismic_processing/wftimefilter \
seismic_processing/pkfilter \
archiving/wave_serverV \
archiving/tankplayer \
archiving/trig2disk \
archiving/tankplayer_tools \
data_exchange/ew2file \
data_exchange/scn_convert \
data_exchange/slink2ew \
data_sources/nmxptool \
diagnostic_tools/sniffwave \
diagnostic_tools/sniffring \
diagnostic_tools/sniffrings \
diagnostic_tools/gaplist \
"

# Compile other modules
RUN \
		. ${EW_RUN_DIR}/environment/ew_linux.bash \
		&& for MODULE in ${MODULE_LIST}; do \
			echo "Compiling ${MODULE} ..." && \
			DIRNAME_MODULE="`dirname ${MODULE}`" && \
			BASENAME_MODULE="`basename ${MODULE}`" && \
			cd ${EW_RUN_DIR}/src && \
			if [ ! -d ${DIRNAME_MODULE} ]; then svn up --set-depth empty ${DIRNAME_MODULE} else echo "NOTICE: ${DIRNAME_MODULE} already exists."; fi && \
			cd ${DIRNAME_MODULE} && \
			svn up ${BASENAME_MODULE} && \
			cd ${BASENAME_MODULE} && \
			make -f makefile.unix; \
		done;

# Compile third modules
RUN \
		. ${EW_RUN_DIR}/environment/ew_linux.bash \
		&& cd ${EW_RUN_DIR}/src \
		&& cd archiving \
		&& git clone https://gitlab.rm.ingv.it/earthworm/arcto3g.git \
		&& cd arcto3g \
		&& make -f makefile.unix

# Create EW_LOG
RUN \
	mkdir ${EW_RUN_DIR}/log

# Set default working directory
WORKDIR ${EW_RUN_DIR}

# Set EW_INSTALL_INSTALLATION and EW_INST_ID
ARG EW_INSTALL_INSTALLATION="INST_UNKNOWN"
RUN \
	 echo "export EW_INSTALL_INSTALLATION=\"${EW_INSTALL_INSTALLATION}\"" >> /root/.bashrc \
	 && echo "export EW_INSTALLATION=\"${EW_INSTALL_INSTALLATION}\"" >> /root/.bashrc \
	 && echo "export EW_INST_ID=\"${EW_INSTALL_INSTALLATION}\"" >> /root/.bashrc

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

RUN cp /root/.bashrc ${HOMEDIR_USER}/
RUN cp /root/.screenrc ${HOMEDIR_USER}/

RUN mkdir -p /opt/OUTPUT
RUN chown -R ${USER_NAME}:${GROUP_NAME} /opt/OUTPUT
RUN chown -R ${USER_NAME}:${GROUP_NAME} /opt/earthworm
RUN chown -R ${USER_NAME}:${GROUP_NAME} ${HOMEDIR_USER}

USER ${USER_NAME}:${GROUP_NAME}
