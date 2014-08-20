#!/bin/bash

function file_extension() {
    local filename="$(basename "$1")"
    echo "${filename##*.}"
}

function file_name() {
    local filename="$(basename "$1")"
    echo "${filename%.*}"
}

function strip_multi_slash() {
    echo "$1" | sed 's#//*#/#g'
}

function is_mountpoint() {
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

    return $is_mounted
}

function make_tempdir() {
    local dir="$(dirname "$0")/.$(basename "$0").$$.tmp"
    
    if mkdir "$dir"; then
    	echo "$dir"
    	trap "rm -Rf '$dir'" EXIT INT HUP TERM QUIT
    	return 0
    else
    	return 1
    fi
}
