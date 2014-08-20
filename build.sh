#!/bin/bash

source lib/instance.sh
source lib/string.sh
source lib/log.sh
source lib/input.sh

SCRIPTDIR="$(script_dir)"
BUILDDIR="$SCRIPTDIR/build/debug/"
LIBNAME="QuickScript"
LIBNAMELOW="$(to_lowercase "$LIBNAME")"
TEMPFILE="$BUILDDIR/.$LIBNAMELOW.tmp"
LIBFILENAME=""
BUILTFILE=""
VERSIONNO="debug"

LIB_COMMENTS=0
GLOBALS=()
WRITE_TARGET="$TEMPFILE"

# Shorthand for writing to file
function write {
    echo "$1" >> "$WRITE_TARGET"
}

function build {
    OPTALIAS[--STRIP-COMMENTS]=-s
    OPTALIAS[--VERSION]=-v

    while qs_opts "sv:" opt; do
        case "$opt" in
            -s|--strip-comments|--STRIP-COMMENTS)
                LIB_COMMENTS=1
            ;;
            -v|--version|--VERSION)
                VERSIONNO="$OPTARG"
            ;;
            \?)
                echo "Non-existent parameter specified: $OPTARG"
                echo "Aborting..."
                exit 1
            ;;
            \!)
                echo "$OPTARG requires a value specified"
                echo "Aborting..."
                exit 1
            ;;
        esac
    done

    local lastline=""
    LIBFILENAME="$LIBNAMELOW-$VERSIONNO.sh"
    BUILTFILE="$BUILDDIR/$LIBFILENAME"

    # Make sure that the build dir exists
    mkdir -p "$BUILDDIR"

    # Remove previously built file
    if [ -e "$BUILTFILE" ]; then
        rm "$BUILTFILE"
    fi

    # If tmp file exists, delete as well
    if [ -e "$TEMPFILE" ]; then
        rm "$TEMPFILE"
    fi

    # Make sure the tmp file gets deleted at end
    trap "rm -f '$TEMPFILE'" EXIT INT HUP TERM QUIT

    # Loop through all lib-files
    while IFS= read -r file; do
        local globalsection=1
        local lineno=0
        local relfile="${file/$SCRIPTDIR/}"

        # Make sure functions don't get cramped together
        if [ "$lastline" != "" ]; then
            write ""
            lastline=""
        fi

        # Add extra build information if LIB_COMMENTS
        if [ $LIB_COMMENTS -eq 0 ]; then
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

                # Skip comments if making a LIB_COMMENTS build
                if [ $LIB_COMMENTS -eq 1 ] && [[ "$(trim_leading_whitespace "$line")" == \#* ]]; then
                    continue
                fi

                # If we're making a LIB_COMMENTS build add the lineno for the function
                if [[ "$line" == "function "* ]] && [ $LIB_COMMENTS -eq 0 ]; then
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
    write ""
    WRITE_TARGET="$BUILTFILE"

    write "#!/bin/bash"
    write ""

    # Always add build info
    write "## QuickScript version $VERSIONNO"
    write "## Build date: $(date '+%Y-%m-%d %T')"
    write ""

    # Append the global variables
    write "QSVERSION=\"$VERSIONNO\""

    for globalvar in "${GLOBALS[@]}"; do
        write "$globalvar"
    done

    # Write all the contents from the temp file to the output file
    write ""
    while IFS= read -r line; do
        write "$line"
    done < "$TEMPFILE"
}

# Run build if script isn't being sourced
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    build $*
fi
