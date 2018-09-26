#
#! \file    ~/call-proxy.mk
#! \author  Jiří Kučera, <sanczes AT gmail.com>
#! \stamp   2018-09-24 22:10:32 +0200
#! \project mkutils - Makefile Utilities
#! \license MIT
#! \version 0.0.0
#! \brief   Works as proxy to call.
#

include $(CURDIR)/mkutils.mk

_0 :=
_1 :=
_2 :=
_3 :=

$(call $(_0),$(_1),$(_2),$(_3))

all:
	@$(TRUE)
