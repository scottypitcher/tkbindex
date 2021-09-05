# lexyacc.mk
#
# Copyright (C) - Scott Pitcher, 2020
#
# Compile lex and yacc source files to source files.
#

$(if $(value buildtoplevel_mk_included),,$(error Cannot include lexyacc.mk directly: buildtoplevel.mk must be included instead.))

# Create the rule for compiling a lex source file into a c or c++ source file.
# The caller selects c or c++ and we only receive a single source file.
# Params:
#	$(1)		Target name
#	$(2)		Source file
#	$(3)		Target source var (where to place the intermediate source file)
#	$(4)		Source deps
#	$(5)		Options.
#	$(6)		Target file extension to be added.
#
define _compile_l
$(eval
$(call is_variable_defined,BUILDDIR,_compile_to_object: BUILDDIR is not defined)
$(eval _m=$(if $(value $(1)_NOMAKEFILEDEP),,$(if $(value NOMAKEFILEDEP),,Makefile)))
$(eval _t=$(basename $(addprefix $(BUILDDIR)/$(1)/,$(notdir $(2))))$(6))
$(eval $(3)+= $(_t))
$(_t): $(2) $(4) $(_m) | $(BUILDDIR)/$(1)/
	$$(call is_variable_defined,LEX,Cannot compile: LEX is not defined. Should point to flex or your local lex compiler.)
	$$(LEX) -o $$@ $(5) $$< 

)
endef

# COMPILELEX2C name(1),source_list(2),target_source_var(3),deps_name_list(4),options(5)
# COMPILELEX2CC name(1),source_list(2),target_source_var(3),deps_name_list(5),options(5)
#
define COMPILELEX2C
$(eval
$(foreach _source_file,$(2),$(call _compile_l,$(1),$(_source_file),$(3),$(4),$(5),.c))
)
endef

# NOTE: We don't incude the --c++ option!
define COMPILELEX2CC
$(eval
$(foreach _source_file,$(2),$(call _compile_l,$(1),$(_source_file),$(3),$(4),$(5),.cxx))
)
endef

# Create the rule for compiling a yacc source file into a c source file.
# The caller selects c or c++ and we only receive a single source file.
# Params:
#	$(1)		Target name
#	$(2)		Source file
#	$(3)		Target source var (where to place the intermediate source file)
#	$(4)		Source deps
#	$(5)		Options.
#	$(6)		Target file extension to be added.
#
define _compile_y
$(eval
$(call is_variable_defined,BUILDDIR,_compile_to_object: BUILDDIR is not defined)
$(eval _m=$(if $(value $(1)_NOMAKEFILEDEP),,$(if $(value NOMAKEFILEDEP),,Makefile)))
$(eval _t=$(basename $(addprefix $(BUILDDIR)/$(1)/,$(notdir $(2))))$(6))
$(eval $(3)+= $(_t))
$(_t): $(2) $(4) $(_m) | $(BUILDDIR)/$(1)/
	$$(call is_variable_defined,LEX,Cannot compile: LEX is not defined. Should point to bison or your local yacc compiler.)
	$$(YACC) -o $$@ $(5) $$< 

)
endef


# COMPILEYACC2C name(1),source_list(2),target_source_var(3),deps_name_list(4),options(5)
# COMPILEYACC2CC name(1),source_list(2),target_source_var(3),deps_name_list(4),options(5)
#
define COMPILEYACC2C
$(eval
$(foreach _source_file,$(2),$(call _compile_y,$(1),$(_source_file),$(3),$(4),$(5),.c))
)
endef

define COMPILEYACC2CC
$(eval
$(foreach _source_file,$(2),$(call _compile_y,$(1),$(_source_file),$(3),$(4),$(5),.cxx))
)
endef
