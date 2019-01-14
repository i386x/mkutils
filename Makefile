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

NAME = $(__mkutils_name__)
INCFILE := $(NAME).mk

$(call AddToolX, chmod)
$(call AddToolX, mkdir)
$(call AddTool, sed)

$(call AddVarX, prefix, /usr/local)
$(call DefVarX, bindir, $$(prefix)/bin)
$(call DefVarX, includedir, $$(prefix)/include)

$(call DefaultTarget, help)

$(call SetVarX, INCDIR, $$(includedir)/$$(NAME))
$(call SetVarX, INCPATH, $$(INCDIR)/$$(INCFILE))
$(call SetVarX, BUNDLESCRIPTFILE, $$(NAME)-bundle)
$(call SetVarX, BUNDLESCRIPTPATH, $$(bindir)/$$(BUNDLESCRIPTFILE))

EDIT := $(SED) -e 's,^\#! \\file    ~/$(INCFILE)$$,\#! \\file    $(INCFILE),g'

$(call TargetX, install, \
    install $(NAME); supported settings are \
    /l -n -i 0 \
    /i prefix=PATH \
    /| [$(prefix)] \
    /| specify the installation prefix \
    /i bindir=PATH \
    /| [$(bindir)] \
    /| where to install binaries \
    /i includedir=PATH \
    /| [$(includedir)] \
    /| where to install $(INCFILE) \
    /e \
)
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

$(call TargetX, uninstall, \
    uninstall $(NAME); supported settings are \
    /l -n -i 0 \
    /i prefix=PATH \
    /| [$(prefix)] \
    /| specify the installation prefix of installed files and directories \
    /i bindir=PATH \
    /| [$(bindir)] \
    /| where the binaries are installed \
    /i includedir=PATH \
    /| [$(includedir)] \
    /| where the $(INCFILE) is installed \
    /e \
)
	$(RM) -rfd $(INCDIR)
	$(RM) -f $(BUNDLESCRIPTPATH)

DEST ?= $(CURDIR)

$(call Target, bundle, \
    bundle $(NAME) to an existing project; $(INCFILE) is copied and edited /n \
    to the location specified by DEST; supported settings are \
    /l -n -i 0 \
    /i DEST=PATH \
    /| [$(DEST)] \
    /| where to copy and edit $(INCFILE) \
    /e \
)
ifeq ($(DEST),$(CURDIR))
	@$(ECHO) "Please set DEST to be not the source location."
	@$(FALSE)
else
	$(EDIT) $(CURDIR)/$(INCFILE) > $(DEST)/$(INCFILE)
endif

$(call Target, test, run the test suite)
	$(MAKE) -f $(CURDIR)/tests.mk

$(call GenerateHelp)
