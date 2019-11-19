#!/bin/bash


MODULEFILECONFIGD_DEFAULT=tankplayer.d
FLAG_PAU_DEFAULT=nopau
SLEEP_SECS=15

SYNTAX="
Syntax: `basename $0` [  <modulefileconfig.d>  [  <action>  ]  ]

        <modulefileconfig.d> default is '${MODULEFILECONFIGD_DEFAULT}'
        <action> can be 'pau' or 'nopau', default is '${FLAG_PAU_DEFAULT}'

"

MODULEFILECONFIGD="$1"
FLAG_PAU="$2"

if [ -z "${MODULEFILECONFIGD}" ]; then
	MODULEFILECONFIGD=${MODULEFILECONFIGD_DEFAULT}
fi

if [ -z "${FLAG_PAU}" ]; then
	FLAG_PAU=${FLAG_PAU_DEFAULT}
fi

TMPFILE_OUTPUTSTATUS=/tmp/status.output.log

# while /bin/true; do [ "`status 2>/dev/null | grep -w ${MODULEFILECONFIGD} | awk '{print $3;}'`" != "Alive" ] && echo End; done

while /bin/true; do
	printf "Checking ${MODULEFILECONFIGD} status... "
	status 2>/dev/null > ${TMPFILE_OUTPUTSTATUS}
	RET_STATUS=$?
	cat ${TMPFILE_OUTPUTSTATUS} | grep -q "Earthworm may be hung; no response"
	RET_EW_HUNG=$?
	MODULESTATUS="`cat ${TMPFILE_OUTPUTSTATUS} | grep -w ${MODULEFILECONFIGD} | awk '{print $3;}'`"
	echo "-${RET_STATUS}-${RET_EW_HUNG}-${MODULESTATUS}-"
	# RET_STATUS          0 is ok, 1 Earthworm is not running
	# RET_EW_HUNG         0 Earthworm may be hung

	if [ ${RET_STATUS} -eq 1 ]; then
			echo "WARNING: Earthworm is not running."
			cat ${TMPFILE_OUTPUTSTATUS}
	fi

	# Before check RET_EW_HUNG
	if [ ${RET_EW_HUNG} -eq 0 ]; then
			echo "WARNING: Earthworm may be hung;"
			cat ${TMPFILE_OUTPUTSTATUS}
	else
		if [ ${RET_STATUS} -eq 0 ] && [ -z "$MODULESTATUS" ]; then
			echo "WARNING: status for ${MODULEFILECONFIGD} is empty. Maybe something is wrong. Please, check arguments!"
		else
			if [ "${FLAG_PAU}" == "pau" ]; then
				if [ -z "${MODULESTATUS}" ]; then
					# Earthworm is not running then quit screen, detaching it
					screen -d
				elif [ "${MODULESTATUS}" != "Alive" ] && [ "${MODULESTATUS}" != "Restarting" ]; then
					# Launch pau to stop Earthworm
					pau
				fi
			else
				echo "Do nothing..."
			fi
		fi
	fi
	echo "Waiting ${SLEEP_SECS} seconds ..."
	sleep ${SLEEP_SECS}
done

