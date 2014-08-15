#!/bin/bash

function trim_whitespace {
    echo "$1" | sed -e 's/^ *//' -e 's/ *$//'
}

function trim_leading_whitespace {
    echo "$1" | sed -e 's/^ *//'
}

function trim_trailing_whitespace {
    echo "$1" | sed -e 's/ *$//'
}

function string_replace {
    echo "${1/$2/$3}"
}

function string_replace_all {
    echo "${1//$2/$3}"
}

function string_ireplace {
    echo "$1" | sed "s/$2/$3/I"
}

function string_ireplace_all {
    echo "$1" | sed "s/$2/$3/Ig"
}

function substring {
    if [ $# -eq 2 ]; then
        echo "${1:$2:$((${#1}-$2))}"
    else
        echo "${1:$2:$3}"
    fi
}

function to_uppercase {
    echo "${1^^}"
}

function to_lowercase {
    echo "${1,,}"
}

function capitalize {
    echo "${1^}"
}
