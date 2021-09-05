#	capplication.mk
#
#	Copyright (C) - Scott Pitcher, 2020
#
#	A generic recursive Makefile skeleton for building C applications from source.
#	The includer Makefile should define the source components and any special
#	make rules.

ifndef TARGET
$(error TARGET is undefined. You must name the application target.)
endif

# Build directory must be defined
ifndef BUILDDIR
$(error BUILDDIR undefined. Must point to the project top level build folder.)
endif

LOCALBUILDDIR= 	$(BUILDDIR)/$(TARGET)

ifndef SOURCES
$(error SOURCES undefined. You must list the application source files.)
endif


# ---Project directories------------------------------------------------------------------------------

# Where we build files.
$(LOCALBUILDDIR):
	mkdir -p $@


# ---Tools--------------------------------------------------------------------------------------------

AS=		as
AR=		ar
CC=		gcc
LD=		ld
OBJDUMP=	objdump
RM=		rm


# ---Flags--------------------------------------------------------------------------------------------

# We add these in case the includer has already defined them.
CFLAGS+=	-Wa,-ahlms=$(@:.o=.lst) -Wall -Wno-deprecated
ifeq ($(DEBUG),yes)
CFLAGS+=	-g
endif

INCLUDES+=	-I$(CONFIG_INCLUDE_DIR) -I$(INCLUDE_DIR)

LDFLAGS+=	-Wl,-Map="$(LOCALBUILDDIR)/$(TARGET).map",--cref
LDFLAGS+=	-L$(LIBDIR)

ifeq ($(BUILD_OS),WINDOWS)
EXEEXTENSION=	.exe
else
EXEEXTENSION=
endif


# ---Autodependency--------------------------------------------------------------------------------------------------------------

# A list of all dep files from the sources.
DEPFILES=	$(addprefix $(LOCALBUILDDIR)/,$(notdir $(SOURCES:.c=.md)))

$(DEPFILES): | $(LOCALBUILDDIR)

-include $(DEPFILES)


# ---Object files----------------------------------------------------------------------------------------------------------------

OBJFILES=	$(addprefix $(LOCALBUILDDIR)/,$(notdir $(SOURCES:.c=.o)))

# A rule to build object files. Dependancy checking is included so we don't need to have any explicit
# rules anymore. Each build directory object file is dependant on the source directory source file.
$(LOCALBUILDDIR)/%.o: %.c Makefile | $(LOCALBUILDDIR)
	$(CC) -c $< -o $@ $(CFLAGS) $(INCLUDES) -MMD -MF $(patsubst %.o,%.md,$@)

# And a special rule for C files in the local build directory (code generated and build time).
$(LOCALBUILDDIR)/%.o: $(LOCALBUILDDIR)/%.c Makefile | $(LOCALBUILDDIR)
	$(CC) -c $< -o $@ $(CFLAGS) $(INCLUDES) -MMD -MF $(patsubst %.o,%.md,$@)


# ---Link and build target files--------------------------------------------------------------------------------------------------------------------------------------

# Targets
ELFTARGET = $(addprefix $(LOCALBUILDDIR)/, $(TARGET)$(EXEEXTENSION))

# Link. Add in 3rd party libs for the GAPBMS (MODBUS and BACnet)
$(ELFTARGET): $(OBJFILES) | $(LOCALBUILDDIR)
	$(CC) $(LDFLAGS) $(OBJFILES) $(LIBS) -o $@ $(OUTPUTLOG)


# Top level targets

all: 	$(ELFTARGET)

clean:
	$(RM) -vfr $(LOCALBUILDDIR)
	$(RM) -vf $(ELFTARGET)

install:
	# TODO

uninstall:
	# TODO
