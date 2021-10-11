#!/bin/bash

# Init pid variable
pid=0

# Current pid
echo "Current pid = $$"

# Set environment variables
. ~/.bashrc

# ISGTERM handler
term_handler () {
        echo "Run pau ..."
        pau
        echo "Waiting startstop ..."
        wait "$pid"
        echo "Finish"
        exit
}

# With no "exit"
trap 'term_handler' SIGTERM

echo "'Run startstop ..."
startstop > /dev/null 2>&1 &
pid="$!"

while true; do sleep 5; done

# Only for debugging
# C=0
# while true; do
#         echo "${C}"
#         sleep 1
#         C=$(( $C + 1 ))
# done



