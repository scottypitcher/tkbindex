#!/usr/bin/tclsh
#
# Copyright (C) Scott Pitcher - 2020.
#
# A test implementation of bindex in tcl.
#
# bindex: a Tk bind extension that permits additional prefixes for querying, removing, replacing bindings.
#


package require Tk

package require bindex 1.0


set T "."
pack [frame [set F .f] -background blue] -expand 1 -fill both
pack [label [set W $F.l] -text "A label" -background red] -expand 1 -fill both
wm geometry . "100x100"

puts "Bindings at start = [bind $W <Enter>]"
bind $W <Enter> "+puts \"(bind) Enter %W (1)\""
bindex $W <Enter> "+puts \"(bindex) Enter %W (2)\""
bindex $W <Enter> "+puts \"(bindex) Enter %W (3)\""
puts "Bindings after added 3 = [bind $W <Enter>]"

puts "Search for the (1) binding = [bindex $W <Enter> "?puts \"(bind) Enter %W (1)\""]"

# Try replacing.
bindex $W <Enter> "-puts \"(bind) Enter %W (1)\""  "puts \"(bindex) Enter %W (4)\""
puts "Bindings after replacing (1) with (4) = [bind $W <Enter>]"
puts "Search for the (1) binding = [bindex $W <Enter> "?puts \"(bind) Enter %W (1)\""]"

# replace the (4) one with (5)
bindex $W <Enter> "-puts \"(bindex) Enter %W (4)\""  "puts \"(bindex) Enter %W (5)\""
puts "Bindings after replacing (4) with (5) = [bind $W <Enter>]"

# replace the middle (3) one with (6)
bindex $W <Enter> "-puts \"(bindex) Enter %W (3)\""  "puts \"(bindex) Enter %W (6)\""
puts "Bindings after replacing (3) with (6) = [bind $W <Enter>]"

# Try to add something that's already there.
bindex $W <Enter> "*puts \"(bindex) Enter %W (5)\""
puts "Bindings after unique adding (5) = [bind $W <Enter>]"
bindex $W <Enter> "*puts \"(bindex) Enter %W (7)\""
puts "Bindings after unique adding (7) = [bind $W <Enter>]"
