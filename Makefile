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

HELP_FIRSTCOLWIDTH := 4
$(call DefaultTarget, help)

$(call Target, test, run test suite)
	$(MAKE) -f $(CURDIR)/tests.mk

$(call GenerateHelp)
