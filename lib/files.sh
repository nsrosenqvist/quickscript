#!/bin/bash

function file_extension {
    local filename="$(basename "$1")"
    echo "${filename##*.}"
}

function file_name {
    local filename="$(basename "$1")"
    echo "${filename%.*}"
}

function strip_multi_slash {
	echo "$1" | sed 's#//*#/#g'
}