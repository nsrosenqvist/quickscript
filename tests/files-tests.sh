#!/bin/bash

oldpwd="$(pwd)" && cd "$(dirname "$0")" && source ../quickscript.sh

function testFileExtension() {
	assertEquals "Wrong file extension returned" "txt" "$(file_extension "very-long.file.name.txt")"
}

function testFileName() {
	assertEquals "Wrong file name returned" "very-long.file.name" "$(file_name "very-long.file.name.txt")"
}

function testStripMultiSlash() {
	assertEquals "Slashes didn't get removed correctly" "/home/user/Documents/" "$(strip_multi_slash "//home////user/Documents//////")"
}

function testIsMountPoint() {
	assertEquals "Failed to recognize /" 0 $(is_mountpoint "/")
	assertEquals "Failed to recognize / and find /etc" 0 $(is_mountpoint "/" "/etc")
	assertNotEquals "Wrongly recognized /non-existing-location.i-promise" 0 $(is_mountpoint "/non-existing-location.i-promise")
	assertNotEquals "Recognized / and wrongly found /non-existing-location.i-promise" 0 $(is_mountpoint "/" "/non-existing-location.i-promise")
}

cd "$oldpwd" && . shunit2
