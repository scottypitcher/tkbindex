#!/usr/bin/wish
#
# Copyright (C) Scott Pitcher - 2020-2021.
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
# Test functions for the bindex extension.
#

# For local path setup (for testing I install it under ~/tcltk).
catch "source ~/.wishrc"

package require Tk
package require bindex 1.0
# source "scripts/tkbindex.tcl.in"
package require tcltest


# puts "Search for the (1) binding = [bindex $W <Enter> "?puts \"(bind) Enter %W (1)\""]"
# 
# # Try replacing.
# bindex $W <Enter> "-puts \"(bind) Enter %W (1)\""  "puts \"(bindex) Enter %W (4)\""
# puts "Bindings after replacing (1) with (4) = [bind $W <Enter>]"
# puts "Search for the (1) binding = [bindex $W <Enter> "?puts \"(bind) Enter %W (1)\""]"
# 
# # replace the (4) one with (5)
# bindex $W <Enter> "-puts \"(bindex) Enter %W (4)\""  "puts \"(bindex) Enter %W (5)\""
# puts "Bindings after replacing (4) with (5) = [bind $W <Enter>]"
# 
# # replace the middle (3) one with (6)
# bindex $W <Enter> "-puts \"(bindex) Enter %W (3)\""  "puts \"(bindex) Enter %W (6)\""
# puts "Bindings after replacing (3) with (6) = [bind $W <Enter>]"
# 
# # Try to add something that's already there.
# bindex $W <Enter> "*puts \"(bindex) Enter %W (5)\""
# puts "Bindings after unique adding (5) = [bind $W <Enter>]"
# bindex $W <Enter> "*puts \"(bindex) Enter %W (7)\""
# puts "Bindings after unique adding (7) = [bind $W <Enter>]"





