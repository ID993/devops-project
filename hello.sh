#!/bin/bash

NAME="devops-project"
echo "Starting $NAME"

if [ -d "$NAME" ]; then
	echo "Directory $NAME exists"
else
	echo "Directory $NAME does not exist"
	mkdir "$NAME"
	echo "Created directory $NAME"
fi
