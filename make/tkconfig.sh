#!/bin/sh
#
# Copyright (C) - Scott Pitcher, 2020
#
# Import the local tk configuration.
# Parameters:
#	$1	Relative path to the target configuration file.
# 	$2	Path and name of a specific tkConfig.sh file to use.

# Where is the local tkConfig.sh file?
if [ ! -z "$2" ]; then
    TKCONFIG_SH="$2"
else
    TKCONFIG_SH=`whereis tkConfig.sh | cut -d" " -f2`
    if [ -z "$TKCONFIG_SH" ]; then
	echo "Couldn't find tkConfig.sh on this system. Please make sure it's in your PATH."
	exit 255
    fi
fi

# Source the local tk config.
. $TKCONFIG_SH

set | grep "^TK_*" | sed "s/'//g" > $1
