#!/bin/bash

oldpwd="$(pwd)" && cd "$(dirname "$0")" && source ../lib/files.sh

function testFileExtension() {
	assertEquals "txt" "$(file_extension "very-long.file.name.txt")"
}

function testFileName() {
	assertEquals "very-long.file.name" "$(file_name "very-long.file.name.txt")"
}

function testStripMultiSlash() {
	assertEquals "/home/user/Documents/" "$(strip_multi_slash "//home////user/Documents//////")"
}

function testIsMountPoint() {
	is_mountpoint "/" && assertEquals "Failed to recognize /" 0 $?
	is_mountpoint "/" "/etc" && assertEquals "Failed to recognize / and find /etc" 0 $?
	is_mountpoint "/non-existing-location.i-promise" && assertNotEquals "Wrongly recognized /non-existing-location.i-promise" 0 $?
	is_mountpoint "/" "/non-existing-location.i-promise" && assertNotEquals "Recognized / and wrongly found /non-existing-location.i-promise" 0 $?
}

cd "$oldpwd" && . shunit2
