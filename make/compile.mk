# compile.mk
#
# Copyright (C) - Scott Pitcher, 2020
#
# Compile source files into object files.
#

$(if $(value buildtoplevel_mk_included),,$(error Cannot include compile.mk directly: buildtoplevel.mk must be included instead.))

# Compile a source file.
# Params:
#	compile_to_object targetname,src,dir,compopts
#
define _compile_to_object
$(eval
$(call is_variable_defined,BUILDDIR,_compile_to_object: BUILDDIR is not defined)
$(call is_variable_defined,_compile_$(suffix $(value 2)),ERROR: compile.mk doesn't know how to handle files with extension $(suffix $(value 2)) )
$(call _compile_$(suffix $(value 2)),$(1),$(2),$(3),$(4))
)
endef

# Compile a c++ source file.
define _compile_.cc
$(eval
$(if $(value _cxxflags_$(1)),, \
$(eval _cxxflags_$(1)=$(if $(value $(1)_NOCXXFLAGS),,$(value CXXFLAGS)))
$(eval _cxxflags_$(1)+=$(value $(1)_CXXFLAGS))
)
$(if $(value _includes_$(1)),, \
$(eval _includes_$(1)=$(if $(value $(1)_NOINCLUDES),,$(value INCLUDES)))
$(eval _includes_$(1)+=$(value $(1)_INCLUDES))
)
$(eval _m=$(if $(value $(1)_NOMAKEFILEDEP),,$(if $(value NOMAKEFILEDEP),,Makefile)))
$(eval _t=$(basename $(addprefix $(3)/,$(call flattenPath,$(2)))).o)
$(eval _d=$(addprefix $(3)/,$(call flattenPath,$(2))).md)
$(_t): $(2) $(_m) | $(3)
	$$(call is_variable_defined,CXX,Cannot compile: CXX is not defined. Should point to g++ or your local c++ compiler.)
	$$(CXX) -c $$< -o $$@ $$(_cxxflags_$(1)) $$(_includes_$(1)) $$(4) -MMD -MF $(_d)

OBJFILES_$(1)+=	$(_t)

-include $(_d)

)
endef

define _compile_.cxx
$(call _compile_.cc,$(1),$(2),$(3),$(4))
endef

define _compile_.cpp
$(call _compile_.cc,$(1),$(2),$(3),$(4))
endef

# Compile a c source file.
define _compile_.c
$(eval
$(if $(value _cflags_$(1)),, \
$(eval _cflags_$(1)=$(if $(value $(1)_NOCFLAGS),,$(value CFLAGS)))
$(eval _cflags_$(1)+=$(value $(1)_CFLAGS))
)
$(if $(value _includes_$(1)),, \
$(eval _includes_$(1)=$(if $(value $(1)_NOINCLUDES),,$(value INCLUDES)))
$(eval _includes_$(1)+=$(value $(1)_INCLUDES))
)
$(eval _m=$(if $(value $(1)_NOMAKEFILEDEP),,$(if $(value NOMAKEFILEDEP),,Makefile)))
$(eval _t=$(basename $(addprefix $(3)/,$(call flattenPath,$(2)))).o)
$(eval _d=$(addprefix $(3)/,$(call flattenPath,$(2))).md)
$(_t): $(2) $(_m) | $(3)
	$$(call is_variable_defined,CC,Cannot compile: CC is not defined. Should point to gcc or your local c compiler.)
	$$(CC) -c $$< -o $$@ $$(_cflags_$(1)) $$(_includes_$(1)) $$(4) -MMD -MF $(_d)

OBJFILES_$(1)+=	$(_t)

-include $(_d)

)
endef

