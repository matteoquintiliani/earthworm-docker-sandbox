#!/bin/bash

# Author: Matteo Quintiliani - matteo.quintiliani@ingv.it
# Istituto Nazionale di Geofisica e Vulcanologia

# This script is based on:
#  - https://github.com/INGV/fdsnws-fetcher
#  - GNU date (gdate on Mac OS X)
#  - Earthworm tankplayer tools: ms2tb, (mseed2tank), remux_tbuf

# Check ms2tb and remux_tbuf
# for CMD in remux_tbuf ms2tb; do
	# command -v ${CMD}
	# if [ $? -eq 1 ]; then
		# echo "ERROR: ${CMD} utility not found. Exit."
		# exit 1
	# fi
# done

SYNTAX="
Syntax: `basename $0`  <origin_time> <secs_before_ot> <secs_after_ot> <latitude> <longitude> <radius> <output_directory>

        <origin_time>: format like YYYY-MM-DDThh:mm:ss (example 2019-06-23T20:43:47)
        <secs_before_ot>: integer number. Seconds before origin time.
        <secs_after_ot>: integer number. Seconds after origin time.
        <latitude>: real number.
        <longitude>: real number.
        <radius>: in degrees.
        <output_directory>: output directory.
"

NS_IMAGE_NAME_VERSION="$1"
OT="$2"
SECS_BEFORE_OT="$3"
SECS_AFTER_OT="$4"
LAT="$5"
LON="$6"
RADIUS="$7"
ROOTDIROUT="$8"

# OT=2019-06-23T20:43:47
# LAT=41.86
# LON=12.76
# RADIUS=3.0

if [ -z "$7" ]; then
	echo "${SYNTAX}"
	exit
fi

# Set DIROUT_COMPLETEPATH
cd "${DIROUT}"
DIROUT_COMPLETEPATH="`pwd`"
cd -

# Compute STARTTIME and ENDTIME from OT and interval before and after based on GNU date installed in Docker
GNUDATECMD="docker run --rm -v ${DIROUT_COMPLETEPATH}:/opt/OUTPUT ${NS_IMAGE_NAME_VERSION} /bin/bash -c"
STARTTIME=$(${GNUDATECMD} -c "TZ=UTC date -d '${OT}Z - ${SECS_BEFORE_OT} seconds' +%Y-%m-%dT%H:%M:%S")
ENDTIME=$(${GNUDATECMD} -c "TZ=UTC date -d '${OT}Z + ${SECS_AFTER_OT} seconds'  +%Y-%m-%dT%H:%M:%S")

DIRNAME="`dirname $0`"
cd "${DIRNAME}"
DIRNAME_COMPLETEPATH="`pwd`"
cd -

if [ -z "${ROOTDIROUT}" ]; then
	ROOTDIROUT="${DIRNAME}"
fi
if [ ! -d "${ROOTDIROUT}" ]; then
	echo "ERROR: output directory ${ROOTDIROUT} not found. Exit."
	exit
fi

FILENAMEBASE="$(echo "${OT}-${SECS_BEFORE_OT}-${SECS_AFTER_OT}-${LAT}-${LON}-${RADIUS}" | tr ' ' '_' | tr '.' '_' | tr ':' '_')"
DIROUT="${ROOTDIROUT}/${FILENAMEBASE}"

if [ -e "${DIROUT}" ]; then
	echo "ERROR: output directory ${DIROUT} already exists. Exit."
	FLAG_ALREADY_EXISTS=yes
	# exit
else
	mkdir -p "${DIROUT}"
fi

if [ "${FLAG_ALREADY_EXISTS}" != "yes" ]; then
	docker run -it --rm -v ${DIRNAME_COMPLETEPATH}/stationxml.conf:/opt/stationxml.conf -v ${DIROUT_COMPLETEPATH}:/opt/OUTPUT fdsnws-fetcher \
		-u "lat=${LAT}&lon=${LON}&maxradius=${RADIUS}&starttime=${STARTTIME}&endtime=${ENDTIME}" \
		-t "miniseed" \
		|| exit
fi

docker run -it --rm -v ${DIROUT_COMPLETEPATH}:/opt/OUTPUT ${NS_IMAGE_NAME_VERSION} /bin/bash -c "\
	. ~/.bashrc \
	&& cd /opt/OUTPUT/ \
	&& rm -f miniseed.tmp.tank miniseed.remux_tbuf.tank \
	&& (find . -iname \"*.[HES][HN][ZNE].miniseed\" | while read f; do echo \$f; ms2tb \$f >> miniseed.tmp.tank; done) \
	&& remux_tbuf miniseed.tmp.tank miniseed.remux_tbuf.tank \
	&& rm -f miniseed.tmp.tank \
	&& mv miniseed.remux_tbuf.tank ${FILENAMEBASE}.tank \
	"

