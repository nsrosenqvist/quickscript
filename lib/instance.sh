#!/bin/bash

###GLOBALS_START###
LOCK_FILE=""
###GLOBALS_END###

#/
# Returns the directory of the current script
#
# @return string The directory containing this script that is being run
# @author        Niklas Rosenqvist
#/
function script_dir() {
    echo "$(cd "$(dirname "$0")" && pwd)"
}

#/
# Returns the name of the current script
#
# @return string Returns the current script's name
# @author        Niklas Rosenqvist
#/
function script_name() {
    echo "$(basename "$0")"
}

#/
# Returns the name of the lock_file which this script would use
#
# @return string The lock file/directory's name
# @author        Niklas Rosenqvist
#/
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

#/
# Creates the lock dir that would hinder other instances of this script to run
#
# To use a lock script then the function "lock_script" would have to be run at
# the top of a script and then the lock file would automatically be deleted
# when the script ends.
#
# @return int Returns 0 if a file was successfully created, if it already existed
#                       the script would instantly terminate.
# @author               Niklas Rosenqvist
#/
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

#/
# Enables the user to unlock the script manually
#
# @return int Returns 0 if successful and otherwise non-zero
# @author     Niklas Rosenqvist
#/
function unlock_script() {
    if [ -e "$LOCK_FILE" ]; then
        rm -Rf "$LOCK_FILE"
        return $?
    fi

    return 0
}

#/
# Returns the number of running instances of this script
#
# @return int The number of instances
# @author     Niklas Rosenqvist
#/
function running_instances() {
    echo $(pgrep -fc "$(script_name)")
}
