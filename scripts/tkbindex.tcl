#!/usr/bin/wish
#
# Copyright (C) Scott Pitcher - 2020-2021
#
# This software is copyrighted (C) by Scott V. Pitcher of Melbourne, Australia
# and Low Power Linux Servers, 2021. The following terms apply to all files
# associated with the software unless explicitly disclaimed in individual
# files.
# 
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License version 3 as
# published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
# for more details.
# 
# You can find a copy of the GNU Lesser General Public License at:
# <https://www.gnu.org/licenses/>.
# 
# 
# See the file "license.terms" that came with the software distribution for
# details.
# 
# -----------------------------------------------------------------------------
# 
# bindex: a Tk bind extension that permits additional prefixes for querying,
# removing, replacing bindings.
#


package require Tk

package provide bindex 1.0

# bindex
# Usage:
#	bindex winortag
#	  Return all events for winortag.
#
#	bindex winortag event
#	  Return the bound script for event for winortag.
#
#	bindex winortag event script 
#	  Replace event binding with script for winortag.
#
#	bindex winortag event +script
#	  Append script to event binding for winortag.
#
# Extended:
#	bindex winortag event ?script
#	  Query if script is bound to event for winortag, returning true if found.
#
#	bindex winortag event -script
#	  Remove script from the scripts for winortag leaving other scripts in place.
#	  Returns true if removed.
#
#	bindex winortag event -script script
#	  Remove first script prefixed with "-" and replace with second script.
#	  Returns true if removed AND added, 0 if not removed.
#
#	bindex winortag event *script
#	  Add script to bindings for winortag, if it doesn't exist already.
#	  Returns true if added.
#
proc bindex {args} {

    set help "bindex winortag ?event ?\[ |+|-|*|?\]script? ?+script?"

    if {[set llen [llength $args]] < 1} {
	error "usage: $help"
    }
    
    # Search the bindings for event in winortag for script and return it's start index.
    # Note we have to insert before and after our script, and also search 
    # Returns:
    #	""		Not found
    #	n1 n2		The start and end index.
    proc search {winortag event script} {
	set bindings [bind $winortag $event]
	set blen [string length $bindings]
	set slen [string length $script]
	set result ""

	# TODO: escape the '*' in string match ...
# 	puts "search: script=<$script> bindings=<$bindings>"
	if {[string compare "$script" "$bindings"] == 0} {
	    # The whole binding matches
# 	    puts "search: whole binding matches"
	    set result [list 0 [expr $slen - 1]]

	} elseif {[string compare "$script\n" [string range $bindings 0 $slen]] == 0} {
	    # Found match at the start with a trailing \n.
# 	    puts "search: start matches with \\n"
	    set result [list 0 $slen]

	} elseif {[string compare "\n$script" [string range $bindings end-$slen end]] == 0} {
	    # Found match at the end with a leading \n.
# 	    puts "search: end matches with \\n "
	    set result [list [expr $blen - $slen - 1] [expr $blen - 1]]

	} elseif {[set n1 [string first "\n$script\n" $bindings]] > -1} {
	    # Found a match in the middle with leading and trailing \n,
	    # and one of these has to be removed.
# 	    puts "search: middle matches with \\n \\n"
	    set result [list $n1 [expr $n1 + $slen]]
	}
	
	return $result
    }
    
    lassign $args winortag event script1 script2
    
    if {$llen == 1} {
	# The default behaviour.
	uplevel bind $winortag

    } elseif {$llen == 2} {
	# The default behaviour.
	uplevel bind $winortag $event

    } elseif {$llen <= 4} {
    
	if {[set ch1 [string index $script1 0]] == "-"} {
	    # New command, remove or remove and replace.

	    if {[set indices [search $winortag $event [string range $script1 1 end]]] == ""} {
		# Not found, return false
		return 0
	    }
	    lassign $indices n1 n2
	    bind $winortag $event [string replace [bind $winortag $event] $n1 $n2]

	    # Add the replacement binding if one is given.
	    if {$llen == 4} {
		bind $winortag $event "+$script2"
	    }
	    return 1

	} elseif {$ch1 == "?"} {
	    # New command, query.
	    if {[set indices [search $winortag $event [string range $script1 1 end]]] == ""} {
		# Not found, return false
		return 0
	    }
	    return 1

	} elseif {$ch1 == "*"} {
	    # New command, add unique
	    if {[set indices [search $winortag $event [string range $script1 1 end]]] == ""} {
		bind $winortag $event "+[string range $script1 1 end]"
		return 1
	    }
	    return 0

	} else {
	    # Default behaviour is to pass it through to bind.
	    if {$llen != 3} {
		error "wrong number of arguments: $help"
	    }
	    return [bind $winortag $event $script1]
	}

    } else {
	error "wrong number of arguments: $help"
    }
}

# kate: syntax Tcl/Tk;
