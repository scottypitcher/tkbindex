#!/usr/bin/tclsh
#
# Copyright (C) Scott Pitcher - 2020.
#
# A test implementation of bindex in tcl.
#
# bindex: a Tk bind extension that permits additional prefixes for querying, removing, replacing bindings.
#


package require Tk


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
    proc search {winortag event script} {
	return [string first $script [bind $winortag $event]]
    }
    
    proc remove {winortag event script} {
	if {[set first [string first $script [bind $winortag $event]]] < 0} {
	    return ""
	}
	return [string trim [string replace [bind $winortag $event] $first [expr $first+[string length $script]]]]
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
	    if {[set removed [remove $winortag $event [string range $script1 1 end]]] == ""} {
		# Not found, return false
		return 0
	    }

	    # Remove the deleted script from the real binding.
	    bind $winortag $event $removed

	    # Add the replacement binding if one is given.
	    if {$llen == 4} {
		bind $winortag $event "+$script2"
	    }
	    return 1

	} elseif {$ch1 == "?"} {
	    # New command, query.
	    # TODO: search for the binding.
	    if {[set start [search $winortag $event [string range $script1 1 end]]] < 0} {
		# Not found, return false
		return 0
	    }
	    return 1

	} elseif {$ch1 == "*"} {
	    # New command, add unique
	    # TODO: search for the binding and add if not found.
	    if {[set start [search $winortag $event [string range $script1 1 end]]] < 0} {
		bind $winortag $event "+[string range $script1 1 end]"
	    }

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

