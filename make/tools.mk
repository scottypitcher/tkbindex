# tools.mk
#
# Copyright (C) - Scott Pitcher, 2020
#
# Common functions for the make system.
#

# Are the variables in the list defined? Report an error message if not.
# Params:
#	1. Variable
#	2. Error message
define is_variable_defined
$(eval x=$(value 1))
$(if $(value $x),,$(error $2))
endef

# Set default variable value
# Params:
#	1. Variable
#	2. Default
define set_variable_default
$(eval
$(eval _x=$(value 1))
$(eval $(if $(value $_x),,$(eval $1 = $(value 2))))
)
endef

# Return the first defined variable else report an error.
# Params:
#	1. Return variable
#	2. Variable list
#	3. Error message
define select_defined_variable
$(eval r=)
$(eval $(foreach i,$2,$(if $(value r),,$(eval r=$(value $i)))))
$(if $(value r),,$(if $(value 3),$(error $3),$(info value of 3 is not set)))
$(eval $1 = $(value r))
endef

# A string compare function fromL
# https://stackoverflow.com/questions/7324204/how-to-check-if-a-variable-is-equal-to-one-of-two-values-using-the-if-or-and-fun
eq = $(if $(or $(1),$(2)),$(and $(findstring $(1),$(2)),\
                                $(findstring $(2),$(1))),1)

# Replace the _ in a path with underscores.
flattenPath = $(subst /,_,$(1))
# F = src/tools.cc
# $(info $(F) = $(call flattenPath,$(F)))
# F = src/libsvg/tools.cc
# $(info $(F) = $(call flattenPath,$(F)))

                                
                                