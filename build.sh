#!/bin/bash

# Shorthand for writing to file
function write {
    echo "$1" >> "$TARGET"
}

# Build config
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSIONNO="0.1"
LIBNAME="quickscript"
TEMPFILE="$SCRIPTDIR/.$LIBNAME.tmp"
BUILTFILE="$SCRIPTDIR/$LIBNAME-$VERSIONNO.sh"
TARGET="$TEMPFILE"
LASTLINE=""
GLOBALS=()

if [ -e "$BUILTFILE" ]; then
    rm "$BUILTFILE"
fi

while IFS= read -r file; do
    globalsection=1
    lineno=0
    relfile="${file/$SCRIPTDIR/}"

    if [ "$LASTLINE" != "" ]; then
        write ""
    fi

    write "### File \"$relfile\":"

    while IFS= read -r line; do
        lineno=$(($lineno+1))

        if [ "$line" = "#!/bin/bash" ] || [ "$line" = "#!/bin/sh" ]; then
            continue
        fi

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
            if [ "$LASTLINE" = "" ] && [ "$line" = "" ]; then
                continue
            else
                if [[ "$line" == "function "* ]]; then
                    write "## $relfile, line $lineno:"
                fi

                write "$line"
            fi
        fi

        LASTLINE="$line"
    done < "$file"
done < <(find "$SCRIPTDIR/lib" -maxdepth 1 -type f -name "*.sh" | sort -V)

TARGET="$BUILTFILE"

write "#!/bin/bash"
write ""
write "## QuickScript version $VERSIONNO"
write "## Build date: "$(date "+%Y-%m-%d %T")""
write ""

for globalvar in "${GLOBALS[@]}"; do
    write "$globalvar"
done

write ""
while IFS= read -r line; do
    write "$line"
done < "$TEMPFILE"

rm "$TEMPFILE"
