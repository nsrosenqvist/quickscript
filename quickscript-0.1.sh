#!/bin/bash

## QuickScript version 0.1
## Build date: 2014-08-15

LOCK_FILE=""
LOG_DIR="/var/log"
LOG=0
UNLOCK_ON_ABORT=0

### File "/lib/input.sh":
doubleline
## /lib/input.sh, line 3:
function ask {
    read -n 1 -r -p "$1 (y/n) "

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
    return 1
    fi
}

### File "/lib/instance.sh":


## /lib/instance.sh, line 7:
function script_dir {
    echo "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
}

## /lib/instance.sh, line 11:
function script_name {
    echo "$(basename $0)"
}

## /lib/instance.sh, line 15:
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

## /lib/instance.sh, line 44:
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
}

## /lib/instance.sh, line 61:
function unlock_script {
    if [ -f "$LOCK_FILE" ]; then
        rm -f "$LOCK_FILE"
    fi
}

### File "/lib/logging.sh":


## /lib/logging.sh, line 8:
function time_stamp {
    echo "$(date "+%Y-%m-%d %T")"
}

## /lib/logging.sh, line 12:
function log_file {
    if [ $LOG -eq 0 ]; then
        echo "$LOG_DIR/$(script_name).log"
    else
        echo "/dev/null"
    fi
}

## /lib/logging.sh, line 20:
function log {
    echo "$(time_stamp) $1" >> "$(log_file)"
}

## /lib/logging.sh, line 24:
function log_msg {
    echo "$(time_stamp) [MSG] $1" >> "$(log_file)"
}

## /lib/logging.sh, line 28:
function log_wrn {
    echo "$(time_stamp) [WRN] $1" >> "$(log_file)"
}

## /lib/logging.sh, line 32:
function log_err {
    echo "$(time_stamp) [ERR] $1" 1>&2 | tee -a "$(log_file)" #Old: 2>&1
}

### File "/lib/mount.sh":

## /lib/mount.sh, line 3:
function is_mountpoint {
    mountpoint -q "$1"
    is_mounted=$?

    if [ $is_mounted -eq 0 ]; then
        # Make sure provided file exists
        if [ $# -ge 2 ]; then
            if [ ! -e "$1/$2" ]; then
                is_mounted=1
            fi
        fi
    fi

    echo $is_mounted
}

## /lib/mount.sh, line 19:
function assert_mountpoint {
    # Check if mountpoint
    if [ $# -ge 2 ] && [ -n "$2" ]; then
        is_mounted=$(is_mountpoint "$1" "$2")
    else
        is_mounted=$(is_mountpoint "$1")
    fi

    # if not a mountpoint
    if [ $is_mounted -ne 0 ]; then
        message="The path \"$1\" failed to be recognized as a mountpoint."

        # Add LineNo on failure
        if [ $# -ge 3 ]; then
            message="$message (Line: $3)"
        fi

        log_err "$message"

        # Execute cmd on failure
        if [ $# -ge 4 ]; then
            $4
        fi

        # Exit program
        if [ $UNLOCK_ON_ABORT -eq 0 ]; then
            unlock_script
        fi
        exit 1
    fi
}

### File "/lib/validation.sh":


## /lib/validation.sh, line 7:
function assert_success {
    if [ $1 -ne 0 ]; then
        message="The script \"$(script_dir)/$(script_name)\" failed"

        # Add error descriptor
        if [ $# -ge 2 ]; then
            message="$message at step: \"$2\""
        else
            message="$message."
        fi

        # Add LineNo on failure
        if [ $# -ge 3 ]; then
            message="$message (Line: $3)"
        fi

        log_err "$message"

        # Execute cmd on failure
        if [ $# -ge 4 ]; then
            $4
        fi

        # Exit program
        if [ $UNLOCK_ON_ABORT -eq 0 ]; then
            unlock_script
        fi
        exit $1
    fi
}
