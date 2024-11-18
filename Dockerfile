################################################################################
# Earthworm Docker Sandbox: a Docker tool for learning, testing, running and
# developing Earthworm System within enclosed environments.
#
# Copyright (C) 2020-2023  Matteo Quintiliani - INGV - Italy
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

FROM debian:bookworm-slim

LABEL maintainer="Matteo Quintiliani <matteo.quintiliani@ingv.it>"

# Main variables
ENV INITRD No
ENV FAKE_CHROOT 1
ENV DEBIAN_FRONTEND=noninteractive

ENV EW_INSTALL_HOME="/opt"
ENV EW_INSTALL_VERSION="earthworm"
ENV EW_INSTALL_BITS=64
ENV EW_EARTHWORM_DIR="${EW_INSTALL_HOME}/${EW_INSTALL_VERSION}"
ENV EW_RUN_DIR="${EW_INSTALL_HOME}/ew_env"

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
			nano \
			git \
			make \
			gcc \
			g++ \
			gfortran \
			libtirpc-dev \
			screen \
			python3 \
			python3-pip \
			python3-venv \
		&& apt-get clean

# Default Earthworm architecture is empty. Otherwise is '_arm'.
ARG EW_ARCHITECTURE=

# gcc-multilib is needed to compiling 32-bit Earthworm version
RUN if [ "${EW_ARCHITECTURE}" != "_arm" ]; then \
		apt-get install -y \
			gcc-multilib \
		&& apt-get clean; \
	fi;

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
	 && echo "export EW_RUN_DIR=\"${EW_RUN_DIR}\"" >> /root/.bashrc \
     && echo "" >> /root/.bashrc \
     && echo "caption always" >> /root/.screenrc \
	 && echo "caption string '%{+b b}%H: %{= .W.} %{b}%D %d-%M %{r}%c %{k}%?%F%{.B.}%?%2n%? [%h]%? (%w)'" >> /root/.screenrc

# Set default working directory
WORKDIR ${EW_INSTALL_HOME}

# Default Earthworm reference is the branch 'master'
ARG EW_GIT_REF=master

# Checkout necessary Earthworm repository directories
RUN \
		git clone --recursive https://gitlab.com/seismic-software/earthworm.git ${EW_EARTHWORM_DIR} \
		&& cd ${EW_EARTHWORM_DIR} \
		&& git checkout ${EW_GIT_REF} \
		&& cd - \
		&& cp ${EW_EARTHWORM_DIR}/environment/earthworm.d ${EW_EARTHWORM_DIR}/environment/earthworm_global.d ${EW_EARTHWORM_DIR}/params/

# Set Earthworm Environment Shell Configuration File
ENV EW_FILE_ENV="${EW_EARTHWORM_DIR}/environment/ew_linux${EW_ARCHITECTURE}.bash"

# Default ARG_SELECTED_MODULE_LIST is empty. Compile all Earthworm modules.
ARG ARG_SELECTED_MODULE_LIST=

# If ARG_SELECTED_MODULE_LIST is not empty then compiling all Earthworm modules.
# Otherwise only directories in REQUIRED_GROUP_MODULE_LIST and ARG_SELECTED_MODULE_LIST will compiled.
# Required directories to compile 'libsrc', 'system_control' and 'diagnostic_tools'
ENV REQUIRED_GROUP_MODULE_LIST="libsrc system_control diagnostic_tools"
RUN \
		source ${EW_FILE_ENV} \
		&& \
		if [ -z "${ARG_SELECTED_MODULE_LIST}" ]; \
		then \
			cd ${EW_EARTHWORM_DIR}/src && make clean_bin_unix && make clean_unix && make unix && cd data_sources/nmxptool && make -f makefile.unix; \
		else \
			for GROUP_MODULE in ${REQUIRED_GROUP_MODULE_LIST}; do \
				echo "=== Compiling required group module ${GROUP_MODULE} ..." && \
				cd ${EW_EARTHWORM_DIR}/src && \
				if [ ! -d ${GROUP_MODULE} ]; then echo "ERROR: ${GROUP_MODULE} not found. Exit."; exit 1; fi && \
				cd ${GROUP_MODULE} && \
				if [ -f makefile.unix ]; then make -f makefile.unix; else make unix; fi \
			done; \
			for MODULE in ${ARG_SELECTED_MODULE_LIST}; do \
				echo "=== Compiling ${MODULE} ..." && \
				DIRNAME_MODULE="`dirname ${MODULE}`" && \
				BASENAME_MODULE="`basename ${MODULE}`" && \
				cd ${EW_EARTHWORM_DIR}/src && \
				if [ ! -d ${DIRNAME_MODULE} ]; then echo "ERROR: module directory ${DIRNAME_MODULE} not found. Exit."; exit 1; fi && \
				cd ${DIRNAME_MODULE} && \
				cd ${BASENAME_MODULE} && \
				make -f makefile.unix; \
			done; \
		fi;

# Checkout necessary Earthworm Contrib repository directories
ENV EW_EARTHWORMCONTRIB_DIR="${EW_INSTALL_HOME}/earthwormContrib"
RUN \
		git clone --recursive https://gitlab.rm.ingv.it/earthworm/earthwormcontrib.git ${EW_EARTHWORMCONTRIB_DIR}

