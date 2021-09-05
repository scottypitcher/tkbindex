# 	buildend.mk
#
#	Copyright (C) - Scott Pitcher, 2020
#
# 	Single Makefile generic final build rules.
#

$(if $(value buildtoplevel_mk_included),,$(error Cannot include buildend.mk directly: buildtoplevel.mk must be included instead.))

# Do the final make rules.
# This macro should be called at the end of the Makefile.
# Presets:
#	none
# Special variables:
#	none
# Usage:
#	MAKEENDRULES
#
define MAKEENDRULES
$(eval
$(call is_variable_defined,BUILDDIR,MAKEENDRULES: BUILDDIR is not defined)

$(eval built_all_flag=$(BUILDDIR)/.built-all)
$(eval config_all_flag=$(BUILDDIR)/.config-all)

$(BUILDDIR):
	mkdir -p $$@


# The top level targets.

$(config_all_flag):
	touch $(config_all_flag)

config: $(CONFIGURE_TARGETS) $(config_all_flag) | $(BUILDDIR)

# ---

_all_flag_built_all:
	touch $(built_all_flag)
	
all: $(config_all_flag) $(ALL_TARGETS) _all_flag_built_all

# ---

install_banner:
	@echo ===INSTALLING====================================================

install_banner_end:
	@echo ===INSTALL=FINISHED==============================================

install: $(built_all_flag) install_banner $(INSTALL_TARGETS) install_banner_end

uninstall_banner:
	@echo ===UNINSTALLING==================================================

uninstall_banner_end:
	@echo ===UNINSTALL=FINISHED============================================

uninstall: uninstall_banner $(UNINSTALL_TARGETS) uninstall_banner_end

# ---

_clean_banner:
	@echo ===CLEANING======================================================

_cleanconfig_banner:
	@echo ===CLEANING=\(+CONFIG\)============================================

_cleangit_banner:
	@echo ===CLEANING=\(+GIT\)===============================================

_clean_banner_end:
	@echo ===CLEAN=FINISHED================================================

_clean_build:
	$$(RM) -vfr $$(BUILDDIR)

_clean_targets: $(CLEAN_TARGETS)
	
clean: _clean_banner _clean_targets _clean_banner_end

# Remove git archives + build files.
_clean_git: $(CLEAN_GIT_TARGETS)

cleangit: _cleangit_banner _clean_git _clean_targets _clean_banner_end

# Remove also the configuration.
cleanconfig: _cleanconfig_banner _clean_git _clean_targets _clean_build _clean_banner_end




)
endef
