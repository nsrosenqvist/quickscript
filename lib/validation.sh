#!/bin/bash

function abort_on_failure() {
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

        exit $1
    fi
}
