#!/bin/bash

oldpwd="$(pwd)" && cd "$(dirname "$0")" && source ../quickscript.sh

function testLockScript() {
	local lock_file="$(lock_file)"

	if [ -e "$lock_file" ]; then
		rm -R "$lock_file"
	fi

	lock_script
	assertTrue "Lock script didn't get created" "[ -e "$lock_file" ]"

	(lock_script) > /dev/null 2>&1
	assertNotEquals "Lock script didn't interrupt execution" 0 $?

	unlock_script
	assertFalse "Script didn't get unlocked" "[ -e "$lock_file" ]"
}

function testRunningInstances() {
	assertTrue "Less than one running instance was reported" "[ $(running_instances) -gt 0 ]"
}

cd "$oldpwd" && . shunit2
