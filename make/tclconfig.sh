#!/bin/sh
#
# Copyright (C) - Scott Pitcher, 2020
#
# Import the local tcl configuration.
# Parameters:
#	$1	Relative path to the target configuration file.
# 	$2	Path and name of a specific tclConfig.sh file to use.

# Where is the local tclConfig.sh file?
if [ ! -z "$2" ]; then
    TCLCONFIG_SH="$2"
else
    TCLCONFIG_SH=`whereis tclConfig.sh | cut -d" " -f2`
    if [ -z "$TCLCONFIG_SH" ]; then
	echo "Couldn't find tclConfig.sh on this system. Please make sure it's in your PATH."
	exit 255
    fi
fi

# Source the local tcl config.
. $TCLCONFIG_SH

set | grep "^TCL_*" | sed "s/'//g" > $1
