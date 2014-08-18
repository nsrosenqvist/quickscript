#!/bin/bash

###GLOBALS_START###
LOCK_FILE=""
###GLOBALS_END###

function script_dir {
    echo "$(cd "$(dirname "$0")" && pwd)"
}

function script_name {
    echo "$(basename "$0")"
}

function lock_file {
    generate_file=0
    lock_dir=""
    lock_file=""

    # Check if lock file is predefined
    if [ -n "$LOCK_FILE" ]; then
        generate_file=1
        lock_dir="$(dirname $LOCK_FILE)"
        lock_file="$(basename $LOCK_FILE)"
    else
        # Generate lock file
        if [ $# -ne 0 ] && [ -n "$1" ]; then
            lock_dir="$1"
        else
            lock_dir="$(script_dir)"
        fi

        lock_file="$(basename "$0").lock"
    fi

    if [ ! -d "$lock_dir" ]; then
        log_err "Can't find lock file directory: \"$lock_dir\""
        exit 1
    fi

    echo "$lock_dir/$lock_file"
}

function lock_script {
    LOCK_FILE="$(lock_file "$1")"
    verify_success $? "Create a lock file (ERROR: $LOCK_FILE)"

    if [ -d "$LOCK_FILE" ]; then
        log_err "A directory exists with the same name as the lock file."
        exit 1
    fi

    if [ -f "$LOCK_FILE" ]; then
        log_err "This script is blocked by a lock file at: $LOCK_FILE"
        exit 2
    fi

    touch "$LOCK_FILE"
    trap 'unlock_script' EXIT
}

function unlock_script {
    if [ -f "$LOCK_FILE" ]; then
        rm -f "$LOCK_FILE"
    fi
}

function running_instances {
    echo $(pgrep -fc "$(script_name)")
}