# bindex test code.
proc moduleTests {} {

    # Test each bindex subcommand.
    # ---command-name description body result output {options:setup cleanup match-type returncode erroroutput}
    
    # bindex tag
    #     Return a list whose elements are all the sequences for which there exist bindings for tag.  Refer
    #     to bind for complete details.
    # 
    lappend testlist {"A. bindex" "compare bind <tag> and bindex <tag> output - should match" {
	return [string compare [bind $W] [bindex $W]]
	} 0 {} setup-T-F-W}

    # bindex tag sequence
    # 	Return the script currently bound to sequence.  Refer to bind for complete details.
    lappend testlist {"B. bindex" "compare bind <tag> <sequence> and bindex <tag> <sequence> output - should match" {
	return [string compare [bind $W <Enter>] [bindex $W <Enter>]]
	} 0 {}}


    # Prove that the <Enter> binding is empty before we start.
    lappend testlist {"C. bindex" "Show that default <Enter> bindings are empty" {
	puts -nonewline [bind $W <Enter>]
	return 1
	} 1 ""}

    # bindex tag sequence script
    #     Arrange  for  script to be evaluated whenever the event(s) given by sequence occur in the window(s)
    #     given by tag.  Refer to bind for complete details.
    lappend testlist {"D. bindex" "bind places an <Enter> binding" {
	set result [bind $W <Enter> "puts \"(bind) Enter %W (1)\""]
	puts -nonewline [bind $W <Enter>]
	return $result
	} {} {puts "(bind) Enter %W (1)"}}
    lappend testlist {"D. bindex" "bindex replaces the <Enter> binding" {
	set result [bindex $W <Enter> "puts \"(bindex) Enter %W (1)\""]
	puts -nonewline [bind $W <Enter>]
	return $result
	} {} {puts "(bindex) Enter %W (1)"} }
	
    # bindex tag sequence +script
    # 	Add script to the scripts that will be evaluated whenever the event(s) given by sequence occur in the
    # 	window(s)  given  by  tag. Refer to bind for complete details.
    lappend testlist {"E. bindex" "bindex adds a three more <Enter> bindings" {
	bindex $W <Enter> "+puts \"(bindex) Enter %W (2)\""
	bindex $W <Enter> "+puts \"(bindex) Enter %W (3)\""
	bindex $W <Enter> "+puts \"(bindex) Enter %W (4)\""
	puts -nonewline [bind $W <Enter>]
	return 1
	} 1 {puts "(bindex) Enter %W (1)"
puts "(bindex) Enter %W (2)"
puts "(bindex) Enter %W (3)"
puts "(bindex) Enter %W (4)"} }

    # bindex tag sequence ?script
    # 	Search the scripts that will be evaluated whenever the event(s) given by sequence occur in the window(s)
    # 	given by tag for script script, and return true if found, otherwise false.
    # 
    lappend testlist {"F. bindex" "bindex searches for the first <Enter> binding" {
	return [bindex $W <Enter> "?puts \"(bindex) Enter %W (1)\""]
	} 1 {} }
    lappend testlist {"F. bindex" "bindex searches for the last <Enter> binding" {
	return [bindex $W <Enter> "?puts \"(bindex) Enter %W (4)\""]
	} 1 {} }
    lappend testlist {"F. bindex" "bindex searches for a middle <Enter> binding" {
	return [bindex $W <Enter> "?puts \"(bindex) Enter %W (2)\""]
	} 1 {} }
    lappend testlist {"F. bindex" "bindex searches for a nonexistant <Enter> binding, returns false" {
	return [bindex $W <Enter> "?puts \"(bindex) Enter %W (7)\""]
	} 0 {} }
    lappend testlist {"F. bindex" "bindex searches for a nonexistant partial <Enter> binding, returns false" {
	return [bindex $W <Enter> "?puts \"(bindex) Enter"]
	} 0 {} }

    # bindex tag sequence -script
    # 	Remove script from the scripts that will be evaluated whenever the event(s) given by sequence occur in the 
    # 	window(s)  given  by tag. Any trailing or leading carriage return will also be removed.
    # 
    lappend testlist {"G. bindex" "bindex removes a middle <Enter> binding" {
	set result [bindex $W <Enter> "-puts \"(bindex) Enter %W (2)\""]
	puts -nonewline [bind $W <Enter>]
	return $result
	} 1 {puts "(bindex) Enter %W (1)"
puts "(bindex) Enter %W (3)"
puts "(bindex) Enter %W (4)"} }
    lappend testlist {"G. bindex" "bindex removes the last <Enter> binding" {
	set result [bindex $W <Enter> "-puts \"(bindex) Enter %W (4)\""]
	puts -nonewline [bind $W <Enter>]
	return $result
	} 1 {puts "(bindex) Enter %W (1)"
puts "(bindex) Enter %W (3)"} }
    lappend testlist {"G. bindex" "bindex removes the first <Enter> binding" {
	set result [bindex $W <Enter> "-puts \"(bindex) Enter %W (1)\""]
	puts -nonewline [bind $W <Enter>]
	return $result
	} 1 {puts "(bindex) Enter %W (3)"} }
    lappend testlist {"G. bindex" "bindex tries to removes a non existant <Enter> binding, returns false" {
	set result [bindex $W <Enter> "-puts \"(bindex) Enter %W (10)\""]
	puts -nonewline [bind $W <Enter>]
	return $result
	} 0 {puts "(bindex) Enter %W (3)"} }
    lappend testlist {"G. bindex" "bindex tries to removes a non existant <Enter> binding with partial match, returns false" {
	set result [bindex $W <Enter> "-puts \"(bindex) Enter"]
	puts -nonewline [bind $W <Enter>]
	return $result
	} 0 {puts "(bindex) Enter %W (3)"} }
    lappend testlist {"G. bindex" "bindex removes the last remaining <Enter> binding" {
	set result [bindex $W <Enter> "-puts \"(bindex) Enter %W (3)\""]
	puts -nonewline [bind $W <Enter>]
	return $result
	} 1 {} }
    
    
    # bindex tag sequence -script1 script2
    # 	Remove  script1  from the scripts that will be evaluated whenever the event(s) given by sequence occur in
    # 	the window(s) given by tag, and add script2 to those scripts.
    # 
    # TODO:
    lappend testlist {"H. bindex" "bindex places an <Enter> binding and then replaces it" {
	bindex $W <Enter> "puts \"(bindex) Enter %W (2)\""
	set result [bindex $W <Enter> "-puts \"(bindex) Enter %W (2)\"" "puts \"(bindex) Enter %W (1)\""]
	puts -nonewline [bind $W <Enter>]
	return $result
	} 1 {puts "(bindex) Enter %W (1)"} }
    lappend testlist {"H. bindex" "bindex tries to replace a nonexistant <Enter> binding, returns false" {
	set result [bindex $W <Enter> "-puts \"(bindex) Enter %W (2)\"" "puts \"(bindex) Enter %W (1)\""]
	puts -nonewline [bind $W <Enter>]
	return $result
	} 0 {puts "(bindex) Enter %W (1)"} }

    # bindex tag sequence *script
    # 	If script does not exist in the scripts that will be evaluated whenever the event(s) given by sequence occur
    # 	in  the  window(s) given by tag, then add it to those scripts.
    # TODO:
    lappend testlist {"I. bindex" "bindex adds a new <Enter> binding if it doesn't exist" {
	set result [bindex $W <Enter> "*puts \"(bindex) Enter %W (2)\""]
	puts -nonewline [bind $W <Enter>]
	return $result
	} 1 {puts "(bindex) Enter %W (1)"
puts "(bindex) Enter %W (2)"} }
    lappend testlist {"I. bindex" "bindex tries to add a new <Enter> binding that already exists, and returns false" {
	set result [bindex $W <Enter> "*puts \"(bindex) Enter %W (2)\""]
	puts -nonewline [bind $W <Enter>]
	return $result
	} 0 {puts "(bindex) Enter %W (1)"
puts "(bindex) Enter %W (2)"} {} cleanup-T-F-W}

    # Common setup and cleanup.
    set setup-T-F-W {
	    set T "."
	    pack [frame [set F .f] -background blue] -expand 1 -fill both
	    pack [label [set W $F.l] -text "A label" -background red] -expand 1 -fill both
	    wm geometry . "100x100"
    }
    set cleanup-T-F-W {
	destroy $T
    }

    # Setup the test output.
    ::tcltest::configure -verbose [list pass skip error]

    # Run the list of tests.
    foreach test_params $testlist {
	lassign $test_params prefix desc body res out setup cleanup match rcode errout
	if {![info exists oldprefix] || $prefix != $oldprefix} {
	    set testn 1
	} else {
	    incr testn
	}
	if {$match == ""} { set match exact }
	if {$errout == ""} { set errout "" }
	if {$rcode == ""} { set rcode "ok return" }
	if {$setup != ""} { set setup [set $setup] }
	if {$cleanup != ""} { set cleanup [set $cleanup] }
	tcltest::test $prefix-$testn $desc \
	    -setup $setup \
	    -body $body \
	    -cleanup $cleanup \
	    -match $match -result $res -output $out -errorOutput $errout -returnCodes $rcode
	set oldprefix $prefix
    }
}

moduleTests
