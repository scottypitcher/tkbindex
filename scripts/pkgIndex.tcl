#
# Tcl package index file
#
package ifneeded bindex 1.0 \
    [list source "[file join $dir tkbindex.tcl]"]

package ifneeded bindex 1.1 "\
  load \"[file join $dir tkbindex[info sharedlibextension]]\" bindex \n
"

# kate: syntax Tcl/Tk;
