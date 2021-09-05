# toplevel.mk
#
# Copyright (C) - Scott Pitcher, 2020
#
# Single Makefile generic toplevel include for defining stuff that will build the application.
#

# The build directory must be defined before we do anything.
$(call is_variable_defined,BUILDDIR,BUILDDIR undefined. Must point to the project top level build folder.)

$(eval buildtoplevel_mk_included=1)
$(eval build_make_path=$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

include $(build_make_path)os.mk
include $(build_make_path)tools.mk
include $(build_make_path)version.mk
include $(build_make_path)config.mk
include $(build_make_path)git.mk
include $(build_make_path)tcl.mk
include $(build_make_path)lexyacc.mk
include $(build_make_path)compile.mk
include $(build_make_path)c.mk
include $(build_make_path)defaults.mk
include $(build_make_path)end.mk
