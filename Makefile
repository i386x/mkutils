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
$(call AddToolX, cat)
$(call AddTool, sed)

$(call AddVarX, prefix=PATH, /usr/local, \
    specify installation prefix of installed or to be /n \
    installed files and directories, \
    install uninstall \
)
$(call DefVarX, bindir=PATH, $$(prefix)/bin, \
    specify where to install binaries or where the /n \
    binaries are installed, \
    install uninstall \
)
$(call DefVarX, includedir=PATH, $$(prefix)/include, \
    specify where to install $(INCFILE) or where the /n \
    $(INCFILE) is installed, \
    install uninstall \
)
$(call AddVar, DEST=PATH, $$(CURDIR), \
    specify where to copy $(INCFILE), \
    bundle \
)

$(call DefaultTarget, help)

$(call SetVarX, INCDIR, $$(includedir)/$$(NAME))
$(call SetVarX, INCPATH, $$(INCDIR)/$$(INCFILE))
$(call SetVarX, BUNDLESCRIPTFILE, $$(NAME)-bundle)
$(call SetVarX, BUNDLESCRIPTPATH, $$(bindir)/$$(BUNDLESCRIPTFILE))

EDIT := $(SED) -e 's,^\#! \\file    ~/$(INCFILE)$$,\#! \\file    $(INCFILE),g'

$(call TargetX, install, install $(NAME))
	$(MKDIR) -p $(INCDIR)
	$(EDIT) $(CURDIR)/$(INCFILE) > $(INCPATH)
	$(CHMOD) 644 $(INCPATH)
	$(CAT) $(CURDIR)/$(BUNDLESCRIPTFILE).in \
	| $(SED) -e 's,@INCFILE@,$(INCFILE),g' \
	         -e 's,@INCPATH@,$(INCPATH),g' \
	> $(BUNDLESCRIPTPATH)
	$(CHMOD) 755 $(BUNDLESCRIPTPATH)

$(call TargetX, uninstall, uninstall $(NAME))
	$(RM) -rfd $(INCDIR)
	$(RM) -f $(BUNDLESCRIPTPATH)

$(call Target, bundle, \
    bundle $(NAME) to an existing project; /n \
    $(INCFILE) is copied and edited to the /n \
    location specified by DEST \
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
