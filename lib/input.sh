#!/bin/bash

###GLOBALS_START###
INPUT_TERM=1
INPUT_PIPE=1
INPUT_FILE=1
INPUT_PROCESSED=1
declare -Ag OPTALIAS
OPTARG=""
OPTORIG=()
NONOPT=()
OPTIND=1
OPTUPDATECMD='eval set -- "${NONOPT[@]}" && unset NONOPT'
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

    if [ -z "$opts" ] || [ -z "$returnvar" ]; then
        log_err "You must specify both parsing options and an output variable."
        exit 1
    fi

    if [ $INPUT_PROCESSED -ne 0 ]; then
        PIPE_ARGS=()
        FILE_ARGS=()
        TERM_ARGS=()
        NONOPT=()

        # BASH_ARGV is reversed so we have to get it in the right order first
        for ((i=${#BASH_ARGV[@]}-1; i>=0; i--)); do
            TERM_ARGS+=("${BASH_ARGV[i]}")
        done

        OPTORIG=("${TERM_ARGS[@]}")

        if readlink /proc/$$/fd/0 | grep -q "^pipe:"; then
            INPUT_PIPE=0

            OLDIFS=IFS
            IFS=$'\n' read -d '' -r -a pipearguments

            for arg in "${pipearguments[@]}"; do
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
        if [ ${#TERM_ARGS[@]} -eq 0 ]; then
            NONOPT+=("${PIPE_ARGS[@]}" "${FILE_ARGS[@]}")

            unset FILE_ARGS
            unset PIPE_ARGS
            unset TERM_ARGS
            return 1
        fi
    fi

    local argument="${TERM_ARGS[0]}"
    local originalarg="$argument"
    local foundopt=1
    local requirevalue=1
    local optvalue=1
    local trimmedargs=""
    local noshift=1
    local longarg=1
    local aliasarg=1
    local singlearg=""

    if [[ "$argument" == \-* ]]; then
        # If an alias is matched we translate it
        if [ -n "${OPTALIAS[${argument%%=*}]}" ]; then
            argument="${OPTALIAS[${argument%%=*}]}"
            aliasarg=0
        else
            argument="${argument%%=*}"
        fi

        # If long argument name has been specified we only check the first character
        if [[ "$argument" == \-\-* ]]; then
            trimmedargs="${argument:2:1}"
            singlearg="${argument:1:2}"
            longarg=0
        else
            trimmedargs="${argument:1}"
            singlearg="${argument:0:2}"
        fi

        # Mark if multiple flags have been specified in one group
        if [ ${#trimmedargs} -gt 1 ]; then
            noshift=0
        fi

        # Loop through the argument characters to see which flags has been set
        local trimmedarg="${trimmedargs:0:1}"

        for ((j=0; j<${#opts}; j++)); do
            if [ $foundopt -eq 0 ]; then
                if [ "${opts:$j:1}" = ":" ]; then
                    requirevalue=0
                fi
                break
            fi
            if [ "${opts:$j:1}" = "$trimmedarg" ]; then
                foundopt=0
            fi
        done

        # We have our argument saved, we can now shift the array
        TERM_ARGS=("${TERM_ARGS[@]:1}")

        # Try to find the value that should have been set
        if [ $foundopt -eq 0 ]; then
            if [ $requirevalue -eq 0 ]; then
                if [[ "$originalarg" == *"="* ]]; then
                    optvalue="${originalarg#*=}"
                    noshift=1
                else
                    if [ "${#TERM_ARGS[@]}" -le 0 ]; then
                        log_err "$argument require a value set!"
                        exit 1
                    else
                        optvalue="${TERM_ARGS[0]}"
                    fi

                    # Now when we have our value set we can shift again
                    TERM_ARGS=("${TERM_ARGS[@]:1}")
                    # New opt/optgroup
                    OPTIND=$(($OPTIND+1))
                fi
            else
                if [ $longarg -eq 0 ]; then
                    optvalue="$argument"
                else
                    optvalue="$singlearg"
                fi
            fi


            # Reinsert if the flag was grouped
            if [ $noshift -eq 0 ]; then
                TERM_ARGS=("-${originalarg:2}" "${TERM_ARGS[@]}")
                echo "noshift: $originalarg, $argument, $singlearg"
                if [ $aliasarg -eq 0 ]; then
                    TERM_ARGS=("-${argument:2}" "${TERM_ARGS[@]}")
                else
                    TERM_ARGS=("-${originalarg:2}" "${TERM_ARGS[@]}")
                fi

                eval "$returnvar=$singlearg"
            else
                # New opt/optgroup
                OPTIND=$(($OPTIND+1))
                eval "$returnvar=$singlearg"
            fi
        else
            # Reinsert if the flag was grouped
            if [ $noshift -eq 0 ]; then
                TERM_ARGS=("-${argument:2}" "${TERM_ARGS[@]}")
            else
                # New opt/optgroup
                OPTIND=$(($OPTIND+1))
            fi

            eval "$returnvar="\?""

            if [ $longarg -eq 0 ]; then
                optvalue="$argument"
            else
                optvalue="$singlearg"
            fi
        fi

        # Set the value and return
        OPTARG="$optvalue"
    else
        OPTARG=
        eval "$returnvar="
        NONOPT+=("$argument")
        TERM_ARGS=("${TERM_ARGS[@]:1}")
    fi

    return 0
}
