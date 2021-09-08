#!/bin/sh
#
# Copyright (C) - Scott Pitcher, 2020
#
# Import the local tk configuration.
# Parameters:
#	$1	Relative path to the target configuration file.
# 	$2	Path and name of a specific tkConfig.sh file to use.

# Find the location of tkConfig.sh
# Modelled on TEA_PATH_TKCONFIG from tcl.m4
# Params:
#	$1	= Optional --with-tk directory.
# Sets:
#	TKCONFIG_SH
#
find_tkConfig()
{
    __with_tk=$1
    TKCONFIG_SH=""
    # Ok, lets find the tk configuration
    # First, look for one uninstalled.
    # the alternative search directory is invoked by --with-tk
    #

    # First check to see if --with-tk was specified.
    if [ -n "$__with_tk" ] ; then
	if [ -e "$__with_tk/tkConfig.sh"; then
	    TKCONFIG_SH="$__with_tk/tkConfig.sh"
	    return
	else
	    echo "Couldn't find tkConfig.sh in $__with_tk (--with-tk)."
	    exit 255
	fi
    fi

    # then check for a private Tcl installation
    for i in \
	    ../tcl \
	    `ls -dr ../tcl[8-9].[0-9].[0-9]* 2>/dev/null` \
	    `ls -dr ../tcl[8-9].[0-9] 2>/dev/null` \
	    `ls -dr ../tcl[8-9].[0-9]* 2>/dev/null` \
	    ../../tcl \
	    `ls -dr ../../tcl[8-9].[0-9].[0-9]* 2>/dev/null` \
	    `ls -dr ../../tcl[8-9].[0-9] 2>/dev/null` \
	    `ls -dr ../../tcl[8-9].[0-9]* 2>/dev/null` \
	    ../../../tcl \
	    `ls -dr ../../../tcl[8-9].[0-9].[0-9]* 2>/dev/null` \
	    `ls -dr ../../../tcl[8-9].[0-9] 2>/dev/null` \
	    `ls -dr ../../../tcl[8-9].[0-9]* 2>/dev/null` ; do
	if [ "`uname -o`" = "Msys" ]; then
	    if [ -e "$i/win/tkConfig.sh" ]; then
		TKCONFIG_SH="$i/win/tkConfig.sh"
		return
	    fi
	fi
	if [ -e "$i/unix/tkConfig.sh" ]; then
	    TKCONFIG_SH="$i/unix/tkConfig.sh"
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
	    if [ -e "$i/Tcl.framework/tkConfig.sh" ]; then
		TKCONFIG_SH="$i/Tcl.framework/tkConfig.sh"
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
	    if [ -e "$i/tkConfig.sh" ]; then
		TKCONFIG_SH="$i/tkConfig.sh"
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
	if [ -e "$i/tkConfig.sh" ]; then
	    TKCONFIG_SH="$i/tkConfig.sh"
	    return
	fi
    done
}


# Where is the local tkConfig.sh file?
if [ ! -z "$2" ]; then
    TKCONFIG_SH="$2"
fi
if [ -z "$TKCONFIG_SH" ]; then
    TKCONFIG_SH=`whereis tkConfig.sh | cut -d" " -f2 -s`
fi
if [ -z "$TKCONFIG_SH" ]; then
    find_tkConfig
fi
if [ -z "$TKCONFIG_SH" ]; then
    echo "Couldn't find tkConfig.sh on this system. Please make sure it's in your PATH."
    exit 255
fi

# Source the local tk config.
. $TKCONFIG_SH

set | grep "^TK_*" | sed "s/'//g" > $1