# Compile snwgetmenu
RUN \
	    cd ${EW_EARTHWORMCONTRIB_DIR}/Menlo/src/snwgetmenu \
	    && sed -i'' -e "s/logit\.o/sema_ew\.o \$L\/logit_mt\.o/" makefile.ux \
	    && source ${EW_FILE_ENV} \
	    && make -f makefile.ux


##########################################################
# Optional compilation: ew2openapi
##########################################################
# Default ARG_ADDITIONAL_MODULE_EW2OPENAPI is "no".
ARG ARG_ADDITIONAL_MODULE_EW2OPENAPI=no
RUN if [ "${ARG_ADDITIONAL_MODULE_EW2OPENAPI}" != "yes" ]; then echo "WARNING: ew2openapi will not be installed."; else \
		apt-get clean \
		&& apt-get update \
		&& apt-get install -y \
			libcurl4-openssl-dev \
			cmake \
			dh-autoreconf \
			pkg-config \
			jq \
		&& apt-get clean \
		; fi

# Default ew2openapi reference is the branch 'master'
ARG EW2OPENAPI_GIT_REF=master

RUN if [ "${ARG_ADDITIONAL_MODULE_EW2OPENAPI}" != "yes" ]; then echo "WARNING: ew2openapi will not be installed."; else \
		git config --global http.sslverify false \
		&& git clone https://gitlab.rm.ingv.it/earthworm/ew2openapi.git \
		&& cd ew2openapi \
		&& git checkout ${EW2OPENAPI_GIT_REF} \
		&& git submodule update --init \
		&& sed -e "s/WARNFLAGS=\(.*\)$/# WARNFLAGS=\1\nWARNFLAGS=\"-Wall\"/g" ${EW_FILE_ENV} > ew2openapi_env.bash \
		&& source ew2openapi_env.bash \
		&& make -f makefile.unix static \
		&& EW_PARAMS=`pwd`/params make -f makefile.unix test_standalone \
		; fi
##########################################################

##########################################################
# Optional compilation: ew2moledb
##########################################################
# Default ARG_ADDITIONAL_MODULE_EW2MOLEDB is "no".
ARG ARG_ADDITIONAL_MODULE_EW2MOLEDB=no
RUN if [ "${ARG_ADDITIONAL_MODULE_EW2MOLEDB}" != "yes" ]; then echo "WARNING: ew2moledb will not be installed."; else \
		apt-get clean \
		&& apt-get update \
		&& apt-get install -y \
			default-libmysqlclient-dev \
		&& apt-get clean \
		; fi

# Apply changesets
#   - http://earthworm.isti.com/trac/earthworm/changeset/8125 (MYSQL_CONNECTOR_C_PATH_BUILD)
#   - http://earthworm.isti.com/trac/earthworm/changeset/8126 (LINUX_FLAGS=-lpthread -fstack-check -Wall -lm)
RUN if [ "${ARG_ADDITIONAL_MODULE_EW2MOLEDB}" != "yes" ]; then echo "WARNING: ew2moledb will not be installed."; else \
		source ${EW_FILE_ENV} \
		&& cd ${EW_EARTHWORM_DIR}/src/archiving/mole/ew2moledb \
		&& sed -i'.bak' -e 's/`$(MYSQL_CONFIG_PROG) --libs_r` $(BINARIES)/$(BINARIES) `$(MYSQL_CONFIG_PROG) --libs_r`/g' makefile.unix \
		&& sed -i'.bak' -e 's/LINUX_FLAGS=\(.*\)$/LINUX_FLAGS=\1 -lm/' makefile.unix \
		&& sed -i'.bak' -e 's=^.*\$L/libebloc\.a \$L/libebpick\.a.*$=\$L/complex_math\.o \$L/libebloc\.a \$L/libebpick\.a \\=' makefile.unix \
		&& make -f makefile.unix MYSQL_CONNECTOR_C_PATH_BUILD=/usr \
		; fi
##########################################################

# Create params, log and data subdirectories
RUN \
	mkdir ${EW_RUN_DIR} \
	&& mkdir ${EW_RUN_DIR}/params \
	&& mkdir ${EW_RUN_DIR}/log \
	&& mkdir ${EW_RUN_DIR}/data

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
		elif grep -q -e "[^:][^:]*:[^:][^:]*:${ENV_UID}:[^:][^:]*:.*$" /etc/passwd; \
		then \
			USER_NAME_ALREADY_EXISTS=$(grep  -e "[^:][^:]*:[^:][^:]*:${ENV_UID}:[^:][^:]*:.*$" /etc/passwd | cut -f 1 -d':'); \
			echo "UID ${ENV_UID} already exists with user name ${USER_NAME_ALREADY_EXISTS}"; \
			usermod -d ${HOMEDIR_USER} -g ${ENV_GID} -l ${USER_NAME} ${USER_NAME_ALREADY_EXISTS}; \
		else \
			echo "UID ${ENV_UID} does not exist"; \
			useradd --system -u ${ENV_UID} -d ${HOMEDIR_USER} -g ${ENV_GID} -G ${GROUP_NAME} -s /bin/bash ${USER_NAME}; \
		fi
			# adduser -S -h ${HOMEDIR_USER} -G ${GROUP_NAME} -s /bin/bash ${USER_NAME}; \
			# adduser --uid ${ENV_UID} --home ${HOMEDIR_USER} --gid ${ENV_GID} --shell /bin/bash ${USER_NAME}; \

