# flex.mk
#
# Copyright (C) - Scott Pitcher, 2020
#
# Compile flex and bison source files.
#

$(if $(value buildtoplevel_mk_included),,$(error Cannot include defaults.mk directly: buildtoplevel.mk must be included instead.))


$(call set_variable_default,CC,gcc)
$(call set_variable_default,CXX,g++)
$(call set_variable_default,LEX,flex)
$(call set_variable_default,YACC,bison)
$(call set_variable_default,GIT,git)
