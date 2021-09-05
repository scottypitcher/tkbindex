# Testing the string compare function from 
# https://stackoverflow.com/questions/7324204/how-to-check-if-a-variable-is-equal-to-one-of-two-values-using-the-if-or-and-fun

define is_variable_defined
$(eval x=$(value 1))
$(if $(value $x),,$(error $2))
endef

eq=$(and $(findstring $(1),$(2)),$(findstring $(2),$(1)))
eqx = $(if $(or $(1),$(2)),$(and $(findstring $(1),$(2)),\
                                $(findstring $(2),$(1))),1)
eqy = $(and $(findstring x$(1),x$(2)), $(findstring x$(2),x$(1)))

report = $(info $(1) says $(2)($(value $(2))) $(3) $(4)($(value $(4))))

compare=$(if $(call $(1),$(value $(2)),$(value $(3))),$(call report,$(1),$(2),==,$(3)),$(call report,$(1),$(2),!=,$(3)) )

tryeach=$(foreach f,eq eqx eqy,$(call compare,$(f),$(1),$(2)))

STR1=blah
STR2=blue blah
STR3=red
STR4=red
STR5=
STR6=

PAIRS=STR1-STR2 STR3-STR4 STR5-STR6

$(foreach p,$(PAIRS),$(call tryeach,$(word 1,$(subst -, ,$(p))),$(word 2,$(subst -, ,$(p)))))

define _compile_to_object
$(eval
$(call is_variable_defined,BUILDDIR,MAKECAPPLICATION: BUILDDIR is not defined)
$(if $(call eq,$(suffix $(value 1)),.c),$(call _compile_c,),)
)
endef


$(eval $(call is_variable_defined,compile_to_object,Sorry - compile_to_object does not exist))


