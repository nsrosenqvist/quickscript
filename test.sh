#!/bin/bash

source build.sh

# If the built library doesn't exist we have to first build it
if [ ! -f "$BUILTFILE" ]; then
	echo "Building $LIBNAME $VERSIONNO..."
	build --DEBUG
fi

# Create a symbolic link to quickscript.sh
if [ ! -h "$(script_dir)/$LIBNAMELOW.sh" ]; then
	ln -s "$BUILTFILE" "$(script_dir)/$LIBNAMELOW.sh"
fi

# Run all tests
while IFS= read -r file; do
	echo "Running test-file \"$(basename "$file")\":"
	(bash "$file")
done < <(find "$(script_dir)/tests" -maxdepth 1 -type f -name "*.sh" | sort -V)
