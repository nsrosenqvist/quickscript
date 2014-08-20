#!/bin/bash

source build.sh

# Run all tests
for file in "tests/"*".sh"; do
	echo "Running test-file \"$(basename "$file")\":"
	(bash "$file")
done
