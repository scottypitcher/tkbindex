# version.mk
#
# From stackoverflow.com 21AUG2020.
#
# From user TrueY on https://stackoverflow.com/questions/3728372/version-number-comparison-inside-makefile

S :=
SP := $S $S

# For non empty strings
str.not = $(if $1,$S,T)
str.ne = $(if $(subst $1,,$2),T,$S)
str.eq = $(if $(subst $1,,$2),$S,T)
str.le = $(call str.eq,$(word 1,$(sort $1 $2)),$1)
str.ge = $(call str.eq,$(word 1,$(sort $1 $2)),$2)

# Creates a list of digits from a number
mklist = $(eval __tmp := $1)$(foreach i,0 1 2 3 4 5 6 7 8 9,$(eval __tmp := $$(subst $$i,$$i ,$(__tmp))))$(__tmp)
# reverse: $(subst $(SP),,$(list))

pop = $(wordlist 2, $(words $1), x $1)
push = $1 $2
shift = $(wordlist 2, $(words $1), $1)
unshift = $2 $1

num.le = $(eval __tmp1 := $(call mklist,$1))$(eval __tmp2 := $(call mklist,$2))$(if $(call str.eq,$(words $(__tmp1)),$(words $(__tmp2))),$(call str.le,$1,$2),$(call str.le,$(words $(__tmp1)),$(words $(__tmp2))))

num.ge = $(eval __tmp1 := $(call mklist,$1))$(eval __tmp2 := $(call mklist,$2))$(if $(call str.eq,$(words $(__tmp1)),$(words $(__tmp2))),$(call str.ge,$1,$2),$(call str.ge,$(words $(__tmp1)),$(words $(__tmp2))))

#Strip zeroes from the beginning of a list
list.strip = $(eval __flag := 1)$(foreach d,$1,$(if $(__flag),$(if $(subst 0,,$d),$(eval __flag :=)$d,$S),$d))
#Strip zeroes from the beginning of a number
num.strip = $(subst $(SP),,$(call list.strip,$(call mklist,$1)))
# $(foreach N,8 08 008 101 100 001,$(info $(N) = $(call num.strip,$(N))))

# temp string: 0 - two number equals, L first LT, G first GT or second is short,
gen.cmpstr = $(eval __Tmp1 := $(subst ., ,$1))$(eval __Tmp2 := $(subst ., ,$2))$(foreach i,$(__Tmp1),$(eval j := $(word 1,$(__Tmp2)))$(if $j,$(if $(call str.eq,$i,$j),0,$(if $(call num.le,$i,$j),L,G)),G)$(eval __Tmp2 := $$(call shift,$(__Tmp2))))$(if $(__Tmp2), L)

ver.lt = $(call str.eq,$(word 1,$(call list.strip,$(call gen.cmpstr,$1,$2))),L)
# checkVersionWithError ver(1),min(2),errmsg(3)
errorIfVersionLessThan = $(if $(call ver.lt,$(1),$(2)),$(error $(3)),)
# $(call errorIfVersionLessThan,1.2,3.6,ERROR: CGAL version minimum is 3.6)


