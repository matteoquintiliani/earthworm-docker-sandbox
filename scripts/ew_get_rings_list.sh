#!/bin/bash

RING_LIST="`status 2>&1 | egrep "^        Ring" | sed -e "s=^.*name/key/size:==" -e "s= /.*$==" -e "s/[[:space:]]*//" | tr '\n' ',' | sed -e "s/,$//"`"

echo ${RING_LIST}

