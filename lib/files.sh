#!/bin/bash

#/
# A simple way to retrieve the file extension from a file name
#
# @param string $1 The file to extract the extension from
# @return string   Returns the file extension
# @author          Niklas Rosenqvist
#/
function file_extension() {
    local filename="$(basename "$1")"
    echo "${filename##*.}"
}

#/
# A simple way to retrieve the file name without the extension from a file name
#
# @param string $1 The file to extract the name from
# @return string   Returns the file name without the extension
# @author          Niklas Rosenqvist
#/
function file_name() {
    local filename="$(basename "$1")"
    echo "${filename%.*}"
}

#/
# Delete all multiple occurrences of forward slashes to get a clean path
#
# @param string $1 The path to strip forward slashes from
# @return string   Returns the string without multiple slashes
# @author          Niklas Rosenqvist
#/
function strip_multi_slash() {
    echo "$1" | sed 's#//*#/#g'
}

#/
# Check if a path is a mountpoint
#
# It uses the program mountpoint to see if anything is
# mounted at the path specified. Even though it's mounted
# the path might be inaccessible (filesystem errors) so the
# second parameter gives the option to verify that a file
# you specify can be found within the filesystem. For example
# if you know you have a file called ".mounted" in the root of
# the filesystem.
#
# @param string $1 The path to check
# @param string $1 Optional file to check for
# @return int      Returns 0 if it's a mountpoint and non-zero
#                  if it's not a mountpoint
# @author          Niklas Rosenqvist
#/
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

#/
# Get the name of a temporary directory, specific to this script instance
#
# It's supposed to be used together with make_tempdir but is required to
# retrieve the tempdir's name
#
# @param string $1 The file to extract the name from
# @return string   Returns the name of the temporary directory
# @author          Niklas Rosenqvist
#/
function tempdir() {
    echo "$(dirname "$0")/.$(basename "$0").$$.tmp"
}

#/
# Creates this script instance's temporary directory
#
# This function creates the temporary directory which's
# name is retrieved by running "tempdir". It also traps
# the end of the script so that it automatically gets
# deleted upon exit.
#
# @return int 0 or non-zero depending upon success
# @author     Niklas Rosenqvist
#/
function make_tempdir() {
    local dir="$(tempdir)"

    if mkdir "$dir"; then
    	echo "$dir"
    	trap "rm -Rf '$dir'" EXIT INT HUP TERM QUIT
    	return 0
    else
    	return 1
    fi
}

#/
# Manually deletes the temporary directory
#
# If you for some reason would like to delete the temporary
# directory for this script instance then you can use this
# function. Otherwise it will get deleted anyway when the script
# exits.
#
# @return int 0 or non-zero depending upon success
# @author     Niklas Rosenqvist
#/
function remove_tempdir() {
    if [ -d "$(tempdir)" ]; then
        rm -Rf "$(tempdir)"
        return $?
    fi
    
    return 0
}

#/
# A function that compares to strings with traditional version formatting
#
# It's pretty flexible and can handle many different kinds of version string.
# It can compare 0.1.002.0.0 to 0.1.2 and many similar cases. The comparators
# That are suported are =, !=, >= >, <= and <.
#
# @param string $1 First version string
# @param string $2 Comparator
# @param string $1 Second version string
# @return int      0 if the statement was true and 1 if not.
# @author          Niklas Rosenqvist
#/
function compare_versions() {
    local comp="$2"

    if [ "$1" = "$3" ]; then
        if [ "$2" = "=" ] || [ "$2" = ">=" ] ||  [ "$2" = "<=" ]; then
            return 0
        fi
    fi

    local IFS=.
    local ver1=($1)
    local ver2=($3)

    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done

    # fill empty fields in ver2 with zeros
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            ver2[i]=0
        fi
    done

    # ne
    if  [ "$comp" = "!=" ]; then
        for ((i=0; i<${#ver1[@]}; i++)); do
            if ((10#${ver1[i]} != 10#${ver2[i]})); then
                return 0
            fi
        done
    fi
    # gt ge
    if  [ "$comp" = ">" ] ||  [ "$comp" = ">=" ]; then
        for ((i=0; i<${#ver1[@]}; i++)); do
            if ((10#${ver1[i]} > 10#${ver2[i]})); then
                return 0
            else
                return 1
            fi
        done
    fi
    # eq ge le
    if  [ "$comp" = "=" ] ||  [ "$comp" = ">=" ] ||  [ "$comp" = "<=" ]; then
        for ((i=0; i<${#ver1[@]}; i++)); do
            if ((10#${ver1[i]} != 10#${ver2[i]})); then
                return 1
            fi
        done

        return 0
    fi
    # lt le
    if  [ "$comp" = "<" ] ||  [ "$comp" = "<=" ]; then
        for ((i=0; i<${#ver1[@]}; i++)); do
            if ((10#${ver1[i]} < 10#${ver2[i]})); then
                return 0
            else
                return 1
            fi
        done
    fi

    return 1
}
