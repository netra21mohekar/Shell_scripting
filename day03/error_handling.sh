#!/bin/bash

create_directory(){
	mkdir demo
}

if ! create_directory; then
	echo "the code is being exited as the directory already exits"
	exit 1
fi

echo "this should not work because the code is interrupted"
