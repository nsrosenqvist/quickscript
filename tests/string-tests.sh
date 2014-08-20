#!/bin/bash

oldpwd="$(pwd)" && cd "$(dirname "$0")" && source ../lib/string.sh

function testTrimWhiteSpace() {
	assertEquals "test text" "$(trim_whitespace '  test text  ')"
}

function testTrimLeadingWhiteSpace() {
	assertEquals "test text" "$(trim_whitespace '  test text')"
}

function testTrimTrailingWhiteSpace() {
	assertEquals "test text" "$(trim_whitespace 'test text  ')"
}

function testStringReplace() {
	assertEquals "We need an example. Orange it is! What an example!" "$(string_replace "We need an example. Example it is! What an example!" "Example" "Orange")"
}

function testStringReplaceAll() {
	assertEquals "We need an orange. Example it is! What an orange!" "$(string_replace_all "We need an example. Example it is! What an example!" "example" "orange")"
}

function testStringIReplace() {
	assertEquals "We need an orange. Example it is! What an example!" "$(string_ireplace "We need an example. Example it is! What an example!" "Example" "orange")"
}

function testStringIReplaceAll() {
	assertEquals "We need an orange. orange it is! What an orange!" "$(string_ireplace_all "We need an example. Example it is! What an example!" "example" "orange")"
}

function testStringIReplaceAll() {
	assertEquals "short example" "$(substring "very short example" 5)"
	assertEquals "very" "$(substring "very short example" 0 4)"
}

function testToUppercase() {
	assertEquals "LOWERCASE WORDS" "$(to_uppercase "lowercase words")"
}

function testToLowercase() {
	assertEquals "uppercase words" "$(to_lowercase "UPPERCASE WORDS")"
}

function testCapitalize() {
	assertEquals "John" "$(capitalize "john")"
}

function testCompareVersions() {
	compare_versions 1 "=" 1 && assertEquals 0 $?
	compare_versions 1.1.1 "=" 1.01.1 && assertEquals 0 $?
	compare_versions 1.0.2 "=" 1.0.2.0 && assertEquals 0 $?
	compare_versions 1..0 "=" 1.0.0.0 && assertEquals 0 $?
	compare_versions 1.3 "=" 1.0.2.0 && assertNotEquals 0 $?
	compare_versions 1..0.43 "=" 1.0.0.0 && assertNotEquals 0 $?
	
	compare_versions 3.2.1.9.81444 ">" 3.2 && assertEquals 0 $?
	compare_versions 1..1 ">" 1.0 && assertEquals 0 $?
	compare_versions 1.2 ">" 1.3 && assertNotEquals 0 $?
	compare_versions 1.01.0 ">=" 1.1 && assertEquals 0 $?
	compare_versions 1.2 ">=" 1.3 && assertNotEquals 0 $?
	compare_versions 0.1 ">=" 1.0 && assertNotEquals 0 $?

	compare_versions 3.2 "<" 3.2.1.9.81444 && assertEquals 0 $?
	compare_versions 1.0 "<" 1..1 && assertEquals 0 $?
	compare_versions 1.3 "<" 1.2 && assertNotEquals 0 $?
	compare_versions 1.1 "<=" 1.01.0 && assertEquals 0 $?
	compare_versions 1.3 "<=" 1.2 && assertNotEquals 0 $?
	compare_versions 1.0 "<=" 0.1 && assertNotEquals 0 $?
}

cd "$oldpwd" && . shunit2
