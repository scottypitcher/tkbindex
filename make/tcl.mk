# tcl.mk
#
# Copyright (C) - Scott Pitcher, 2020
#
# TCLTK configuration and extension building.
#

$(if $(value buildtoplevel_mk_included),,$(error Cannot include tcl.mk directly: buildtoplevel.mk must be included instead.))

# Find the OS dependant private header directory prefix.
$(if $(call eq,$(BUILD_OS),WINDOWS),$(eval _tcl_tk_os_private=windows),)
$(if $(call eq,$(BUILD_OS),LINUX),$(eval _tcl_tk_os_private=unix),)
# Don't know about OSX.

# Make a TCL PACKAGE from a binary and scripts.
# Params
#	$(1)	Package directory
#	$(2)	ELF binary
#	$(3)	Optional scripts to copy over to the package directory.
#	$(4)	Optional dependencies
#
define maketclpackage
$(eval
$(eval
$(1):
	mkdir -p $$@

)
$(eval $(1)_tcl_package_bin=$(1)/$(notdir $(2)))

# Build the package.
$(eval
$($(1)_tcl_package_bin): $(2) | $(1)
	@cp -puv $$< $$@

ALL_TARGETS += $($(1)_tcl_package_bin)

)
# Now the scripts.
$(eval
$(if $(value $(3)),,
$(foreach _script_file,$(3),
$(eval
$(1)/$(notdir $(_script_file)): $(_script_file) | $(1)
	@cp -puv $$< $$@

ALL_TARGETS += $(1)/$(notdir $(_script_file))

))))
)
endef

# Build the TCL configuration and TCL extensions.
# Params
#	$(1)		Target name
#	$(2)		Source files
#	$(3)		Optional scripts to copy over to the install directory.
#	$(4)		Optional dependencies
#
define MAKETCLEXTENSION
$(eval
$(eval
_tcl_configuration=$$(BUILDDIR)/tclconfig.mk

$$(_tcl_configuration): | $(BUILDDIR)
	@echo ---Building TCL configuration ---
	$$(call is_variable_defined,BUILDDIR,Cannot configure: BUILDDIR is not defined. Should point to the build directory.)
	@ $$(build_make_path)tclconfig.sh $$(_tcl_configuration)

CONFIGURE_TARGETS+=$$(_tcl_configuration)

-include $$(_tcl_configuration)

)
$(eval $(1)_CFLAGS+=-DUSE_TCL_STUBS)
$(eval $(1)_CXXFLAGS+=-DUSE_TCL_STUBS)
$(eval $(1)_STATICLIBS+=$$(TCL_STUB_LIB_SPEC))
$(eval $(1)_INCLUDES+=$$(TCL_INCLUDE_SPEC))
$(if $(call eq,$(value $(1)_TCL_PRIVATE_INCLUDE),yes),
$(eval $(1)_INCLUDES+= -I$$(TCL_SRC_DIR)/generic -I$$(TCL_SRC_DIR)/$(_tcl_tk_os_private))
,)
$(call build_c_binary,$(1),$(2),$(3),$(_tcl_configuration) $(4),dynamic)

$(if $(value $(1)_TCL_PACKAGE_DIR),$(call maketclpackage,$($(1)_TCL_PACKAGE_DIR),$(ELFTARGET_$(1)),$(3),$(4))
,)

)
endef


# Build the TK configuration and TK extensions.
# Params
#	$(1)		Target name
#	$(2)		Source files
#	$(3)		Optional scripts to copy over to the install directory.
#	$(4)		Optional dependencies
##	MAKECEXECUTABLE name(1),source_list(2),deps_name_list(3)

define MAKETKEXTENSION
$(eval
$(eval
_tk_configuration=$$(BUILDDIR)/tkconfig.mk

$$(_tk_configuration): | $(BUILDDIR)
	@echo ---Building TK configuration ---
	$$(call is_variable_defined,BUILDDIR,Cannot configure: BUILDDIR is not defined. Should point to the build directory.)
	@ $$(build_make_path)tkconfig.sh $$(_tk_configuration)

CONFIGURE_TARGETS+=$$(BUILDDIR)/tkconfig.mk

-include $$(_tk_configuration)

)
$(eval $(1)_CFLAGS+=-DUSE_TK_STUBS)
$(eval $(1)_CXXFLAGS+=-DUSE_TK_STUBS)
$(eval $(1)_STATICLIBS+=$$(TK_STUB_LIB_SPEC))
$(eval $(1)_INCLUDES+=$$(TK_INCLUDE_SPEC))
$(if $(call eq,$(value $(1)_TK_PRIVATE_INCLUDE),yes),
$(eval $(1)_INCLUDES+= -I$$(TK_SRC_DIR)/generic -I$$(TK_SRC_DIR)/$(_tcl_tk_os_private))
,)
$(eval $(call MAKETCLEXTENSION,$(1),$(2),$(3),$(_tk_configuration) $(4)))
)
endef
