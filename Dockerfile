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
seismic_processing/carlstatrig \
seismic_processing/carlsubtrig \
archiving/wave_serverV \
archiving/tankplayer \
data_exchange/ew2file \
data_exchange/scn_convert \
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

