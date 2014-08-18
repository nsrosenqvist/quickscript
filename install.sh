#!/bin/bash

# Get build information from build.sh
source build.sh

INSTALLDIR="/usr/lib/"

function install {
	OPTALIAS[--INSTALL-DIR]=-i

	# Parse parameters
	while qs_opts "i:" opt; do
		case "$opt" in
			-i|--install-dir|--INSTALL-DIR)
				INSTALLDIR="$OPTARG"
			;;
			\?)
				echo "Non-existent parameter specified: $OPTARG"
				echo "Aborting..."
				exit 1
			;;
		esac
	done

	# Reset parameter parsing so that it doesn't interfere with build.sh
	INPUT_PROCESSED=0

	# Rebuild project
	echo "Building $LIBNAME $VERSIONNO..."
	build --STRIP-COMMENTS

	# If the build was successful, install it to $INSTALLDIR
	if [ $? -eq 0 ]; then
		echo "Build successful!"
		cp "$BUILTFILE" "$INSTALLDIR/"

		if [ $? -eq 0 ]; then
			local libpath=$(echo "$INSTALLDIR/$LIBFILENAME" | sed 's#//*#/#g')
			echo "$LIBNAME $VERSIONNO successfully installed to $INSTALLDIR"
			echo "Start using $LIBNAME by sourcing it into your BASH-scripts: source \"$libpath/\""
		else
			echo "Installation failed!"
			echo "Make sure you have the right permissions to write to $INSTALLDIR"
			exit 1
		fi
	else
		echo "Build failed!"
		echo "Aborting installation..."
		exit 1
	fi
}

# Run install if script isn't being sourced
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	install $*
fi
