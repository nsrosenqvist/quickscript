#!/bin/bash

oldpwd="$(pwd)" && cd "$(dirname "$0")" && source ../lib/input.sh

function oneTimeSetUp() {
	ask_tmpfile="$(dirname "$0")/.testAskReponse.tmp"
	qsopts_tmpfile="$(dirname "$0")/.testQSOptsScript.tmp"
	qsopts_input_tmpfile="$(dirname "$0")/.testQSOptsInput.tmp"

	cat << 'EOF' > "$qsopts_tmpfile"
		cd "$(dirname "$0")" && source ../lib/input.sh
		OPTALIAS[--DIR]=-p
		OPTALIAS[--VERBOSE]=-v
		OPTALIAS[--MODE-DETAILED]=-vn
		OPTALIAS[--ALL]=-vnp

		while qs_opts "vnp:" opt $*; do
		    case "$opt" in
		        -v) echo -n "v($OPTARG)";;
		        -n) echo -n "n($OPTARG)";;
		        -p) echo -n "p($OPTARG)";;
		        \?) echo -n "nofound($OPTARG)";;
                \!) echo -n "error($OPTARG)";;
		    esac
		done

		eval "$OPTUPDATECMD"
		echo -n "$2"
EOF
}

function oneTimeTearDown() {
	rm "$ask_tmpfile"
	rm "$qsopts_tmpfile"
	rm "$qsopts_input_tmpfile"
}

function testAskResponse() {
	echo "y" > "$ask_tmpfile"
	ask "" < "$ask_tmpfile"
	assertEquals "Didn't recognize lowercase y as yes" 0 $?

	echo "Y" > "$ask_tmpfile"
	ask "" < "$ask_tmpfile"
	assertEquals "Didn't recognize uppercase Y as yes" 0 $?

	echo "n" > "$ask_tmpfile"
	ask "" < "$ask_tmpfile"
	assertEquals "Didn't recognize lowercase n as no" 1 $?

	echo "N" > "$ask_tmpfile"
	ask "" < "$ask_tmpfile"
	assertEquals "Didn't recognize uppercase N as no" 1 $?
}

function testQSOpts() {
	local output=""
	local expected=""

	(qs_opts "vnp") > /dev/null 2>&1
	assertNotEquals "Failed to handle erroneous parameters" 0 $?

	output="$(bash "$qsopts_tmpfile" -on --NONE --NONE="/dev/null" -p)"
	expected="nofound(-o)n(-n)nofound(--NONE)nofound(--NONE)error(-p)"
	assertEquals "Failed to handle erroneous opts" "$expected" "$output"

	output="$(bash "$qsopts_tmpfile" -vn)"
	expected="v(-v)n(-n)"
	assertEquals "Failed to process optgroup" "$expected" "$output"

	output="$(bash "$qsopts_tmpfile" -p "/home/user" -p="/home/user")"
	expected="p(/home/user)p(/home/user)"
	assertEquals "Failed to process value assignment" "$expected" "$output"

	output="$(bash "$qsopts_tmpfile" -vnp "/home/user" -vnp="/home/user")"
	expected="v(-v)n(-n)p(/home/user)v(-v)n(-n)p(/home/user)"
	assertEquals "Failed to process optgroup value assignment" "$expected" "$output"

	output="$(bash "$qsopts_tmpfile" -v --verbose)"
	expected="v(-v)v(-v)"
	assertEquals "Failed to process long opts" "$expected" "$output"

	output="$(bash "$qsopts_tmpfile" --path "/home/user" --path="/home/user")"
	expected="p(/home/user)p(/home/user)"
	assertEquals "Failed to process long opts value assignment" "$expected" "$output"

	output="$(bash "$qsopts_tmpfile" -v --VERBOSE)"
	expected="v(-v)v(-v)"
	assertEquals "Failed to process opt alias" "$expected" "$output"

	output="$(bash "$qsopts_tmpfile" --DIR "/home/user" --DIR="/home/user")"
	expected="p(/home/user)p(/home/user)"
	assertEquals "Failed to process opt alias with value assignment" "$expected" "$output"

	output="$(bash "$qsopts_tmpfile" -vn --MODE-DETAILED)"
	expected="v(-v)n(-n)v(-v)n(-n)"
	assertEquals "Failed to process optgroup alias" "$expected" "$output"

	output="$(bash "$qsopts_tmpfile" --ALL "/home/user" --ALL="/home/user")"
	expected="v(-v)n(-n)p(/home/user)v(-v)n(-n)p(/home/user)"
	assertEquals "Failed to process optgroup alias with value assignment" "$expected" "$output"

	output="$(bash "$qsopts_tmpfile" -vn first second)"
	expected="v(-v)n(-n)second"
	assertEquals "Failed to process terminal input" "$expected" "$output"

	output="$(echo "second" | bash "$qsopts_tmpfile" -vn first)"
	expected="v(-v)n(-n)second"
	assertEquals "Failed to process pipe input" "$expected" "$output"

	echo "second" > "$qsopts_input_tmpfile"
	output="$(bash "$qsopts_tmpfile" -vn first < "$qsopts_input_tmpfile")"
	expected="v(-v)n(-n)second"
	assertEquals "Failed to process file input" "$expected" "$output"
}

cd "$oldpwd" && . shunit2