RUN mkdir ${HOMEDIR_USER}

# Copy scripts to container
RUN mkdir -p ${EW_INSTALL_HOME}/scripts
COPY ./scripts/ew_get_rings_list.sh ${EW_INSTALL_HOME}/scripts/
COPY ./scripts/ew_sniff_all_rings_except_tracebuf_message.sh ${EW_INSTALL_HOME}/scripts/
COPY ./scripts/ew_check_process_status.sh ${EW_INSTALL_HOME}/scripts/
COPY ./scripts/ew_startstop_trap_pau.sh ${EW_INSTALL_HOME}/scripts/

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
	 echo "export EW_INSTALL_INSTALLATION=\"\${EW_INSTALL_INSTALLATION:-${EW_INSTALL_INSTALLATION}}\"" >> /root/.bashrc \
	 && echo "export EW_INSTALLATION=\"\${EW_INSTALL_INSTALLATION}\"" >> /root/.bashrc \
	 && echo "export EW_INST_ID=\"\${EW_INSTALL_INSTALLATION}\"" >> /root/.bashrc \
	 && echo "" >> /root/.bashrc \
	 && echo "source ${EW_FILE_ENV}" >> /root/.bashrc \
	 && echo "" >> /root/.bashrc \
	 && echo "export PS1='\${debian_chroot:+(\$debian_chroot)}\h-\${EW_HOSTNAME}:\w\${EW_ENV:+ [ew:\${EW_ENV}]} \$ '" >> /root/.bashrc \
	 && echo "" >> /root/.bashrc

RUN cp /root/.bashrc ${HOMEDIR_USER}/
RUN cp /root/.screenrc ${HOMEDIR_USER}/
RUN echo ". ~/.bashrc" > ${HOMEDIR_USER}/.bash_profile

RUN chown -R ${USER_NAME}:${GROUP_NAME} ${HOMEDIR_USER}

RUN \
		cd ${EW_INSTALL_HOME} \
		&& git clone https://gitlab.com/matteoquintiliani/mysql_printf.git \
		&& cd mysql_printf \
		&& rm aclocal.m4 \
		&& aclocal \
		&& ./bootstrap \
		&& ./configure \
		&& make \
		&& make install

RUN \
		cd ${EW_INSTALL_HOME} \
		&& git clone https://github.com/iris-edu-legacy/rdseed.git \
		&& cd rdseed \
		&& git remote add origin_yob https://github.com/yoboujon/rdseed.git \
		&& git fetch --all \
		&& git checkout -b master_yob origin_yob/master \
		&& sed -i'.bak' -e "s/-m64//g" Makefile \
		&& git diff \
		&& make clean \
		&& make CPPFLAGS="-I/usr/include  -I/usr/include/tirpc" \
		&& echo "export PATH=\${PATH}:${EW_INSTALL_HOME}/rdseed" >> /root/.bashrc \
		&& echo "export PATH=\${PATH}:${EW_INSTALL_HOME}/rdseed" >> ${HOMEDIR_USER}/.bashrc

# Packages for Obspy
# ref: https://github.com/obspy/obspy/wiki/Installation-on-Linux-via-Apt-Repository
RUN \
		apt-get install -y \
		python3-pip python3-numpy python3-scipy python3-matplotlib python3-lxml python3-setuptools python3-sqlalchemy python3-decorator python3-requests \
		python3-packaging python3-pyproj python3-pytest python3-geographiclib python3-cartopy python3-pyshp

# Install ewconfig and Obspy
ARG EWCONFIG_GIT_REP=https://gitlab.com/seismic-software/ewconfig.git
# ARG EWCONFIG_GIT_BRANCH=master
ARG EWCONFIG_GIT_BRANCH=19-proposal-to-add-pick_ew-configuration-based-on-mele-et-al-2010
# ARG EWCONFIG_GIT_REP=https://gitlab.com/matteoquintiliani/ewconfig.git
# ARG EWCONFIG_GIT_BRANCH=pick_ew_config_by_mele_et_al_2010

RUN \
		mkdir -p ${EW_INSTALL_HOME}/ewconfig \
		&& cd ${EW_INSTALL_HOME}/ewconfig \
		&& python3 -m venv env \
		&& source env/bin/activate \
		&& pip install --upgrade pip \
		&& pip install obspy \
		&& git clone --single-branch --branch ${EWCONFIG_GIT_BRANCH} ${EWCONFIG_GIT_REP} \
		&& cd ewconfig \
		&& pip install .
# && chown -R ${USER_NAME}:${GROUP_NAME} ${EW_INSTALL_HOME}/ewconfig

USER ${USER_NAME}:${GROUP_NAME}

