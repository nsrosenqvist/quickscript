#!/bin/bash

source string.sh
source log.sh

#TODO: delete above
# Fix FINAL_ARGS
# remove bottom test code
# Unset FILE_ARGS, PIPE_ARGS, TERM_ARGS, FINAL_ARGS

###GLOBALS_START###
INPUT_TERM=1
INPUT_PIPE=1
INPUT_FILE=1
INPUT_PROCESSED=1
declare -A OPTALIAS
###GLOBALS_END###

function ask {
    read -n 1 -r -p "$1 (y/n) "

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

function qs_opts {
    local opts="$1"
    local returnvar="$2"
    shift 2

    if [ -z "$opts" ] || [ -z "$returnvar" ]; then
        log_err "You must specify both parsing options and an output variable."
        exit 1
    fi

    if [ $INPUT_PROCESSED -ne 0 ]; then
        PIPE_ARGS=()
        FILE_ARGS=()
        TERM_ARGS=()
        FINAL_ARGS=()

        # BASH_ARGV is reversed so we have to get it in the right order first
        for ((i=${#BASH_ARGV[@]}-1; i>=0; i--)); do
            TERM_ARGS+=("${BASH_ARGV[i]}")
        done

        if readlink /proc/$$/fd/0 | grep -q "^pipe:"; then
            INPUT_PIPE=0

            OLDIFS=IFS
            IFS=$'\n' read -d '' -r -a arguments

            for arg in "${arguments[@]}"; do
                PIPE_ARGS+=("$arg")
            done

            IFS=OLDIFS
        elif file $( readlink /proc/$$/fd/0 ) | grep -q "character special"; then
            INPUT_TERMINAL=0
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
        if [ ${#TERM_ARGS[@]} -eq 0 ] && [ ${#PIPE_ARGS[@]} -eq 0 ] && [ ${#FILE_ARGS[@]} -eq 0 ]; then
            return 1
        fi
    fi

    local argument="${TERM_ARGS[0]}"
    local originalarg="$argument"
    local foundopt=1
    local requirevalue=1
    local value=1
    local trimmedargs=""
    local noshift=1
    local aliasarg=1

    if [[ "$argument" == \-* ]]; then
        # If an alias is matched we translate it
        if [ -n "${OPTALIAS[${argument%=*}]}" ]; then
            originalarg="$argument"
            argument="${OPTALIAS[${argument%=*}]}"
        fi

        # If long argument name has been specified we only check the first character
        if [[ "$argument" == \-\-* ]]; then
            trimmedargs="$(substring "$argument" 2)"
        else
            trimmedargs="$(substring "$argument" 1)"
        fi

        # Mark if multiple flags have been specified in one group
        if [ ${#trimmedargs} -gt 1 ]; then
            noshift=0
        fi

        # Loop through the argument characters to see which flags has been set
        for ((i=0; i<${#trimmedargs}; i++)); do
            local trimmedarg="${trimmedargs:i:1}"

            for ((j=0; j<${#opts}; j++)); do
                if [ $foundopt -eq 0 ]; then
                    if [ "${opts:$j:1}" = ":" ]; then
                        requirevalue=0
                    fi
                    break 2
                fi
                if [ "${opts:$j:1}" = "$trimmedarg" ]; then
                    foundopt=0
                fi
            done
        done

        # We have our argument saved, we can now shift the array
        TERM_ARGS=("${TERM_ARGS[@]:1}")

        # Try to find the value that should have been set
        if [ $foundopt -eq 0 ]; then
            if [ $requirevalue -eq 0 ]; then
                if [[ "$originalarg" == *"="* ]]; then
                    splitstr=(${originalarg//=/ })

                    if [ -n "${splitstr[1]}" ]; then
                        value="${splitstr[1]}"
                    else
                        log_err "${originalarg%=*} require a value set!"
                        exit 1
                    fi
                else
                    if [ -z "${TERM_ARGS[0]}" ] || [ "${TERM_ARGS[0]}" == \-* ]; then
                        log_err "${originalarg%=*} require a value set!"
                        exit 1
                    else
                        value="${TERM_ARGS[0]}"
                    fi
                fi

                # Now when we have our value set we can shift again
                TERM_ARGS=("${TERM_ARGS[@]:1}")
            else
                value=0
            fi

            # Reinsert if the flag was grouped
            if [ $noshift -eq 0 ]; then
                TERM_ARGS=("-$(substring "$argument" 2)" "${TERM_ARGS[@]}")
                eval "$returnvar=${argument:0:2}"
            else
                eval "$returnvar=$argument"
            fi
        else
            # Reinsert if the flag was grouped
            if [ $noshift -eq 0 ]; then
                TERM_ARGS=("-$(substring "$argument" 2)" "${TERM_ARGS[@]}")
            fi

            eval "$returnvar="\?""
            value=1
        fi

        # Set the value and return
        OPTARG="$value"
    else
        FINAL_ARGS+=("$argument")
        TERM_ARGS=("${TERM_ARGS[@]:1}")
    fi

    return 0
}

OPTALIAS[--PATH]=-p

while qs_opts "vnp:" opt; do
    case "$opt" in
        -n|--normal)
            echo "NORMAL"
            ;;
        -v|--verbose)
            echo "VERBOSE"
            ;;
        -p|--path)
            echo "PATH: $OPTARG"
            ;;
        \?)
            echo "Couldn't find"
    esac
done
