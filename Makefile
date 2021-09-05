# Makefile
#
# Copyright (C) - Scott Pitcher, 2021
#
# The top level makefile that builds the complete extension.
# ----------------------------------------------------------------------------------------------------
# SVP 5SEP2021: I replaced the TEA autoconf files with this.

# Top level Makefile.
include make/toplevel.mk

# Global debugging flag. This turns on debugging in the whole system. Do a make clean if you change this.
export DEBUG= yes

# The main build directory for all subcomponents.
export BUILDDIR= build

# The C source files.
tkbindex_CFLAGS= -Wall -fPIC -Wa,-a=$@.lst
tkbindex_SOURCE_FILES= tkbindex.c
tkbindex_SOURCES=$(addprefix src/,$(tkbindex_SOURCE_FILES))

# The tcl script files.
tkbindex_SCRIPT_FILES= pkgIndex.tcl tkbindex.tcl
tkbindex_SCRIPTS=$(addprefix scripts/,$(tkbindex_SCRIPT_FILES))

# Include Tk private header files.
tkbindex_TK_PRIVATE_INCLUDE=yes

# And build a package.
tkbindex_TCL_PACKAGE_DIR=$(BUILDDIR)/lib/tkbindex

# Debugging.
$(if $(call eq,$(DEBUG),yes), \
$(eval tkbindex_CFLAGS+= -g) \
$(eval tkbindex_CXXFLAGS+= -g) \
,)

# ---Build the extension library.
$(call MAKETKEXTENSION,tkbindex,$(tkbindex_SOURCES),$(tkbindex_SCRIPTS))

# Now define the top level targets
$(call MAKEENDRULES)
