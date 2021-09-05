# config.mk
#
# Copyright (C) - Scott Pitcher, 2020
#
# Tools for configuration.
#


# Name the configuration script, file and the rule for creating it.
# Params:
#	(1) project name
#	(2) configure script name
#	(2) target config file name
#
define CONFIG_FILE
$(eval
$(eval _config_file=$(3))
$(info CONFIG_FILE _config_file=$(_config_file))
_pre_$(1)_configuration:
	@echo ---Configuring $(1)---
	@echo "" > $(_config_file)

_$(1)_configuration: _pre_$(1)_configuration
	$$(eval include $(2))

CONFIGURE_TARGETS+= _$(1)_configuration

-include $(3)
)
endef

# Write a key and value to the configuration file.
# Params:
#	(1) key
#	(2) value
#
define CONFIG_VARIABLE
$(eval
$(info CONFIG_VARIABLE: 1=$(1) 2=$(2))
$(call is_variable_defined,_config_file,CONFIG_VARIABLE($(1)): Cannot write to the configuration file: none defined; Use CONFIG_FILE)
$(shell echo "$(1)=$(2)" >> $(_config_file))
$(1)=$(2)
)
endef
