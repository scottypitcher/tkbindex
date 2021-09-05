# 	buildc.mk
#
#	Copyright (C) - Scott Pitcher, 2020
#
# 	Single Makefile generic c binary builder.
#

$(if $(value buildtoplevel_mk_included),,$(error Cannot include buildend.mk directly: buildtoplevel.mk must be included instead.))

# Generic C binary builder.
# Presets:
# OK	BUILDDIR	The directory where the build targets are placed under a subdirectory called name(1).
#	INSTALLPREFIX	The system directory prefix under which the library is installed.
# Special variables:
# (LIB)	name_LIBTYPE		Either: dynamic, static or local. [default dynamic]
# OK	BUILDSOURCES,		Common source files found under $(BUILDDIR)/name
# OK	    name_BUILDSOURCES,
# OK	    name_NOBUILDSOURCES
#	CFLAGS,	 		Common and special CFLAGS.
#	    name_CFLAGS,
#	    name_NOCFLAGS
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
# Usage:
#	build_c_binary name(1),dir(2),source_list(3),deps_name_list(4),type(5)
#		type: exe,lib
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
$(eval SOURCES_$(1)=$(addprefix $(2)/,$(3)))
$(if $(value $(1)_BUILDSOURCES,$(eval SOURCES_$(1)+=$(addprefix $(LOCALBUILDDIR_$(1)),$($(1)_BUILDSOURCES))),)
$(if $(value $(1)_NOBUILDSOURCES),,$(eval SOURCES_$(1)+=$(addprefix $(BUILDDIR),$(BUILDSOURCES))))

# Autodependency
$(eval DEPFILES_$(1)=$(addprefix $(LOCALBUILDDIR_$(1))/,$(notdir $(SOURCES_$(1):.c=.md))))
$(eval
$(DEPFILES_$(1)): | $(LOCALBUILDDIR_$(1))

)
$(eval
-include $(DEPFILES_$(1))
)
# Object files
$(eval OBJFILES_$(1)=	$(addprefix $(LOCALBUILDDIR_$(1))/,$(notdir $(SOURCES_$(1):.c=.o))))
# A rule to build object files from the 3 different source directories.
# TODO: CFLAGS, name_CFLAGS and name_NOCLAGS.
$(eval
$(LOCALBUILDDIR_$(1))/%.o: $(2)/%.c Makefile | $(LOCALBUILDDIR_$(1))
	$$(CC) -c $$< -o $$@ $$(CFLAGS) $$($(1)_CFLAGS) $$($(1)_INCLUDES) $$(INCLUDES) -MMD -MF $$(patsubst %.o,%.md,$$@)

)
$(eval
$(LOCALBUILDDIR_$(1))/%.o: $(LOCALBUILDDIR_$(1))/%.c Makefile | $(LOCALBUILDDIR_$(1))
	$$(CC) -c $$< -o $$@ $$(CFLAGS) $$($(1)_CFLAGS) $$($(1)_INCLUDES) $$(INCLUDES) -MMD -MF $$(patsubst %.o,%.md,$$@)

)
$(if $(value $(1)_NOBUILDSOURCES),,\
$(eval
$(LOCALBUILDDIR_$(1))/%.o: $(BUILDDIR)/%.c Makefile | $(LOCALBUILDDIR_$(1))
	$$(CC) -c $$< -o $$@ $$(CFLAGS) $$($(1)_CFLAGS) $$($(1)_INCLUDES) $$(INCLUDES) -MMD -MF $$(patsubst %.o,%.md,$$@)

))
$(eval
$(LOCALBUILDDIR_$(1))/%.o: $(2)/%.cc Makefile | $(LOCALBUILDDIR_$(1))
	$$(CXX) -c $$< -o $$@ $$(CXXFLAGS) $$($(1)_CFLAGS) $$($(1)_INCLUDES) $$(INCLUDES) -MMD -MF $$(patsubst %.o,%.md,$$@)

)
$(eval
$(LOCALBUILDDIR_$(1))/%.o: $(LOCALBUILDDIR_$(1))/%.cc Makefile | $(LOCALBUILDDIR_$(1))
	$$(CXX) -c $$< -o $$@ $$(CXXFLAGS) $$($(1)_CFLAGS) $$($(1)_INCLUDES) $$(INCLUDES) -MMD -MF $$(patsubst %.o,%.md,$$@)

)
$(if $(value $(1)_NOBUILDSOURCES),,\
$(eval
$(LOCALBUILDDIR_$(1))/%.o: $(BUILDDIR)/%.cc Makefile | $(LOCALBUILDDIR_$(1))
	$$(CXX) -c $$< -o $$@ $$(CXXFLAGS) $$($(1)_CFLAGS) $$($(1)_INCLUDES) $$(INCLUDES) -MMD -MF $$(patsubst %.o,%.md,$$@)

))
# Link the target file.
$(if $(call eq,dynamic,$(value 5)), \
$(eval
$(eval elftarget_$(1) = $(addprefix $(LOCALBUILDDIR_$(1))/, $(1)$(DLIBEXTENSION)))
$(elftarget_$(1)): $(OBJFILES_$(1)) $(4) | $(LOCALBUILDDIR_$(1))
	$$(CC) -fPIC -rdynamic -shared -Lstatic -o $$@ $$(OBJFILES_$(1))  -lstatic

),)
$(if $(call eq,static,$(value 5)), \
$(eval
$(eval elftarget_$(1) = $(addprefix $(LOCALBUILDDIR_$(1))/, $(1)$(SLIBEXTENSION)))
$(elftarget_$(1)): $(OBJFILES_$(1)) $(4) | $(LOCALBUILDDIR_$(1))
	$$(AR) rcs $$@ $$(OBJFILES_$(1)) 
	$$(OBJDUMP) --syms $$@ > $(elftarget_$(1):.a=.lst)

),)
$(if $(call eq,exe,$(value 5)), \
$(eval
$(eval elftarget_$(1) = $(addprefix $(LOCALBUILDDIR_$(1))/, $(1)$(EXEEXTENSION)))
$(elftarget_$(1)): $(OBJFILES_$(1)) $(4) | $(LOCALBUILDDIR_$(1))
	$$(CC) $$(LDFLAGS) $$($(1)_LDFLAGS) $$(OBJFILES_$(1)) -Bdymanic $$($(1)_LIBS) $$(LIBS) -Bstatic $$($(1)_STATICLIBS) $$(STATICLIBS) -o $$@

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

# TODO: Define the install directory here.
$(eval
uninstall_$(1):
	$$(call is_variable_defined,INSTALLPREFIX,Cannot uninstall: INSTALLPREFIX is not defined. Should point to /usr or /usr/local etc.)
	$$(call select_defined_variable,INSTALL_PATH_$(1),$(1)_INSTALLDIR INSTALLDIR,Cannot install: $(1)_INSTALLDIR or INSTALLDIR are not set)
	rm $$(INSTALL_PATH_$(1))

UNINSTALL_TARGETS+=uninstall_$(1)
)
$(eval
install_$(1): $(ELFTARGET_$(1))
	$$(call is_variable_defined,INSTALLPREFIX,Cannot install: INSTALLPREFIX is not defined. Should point to /usr or /usr/local etc.)
	$$(call select_defined_variable,INSTALL_PATH_$(1),$(1)_INSTALLDIR INSTALLDIR,Cannot install: $(1)_INSTALLDIR or INSTALLDIR are not set)
	install -v $$(elftarget_$(1)) $$(INSTALLPREFIX)/$$(INSTALL_PATH_$(1))

INSTALL_TARGETS+=install_$(1)
)
)
endef

# 
# Build  executables and libraries.
# Presets:
#	BUILDDIR	The directory where the build targets are placed under a subdirectory called name(1).
#	INSTALLPREFIX	The system directory prefix under which the library is installed.
# Special variables:
# (LIB)	name_LIBTYPE		Either: dynamic, static or local. [default dynamic]
#	BUILDSOURCES,		Common source files found under $(BUILDDIR)/name
#	    name_BUILDSOURCES,
#	    name_NOBUILDSOURCES
#	CFLAGS,	 		Common and special CFLAGS.
#	    name_CFLAGS,
#	    name_NOCFLAGS
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
# Usage:
#	MAKECEXECUTABLE name(1),dir(2),source_list(3),deps_name_list(4)
#	MAKECLIBRARY name(1),dir(2),source_list(3),deps_name_list(4)
#

define MAKECEXECUTABLE
$(eval $(call build_c_binary,$(1),$(2),$(3),$(4),exe))
endef

define MAKESTATICLIBRARY
$(eval $(call build_c_binary,$(1),$(2),$(3),$(4),static))
endef

define MAKEDYNAMICLIBRARY
$(eval $(call build_c_binary,$(1),$(2),$(3),$(4),dynamic))
endef
