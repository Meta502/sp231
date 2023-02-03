#!/bin/bash

LOG_WEEKS=(W00 W01 W02 W03 W04 W05 W06 W07 W08 W09 W10 W11)

function serialize_array() {
        declare -n _array="${1}" _str="${2}" # _array, _str => local reference vars
        local IFS="${3:-$'\x01'}"
        # shellcheck disable=SC2034 # Reference vars assumed used by caller
        _str="${_array[*]}" # * => join on IFS
}

LOG_TYPE=$(curl -s https://osp4diss.vlsm.org/ETC/logCodes.txt | awk '$1 ~ /^L/' | fzf)
LOG_CODE=$(echo $LOG_TYPE | cut -d " " -f1)
if [ "$LOG_CODE" == "" ]; then
    exit 0
fi

serialize_array LOG_WEEKS LOG_WEEK_STRING $'\n'
LOG_WEEK=$(echo "$LOG_WEEK_STRING" | fzf)
if [ "$LOG_WEEK" == "" ]; then
    exit 0
fi

echo
read -p "Enter Time Allocated: " LOG_TIME
read -p "Enter Log Message: " LOG_MESSAGE
echo

LOG_LINE="ZCZC ${LOG_WEEK} ${LOG_TIME} ${LOG_CODE} ${LOG_MESSAGE}"

echo "==== LOG TO BE ADDED ===="
echo $LOG_LINE

read -p 'Commit Log? (y/n)' yn
if [ "$yn" == "y" ]; then
    echo $LOG_LINE >> TXT/mylog.txt
    echo "==== UPDATED ZCZC LOG ===="
    cat TXT/mylog.txt
fi
