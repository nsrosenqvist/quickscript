#!/bin/bash

#/
# Trims all trailing and leading whitespace
#
# @param string $1 The string to trim
# @return string   The trimmed string
# @author          Niklas Rosenqvist
#/
function trim_whitespace() {
    echo "$1" | sed -e 's/^[ \t]*//;s/[ \t]*$//'
}

#/
# Trims all leading whitespace
#
# @param string $1 The string to trim
# @return string   The trimmed string
# @author          Niklas Rosenqvist
#/
function trim_leading_whitespace() {
    echo "$1" | sed -e 's/^[ \t]*//'
}

#/
# Trims all trailing whitespace
#
# @param string $1 The string to trim
# @return string   The trimmed string
# @author          Niklas Rosenqvist
#/
function trim_trailing_whitespace() {
    echo "$1" | sed -e 's/[ \t]*$//'
}

#/
# Replaces the first substring within a string
#
# @param string $1 The haystack
# @param string $2 The needle
# @param string $2 The string to replace with
# @return string   The string with the substition taken place
# @author          Niklas Rosenqvist
#/
function string_replace() {
    echo "${1/$2/$3}"
}

#/
# Replaces all occurrences of a substring within a string
#
# @param string $1 The haystack
# @param string $2 The needle
# @param string $2 The string to replace with
# @return string   The string with the substition taken place
# @author          Niklas Rosenqvist
#/
function string_replace_all() {
    echo "${1//$2/$3}"
}

#/
# Replaces the first substring within a string, case-insensitive
#
# @param string $1 The haystack
# @param string $2 The needle
# @param string $2 The string to replace with
# @return string   The string with the substition taken place
# @author          Niklas Rosenqvist
#/
function string_ireplace() {
    echo "$1" | sed "s/$2/$3/I"
}

#/
# Replaces all occurrences of a substring within a string, case-insensitive
#
# @param string $1 The haystack
# @param string $2 The needle
# @param string $2 The string to replace with
# @return string   The string with the substition taken place
# @author          Niklas Rosenqvist
#/
function string_ireplace_all() {
    echo "$1" | sed "s/$2/$3/Ig"
}

#/
# Extracts a substring from a string
#
# @param string $1 String to extract the substring from
# @param int $2    The start position of the extraction
# @param int $2    Optionally the position to end at
# @return string   The extracted string
# @author          Niklas Rosenqvist
#/
function substring() {
    if [ $# -eq 2 ]; then
        echo "${1:$2}"
    else
        echo "${1:$2:$3}"
    fi
}

#/
# Converts a string to uppercase
#
# @param string $1 String to change case
# @return string   The string but in all uppercase letters
# @author          Niklas Rosenqvist
#/
function to_uppercase() {
    echo "${1^^}"
}

#/
# Converts a string to lowercase
#
# @param string $1 String to change case
# @return string   The string but in all lowercase letters
# @author          Niklas Rosenqvist
#/
function to_lowercase() {
    echo "${1,,}"
}

#/
# Capitalizes the first letter in the word
#
# @param string $1 String to capitalize
# @return string   The string but with the first letter capitalized
# @author          Niklas Rosenqvist
#/
function capitalize() {
    echo "${1^}"
}
