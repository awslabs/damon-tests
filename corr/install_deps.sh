#!/bin/bash

if ! sudo apt install -y xz-utils lftp python &> /dev/null
then
	# python package is not in Ubuntu 22.04
	sudo apt install -y xz-utils lftp python-is-python3
fi
