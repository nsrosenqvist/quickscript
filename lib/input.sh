#!/bin/bash

###GLOBALS_START###
INPUT_PROCESSED=1 # Reset to use qs_opts again in same script
INPUT_TERM=1 # Flag for terminal input
INPUT_PIPE=1 # Flag for pipe input
INPUT_FILE=1 # Flag for file input
declare -Ag OPTALIAS # Aliases for options or groups of options
OPTARG="" # Compatibility with getops
OPTORIG=() # The original command line input
NONOPT=() # Arguments that aren't considered options
OPTIND=1 # Compatibility with getopts
OPTUPDATECMD='eval set -- "${NONOPT[@]}"' # Command to update input
###GLOBALS_END###

function ask() {
    read -n 1 -r -p "$1 (y/n) "

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

function qs_opts() {
    local opts="$1"
    local returnvar="$2"
    shift 2

    # Validate options specified
    if [ -z "$opts" ] || [ -z "$returnvar" ]; then
        echo "Error: You must specify both parsing options and an output variable." 1>&2
        return 1
    fi

    # Process the script's input if it hasn't been processed already
    if [ $INPUT_PROCESSED -ne 0 ]; then
        PIPE_ARGS=()
        FILE_ARGS=()
        TERM_ARGS=()
        NONOPT=()

        # If the user has provided the opts to parse, use them instead of BASH_ARGV
        if [ $# -gt 2 ]; then
            TERM_ARGS=("$@")
        else
            # BASH_ARGV is reversed so we have to get it in the right order first
            for ((i=${#BASH_ARGV[@]}-1; i>=0; i--)); do
                TERM_ARGS+=("${BASH_ARGV[i]}")
            done
        fi

        OPTORIG=("${TERM_ARGS[@]}")

        # Process input from pipe
        if readlink /proc/$$/fd/0 | grep -q "^pipe:"; then
            INPUT_PIPE=0

            OLDIFS=IFS
            IFS=$'\n' read -d '' -r -a pipearguments

            for arg in "${pipearguments[@]}"; do
                PIPE_ARGS+=("$arg")
            done

            IFS=OLDIFS
        # Input from terminal
        elif file $( readlink /proc/$$/fd/0 ) | grep -q "character special"; then
            INPUT_TERMINAL=0
        # Input from file
        else
            INPUT_FILE=0

            while read arg
            do
                FILE_ARGS+=("$arg")
            done
        fi

        INPUT_PROCESSED=0
    else
        # Return 1 and exit loop if all input has been processed
        if [ ${#TERM_ARGS[@]} -eq 0 ]; then
            NONOPT+=("${PIPE_ARGS[@]}" "${FILE_ARGS[@]}")
            return 1
        fi
    fi

    # Check for hyphen to see if it's an option
    if [[ "${TERM_ARGS[0]}" == \-* ]]; then
        local translatedopt="" # The real opt being processed, translated from alias if found
        local translatedarg="" # The real opt being processed, translated from alias if found, with value assignment preserved
        local originalarg="${TERM_ARGS[0]}" # Original argument from commandline (--path="/example")
        local originalopt="${TERM_ARGS[0]%%=*}" # Original argument but stripped from value assignment (--path)
        local singleopt="" # The current opt being processed with hyphen (-o)
        local trimmedopt="" # The current opt begin processed without hyphen (o)

        local longarg=1
        local aliasarg=1
        local foundopt=1
        local requirevalue=1
        local optvalue=""
        local noshift=1

        # Translate if argument matches an alias (OPTALIAS[--DIR]=-p)
        if [ -n "${OPTALIAS[$originalopt]}" ]; then
            translatedopt="${OPTALIAS[$originalopt]}"
            aliasarg=0
        else
            translatedopt="$originalopt"
        fi

        # If the value was specified in the argument, append it to translatedarg
        if [[ "$originalarg" == *"="* ]]; then
            translatedarg="$translatedopt=${originalarg#*=}"
        else
            translatedarg="$translatedopt"
        fi

        # If long argument name has been specified we only check the first character
        if [[ "$translatedopt" == \-\-* ]]; then
            singleopt="${translatedopt:1:2}"
            trimmedopt="${translatedopt:2:1}"
            longarg=0
        else
            singleopt="${translatedopt:0:2}"
            trimmedopt="${translatedopt:1:1}"

            # Mark if we're processing an optgroup (-ovpn)
            if [ ${#translatedopt} -gt 2 ]; then
                noshift=0
            fi
        fi

        # Loop through the options see which one has been set and flag if it requires a value
        for ((i=0; i<${#opts}; i++)); do
            if [ $foundopt -eq 0 ]; then
                if [ "${opts:$i:1}" = ":" ]; then
                    requirevalue=0
                fi
                break
            fi
            if [ "${opts:$i:1}" = "$trimmedopt" ]; then
                foundopt=0
            fi
        done

        # We have our argument saved, we can now shift the input array
        TERM_ARGS=("${TERM_ARGS[@]:1}")

        # Try to find the value that should have been set
        if [ $foundopt -eq 0 ]; then
            # See if the opt requires a value set
            if [ $requirevalue -eq 0 ]; then
                # See if the value has been set in the same argument
                if [[ "$translatedarg" == *"="* ]]; then
                    optvalue="${translatedarg#*=}"
                else
                    # The value should be the next argument
                    if [ "${#TERM_ARGS[@]}" -le 0 ]; then
                        optvalue="$singleopt"
                        singleopt=\!
                    else
                        optvalue="${TERM_ARGS[0]}"
                    fi

                    # Since the value was the next argument we shift the input array again
                    TERM_ARGS=("${TERM_ARGS[@]:1}")
                    # New opt/optgroup
                    OPTIND=$(($OPTIND+1))
                fi
            else
                # The opt doesn't require a value, so we set it to the opt name
                optvalue="$singleopt"
            fi

            # Reinsert if the opt was grouped
            if [ $noshift -eq 0 ]; then
                TERM_ARGS=("-${translatedarg:2}" "${TERM_ARGS[@]}")
            else
                # New opt/optgroup
                OPTIND=$(($OPTIND+1))
            fi
        else
            # Couldn't find the option

            # Reinsert if the flag was grouped
            if [ $noshift -eq 0 ]; then
                TERM_ARGS=("-${translatedarg:2}" "${TERM_ARGS[@]}")
            else
                # New opt/optgroup
                OPTIND=$(($OPTIND+1))
            fi

            # Set the original opt parameter so that it's easier for the user to debug
            if [ $longarg -eq 0 ]; then
                optvalue="$originalopt"
                singleopt=\?
            else
                optvalue="$singleopt"
                singleopt=\?
            fi
        fi

        # Set the value and return
        OPTARG="$optvalue"
        eval "$returnvar=$singleopt"
    else
        # Argument that is not considered an option
        OPTARG=
        eval "$returnvar="
        NONOPT+=("${TERM_ARGS[0]}")
        TERM_ARGS=("${TERM_ARGS[@]:1}")
    fi

    return 0
}
