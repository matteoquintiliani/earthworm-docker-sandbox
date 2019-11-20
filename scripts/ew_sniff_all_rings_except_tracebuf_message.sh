#!/bin/bash

DIRNAME="`dirname $0`"
EWGETRINGS_CMD="${DIRNAME}/ew_get_rings_list.sh"
RING_LIST=`${EWGETRINGS_CMD}`
echo ${RING_LIST}

# RING_LIST_EXCEPT_WAVE=$(echo ${RING_LIST} | sed -e "s/^/,/" -e "s/$/,/" -e "s/,[^,]*WAVE[^,]*,//" -e "s/^,//" -e "s/,$//")
# echo ${RING_LIST_EXCEPT_WAVE}

sniffrings ${RING_LIST} verbose 2>&1 | grep -v TYPE_TRACEBUF

