#!/bin/bash

MODULENAME=tankplayer

# while /bin/true; do [ "`status 2>/dev/null | grep ${MODULENAME} | awk '{print $3;}'`" != "Alive" ] && echo End; done

while /bin/true; do
	echo "Check ${MODULENAME} status..."
	MODULESTATUS="`status 2>/dev/null | grep ${MODULENAME} | awk '{print $3;}'`"
	echo "-$MODULESTATUS-"
	if [ -z "${MODULESTATUS}" ]; then
		echo "killall screen"
	elif [ "${MODULESTATUS}" != "Alive" ] && [ "${MODULESTATUS}" != "Restarting" ]; then
		echo "pau"
	fi
	sleep 5
done

