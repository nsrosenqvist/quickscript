#!/bin/bash

oldpwd="$(pwd)" && cd "$(dirname "$0")" && source ../quickscript.sh

function testAbortOnFailure() {
	(abort_on_failure 0) 
	assertEquals "Wrongly halted execution" 0 $?

	(abort_on_failure 1) > /dev/null 2>&1
	assertNotEquals "Failed to cancel execution" 0 $?
}

cd "$oldpwd" && . shunit2
