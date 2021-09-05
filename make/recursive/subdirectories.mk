# 	subdirectories.mk
#
#	Copyright (C) - Scott Pitcher, 2020
#
# 	Generic recursive Makefile for defining targets for subdirectories and recursively building them.
#	The user Makefile should include this, plus should define path and target names
#	and special dependencies.

# Makefile should set BUILDSUBDIR to use a build subdirectory under BUILDDIR.
ifndef BUILDSUBDIR
$(warning BUILDSUBDIR not defined. Using BUILDDIR instead)
endif

# Makefile should define the list of target, which might be "all clean install", etc
ifndef BUILD_TARGETS_LIST
$(warning BUILD_TARGETS_LIST not defined. No targets will be generated.)
endif

# Makefile should define at least 1 subfolder name to recursively build in.
# WIN32 only
ifndef SUBFOLDERS_WIN32
ifndef SUBFOLDERS_UNIX
ifndef SUBFOLDERS_MAC
ifndef SUBFOLDERS
$(warning No SUBFOLDERSxxxx defined. No targets will be generated.)
endif
endif
endif
endif


define uppercase
$(shell echo $(1) | tr a-z A-Z)
endef


# ---Project directories------------------------------------------------------------------------------

# Check and redefine the build directory.
ifndef BUILDDIR
$(error BUILDDIR is undefined. Please point BUILDDIR to the main build directory)
endif
ifneq ($(BUILDSUBDIR),)
BUILDDIR:= 	$(BUILDDIR)/$(BUILDSUBDIR)
endif

$(BUILDDIR):
	mkdir -p $@


# ---Components---------------------------------------------------------------------------------------

# Macro for making subdirectories.
# Usage:
#	MAKESUBCOMPONENT target,directory,builddir,list-var-suffix
#
define MAKESUBDIRECTORY

# Change target to upper case
$(eval UPC_TGT:=$(call uppercase,$(1)))

# Target object file depends on source
$(1)-$(2): $(1) Makefile | $(3)
	@echo "---BUILDING-$(UPC_TGT)-$(2)----------------------------------------------------"
	$(MAKE) -C $(2) $(1)

$(eval $(UPC_TGT)_$(4)=$($(UPC_TGT)_$(4)) $(1)-$(2))

endef

# Make all build targets for a given subdirectory
# Usage:
#	MAKESUBDIRECTORYALL directory,builddir,list-var-suffix
define MAKESUBDIRECTORYALL
$(foreach i,$(BUILD_TARGETS_LIST),$(eval $(call MAKESUBDIRECTORY,$(i),$(1),$(BUILDDIR),TARGETS) ) )
endef

# Make the top level build targets
# We specify the target variable for each target.
# Usage:
#	MAKETOPLEVELTARGETS target
define MAKETOPLEVELTARGETS

$(eval UPC_TGT:=$(call uppercase,$(1)))

$(1): $($(UPC_TGT)_TARGETS)

endef


# ---Subdirectory components--------------------------------------------------------------------------

# Make components for different OS
ifeq ($(BUILD_OS),WINDOWS)
$(foreach i,$(SUBFOLDERS_WIN32),$(eval $(call MAKESUBDIRECTORYALL,$(i),$(BUILDDIR),TARGETS) ) )
endif

ifeq ($(BUILD_OS),LINUX)
$(foreach i,$(SUBFOLDERS_LINUX),$(eval $(call MAKESUBDIRECTORYALL,$(i),$(BUILDDIR),TARGETS) ) )
endif

ifeq ($(BUILD_OS),MAC)
$(foreach i,$(SUBFOLDERS_MAC),$(eval $(call MAKESUBDIRECTORYALL,$(i),$(BUILDDIR),TARGETS) ) )
endif

# Make generic components
$(foreach i,$(SUBFOLDERS),$(eval $(call MAKESUBDIRECTORYALL,$(i),$(BUILDDIR),TARGETS) ) )


# ---Top level targets--------------------------------------------------------------------------------

$(foreach i,$(BUILD_TARGETS_LIST),$(eval $(call MAKETOPLEVELTARGETS,$(i)) ) )
