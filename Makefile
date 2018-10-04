#
#! \file    ~/Makefile
#! \author  Jiří Kučera, <sanczes AT gmail.com>
#! \stamp   2018-09-23 11:43:05 +0200
#! \project mkutils - Makefile Utilities
#! \license MIT
#! \version 0.0.0
#! \brief   Makefile.
#

include $(CURDIR)/mkutils.mk

NAME = mkutils
INCFILE := $(NAME).mk

ifneq ($(MSWINDOWS),1)
CHMOD ?= $(TOOLS_PREFIX)chmod$(TOOLS_EXESUFF)
MKDIR ?= $(TOOLS_PREFIX)mkdir$(TOOLS_EXESUFF)
endif
SED ?= $(TOOLS_PREFIX)sed$(TOOLS_EXESUFF)

ifneq ($(MSWINDOWS),1)
prefix ?= /usr/local
bindir = $(prefix)/bin
includedir = $(prefix)/include
endif

HELP_FIRSTCOLWIDTH := 9
$(call DefaultTarget, help)

ifneq ($(MSWINDOWS),1)
INCDIR := $(includedir)/$(NAME)
INCPATH := $(INCDIR)/$(INCFILE)
BUNDLESCRIPTFILE := $(NAME)-bundle
BUNDLESCRIPTPATH := $(bindir)/$(BUNDLESCRIPTFILE)
endif

EDIT := $(SED) -e 's,^\#! \\file    ~/$(INCFILE)$$,\#! \\file    $(INCFILE),g'

ifneq ($(MSWINDOWS),1)
$(call Target, install, install mkutils)
	$(MKDIR) -p $(INCDIR)
	$(EDIT) $(CURDIR)/$(INCFILE) > $(INCPATH)
	$(CHMOD) 644 $(INCPATH)
	( \
	  $(ECHO) '#!/bin/sh'; \
	  $(ECHO) ''; \
	  $(ECHO) 'P=$$(basename $$0)'; \
	  $(ECHO) 'D=$${1:-$$PWD}'; \
	  $(ECHO) ''; \
	  $(ECHO) 'case "x$$D" in'; \
	  $(ECHO) '  x-h | x-? | x--help)'; \
	  $(ECHO) '    echo "Usage: $$P [-h | -? | --help] [DEST]" >&2'; \
	  $(ECHO) '    echo "" >&2'; \
	  $(ECHO) '    echo "Copy $(INCFILE) to DEST.  If DEST is not" >&2'; \
	  $(ECHO) '    echo "given, current working directory is used." >&2'; \
	  $(ECHO) '    echo "If one of -h, -?, or --help is present," >&2'; \
	  $(ECHO) '    echo "$$P prints its help and exits." >&2'; \
	  $(ECHO) '    echo "" >&2'; \
	  $(ECHO) '    exit 0'; \
	  $(ECHO) '    ;;'; \
	  $(ECHO) 'esac'; \
	  $(ECHO) ''; \
	  $(ECHO) 'cp $(INCPATH) $$D/$(INCFILE)'; \
	) > $(BUNDLESCRIPTPATH)
	$(CHMOD) 755 $(BUNDLESCRIPTPATH)

$(call Target, uninstall, uninstall mkutils)
	$(RM) -rfd $(INCDIR)
	$(RM) -f $(BUNDLESCRIPTPATH)
endif

$(call Target, bundle, bundle mkutils to an existing project)
	$(EDIT) $(CURDIR)/$(INCFILE) > $(DEST)/$(INCFILE)

$(call Target, test, run test suite)
	$(MAKE) -f $(CURDIR)/tests.mk

$(call GenerateHelp)
