#!/bin/bash

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
