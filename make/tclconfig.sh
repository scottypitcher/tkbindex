#!/bin/sh
#
# Copyright (C) - Scott Pitcher, 2020
#
# Import the local tcl configuration.
# Parameters:
#	$1	Relative path to the target configuration file.
# 	$2	Path and name of a specific tclConfig.sh file to use.

# Find the location of tclConfig.sh
# Modelled on TEA_PATH_TCLCONFIG from tcl.m4
# Params:
#	$1	= Optional --with-tcl directory.
# Sets:
#	TCLCONFIG_SH
#
find_tclConfig()
{
    __with_tcl=$1
    TCLCONFIG_SH=""
    # Ok, lets find the tcl configuration
    # First, look for one uninstalled.
    # the alternative search directory is invoked by --with-tcl
    #

    # First check to see if --with-tcl was specified.
    if [ -n "$__with_tcl" ] ; then
	if [ -e "$__with_tcl/tclConfig.sh"; then
	    TCLCONFIG_SH="$__with_tcl/tclConfig.sh"
	    return
	else
	    echo "Couldn't find tclConfig.sh in $__with_tcl (--with-tcl)."
	    exit 255
	fi
    fi

    # then check for a private Tcl installation
    for i in \
	    ../tcl \
	    `ls -dr ../tcl[[8-9]].[[0-9]].[[0-9]]* 2>/dev/null` \
	    `ls -dr ../tcl[[8-9]].[[0-9]] 2>/dev/null` \
	    `ls -dr ../tcl[[8-9]].[[0-9]]* 2>/dev/null` \
	    ../../tcl \
	    `ls -dr ../../tcl[[8-9]].[[0-9]].[[0-9]]* 2>/dev/null` \
	    `ls -dr ../../tcl[[8-9]].[[0-9]] 2>/dev/null` \
	    `ls -dr ../../tcl[[8-9]].[[0-9]]* 2>/dev/null` \
	    ../../../tcl \
	    `ls -dr ../../../tcl[[8-9]].[[0-9]].[[0-9]]* 2>/dev/null` \
	    `ls -dr ../../../tcl[[8-9]].[[0-9]] 2>/dev/null` \
	    `ls -dr ../../../tcl[[8-9]].[[0-9]]* 2>/dev/null` ; do
	if [ "`uname -o`" = "Msys" ]; then
	    if [ -e "$i/win/tclConfig.sh" ]; then
		TCLCONFIG_SH="$i/win/tclConfig.sh"
		return
	    fi
	fi
	if [ -e "$i/unix/tclConfig.sh" ]; then
	    TCLCONFIG_SH="$i/unix/tclConfig.sh"
	    return
	fi
    done

    # on Darwin, check in Framework installation locations
    if [ "`uname -s`" = "Darwin" ]; then
	for i in `ls -d ~/Library/Frameworks 2>/dev/null` \
		`ls -d /Library/Frameworks 2>/dev/null` \
		`ls -d /Network/Library/Frameworks 2>/dev/null` \
		`ls -d /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/Library/Frameworks/Tcl.framework 2>/dev/null` \
		`ls -d /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/Network/Library/Frameworks/Tcl.framework 2>/dev/null` \
		`ls -d /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Tcl.framework 2>/dev/null` \
		; do
	    if [ -e "$i/Tcl.framework/tclConfig.sh" ]; then
		TCLCONFIG_SH="$i/Tcl.framework/tclConfig.sh"
		return
	    fi
	done
    fi

    # TEA specific: on Windows, check in common installation locations
    if [ "`uname -o`" = "Msys" ]; then
	for i in `ls -d C:/Tcl/lib 2>/dev/null` \
		`ls -d C:/Progra~1/Tcl/lib 2>/dev/null` \
		`ls -dr C:/Tcl[8-9].[0-9].[0-9]/lib 2>/dev/null` \
		`ls -d C:/Progra~1/Tcl[8-9].[0-9].[0-9]/lib 2>/dev/null` ; do
	    if [ -e "$i/tclConfig.sh" ]; then
		TCLCONFIG_SH="$i/tclConfig.sh"
		return
	    fi
	done
    fi

    # check in a few common install locations
    for i in `ls -d /usr/lib 2>/dev/null` \
	    `ls -d /usr/local/lib 2>/dev/null` \
	    `ls -d /usr/contrib/lib 2>/dev/null` \
	    `ls -d /usr/pkg/lib 2>/dev/null` \
	    `ls -d /usr/lib 2>/dev/null` \
	    `ls -d /usr/lib64 2>/dev/null` \
	    `ls -d /usr/lib/tcl8.6 2>/dev/null` \
	    `ls -d /usr/lib/tcl8.5 2>/dev/null` \
	    `ls -d /usr/local/lib/tcl8.6 2>/dev/null` \
	    `ls -d /usr/local/lib/tcl8.5 2>/dev/null` \
	    `ls -d /usr/local/lib/tcl/tcl8.6 2>/dev/null` \
	    `ls -d /usr/local/lib/tcl/tcl8.5 2>/dev/null` \
	    ; do
	if [ -e "$i/tclConfig.sh" ]; then
	    TCLCONFIG_SH="$i/tclConfig.sh"
	    return
	fi
    done
}

# Where is the local tclConfig.sh file?
if [ ! -z "$2" ]; then
    TCLCONFIG_SH="$2"
fi
if [ -z "$TCLCONFIG_SH" ]; then
    TCLCONFIG_SH=`whereis tclConfig.sh | cut -d" " -f2 -s`
fi
if [ -z "$TCLCONFIG_SH" ]; then
    find_tclConfig
fi
if [ -z "$TCLCONFIG_SH" ]; then
    echo "Couldn't find tclConfig.sh on this system. Please make sure it's in your PATH."
    exit 255
fi

# Source the local tcl config.
. $TCLCONFIG_SH

set | grep "^TCL_*" | sed "s/'//g" > $1
