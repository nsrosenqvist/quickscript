#!/bin/bash

#/
# Terminates the script if the value given is not 0
#
# Similar functionality to just setting "set -e" but given more
# control to the user. The user simply pass $? from the previous
# command and if it wasn't successful it terminates the script
# and writes a message to the log and stderr.  
#
# @param string $1 The value to check is 0
# @param string $2 Optionally the log message
# @param int    $3 Optionally the $LINENO
# @return          void
# @author          Niklas Rosenqvist
#/
function abort_if_failure() {
    if [ $1 -ne 0 ]; then
        message="The script \"$(script_dir)/$(script_name)\" failed"

        # Add error descriptor
        if [ $# -ge 2 ]; then
            message="$message: \"$2\""
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

        exit $1
    fi
}

#/
# Set -e shorthand
#
# @return int Set's return value
# @author     Niklas Rosenqvist
#/
function allow_no_errors {
    set -e
    return $?
}

#/
# Set +e shorthand
#
# @return int Set's return value
# @author     Niklas Rosenqvist
#/
function allow_errors {
    set +e
    return $?
}
