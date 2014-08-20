#!/bin/bash

function trim_whitespace() {
    echo "$1" | sed -e 's/^ *//' -e 's/ *$//'
}

function trim_leading_whitespace() {
    echo "$1" | sed -e 's/^ *//'
}

function trim_trailing_whitespace() {
    echo "$1" | sed -e 's/ *$//'
}

function string_replace() {
    echo "${1/$2/$3}"
}

function string_replace_all() {
    echo "${1//$2/$3}"
}

function string_ireplace() {
    echo "$1" | sed "s/$2/$3/I"
}

function string_ireplace_all() {
    echo "$1" | sed "s/$2/$3/Ig"
}

function substring() {
    if [ $# -eq 2 ]; then
        echo "${1:$2}"
    else
        echo "${1:$2:$3}"
    fi
}

function to_uppercase() {
    echo "${1^^}"
}

function to_lowercase() {
    echo "${1,,}"
}

function capitalize() {
    echo "${1^}"
}

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
