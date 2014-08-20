#!/bin/bash

###GLOBALS_START###
LOCK_FILE=""
###GLOBALS_END###

function script_dir() {
    echo "$(cd "$(dirname "$0")" && pwd)"
}

function script_name() {
    echo "$(basename "$0")"
}

function lock_file() {
    local generate_file=0
    local lock_dir=""
    local lock_file=""

    # Check if lock file is predefined
    if [ -n "$LOCK_FILE" ]; then
        generate_file=1
        lock_dir="$(dirname $LOCK_FILE)"
        lock_file="$(basename $LOCK_FILE)"
    else
        # Generate lock file        
        lock_file="$(basename "$0").lock"
        lock_dir="$(script_dir)"

        # Make sure that the lock file is hidden
        if [ "${lock_file:0:1}" != "." ]; then
            lock_file=".$lock_file"
        fi
    fi

    if [ ! -d "$lock_dir" ]; then
        echo "Error: Can't find lock file directory: \"$lock_dir\"" 1>&2
        exit 1
    fi

    echo "$lock_dir/$lock_file"
}

function lock_script() {
    LOCK_FILE="$(lock_file)"

    # Try to create a lock file with the mkdir technique
    if ! mkdir "$LOCK_FILE"; then
        echo "Error: This script is locked ($LOCK_FILE)" 1>&2
        exit 1
    fi

    # Make sure the script gets unlocked upon exit
    trap 'unlock_script' EXIT INT HUP TERM QUIT
    return 0
}

function unlock_script() {
    if [ -e "$LOCK_FILE" ]; then
        rm -Rf "$LOCK_FILE"
    fi

    return 0
}

function running_instances() {
    echo $(pgrep -fc "$(script_name)")
}
