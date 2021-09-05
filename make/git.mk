# git.mk
#
# Copyright (C) - Scott Pitcher, 2020
#
# Rules for checking out git archives.
#

$(if $(value buildtoplevel_mk_included),,$(error Cannot include git.mk directly: buildtoplevel.mk must be included instead.))


# GITCHECKOOUT,url(1),checkout(2),tgt_dir_var(3),options(4))
#
define GITCHECKOOUT
$(eval
$(call is_variable_defined,BUILDDIR,GITCHECKOOUT: BUILDDIR is not defined)
$(eval _t=$(addprefix $(BUILDDIR)/,$(notdir $(basename $(1)))).git)
$(eval $(3)+= $(_t))
$(eval _cmd1=$(if $(2),@echo ---Checking out branch $(2)---,))
$(eval _cmd2=$(if $(2),$$(GIT) -C $(_t) checkout $(2) --detach -q,))
$(eval $(info _cmd1=$(_cmd1)))
$(_t): | $(BUILDDIR)
	$$(call is_variable_defined,GIT,Cannot clone: GIT is not defined. Should point to git or your local equivalent.)
	@echo ---Cloning $(1)---
	$$(GIT) clone $(1) $$@ $(_o) $(4)
	@if [ ! -z "$(2)" ] ; then \
		echo ---Checking out $(2)--- ; \
		$$(GIT) -C $(_t) checkout $(2) --detach -q ; \
	fi

$(_t)_clean:
	@echo ---Cleaning $(1)---
	rm -rvf $(_t)

ALL_TARGETS+=$(_t)

CLEAN_GIT_TARGETS+=$(_t)_clean
)
endef
