#!/bin/bash

###GLOBALS_START###
UNLOCK_ON_ABORT=0
###GLOBALS_END###

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
