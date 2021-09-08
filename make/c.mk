# 	buildc.mk
#
#	Copyright (C) - Scott Pitcher, 2020
#
# 	Single Makefile generic c and c++ binary builder.
#

$(if $(value buildtoplevel_mk_included),,$(error Cannot include buildend.mk directly: buildtoplevel.mk must be included instead.))

# Compile a source file.


# Generic C binary builder.
# Presets:
#	BUILDDIR	The directory where the build targets are placed under a subdirectory called name(1).
#	INSTALLPREFIX	The system directory prefix under which the library is installed.
# Special variables:
#	CFLAGS,	 		Common and special CFLAGS.
#	    name_CFLAGS,
#	    name_NOCFLAGS
#	CXXFLAGS,	 		Common and special CFLAGS.
#	    name_CXXFLAGS,
#	    name_NOCXXFLAGS
#	INCLUDES,		Common and special include folders.
#	    name_INCLUDES,
#	    name_NOINCLUDES
#	LDFLAGS,		Common and special linker flags.
#	    name_LDFLAGS,
#	    name_NOLDFLAGS
#	LIBS,			Common and extra libs to link.
#	    name_LIBS,
#	    name_NOLIBS
#	STATICLIBS,		Common and extra static libraries to link.
#	    name_STATICLIBS,
#	    name_NOSTATICLIBS
#	INSTALLDIR,		Install under $(INSTALLPREFIX)/name_INSTALLDIR.
#	    name_INSTALLDIR
#	    name_NOINSTALL
# Usage:
#	build_c_binary name(1),source_list(2),deps_name_list(3),type(4)
#		type: exe,static,dynamic
#
#
define build_c_binary
$(eval
$(call is_variable_defined,BUILDDIR,MAKECAPPLICATION: BUILDDIR is not defined)
$(eval LOCALBUILDDIR_$(1)=$(BUILDDIR)/$(1))
$(eval
$(LOCALBUILDDIR_$(1)):
	mkdir -p $$@

)

# Source files.
$(eval SOURCES_$(1)=$(2) )

# Build all the source files into object files.
$(foreach _source_file,$(SOURCES_$(1)),$(call _compile_to_object,$(1),$(_source_file),$(LOCALBUILDDIR_$(1))))

# Compile the correct set of linker arguments.
$(eval ldflags_$(1)=$(if $(value $(1)_NOLDFLAGS),,$(value LDFLAGS)))
$(eval ldflags_$(1)+=$(value $(1)_LDFLAGS))
$(eval libs_$(1)=$(if $(value $(1)_NOLIBS),,$(value LIBS)))
$(eval libs_$(1)+=$(value $(1)_LIBS))
$(eval staticlibs_$(1)=$(if $(value $(1)_NOSTATICLIBS),,$(value STATICLIBS)))
$(eval staticlibs_$(1)+=$(value $(1)_STATICLIBS))
# Link the target file.
$(if $(call eq,dynamic,$(value 5)), \
$(eval
$(eval elftarget_$(1) = $(addprefix $(LOCALBUILDDIR_$(1))/, $(1)$(DLIBEXTENSION)))
$(eval default_install_dir_$(1)=lib)
$(elftarget_$(1)): $(OBJFILES_$(1)) $(4) | $(LOCALBUILDDIR_$(1))
	@echo ---Linking Dynamic Library $(1)---
	$$(CC) -shared -o $$@ -Bdynamic $$(ldflags_$(1))  $$(OBJFILES_$(1)) -Bdynamic $$(libs_$(1)) -Bstatic $$(staticlibs_$(1))
	$$(OBJDUMP) --syms $$@ > $(elftarget_$(1)).lst

ELFTARGET_$(1)=$(elftarget_$(1))
),)
$(if $(call eq,static,$(value 5)), \
$(eval
$(eval elftarget_$(1) = $(addprefix $(LOCALBUILDDIR_$(1))/, $(1)$(SLIBEXTENSION)))
$(eval default_install_dir_$(1)=lib)
$(elftarget_$(1)): $(OBJFILES_$(1)) $(4) | $(LOCALBUILDDIR_$(1))
	@echo ---Linking Static Library $(1)---
	$$(AR) rcs $$@ $$(OBJFILES_$(1)) 
	$$(OBJDUMP) --syms $$@ > $(elftarget_$(1)).lst

ELFTARGET_$(1)=$(elftarget_$(1))
),)
$(if $(call eq,exe,$(value 5)), \
$(eval
$(eval elftarget_$(1) = $(addprefix $(LOCALBUILDDIR_$(1))/, $(1)$(EXEEXTENSION)))
$(eval default_install_dir_$(1)=bin)
$(elftarget_$(1)): $(OBJFILES_$(1)) $(4) | $(LOCALBUILDDIR_$(1))
	@echo ---Linking Executable $(1)---
	$$(CC) $$(ldflags_$(1)) $$(OBJFILES_$(1)) -Bdynamic $$(libs_$(1)) -Bstatic $$(staticlibs_$(1)) -o $$@

ELFTARGET_$(1)=$(elftarget_$(1))
),)
# Add this target to the top level targets.
$(eval
$(1): $(elftarget_$(1))

)
$(eval ALL_TARGETS+=$(elftarget_$(1)))
$(eval
clean_$(1):
	$$(RM) -vf $$(elftarget_$(1))
	$$(RM) -vfr $$(LOCALBUILDDIR_$(1))

CLEAN_TARGETS+=clean_$(1)
)
# Do install and uninstall
$(call select_defined_variable,install_path_$(1),$(1)_INSTALLDIR INSTALLDIR default_install_dir_$(1),Cannot install: $(1)_INSTALLDIR or INSTALLDIR are not set)
$(if $(value $(1)_NOINSTALL),,\
$(eval
uninstall_$(1):
	@echo Running uninstall command for $(1)
	$$(call is_variable_defined,INSTALLPREFIX,Cannot uninstall: INSTALLPREFIX is not defined. Should point to /usr or /usr/local etc.)
	rm $$(INSTALLPREFIX)/$$(install_path_$(1))/$$(elftarget_$(1))

UNINSTALL_TARGETS+=uninstall_$(1)
))
$(if $(value $(1)_NOINSTALL),,\
$(eval
install_$(1): $(elftarget_$(1))
	@echo Running install command for $(1)
	$$(call is_variable_defined,INSTALLPREFIX,Cannot install: INSTALLPREFIX is not defined. Should point to /usr or /usr/local etc.)
	install -v -D -t $$(INSTALLPREFIX)/$$(install_path_$(1)) $$(elftarget_$(1))

INSTALL_TARGETS+=install_$(1)
) )
)
endef

# Usage:
#	MAKECEXECUTABLE name(1),source_list(2),deps_name_list(3)
#	MAKESTATICLIBRARY name(1),source_list(2),deps_name_list(3)
#	MAKEDYNAMICLIBRARY name(1),source_list(2),deps_name_list(3)
# See build_c_binary above for specific flags and argument.
define MAKECEXECUTABLE
$(eval $(call build_c_binary,$(1),$(2),$(3),exe))
endef

define MAKESTATICLIBRARY
$(eval $(call build_c_binary,$(1),$(2),$(3),static))
endef

define MAKEDYNAMICLIBRARY
$(eval $(call build_c_binary,$(1),$(2),$(3),dynamic))
endef
