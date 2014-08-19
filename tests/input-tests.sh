#!/bin/bash

oldpwd="$(pwd)" && cd "$(dirname "$0")" && source ../quickscript.sh

function testAskResponse() {
	local tmpfile="$(dirname "$0")/.testAskReponse.tmp"
	
	echo "y" > "$tmpfile"
	ask "" < "$tmpfile"
	assertEquals "Didn't recognize lowercase y as yes" 0 $?

	echo "Y" > "$tmpfile"
	ask "" < "$tmpfile"
	assertEquals "Didn't recognize uppercase Y as yes" 0 $?

	echo "n" > "$tmpfile"
	ask "" < "$tmpfile"
	assertEquals "Didn't recognize lowercase n as no" 1 $?

	echo "N" > "$tmpfile"
	ask "" < "$tmpfile"
	assertEquals "Didn't recognize uppercase N as no" 1 $?

	rm "$tmpfile"
}

# function testQSOptsGroupedOptions() {
# 	local tmpfile="$(dirname "$0")/.qsOutput.tmp"

# 	cat << 'EOF' > "$tmpfile"
		
# 		cd "$(dirname "$0")" && source ../quickscript.sh
# 		OPTALIAS[--INSTALL-DIR]=-vn
# 		while qs_opts "vnp:" opt; do
# 			case "$opt" in
# 				-v) echo "v($OPTARG)";;
# 				-n) echo "n($OPTARG)";;
# 				-p) echo "p($OPTARG)";;
# 				\?) echo "error($OPTARG)";;
# 			esac
# 		done
# EOF

# 	local output="$(bash "$tmpfile" -op "/path/to/so-m ething" --INSTALL-DIR)"
# 	assertEquals "error(-o)\nv(-v)\nn(-n)\np(/path/to/so-m ething)" "$output"
# 	rm "$tmpfile"
# }

cd "$oldpwd" && . shunit2
