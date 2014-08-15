#!/bin/bash

source lib/instance.sh
source lib/string.sh

SCRIPTDIR="$(script_dir)"
VERSIONNO="0.1"
LIBNAME="quickscript"
TEMPFILE="$SCRIPTDIR/.$LIBNAME.tmp"
BUILTFILE="$SCRIPTDIR/$LIBNAME-$VERSIONNO.sh"
TARGET="$TEMPFILE"
STRIP_COMMENTS=1
DEBUG_COMMENTS=0
GLOBALS=()

# Shorthand for writing to file
function write {
    echo "$1" >> "$TARGET"
}

function build {
    local lastline=""

    # Remove previously built file
    if [ -e "$BUILTFILE" ]; then
        rm "$BUILTFILE"
    fi

    while IFS= read -r file; do
        local globalsection=1
        local lineno=0
        local relfile="${file/$SCRIPTDIR/}"

        # Make sure functions don't get cramped together
        if [ "$lastline" != "" ]; then
            write ""
            lastline=""
        fi

        # Add extra build information if DEBUG_COMMENTS
        if [ $DEBUG_COMMENTS -eq 0 ]; then
            write "### File \"$relfile\":"
        fi

        # Process the file
        while IFS= read -r line; do
            lineno=$(($lineno+1))

            # Skip shell script definition
            if [ "$line" = "#!/bin/bash" ] || [ "$line" = "#!/bin/sh" ]; then
                continue
            fi

            # Gather all the globals so that we can put them at the top of the built file
            if [ "$line" = "###GLOBALS_END###" ]; then
                globalsection=1
                continue
            fi

            if [ "$line" = "###GLOBALS_START###" ]; then
                globalsection=0
                continue
            fi

            if [ $globalsection -eq 0 ]; then
                GLOBALS+=("$line")
            else
                # Skip multiple blank lines
                if [ "$lastline" = "" ] && [ "$line" = "" ]; then
                    continue
                fi

                # Skip comments if making a STRIP_COMMENTS build
                if [ $STRIP_COMMENTS -eq 0 ] && [[ "$(trim_leading_whitespace "$line")" == \#* ]]; then
                    continue
                fi

                # If we're making a DEBUG_COMMENTS build add the lineno for the function
                if [[ "$line" == "function "* ]] && [ $DEBUG_COMMENTS -eq 0 ]; then
                    # Make sure the comment doesn't get cramped in
                    if [ "$lastline" != "" ]; then
                        write ""
                    fi

                    write "## $relfile, line $lineno:"
                fi

                # Write the file's line
                write "$line"
                lastline="$line"
            fi
        done < "$file"
    done < <(find "$SCRIPTDIR/lib" -maxdepth 1 -type f -name "*.sh" | sort -V)

    # Change write target to the final output file
    TARGET="$BUILTFILE"

    write "#!/bin/bash"
    write ""

    # Add build info if we're not making a STRIP_COMMENTS build
    if [ $STRIP_COMMENTS -ne 0 ]; then
        write "## QuickScript version $VERSIONNO"
        write "## Build date: $(date '+%Y-%m-%d %T')"
        write ""
    fi

    # Append the global variables
    for globalvar in "${GLOBALS[@]}"; do
        write "$globalvar"
    done

    # Write all the contents from the temp file to the output file
    write ""
    while IFS= read -r line; do
        write "$line"
    done < "$TEMPFILE"

    # Remove temp file
    rm "$TEMPFILE"
}

build
