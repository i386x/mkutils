#
#! \file    ~/mkutils.mk
#! \author  Jiří Kučera, <sanczes AT gmail.com>
#! \stamp   2018-09-05 15:52:56 +0200
#! \project mkutils - Makefile Utilities
#! \license MIT
#! \version 0.0.0
#! \brief   Makefile utilities.
#

ifndef __mkutils_version__

## ============================================================================
## == 1) System settings                                                     ==
## ============================================================================

# mkutils name
__mkutils_name__ := mkutils

# mkutils version
__mkutils_version__ := 0.0.0

##
# Handy constants.
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
LINE := ---------------------------------------
LINE := $(LINE)$(LINE)-
DLINE := =======================================
DLINE := $(DLINE)$(DLINE)=
[ := (
] := )
. := .
, := ,
define nl =

endef
[a-z] := a b c d e f g h i j k l m n o p q r s t u v w x y z
[A-Z] := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z

##
# Help to specify the location of tools used by mkutils. TOOLS_PREFIX should
# be an absolute path to the tools directory (must ends with `/`),
# TOOLS_EXESUFF specifies the tool's extension (e.g. `.exe`). If TOOLS_PREFIX
# (TOOLS_EXESUFF) is not defined, PREFIX (EXESUFF) are used as default.
TOOLS_PREFIX ?= $(PREFIX)
export TOOLS_PREFIX
TOOLS_EXESUFF ?= $(EXESUFF)
export TOOLS_EXESUFF

##
# Tools. The user has last word here.
TRUE ?= $(TOOLS_PREFIX)true$(TOOLS_EXESUFF)
export TRUE
FALSE ?= $(TOOLS_PREFIX)false$(TOOLS_EXESUFF)
export FALSE
ECHO ?= $(TOOLS_PREFIX)echo$(TOOLS_EXESUFF)
export ECHO
TEST ?= $(TOOLS_PREFIX)test$(TOOLS_EXESUFF)
export TEST
WHICH ?= $(TOOLS_PREFIX)which$(TOOLS_EXESUFF)
export WHICH
PRINTF ?= $(TOOLS_PREFIX)printf$(TOOLS_EXESUFF)
export PRINTF
EXPR ?= $(TOOLS_PREFIX)expr$(TOOLS_EXESUFF)
export EXPR

# Detect if are running under MS Windows
ifneq ($(PATHEXT),)
MSWINDOWS ?= 1
else
MSWINDOWS ?= 0
endif
export MSWINDOWS

# Detect if we are running in interactive shell
ifneq ($(MSWINDOWS),1)
  ifeq ($(ISATTY),)
    $(shell $(TEST) -t 0 >/dev/null 2>&1)
    ifeq ($(.SHELLSTATUS),0)
      ISATTY := 1
    else
      ISATTY := 0
    endif
    export ISATTY
  endif
endif

# Set default goal's name
.DEFAULT_GOAL := all
.PHONY: all

## ============================================================================
## == 2) Boolean operations                                                  ==
## ============================================================================

##
# Identity $1
# -----------------------------------------------------------------------------
# $1 - value
# -----------------------------------------------------------------------------
# Return $1.
Identity = $(call $(0)_,$(strip $1))
Identity_ = $1

##
# Not $1
# -----------------------------------------------------------------------------
# $1 - value
# -----------------------------------------------------------------------------
# Return true (non-empty value) if $1 is false (empty) and vice versa.
Not = $(call $(0)_,$(strip $1))
Not_ = $(if $1,,X)

## ============================================================================
## == 3) List operations                                                     ==
## ============================================================================

##
# Head $1
# -----------------------------------------------------------------------------
# $1 - list
# -----------------------------------------------------------------------------
# Return first element of $1.
Head = $(call $(0)_,$(strip $1))
Head_ = $(firstword $1)

##
# Elem $1 $2
# -----------------------------------------------------------------------------
# $1 - list
# $2 - element position (1 if missing)
# -----------------------------------------------------------------------------
# Return the $2th element of $1 (starting from 1). If $2 is out of range,
# return false. $2 can be omitted; in this case `Elem $1` is an alias for
# `Head $1`.
Elem = $(call $(0)_,$(strip $1),$(strip $2))
Elem_ = $(word $(if $2,$2,1),$1)

##
# Tail $1
# -----------------------------------------------------------------------------
# $1 - list
# -----------------------------------------------------------------------------
# Return the list equal to $1 without first element.
Tail = $(call $(0)_,$(strip $1))
Tail_ = $(wordlist 2,$(words $1),$1)

##
# Slice $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - list
# $2 - from
# $3 - to (optional)
# -----------------------------------------------------------------------------
# Return a sublist of $1 starting from element number $2 and ending by element
# number $3. Both $2 and $3 are included in the returned sublist. If $3 is not
# given, it is treated as the index of the last element of $1. All indexes are
# 1-based. If there is no element between $2 and $3, empty list is returned.
# Note that if $2 == $3 and $2 is in range then there is exactly one element
# in the returned sublist.
Slice = $(call $(0)_,$(strip $1),$(strip $2),$(strip $3))
Slice_ = $(wordlist $2,$(if $3,$3,$(words $1)),$1)

## ============================================================================
## == 4) String services                                                     ==
## ============================================================================

__mkutils_translate_temp :=
__mkutils_tolowertab := A,a B,b C,c D,d E,e F,f G,g H,h I,i J,j K,k L,l M,m
__mkutils_tolowertab += N,n O,o P,p Q,q R,r S,s T,t U,u V,v W,w X,x Y,y Z,z
__mkutils_touppertab := a,A b,B c,C d,D e,E f,F g,G h,H i,I j,J k,K l,L m,M
__mkutils_touppertab += n,N o,O p,P q,Q r,R s,S t,T u,U v,V w,W x,X y,Y z,Z

##
# Strlen $1
# -----------------------------------------------------------------------------
# $1 - string
# -----------------------------------------------------------------------------
# Return the length of $1 or report an error.
Strlen = $(call EvalExpr,length "$(strip $1)")

##
# Translate $1 $2
# -----------------------------------------------------------------------------
# $1 - variable name holding the translation table
# $2 - string
# -----------------------------------------------------------------------------
# Translate $2 according to $1. $1 is a name of a variable that holds
# translation table. A translation table is a list of pairs X,Y (the comma
# between X and Y is important). Given a pair X,Y from $1, every occurence of
# X in $2 is substituted by Y.
Translate = $(strip \
    $(eval __mkutils_translate_temp := $2) \
    $(foreach x,$($(strip $1)),$(call $(0)_,$(subst $(,), ,$x))) \
    $(__mkutils_translate_temp) \
)
Translate_ = $(eval \
    __mkutils_translate_temp := $(subst \
        $(call Elem_,$1,1),$(call Elem_,$1,2),$(__mkutils_translate_temp) \
    ) \
)

##
# ToLower $1
# -----------------------------------------------------------------------------
# $1 - string
# -----------------------------------------------------------------------------
# Convert all uppercase letters in $1 to lowercase.
ToLower = $(call Translate, __mkutils_tolowertab, $1)

##
# ToUpper $1
# -----------------------------------------------------------------------------
# $1 - string
# -----------------------------------------------------------------------------
# Convert all lowercase letters in $1 to uppercase.
ToUpper = $(call Translate, __mkutils_touppertab, $1)

## ============================================================================
## == 5) Hashing                                                             ==
## ============================================================================

##
# MakeMap $1
# -----------------------------------------------------------------------------
# $1 - map name
# -----------------------------------------------------------------------------
# Create a map under the name $1.
MakeMap = $(eval __mkutils_map_$(strip $1)_keys :=)

##
# MapKeys $1
# -----------------------------------------------------------------------------
# $1 - map name
# -----------------------------------------------------------------------------
# Return the list of keys of $1.
MapKeys = $(__mkutils_map_$(strip $1)_keys)

##
# MapSize $1
# -----------------------------------------------------------------------------
# $1 - map name
# -----------------------------------------------------------------------------
# Return the number of items in $1.
MapSize = $(words $(call MapKeys, $1))

##
# KVSetKey $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# $3 - value
# -----------------------------------------------------------------------------
# Store $3 to $1 under the $2. Low-level routine.
KVSetKey = $(eval __mkutils_map_$1[$2] := $3)

##
# KVGetKey $1 $2
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# -----------------------------------------------------------------------------
# Get the value stored under the key $2 in $1. Low-level routine.
KVGetKey = $(__mkutils_map_$1[$2])

##
# KVHasKey $1 $2
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# -----------------------------------------------------------------------------
# Return true if $2 is in $1. Low-level routine.
KVHasKey = $(if $2,$(filter $2,$(call MapKeys, $1)))

##
# KVAddKey $1 $2
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# -----------------------------------------------------------------------------
# Add key $2 to $1, but do not associate $2 with any value (the former
# associations remain untouched). Low-level routine.
KVAddKey = $(if $(call KVHasKey,$1,$2),,$(eval __mkutils_map_$1_keys += $2))

##
# KVTagKey $1 $2
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# -----------------------------------------------------------------------------
# Tag $2 in $1. Tagging is used to mark selected keys for further processing.
# Low-level routine.
KVTagKey = $(if $(call KVHasKey,$1,$2),$(eval __mkutils_map_$1[$2]_ := 1))

##
# KVIsTagged $1 $2
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# -----------------------------------------------------------------------------
# Return true if $2 is tagged in $1. Low-level routine.
KVIsTagged = $(__mkutils_map_$1[$2]_)

##
# KVUntagKey $1 $2
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# -----------------------------------------------------------------------------
# Untag $2 in $1. Low-level routine.
KVUntagKey = $(if $(call KVIsTagged,$1,$2),$(eval __mkutils_map_$1[$2]_ :=))

##
# KVRemoveKey $1 $2
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# -----------------------------------------------------------------------------
# Remove $2 from $1. Low-level routine.
KVRemoveKey = $(eval \
    __mkutils_map_$1_keys := $(filter-out $2,$(call MapKeys, $1)) \
)

##
# KVSet $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# $3 - value
# -----------------------------------------------------------------------------
# Add $3 to $1 under the key $2. This also untag $2. Also create $1 if it is
# not created yet.
KVSet = $(call $(0)_,$(strip $1),$(strip $2),$(strip $3))
KVSet_ = $(if $2,$(strip \
    $(if $(call MapKeys, $1),,$(call MakeMap, $1)) \
    $(call KVAddKey,$1,$2) \
    $(call KVUntagKey,$1,$2) \
    $(call KVSetKey,$1,$2,$3) \
))

##
# KVGet $1 $2
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# -----------------------------------------------------------------------------
# Get the value stored under the key $2 in $1.
KVGet = $(call $(0)Key,$(strip $1),$(strip $2))

##
# KVHas $1 $2
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# -----------------------------------------------------------------------------
# Return true if $2 is in $1.
KVHas = $(call $(0)Key,$(strip $1),$(strip $2))

##
# KVDel $1 $2
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# -----------------------------------------------------------------------------
# Remove $2 from $1. This also untag $2.
KVDel = $(call $(0)_,$(strip $1),$(strip $2))
KVDel_ = $(if $(call KVHasKey,$1,$2),$(strip \
    $(call KVSetKey,$1,$2,) \
    $(call KVUntagKey,$1,$2) \
    $(call KVRemoveKey,$1,$2) \
))

##
# KVHide $1 $2
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# -----------------------------------------------------------------------------
# Hide $2 in $1, so algorithms working with $1 behave like if $2 was removed.
# The value stored under the key $2 remains untouched. Use hiding instead of
# removing for reusable keys.
KVHide = $(call KVTagKey,$(strip $1),$(strip $2))

##
# KVIsHidden $1 $2
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# -----------------------------------------------------------------------------
# Return true if $2 is hidden in $1.
KVIsHidden = $(call KVIsTagged,$(strip $1),$(strip $2))

##
# KVUnhide $1 $2
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - key
# -----------------------------------------------------------------------------
# Unhide $2 in $1.
KVUnhide = $(call KVUntagKey,$(strip $1),$(strip $2))

##
# KVApply $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - function
# $3 - user argument to $2
# -----------------------------------------------------------------------------
# Iterate over all visible keys of $1. During every iteration, call $2 with the
# value stored under the current key in $1 as the 1st argument, the current key
# as the 2nd argument, the $1 as the 3rd argument, and the $3 as the 4th
# argument.
KVApply = $(call $(0)_,$(strip $1),$(strip $2),$(strip $3))
KVApply_ = $(strip $(foreach x,$(call MapKeys,$1),$(call $(0)a,$x,$1,$2,$3)))
KVApply_a = $(if $(call KVIsTagged,$2,$1),, \
    $(call $3,$(call KVGetKey,$2,$1),$1,$2,$4) \
)

##
# KVApplyHidden $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - function
# $3 - user argument to $2
# -----------------------------------------------------------------------------
# Iterate over all hidden keys of $1. During every iteration, call $2 with the
# value stored under the current key in $1 as the 1st argument, the current key
# as the 2nd argument, the $1 as the 3rd argument, and the $3 as the 4th
# argument.
KVApplyHidden = $(call $(0)_,$(strip $1),$(strip $2),$(strip $3))
KVApplyHidden_ = $(strip \
    $(foreach x,$(call MapKeys,$1),$(call $(0)a,$x,$1,$2,$3)) \
)
KVApplyHidden_a = $(if $(call KVIsTagged,$2,$1), \
    $(call $3,$(call KVGetKey,$2,$1),$1,$2,$4) \
)

##
# KVApplyAll $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - map name
# $2 - function
# $3 - user argument to $2
# -----------------------------------------------------------------------------
# Iterate over all keys of $1. During every iteration, call $2 with the value
# stored under the current key in $1 as the 1st argument, the current key as
# the 2nd argument, the $1 as the 3rd argument, and the $3 as the 4th argument.
KVApplyAll = $(call $(0)_,$(strip $1),$(strip $2),$(strip $3))
KVApplyAll_ = $(strip $(foreach x,$(call MapKeys,$1), \
    $(call $2,$(call KVGetKey,$1,$x),$x,$1,$3) \
))

## ============================================================================
## == 6) Evaluating expressions                                              ==
## ============================================================================

# Counters
__mkutils_counter_a := 0
__mkutils_counter_b := 0
__mkutils_counter_c := 0
__mkutils_counter_d := 0
__mkutils_counter_e := 0
__mkutils_counter_f := 0
__mkutils_counter_g := 0
__mkutils_counter_h := 0
__mkutils_counter_i := 0
__mkutils_counter_j := 0

##
# EvalExpr $1
# -----------------------------------------------------------------------------
# $1 - expression to be evaluated
# -----------------------------------------------------------------------------
# Eval $1 using $(EXPR) and return the result or report an error.
EvalExpr = $(call RunWithHooks_,$(EXPR) $1,Identity,$(0)_)
EvalExpr_ = $(if $(call Equal_,$1,1),$(__mkutils_Run_output), \
    $(error Evaluating expression failed with $1: $(__mkutils_Run_output)) \
)

##
# AssertCounter $1
# -----------------------------------------------------------------------------
# $1 - counter name (must be a letter from "a" to "j")
# -----------------------------------------------------------------------------
# Report an error if $1 is not defined.
AssertCounter = $(call AssertVar_,__mkutils_counter_$(strip $1))

##
# Reset $1 $2
# -----------------------------------------------------------------------------
# $1 - counter name (must be a letter from "a" to "j")
# $2 - counter value (must be an integer or empty)
# -----------------------------------------------------------------------------
# Set $1's value to $2. If $2 is ommited, set $1 to 0.
Reset = $(call $(0)_,$(strip $1),$(strip $2))
Reset_ = $(call AssertCounter,$1)$(eval __mkutils_counter_$1 := $(if $2,$2,0))

##
# Value $1
# -----------------------------------------------------------------------------
# $1 - counter name (must be a letter from "a" to "j")
# -----------------------------------------------------------------------------
# Get the $1's value.
Value = $(call AssertCounter,$1)$(__mkutils_counter_$(strip $1))

##
# IsZero $1
# -----------------------------------------------------------------------------
# $1 - counter name (must be a letter from "a" to "j")
# -----------------------------------------------------------------------------
# Test if $1 is zero.
IsZero = $(call Eq,$(call Value,$1),0)

##
# Inc $1
# -----------------------------------------------------------------------------
# $1 - counter name (must be a letter from "a" to "j")
# -----------------------------------------------------------------------------
# Increase $1 by one.
Inc = $(call $(0)_,$(strip $1))
Inc_ = $(eval __mkutils_counter_$1 := $(call Add,$(call Value,$1),1))

##
# Dec $1
# -----------------------------------------------------------------------------
# $1 - counter name (must be a letter from "a" to "j")
# -----------------------------------------------------------------------------
# Decrease $1 by one, but not to negative value (Dec 0 will be always 0).
Dec = $(call $(0)_,$(strip $1))
Dec_ = $(strip \
    $(if $(call Gt_,$(call Value,$1),0), \
        $(eval __mkutils_counter_$1 := $(call Sub,$(call Value,$1),1)), \
        $(eval __mkutils_counter_$1 := 0) \
    ) \
)

##
# Add $1 $2
# -----------------------------------------------------------------------------
# $1 - 1st operand (must be an integer)
# $2 - 2nd operand (must be an integer)
# -----------------------------------------------------------------------------
# Return the value of `$1 + $2` or report an error.
Add = $(call EvalExpr,$1 + $2)

##
# Sub $1 $2
# -----------------------------------------------------------------------------
# $1 - 1st operand (must be an integer)
# $2 - 2nd operand (must be an integer)
# -----------------------------------------------------------------------------
# Return the value of `$1 - $2` or report an error.
Sub = $(call EvalExpr,$1 - $2)

##
# Mul $1 $2
# -----------------------------------------------------------------------------
# $1 - 1st operand (must be an integer)
# $2 - 2nd operand (must be an integer)
# -----------------------------------------------------------------------------
# Return the value of `$1 * $2` or report an error.
Mul = $(call EvalExpr,$1 \* $2)

##
# Div $1 $2
# -----------------------------------------------------------------------------
# $1 - 1st operand (must be an integer)
# $2 - 2nd operand (must be a non-zero integer)
# -----------------------------------------------------------------------------
# Return the value of `$1 / $2` or report an error.
Div = $(call AssertNe_,$2,0)$(call EvalExpr,$1 / $2)

##
# Mod $1 $2
# -----------------------------------------------------------------------------
# $1 - 1st operand (must be an integer)
# $2 - 2nd operand (must be a non-zero integer)
# -----------------------------------------------------------------------------
# Return the value of `$1 % $2` or report an error.
Mod = $(call AssertNe_,$2,0)$(call EvalExpr,$1 % $2)

## ============================================================================
## == 7) Value testing                                                       ==
## ============================================================================

##
# IfEmpty $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - values
# -----------------------------------------------------------------------------
# Return $2 if $1 is empty. Otherwise $1 is returned.
IfEmpty = $(call $(0)_,$(strip $1),$(strip $2))
IfEmpty_ = $(if $1,$1,$2)

##
# Eq $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Return true if $1 == $2.
Eq = $(call $(0)_,$(strip $1),$(strip $2))
Eq_ = $(call ExitsWith,$(TEST) $1 -eq $2,0)

##
# Ne $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Return true if $1 != $2.
Ne = $(call $(0)_,$(strip $1),$(strip $2))
Ne_ = $(call ExitsWith,$(TEST) $1 -ne $2,0)

##
# Lt $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Return true if $1 < $2.
Lt = $(call $(0)_,$(strip $1),$(strip $2))
Lt_ = $(call ExitsWith,$(TEST) $1 -lt $2,0)

##
# Gt $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Return true if $1 > $2.
Gt = $(call $(0)_,$(strip $1),$(strip $2))
Gt_ = $(call ExitsWith,$(TEST) $1 -gt $2,0)

##
# Le $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Return true if $1 <= $2.
Le = $(call $(0)_,$(strip $1),$(strip $2))
Le_ = $(call ExitsWith,$(TEST) $1 -le $2,0)

##
# Ge $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Return true if $1 >= $2.
Ge = $(call $(0)_,$(strip $1),$(strip $2))
Ge_ = $(call ExitsWith,$(TEST) $1 -ge $2,0)

##
# Equal $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - strings
# -----------------------------------------------------------------------------
# Return true if $1 == $2.
Equal = $(call $(0)_,$(strip $1),$(strip $2))
Equal_ = $(call Not_,$(call NotEqual_,$1,$2))

##
# NotEqual $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - strings
# -----------------------------------------------------------------------------
# Return true if $1 != $2.
NotEqual = $(call $(0)_,$(strip $1),$(strip $2))
NotEqual_ = $(subst x$1,,x$2)$(subst x$2,,x$1)

## ============================================================================
## == 8) Assertions                                                          ==
## ============================================================================

##
# Assert $1 $2
# -----------------------------------------------------------------------------
# $1 - value
# $2 - error message
# -----------------------------------------------------------------------------
# Proceed with error and print $2 if $1 is false.
Assert = $(call $(0)_,$(strip $1),$(strip $2))
Assert_ = $(if $1,,$(error $2))

##
# AssertVar $1
# -----------------------------------------------------------------------------
# $1 - variable name
# -----------------------------------------------------------------------------
# Proceed with error if $1 is empty or undefined.
AssertVar = $(call $(0)_,$(strip $1))
AssertVar_ = $(call Assert_,$($1),$1 is empty or undefined)

##
# AssertEq $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Proceed with error if $1 != $2.
AssertEq = $(call $(0)_,$(strip $1),$(strip $2))
AssertEq_ = $(call Assert_,$(call Eq_,$1,$2),Assertion x == y failed: $1 != $2)

##
# AssertNe $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Proceed with error if $1 == $2.
AssertNe = $(call $(0)_,$(strip $1),$(strip $2))
AssertNe_ = $(call Assert_,$(call Ne_,$1,$2),Assertion x != y failed: $1 == $2)

##
# AssertLt $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Proceed with error if $1 >= $2.
AssertLt = $(call $(0)_,$(strip $1),$(strip $2))
AssertLt_ = $(call Assert_,$(call Lt_,$1,$2),Assertion x < y failed: $1 >= $2)

##
# AssertGt $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Proceed with error if $1 <= $2.
AssertGt = $(call $(0)_,$(strip $1),$(strip $2))
AssertGt_ = $(call Assert_,$(call Gt_,$1,$2),Assertion x > y failed: $1 <= $2)

##
# AssertLe $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Proceed with error if $1 > $2.
AssertLe = $(call $(0)_,$(strip $1),$(strip $2))
AssertLe_ = $(call Assert_,$(call Le_,$1,$2),Assertion x <= y failed: $1 > $2)

##
# AssertGe $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Proceed with error if $1 < $2.
AssertGe = $(call $(0)_,$(strip $1),$(strip $2))
AssertGe_ = $(call Assert_,$(call Ge_,$1,$2),Assertion x >= y failed: $1 < $2)

##
# AssertEqual $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - strings
# -----------------------------------------------------------------------------
# Proceed with error if $1 != $2.
AssertEqual = $(call $(0)_,$(strip $1),$(strip $2))
AssertEqual_ = $(call Assert_,$(call Equal_,$1,$2),$(strip \
    Assertion x == y failed: '$1' != '$2' \
))

##
# AssertNotEqual $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - strings
# -----------------------------------------------------------------------------
# Proceed with error if $1 == $2.
AssertNotEqual = $(call $(0)_,$(strip $1),$(strip $2))
AssertNotEqual_ = $(call Assert_,$(call NotEqual_,$1,$2),$(strip \
    Assertion x != y failed: '$1' == '$2' \
))

## ============================================================================
## == 9) Printing                                                            ==
## ============================================================================

# Detect for coloured output support
ifneq ($(COLORTERM),)
__mkutils_color = $1
else ifneq ($(findstring color,$(TERM)),)
__mkutils_color = $1
else ifeq ($(TERM),xterm)
__mkutils_color = $1
else ifeq ($(TERM),linux)
__mkutils_color = $1
else
__mkutils_color =
endif

# Not running in terminal
ifneq ($(ISATTY),1)
__mkutils_color =
endif

# The user has the last word
ifdef NOCOLORS
__mkutils_color =
export NOCOLORS
endif

# Enable `-e` option for $(ECHO) only if coloring is supported
__mkutils_echo_e := $(call __mkutils_color,-e)

##
# ANSI color escape codes to be handled by `$(ECHO) -e`.
ANSI_COLOR_OFF := $(call __mkutils_color,\e[0m)
ANSI_COLOR_BLACK := $(call __mkutils_color,\e[0;30m)
ANSI_COLOR_RED := $(call __mkutils_color,\e[0;31m)
ANSI_COLOR_GREEN := $(call __mkutils_color,\e[0;32m)
ANSI_COLOR_BROWN := $(call __mkutils_color,\e[0;33m)
ANSI_COLOR_BLUE := $(call __mkutils_color,\e[0;34m)
ANSI_COLOR_PURPLE := $(call __mkutils_color,\e[0;35m)
ANSI_COLOR_CYAN := $(call __mkutils_color,\e[0;36m)
ANSI_COLOR_LIGHT_GRAY := $(call __mkutils_color,\e[0;37m)
ANSI_COLOR_DARK_GRAY := $(call __mkutils_color,\e[1;30m)
ANSI_COLOR_LIGHT_RED := $(call __mkutils_color,\e[1;31m)
ANSI_COLOR_LIGHT_GREEN := $(call __mkutils_color,\e[1;32m)
ANSI_COLOR_YELLOW := $(call __mkutils_color,\e[1;33m)
ANSI_COLOR_LIGHT_BLUE := $(call __mkutils_color,\e[1;34m)
ANSI_COLOR_LIGHT_PURPLE := $(call __mkutils_color,\e[1;35m)
ANSI_COLOR_LIGHT_CYAN := $(call __mkutils_color,\e[1;36m)
ANSI_COLOR_WHITE := $(call __mkutils_color,\e[1;37m)

##
# Colorize $1 $2
# -----------------------------------------------------------------------------
# $1 - color name without ANSI_COLOR_ prefix
# $2 - text
# -----------------------------------------------------------------------------
# Make $2 $1-colored.
Colorize = $(ANSI_COLOR_$1)$2$(ANSI_COLOR_OFF)

##
# Print $1 $2
# -----------------------------------------------------------------------------
# $1 - text
# $2 - additional options to $(ECHO)
# -----------------------------------------------------------------------------
# Print $1 to standard error output.
Print = $(shell $(ECHO) $2 "$1" >&2)

##
# ColorPrint $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - color name without `ANSI_COLOR_` prefix
# $2 - text
# $3 - additional options to $(ECHO)
# -----------------------------------------------------------------------------
# Print $2 to standard error output colored.
ColorPrint = $(call Print,$(call Colorize,$1,$2),$(__mkutils_echo_e) $3)

##
# LightColorPrint $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - color name without `ANSI_COLOR_LIGHT_` prefix
# $2 - text
# $3 - additional options to $(ECHO)
# -----------------------------------------------------------------------------
# Like ColorPrint but use light colors.
LightColorPrint = $(call ColorPrint,LIGHT_$1,$2,$3)

## ============================================================================
## == 10) Running programs                                                   ==
## ============================================================================

__mkutils_Run_output :=
__mkutils_Run_exitcode := 0
__mkutils_SoftRun_ :=

##
# ShowOutput
# -----------------------------------------------------------------------------
# Show the output of the last command invoked by Run.
ShowOutput = $(call LightColorPrint,GREEN,$(__mkutils_Run_output))

##
# ShowExitcode
# -----------------------------------------------------------------------------
# Show the exit code of the last command invoked by Run.
ShowExitcode = $(call \
    LightColorPrint,RED,[exit_code = $(__mkutils_Run_exitcode)], \
)

##
# ShowStatus
# -----------------------------------------------------------------------------
# Show both output and exit code of the last command invoked by Run.
ShowStatus = $(call ShowOutput)$(call ShowExitcode)

##
# Run $1
# -----------------------------------------------------------------------------
# $1 - shell command
# -----------------------------------------------------------------------------
# Run $1, save output to __var_Run_output and exit code to __var_Run_exitcode.
Run = $(strip \
    $(eval __mkutils_Run_output := $(shell $1 2>&1)) \
    $(eval __mkutils_Run_exitcode := $(.SHELLSTATUS)) \
)

##
# SoftRun $1
# -----------------------------------------------------------------------------
# $1 - shell command
# -----------------------------------------------------------------------------
# Run $1 quietly.
SoftRun = $(eval __mkutils_SoftRun_ := $(shell $1 >/dev/null 2>&1))

##
# RunWithHooks $1 $2 $3
# -----------------------------------------------------------------------------
# $1     - shell command
# $2, $3 - name of a function with one argument
# -----------------------------------------------------------------------------
# Run $1. If $1 succeeds, call $2 with $1's output. Otherwise, call $3 with
# $1's exit code. Return the value returned by $2 or $3.
RunWithHooks = $(call $(0)_,$1,$(strip $2),$(strip $3))
RunWithHooks_ = $(strip $(if $(call ExitsWith,$1,0), \
    $(call $2,$(__mkutils_Run_output)), \
    $(call $3,$(__mkutils_Run_exitcode)) \
))

##
# WhenOk $1 $2
# -----------------------------------------------------------------------------
# $1 - shell command
# $2 - name of a function with one argument
# -----------------------------------------------------------------------------
# Run $1. If $1 succeeds, call $2 with $1's output and return the value
# returned by $2. Otherwise, return false.
WhenOk = $(call $(0)_,$1,$(strip $2))
WhenOk_ = $(if $(call ExitsWith,$1,0),$(call $2,$(__mkutils_Run_output)))

##
# WhenFail $1 $2
# -----------------------------------------------------------------------------
# $1 - shell command
# $2 - name of a function with one argument
# -----------------------------------------------------------------------------
# Run $1. If $1 fails, call $2 with $1's exit code and return the value
# returned by $2. Otherwise, return false.
WhenFail = $(call $(0)_,$1,$(strip $2))
WhenFail_ = $(if $(call ExitsWith,$1,0),,$(call $2,$(__mkutils_Run_exitcode)))

##
# ExitsWith $1 $2
# -----------------------------------------------------------------------------
# $1 - shell command
# $2 - expected exit code
# -----------------------------------------------------------------------------
# Return true if $1 exits with $2.
ExitsWith = $(call Run,$1)$(call Equal_,$(__mkutils_Run_exitcode),$(strip $2))

##
# NotExitsWith $1 $2
# -----------------------------------------------------------------------------
# $1 - shell command
# $2 - exit code
# -----------------------------------------------------------------------------
# Return false if $1 exits with $2.
NotExitsWith = $(strip \
    $(call Run,$1) \
    $(call NotEqual_,$(__mkutils_Run_exitcode),$(strip $2)) \
)

##
# Which $1
# -----------------------------------------------------------------------------
# $1 - name of executable
# -----------------------------------------------------------------------------
# Return true if $1 is installed on a system.
Which = $(call ExitsWith,$(WHICH) $1,0)

##
# FindProgram $1
# -----------------------------------------------------------------------------
# $1 - list of program names
# -----------------------------------------------------------------------------
# Search $1 and return the name of first existing program within $1. If such a
# program is not installed on a system, return false.
FindProgram = $(call $(0)_,$(strip $1))
FindProgram_ = $(if $1,$(strip \
    $(call FindProgram_a,$(call Head_,$1),$(call Tail_,$1)) \
))
FindProgram_a = $(if $(call Which,$1),$1,$(call FindProgram_,$2))

## ============================================================================
## == 11) Probing Python interpreter                                         ==
## ============================================================================

##
# PyVersion $1 $2
# -----------------------------------------------------------------------------
# $1 - Python interpreter
# $2 - `major` or `minor`
# -----------------------------------------------------------------------------
# Depending on $2's value, return major or minor version number of $1. On
# error, return false.
PyVersion = $(call WhenOk_,$(call $(0)_a,$1,$(strip $2)),Identity)
PyVersion_a = $1 -c "import sys; sys.stdout.write(repr(sys.version_info.$2))"

##
# NeedPython $1 $2
# -----------------------------------------------------------------------------
# $1 - variable name with list of Python interpreters
# $2 - variable name with expected version
# -----------------------------------------------------------------------------
# Search $1 for a Python interpreter with version >= $2. If such an interpreter
# does not exist, proceed with error.
NeedPython = $(call $(0)_,$(strip $1),$(strip $2))
NeedPython_ = $(call AssertVar_,$2)$(call NeedPython_a,$($1),$($2))
NeedPython_a = $(call NeedPython_b,$(call NeedPython_c,$1,$2),$2)
NeedPython_b = $(if $1,$1,$(error Required Python X.Y, where XY >= $2))
NeedPython_c = $(strip \
    $(if $1,$(call NeedPython_d,$(call Head_,$1),$(call Tail_,$1),$2)) \
)
NeedPython_d = $(call NeedPython_e,$(call NeedPython_f,$1,$3),$2,$3)
NeedPython_e = $(if $1,$1,$(call NeedPython_c,$2,$3))
NeedPython_f = $(if $(call Which,$1),$(if $(call NeedPython_g,$1,$2),$1))
NeedPython_g = $(call NeedPython_h, \
    $(call PyVersion,$1,major), \
    $(call PyVersion,$1,minor), \
    $2 \
)
NeedPython_h = $(call NeedPython_i,$(strip $1),$(strip $2),$(strip $3))
NeedPython_i = $(if $1,$(if $2,$(call Ge_,$1$2,$3)))

## ============================================================================
## == 12) Targets                                                            ==
## ============================================================================

VARHELP_PADDING := 4

__mkutils_help_temp :=
__mkutils_help_targets :=
__mkutils_help_uvars :=
__mkutils_help_dvars :=
__mkutils_help_env :=
__mkutils_help_descname :=
__mkutils_help_l_i := 2
__mkutils_help_l_w := 1
__mkutils_help_l_s := *
__mkutils_help_l_j :=
__mkutils_help_l_t := 4
__mkutils_help_l_n := Empty
__mkutils_help_l_g = $(__mkutils_help_l_s)

##
# TargetNSQ
# -----------------------------------------------------------------------------
# Namespace qualifier of targets. Used only internally.
TargetNSQ = tg

##
# DVarNSQ
# -----------------------------------------------------------------------------
# Namespace qualifier of default variables (i.e. variables defined by mkutils).
# Used only internally.
DVarNSQ = dv

##
# UVarNSQ
# -----------------------------------------------------------------------------
# Namespace qualifier of user variables. Used only internally.
UVarNSQ = uv

##
# UpdatePadding $1 $2
# -----------------------------------------------------------------------------
# $1 - text
# $2 - namespace
# -----------------------------------------------------------------------------
# Updates HELP_$2_FIRSTCOLWIDTH and HELP_$2_PADDING (HELP_FIRSTCOLWIDTH and
# HELP_PADDING in case $2 is empty). HELP_$2_FIRSTCOLWIDTH holds the minimal
# size of space needed to fit $1. HELP_$2_PADDING is HELP_$2_FIRSTCOLWIDTH
# increased by the size of delimiter space. Parameters HELP_$2_FIRSTCOLWIDTH
# and HELP_$2_PADDING are used internally by FormatHelp to format term and its
# description to two-column table formatting.
UpdatePadding = $(call $(0)_a,$(call Strlen, $1),$(strip $2))
UpdatePadding_a = $(call UpdatePadding_b,$1,$(if $2,_$(2)_,_))
UpdatePadding_b = $(strip \
    $(if $(HELP$(2)FIRSTCOLWIDTH),, \
        $(eval HELP$(2)FIRSTCOLWIDTH := 0) \
        $(eval HELP$(2)PADDING := 0) \
    ) \
    $(if $(call Gt_,$1,$(HELP$(2)FIRSTCOLWIDTH)), \
        $(eval HELP$(2)FIRSTCOLWIDTH := $1) \
        $(eval HELP$(2)PADDING := $(call Add, $1, 3)) \
    ) \
)

##
# HelpLinesMap $1
# -----------------------------------------------------------------------------
# $1 - namespace
# -----------------------------------------------------------------------------
# Get the name of map with help lines associated with $1. Used only internally.
HelpLinesMap = help[$(strip $1)].lines

##
# HelpLines $1
# -----------------------------------------------------------------------------
# $1 - namespace
# -----------------------------------------------------------------------------
# Return help lines as a list of indicies. Used only internally.
HelpLines = $(call MapKeys,$(call HelpLinesMap,$1))

##
# GetHelpLine $1 $2
# -----------------------------------------------------------------------------
# $1 - namespace
# $2 - line index
# -----------------------------------------------------------------------------
# Return a help line at index $2. Used only internally.
GetHelpLine = $(call KVGet,$(call HelpLinesMap,$1),$2)

##
# AddToHelpLine $1 $2
# -----------------------------------------------------------------------------
# $1 - namespace
# $2 - words
# -----------------------------------------------------------------------------
# Add $2 to help lines under the index given by value of counter `a`. Used only
# internally.
AddToHelpLine = $(call $(0)_,$(call HelpLinesMap,$1),$2)
AddToHelpLine_ = $(strip \
    $(call KVSet, $1, $(call Value, a), \
        $(call KVGet, $1, $(call Value, a)) $2 \
    ) \
)

##
# DelHelpLine $1 $2
# -----------------------------------------------------------------------------
# $1 - namespace
# $2 - line index
# -----------------------------------------------------------------------------
# Remove a help line at index $2. Used only internally.
DelHelpLine = $(call KVDel,$(call HelpLinesMap,$1),$2)

##
# ReadHelpLine $1
# -----------------------------------------------------------------------------
# $1 - namespace
# -----------------------------------------------------------------------------
# From help lines, read and return a line with the least index. The reading
# operation is destructive, i.e. the read line is removed from help lines
# permanently. Used only internally.
ReadHelpLine = $(call $(0)_,$1,$(call Head_,$(call HelpLines, $1)))
ReadHelpLine_ = $(call GetHelpLine, $1, $2)$(call DelHelpLine, $1, $2)

##
# FormatHelp $1 $2
# -----------------------------------------------------------------------------
# $1 - namespace
# $2 - help text
# -----------------------------------------------------------------------------
# Split $2 to lines. The lines are stored to the help lines container
# associated with $1 and are accessible throught their indicies (1st line is
# mapped to `1` etc.). A help text is a list of words and commands. Commands
# supported so far are
#
#   /p <w> - print <w>
#   /n     - end the recent line
#   //     - end the recent line and insert empty line
#   /l ... - end the recent line and start a list environment; parameters (...)
#            are
#              -i <indentation>   set the list indentation from the left
#                                 (default: 2)
#              -w <label_width>   set the width of a label (default: 1)
#              -s <label_style>   set the style of a label; supported styles
#                                 are
#                                   1, a, A   use alphanumeric numbering
#                                   <x>       use <x> as a label
#                                 (default: *)
#              -l, -r             justify label to the left or right
#                                 (default: right)
#              -t <tab_size>      if item continue on the next line, insert
#                                 <tab_size> spaces before it (default: 4)
#              -n                 do not insert empty lines before and after
#                                 items
#   /d <n> - end the recent line and start a description environmet; <n> is
#            unique name to distinguish internal variables across description
#            environments
#   /i     - end the recent line and start an item
#   /|     - end the recent line and start a next line in item
#   /e     - end the recent line and close the current environment
#
# Unknown and incomplete commands are treated as ordinary words. Nested lists
# are not supported for now, the improper use of commands leads to undefined
# behaviour. As a side effect, this macro resets counter `a` to 0.
FormatHelp = $(strip \
    $(eval __mkutils_help_temp :=) \
    $(eval __mkutils_help_env :=) \
    $(eval __mkutils_help_descname :=) \
    $(call Reset_,a,1) \
    $(foreach w,$2,$(call $(0)_a,$1,$w)) \
    $(if $(__mkutils_help_temp), \
        $(call AddToHelpLine, $1, $(__mkutils_help_temp)) \
        $(eval __mkutils_help_temp :=) \
    ) \
    $(eval __mkutils_help_env :=) \
    $(eval __mkutils_help_descname :=) \
    $(call Reset_,a) \
)
# Note on formatting: read ",$(if ..." as "else if ..." and standalone "," as
# "else".
FormatHelp_a = $(strip \
    $(if $(call Equal_,$(__mkutils_help_temp),/p), \
        $(call AddToHelpLine, $1, $2) \
        $(eval __mkutils_help_temp :=) \
    ,$(if $(call Equal_,$(__mkutils_help_temp),/d), \
        $(call Inc_,a) \
        $(call AddToHelpLine, $1, /d $2) \
        $(eval __mkutils_help_env := D) \
        $(eval __mkutils_help_descname := $2) \
        $(eval __mkutils_help_temp :=) \
    ,$(if $(call Equal_,$(__mkutils_help_temp),/i), \
        $(call Inc_,a) \
        $(call UpdatePadding, $2, $(__mkutils_help_descname)) \
        $(call AddToHelpLine, $1, /i $2) \
        $(eval __mkutils_help_temp :=) \
    ,$(if $(call Equal_,$2,/p), \
        $(eval __mkutils_help_temp := $2) \
    ,$(if $(call Equal_,$2,/n), \
        $(call Inc_,a) \
    ,$(if $(call Equal_,$2,//), \
        $(call Inc_,a) \
        $(call AddToHelpLine, $1, $2) \
    ,$(if $(call Equal_,$2,/l), \
        $(call Inc_,a) \
        $(call AddToHelpLine, $1, $2) \
        $(eval __mkutils_help_env := L) \
    ,$(if $(call Equal_,$2,/d), \
        $(eval __mkutils_help_temp := $2) \
    ,$(if $(call Equal_,$2,/i), \
        $(if $(call Equal_,$(__mkutils_help_env),D), \
            $(eval __mkutils_help_temp := $2) \
        , \
            $(call Inc_,a) \
            $(call AddToHelpLine, $1, $2) \
        ) \
    ,$(if $(call Equal_,$2,/|), \
        $(call Inc_,a) \
        $(call AddToHelpLine, $1, $2) \
    ,$(if $(call Equal_,$2,/e), \
        $(call Inc_,a) \
        $(call AddToHelpLine, $1, $2) \
        $(eval __mkutils_help_env :=) \
    , \
        $(call AddToHelpLine, $1, $2) \
    ))))))))))) \
)

##
# GhlPunct $1
# -----------------------------------------------------------------------------
# $1 - text
# -----------------------------------------------------------------------------
# Sanitize spaces around punctation. Used only internally.
GhlPunct = $(subst e.g.  ,e.g. ,$(subst . ,.  ,$1))

##
# GhlIntro $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - namespace
# $2 - target name
# $3 - label
# -----------------------------------------------------------------------------
# Generate commands that prints first line of help text associated with $2.
# Used only internally.
GhlIntro = $(eval $(call \
    $(0)_,$2,$3,HELP_FIRSTCOLWIDTH,$(strip $(call ReadHelpLine,$1)), \
))
define GhlIntro_ =
.PHONY: $2
$2::
	@$$(PRINTF) "  %-$$($3)s - $(call GhlPunct,$4)\n" "$1"
endef

##
# GhlVarIntro $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - namespace
# $2 - var=domain pair (e.g. PROG=PATH)
# $3 - label
# $4 - variable holding indentation
# -----------------------------------------------------------------------------
# Generate commands that prints first lines of help text associated with $2.
# Used only internally.
GhlVarIntro = $(eval $(call $(0)_,$2,$3,$(call Head_,$(subst =, ,$2))))
GhlVarIntro_ = $(call $(0)a,$1,$2,$3,$(call GetTargetsAssociatedWithVar,$3))
define GhlVarIntro_a =
.PHONY: $2
$2::
	@$$(ECHO) "  $1"
ifneq ($4,)
	@$$(ECHO) "      [targets: $$(subst $$(SPACE),$$(,) ,$4)]"
endif
	@$$(ECHO) "      [default: $$(call ShowVar, $3)]"
endef

##
# GhlText $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - namespace
# $2 - target name or var=domain pair
# $3 - label
# $4 - variable holding indentation
# -----------------------------------------------------------------------------
# Generate commands that print the rest of lines of help text associated with
# $2. Used only internally.
GhlText = $(strip \
    $(call KVApplyAll, $(call HelpLinesMap, $1), GhlTextProcessLineCb,$3 $4) \
)

##
# GhlTextProcessLineCb $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - current value (here: line)
# $2 - current key (here: line number)
# $3 - map name (here: help[$namespace].lines)
# $4 - user's argument (here: $label $variable_holding_indentation)
# -----------------------------------------------------------------------------
# Callback to KVApplyAll. Called on each line from $3. Used only internally.
GhlTextProcessLineCb = $(call $(0)_,$4,$1)
GhlTextProcessLineCb_ = $(strip \
    $(call GhlTextProcessLineSwitch,$(call \
        Head_,$1),$(call \
        Elem_,$1,2),$(call \
        Head_,$2),$(call \
        Elem_,$2,2),$(call \
        Slice_,$2,3), \
    ) \
    $(call KVDel, $3, $2) \
)

##
# GhlTextProcessLineSwitch $1 $2 $3 $4 $5
# -----------------------------------------------------------------------------
# $1 - label
# $2 - variable holding indentation
# $3 - 1st word of line
# $4 - 2nd word of line
# $5 - the rest of line
# -----------------------------------------------------------------------------
# Based on value of $3, choose the proper action that generates printing
# commands. Used only internally.
GhlTextProcessLineSwitch = $(strip \
    $(if $(call Equal_,$3,//), \
        $(call GhlTextEmpty$(if $4,Plain),$1,$2,$4 $5) \
    ,$(if $(call Equal_,$3,/l), \
        $(eval __mkutils_help_env := L) \
        $(call GhlTextSetListDefaults) \
        $(call GhlTextProcessListParams,$4 $5) \
        $(eval __mkutils_help_temp :=) \
        $(call GhlTextSetListItemLabelRenderer) \
        $(call GhlText$(__mkutils_help_l_n),$1) \
    ,$(if $(call Equal_,$3,/d), \
        $(eval __mkutils_help_env := D) \
        $(eval __mkutils_help_descname := $4) \
        $(call GhlTextEmpty,$1) \
    ,$(if $(call Equal_,$3,/i), \
        $(call GhlTextInc$(__mkutils_help_env)ItemCounter) \
        $(call GhlText$(__mkutils_help_env)Item,$1,$2,$4,$5) \
    ,$(if $(call Equal_,$3,/|), \
        $(call GhlTextCont$(__mkutils_help_env)Item,$1,$2,$4 $5) \
    ,$(if $(call Equal_,$3,/e), \
        $(call GhlText$(call GhlTextNeedEmpty)$(if $4,Plain),$1,$2,$4 $5) \
        $(call GhlTextSetListDefaults) \
        $(eval __mkutils_help_env :=) \
        $(eval __mkutils_help_descname :=) \
    , \
        $(call GhlTextNonePlain,$1,$2,$3 $4 $5) \
    )))))) \
)

##
# GhlTextSetListDefaults
# -----------------------------------------------------------------------------
# Set the default parameters of list environment. Used only internally.
GhlTextSetListDefaults = $(strip \
    $(eval __mkutils_help_l_i := 2) \
    $(eval __mkutils_help_l_w := 1) \
    $(eval __mkutils_help_l_s := *) \
    $(eval __mkutils_help_l_j :=) \
    $(eval __mkutils_help_l_t := 4) \
    $(eval __mkutils_help_l_n := Empty) \
    $(eval __mkutils_help_l_g = $$(__mkutils_help_l_s)) \
    $(eval __mkutils_help_temp :=) \
    $(call Reset_,b) \
)

##
# GhlTextProcessListParams $1
# -----------------------------------------------------------------------------
# $1 - list environment parameters
# -----------------------------------------------------------------------------
# Process list environment parameters. Used only internally.
GhlTextProcessListParams = $(strip $(foreach \
    p,$1,$(call GhlTextProcessListParam,$p) \
))

##
# GhlTextProcessListParam $1
# -----------------------------------------------------------------------------
# $1 - list environment parameter
# -----------------------------------------------------------------------------
# Process one parameter of the list environment. Used only internally.
GhlTextProcessListParam = $(strip \
    $(if $(call Equal_,$(__mkutils_help_temp),-i), \
        $(eval __mkutils_help_l_i := $1) \
        $(eval __mkutils_help_temp :=) \
    ,$(if $(call Equal_,$(__mkutils_help_temp),-w), \
        $(eval __mkutils_help_l_w := $1) \
        $(eval __mkutils_help_temp :=) \
    ,$(if $(call Equal_,$(__mkutils_help_temp),-s), \
        $(eval __mkutils_help_l_s := $1) \
        $(eval __mkutils_help_temp :=) \
    ,$(if $(call Equal_,$(__mkutils_help_temp),-t), \
        $(eval __mkutils_help_l_t := $1) \
        $(eval __mkutils_help_temp :=) \
    ,$(if $(call Equal_,$1,-i), \
        $(eval __mkutils_help_temp := $1) \
    ,$(if $(call Equal_,$1,-w), \
        $(eval __mkutils_help_temp := $1) \
    ,$(if $(call Equal_,$1,-s), \
        $(eval __mkutils_help_temp := $1) \
    ,$(if $(call Equal_,$1,-l), \
        $(eval __mkutils_help_l_j := -) \
    ,$(if $(call Equal_,$1,-r), \
        $(eval __mkutils_help_l_j :=) \
    ,$(if $(call Equal_,$1,-t), \
        $(eval __mkutils_help_temp := $1) \
    ,$(if $(call Equal_,$1,-n), \
        $(eval __mkutils_help_l_n := None) \
    ))))))))))) \
)

##
# GhlTextSetListItemLabelRenderer
# -----------------------------------------------------------------------------
# Determine and set a macro that is used to render labels of ordered lists
# items. Used only internally.
GhlTextSetListItemLabelRenderer = $(strip \
    $(if $(findstring 1,$(__mkutils_help_l_s)), \
        $(eval __mkutils_help_l_g = $$(call GhlTextRenderOListItemLabel,1, \
            GhlTextOListItemLabelArabic \
        )) \
    ,$(if $(findstring a,$(__mkutils_help_l_s)), \
        $(eval __mkutils_help_l_g = $$(call GhlTextRenderOListItemLabel,a, \
            GhlTextOListItemLabelLcLetter \
        )) \
    ,$(if $(findstring A,$(__mkutils_help_l_s)), \
        $(eval __mkutils_help_l_g = $$(call GhlTextRenderOListItemLabel,A, \
            GhlTextOListItemLabelUcLetter \
        )) \
    , \
        $(eval __mkutils_help_l_g = $$(__mkutils_help_l_s)) \
    ))) \
)

##
# GhlTextRenderOListItemLabel $1 $2
# -----------------------------------------------------------------------------
# $1 - ordered list item numbering style selector
# $2 - ordered list item number value getter
# -----------------------------------------------------------------------------
# Render a label of ordered list item. Used only internally.
GhlTextRenderOListItemLabel = $(subst $1,$(call $2),$(__mkutils_help_l_s))

##
# GhlTextOListItemLabelArabic
# -----------------------------------------------------------------------------
# Return the order of ordered list item as arabic number. Used only internally.
GhlTextOListItemLabelArabic = $(call Value, b)

##
# GhlTextOListItemLabelLcLetter
# -----------------------------------------------------------------------------
# Return the order of ordered list item as lower-case letter. Used only
# internally.
GhlTextOListItemLabelLcLetter = $(call \
    IfEmpty,$(call Elem_,$([a-z]),$(call Value, b)),? \
)

##
# GhlTextOListItemLabelUcLetter
# -----------------------------------------------------------------------------
# Return the order of ordered list item as upper-case letter. Used only
# internally.
GhlTextOListItemLabelUcLetter = $(call \
    IfEmpty,$(call Elem_,$([A-Z]),$(call Value, b)),? \
)

##
# GhlTextNeedEmpty
# -----------------------------------------------------------------------------
# Return `Empty` if the emtpy line need to be inserted or `None` otherwise.
# Used only internally.
GhlTextNeedEmpty = $(call $(0)$(__mkutils_help_env))
GhlTextNeedEmptyD = Empty
GhlTextNeedEmptyL = $(__mkutils_help_l_n)

##
# GhlTextNone
# -----------------------------------------------------------------------------
# Generate no printing command. Used only internally.
GhlTextNone =

##
# GhlTextEmpty $1
# -----------------------------------------------------------------------------
# $1 - label
# -----------------------------------------------------------------------------
# Generate command that prints empty line. Used only internally.
GhlTextEmpty = $(eval $(call $(0)_,$1))
define GhlTextEmpty_ =
$1::
	@$$(ECHO) ""
endef

##
# GhlTextNonePlain $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - label
# $2 - variable holding indentation
# $3 - text
# -----------------------------------------------------------------------------
# Generate command that prints ordinary line of text. Used only internally.
GhlTextNonePlain = $(eval $(call $(0)_,$1,$2,$(strip $3)))
define GhlTextNonePlain_ =
$1::
	@$$(PRINTF) "  %-$$($2)s$(call GhlPunct,$3)\n" ""
endef

##
# GhlTextEmptyPlain $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - label
# $2 - variable holding indentation
# $3 - text
# -----------------------------------------------------------------------------
# Generate command that prints empty line and ordinary line of text. Used only
# internally.
GhlTextEmptyPlain = $(eval $(call $(0)_,$1,$2,$(strip $3)))
define GhlTextEmptyPlain_ =
$1::
	@$$(PRINTF) "\n  %-$$($2)s$(call GhlPunct,$3)\n" ""
endef

##
# GhlTextDItem $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - label
# $2 - variable holding indentation
# $3 - term to be described
# $4 - description
# -----------------------------------------------------------------------------
# Generate command that prints description environment item. Used only
# internally.
GhlTextDItem = $(eval $(call \
    $(0)_,$1,$2,HELP_$(__mkutils_help_descname)_FIRSTCOLWIDTH,$3,$4, \
))
define GhlTextDItem_ =
$1::
	@$$(PRINTF) "  %-$$($2)s  %-$$($3)s - $(call GhlPunct,$5)\n" "" "$4"
endef

##
# GhlTextIncDItemCounter
# -----------------------------------------------------------------------------
# Increase description environment item counter (no operation). Used only
# internally.
GhlTextIncDItemCounter =

##
# GhlTextLItem $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - label
# $2 - variable holding indentation
# $3 - text
# $4 - text
# -----------------------------------------------------------------------------
# Generate command that prints list environment item. Used only internally.
GhlTextLItem = $(eval $(call \
    $(0)_,$1,$2,$(strip \
        $(if $(call Gt_,0$(__mkutils_help_l_i),0),%-$(__mkutils_help_l_i)s) \
    ),$(__mkutils_help_l_j),$(__mkutils_help_l_w),$(strip \
        $(call __mkutils_help_l_g) \
    ),$(strip $3 $4), \
))
define GhlTextLItem_ =
$1::
	@$$(PRINTF) "  %-$$($2)s$(3)%$(4)$(5)s $(call GhlPunct,$7)\n" \
	            "" $(if $3,"") "$6"
endef

##
# GhlTextIncLItemCounter
# -----------------------------------------------------------------------------
# Increase list environment item counter (increase `b` counter). Used only
# internally.
GhlTextIncLItemCounter = $(call Inc_,b)

##
# GhlTextContDItem $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - label
# $2 - variable holding indentation
# $3 - text
# -----------------------------------------------------------------------------
# Generate command that prints next line of description environment item. Used
# only internally.
GhlTextContDItem = $(eval $(call \
    $(0)_,$1,$2,HELP_$(__mkutils_help_descname)_PADDING,$(strip $3), \
))
define GhlTextContDItem_ =
$1::
	@$$(PRINTF) "  %-$$($2)s  %-$$($3)s$(call GhlPunct,$4)\n" "" ""
endef

##
# GhlTextContLItem $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - label
# $2 - variable holding indentation
# $3 - text
# -----------------------------------------------------------------------------
# Generate command that prints next line of list environment item. Used only
# internally.
GhlTextContLItem = $(call \
    $(0)_,$1,$2,$(call Add, $(__mkutils_help_l_i), $(__mkutils_help_l_t)),$3, \
)
GhlTextContLItem_ = $(eval $(call \
    $(0)a,$1,$2,$(if $(call Gt_,$3,0),%-$(3)s),$(strip $4), \
))
define GhlTextContLItem_a =
$1::
	@$$(PRINTF) "  %-$$($2)s$(3)$(call GhlPunct,$4)\n" $(if $3,"") ""
endef

##
# GhlGenTargetHlp $1 $2
# -----------------------------------------------------------------------------
# $1 - target name
# $2 - list of macros that generate printing commands
# -----------------------------------------------------------------------------
# Drive a generating of commands that print help for $1. Used only internally.
GhlGenTargetHlp = $(call $(0)_,$(TargetNSQ).$1,$1,$2)
GhlGenTargetHlp_ = $(strip \
    $(if $(call HelpLines, $1), \
        $(eval __mkutils_help_targets += help-$2) \
        $(call UpdatePadding, $2) \
        $(foreach f,$3,$(call $f,$1,$2,help-$2,HELP_PADDING)) \
    ) \
)

##
# GhlGenDVarHlp $1 $2
# -----------------------------------------------------------------------------
# $1 - var=domain pair (e.g. PROG=PATH)
# $2 - list of macros that generate printing commands
# -----------------------------------------------------------------------------
# Drive a generating of commands that print help for $1. Used only internally.
GhlGenDVarHlp = $(call $(0)_,$1,$(call Head_,$(subst =, ,$1)),$2)
GhlGenDVarHlp_ = $(call $(0)a,$1,$(DVarNSQ).$2,$2,$3)
GhlGenDVarHlp_a = $(strip \
    $(if $(call HelpLines, $2), \
        $(eval __mkutils_help_dvars += help-dv-$3) \
        $(foreach f,$4,$(call $f,$2,$1,help-dv-$3,VARHELP_PADDING)) \
    ) \
)

##
# GhlGenUVarHlp $1 $2
# -----------------------------------------------------------------------------
# $1 - var=domain pair (e.g. PROG=PATH)
# $2 - list of macros that generate printing commands
# -----------------------------------------------------------------------------
# Drive a generating of commands that print help for $1. Used only internally.
GhlGenUVarHlp = $(call $(0)_,$1,$(call Head_,$(subst =, ,$1)),$2)
GhlGenUVarHlp_ = $(call $(0)a,$1,$(UVarNSQ).$2,$2,$3)
GhlGenUVarHlp_a = $(strip \
    $(if $(call HelpLines, $2), \
        $(eval __mkutils_help_uvars += help-uv-$3) \
        $(foreach f,$4,$(call $f,$2,$1,help-uv-$3,VARHELP_PADDING)) \
    ) \
)

##
# GenerateHelpLines $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - help generating driver name
# $2 - term (target name or variable with its domain) the help is associated
#      with
# $3 - list of macros that generate printing commands
# -----------------------------------------------------------------------------
# Generate commands that print help lines associated with $2. A name of driver
# that drives entire process is one of `Target`, `DVar`, or `UVar`. $3 should
# contain only GhlIntro, GhlVarIntro, and GhlText macros.
GenerateHelpLines = $(call GhlGen$(strip $1)Hlp,$(strip $2),$3)

##
# DefaultTarget $1
# -----------------------------------------------------------------------------
# $1 - target name
# -----------------------------------------------------------------------------
# Set the default target (goal).
DefaultTarget = $(eval .DEFAULT_GOAL := $(strip $1))

##
# DocTarget $1 $2
# -----------------------------------------------------------------------------
# $1 - target name
# $2 - help text
# -----------------------------------------------------------------------------
# Document a target $1.
DocTarget = $(strip \
    $(call FormatHelp, $(TargetNSQ).$(strip $1), $2) \
    $(call GenerateHelpLines, Target, $1, GhlIntro GhlText) \
)

##
# Target $1 $2
# -----------------------------------------------------------------------------
# $1 - target name
# $2 - help text
# -----------------------------------------------------------------------------
# Define $1 with help $2.
Target = $(eval $(call $(0)_,$(strip $1),$(strip $2)))$(strip $1):
define Target_ =
$(call DocTarget, $1, $2)
.PHONY: $1
endef

##
# TargetW $1 $2
# -----------------------------------------------------------------------------
# $1 - target name
# $2 - help text
# -----------------------------------------------------------------------------
# Define $1 with help $2 only if MS Windows environment was detected.
TargetW = $(call $(0)_$(MSWINDOWS),$1,$2)
TargetW_0 = $(eval $(call $(0)_,$(strip $1)))$(strip $1)::
define TargetW_0_ =
.PHONY: $1
$1::
	@$$(ECHO) "Option $1 is available only on MS Windows"
	@$$(FALSE)
endef
TargetW_1 = $(call Target,$1,$2)

##
# TargetX $1 $2
# -----------------------------------------------------------------------------
# $1 - target name
# $2 - help text
# -----------------------------------------------------------------------------
# Define $1 with help $2 only if other than MS Windows environment was
# detected.
TargetX = $(call $(0)_$(MSWINDOWS),$1,$2)
TargetX_0 = $(call Target,$1,$2)
TargetX_1 = $(eval $(call $(0)_,$(strip $1)))$(strip $1)::
define TargetX_1_ =
.PHONY: $1
$1::
	@$$(ECHO) "Option $1 is not supported on MS Windows"
	@$$(FALSE)
endef

##
# GenerateHelp
# -----------------------------------------------------------------------------
# Define `help` target that prints help for all targets defined by Target and
# all defined and documented variables.
GenerateHelp = $(eval $(call $(0)_))
define GenerateHelp_ =

$(call DocTarget, help, print this help)

__mkutils_help_targets := $$(sort $$(__mkutils_help_targets))
__mkutils_help_dvars := $$(sort $$(__mkutils_help_dvars))
__mkutils_help_uvars := $$(sort $$(__mkutils_help_uvars))
__mkutils_help_deps :=

.PHONY: help_prologue help_epilogue
__mkutils_help_deps += help_prologue
help_prologue:
	@$$(ECHO) "Usage: $$(MAKE) <target> [settings]"
	@$$(ECHO) "where <target> is one of"
	@$$(ECHO) ""
__mkutils_help_deps += $$(__mkutils_help_targets)
help_epilogue:
	@$$(ECHO) ""
	@$$(ECHO) "and settings are of the form NAME1=VALUE1 NAME2=VALUE2 etc."
__mkutils_help_deps += help_epilogue

ifneq ($$(__mkutils_help_uvars),)
.PHONY: help_uvars_prologue help_uvars_epilogue
__mkutils_help_deps += help_uvars_prologue
help_uvars_prologue:
	@$$(ECHO) "Available settings are:"
	@$$(ECHO) ""
__mkutils_help_deps += $$(__mkutils_help_uvars)
help_uvars_epilogue:
	@$$(ECHO) ""
__mkutils_help_deps += help_uvars_epilogue
endif

.PHONY: help_dvars_prologue help_dvars_epilogue
__mkutils_help_deps += help_dvars_prologue
ifneq ($$V,)
help_dvars_prologue:
	@$$(ECHO) "By default, $$(__mkutils_name__) supports these settings:"
	@$$(ECHO) ""
__mkutils_help_deps += $$(__mkutils_help_dvars)
else
help_dvars_prologue:
	@$$(ECHO) "For more help, set V to an arbitrary value."
endif
help_dvars_epilogue:
	@$$(ECHO) ""
__mkutils_help_deps += help_dvars_epilogue

.PHONY: help
help: $$(__mkutils_help_deps)

endef

## ============================================================================
## == 13) Testing                                                            ==
## ============================================================================

__mkutils_test_temp :=
__mkutils_passed :=
__mkutils_failed :=

##
# TestsBegin
# -----------------------------------------------------------------------------
# Prepare for running the tests.
TestsBegin = $(strip \
    $(eval __mkutils_test_temp :=) \
    $(eval __mkutils_passed :=) \
    $(eval __mkutils_failed :=) \
)

##
# TestsEnd
# -----------------------------------------------------------------------------
# Close the test phase, print overall statistics.
TestsEnd = $(eval $(call $(0)_))
define TestsEnd_ =
all:
	@$$(ECHO) ""
	@$$(ECHO) $(__mkutils_echo_e) \
	"$(call Colorize,LIGHT_CYAN,Test Results)"
	@$$(ECHO) $(__mkutils_echo_e) "$(call Colorize,LIGHT_CYAN,$(DLINE))"
	@$$(ECHO) $(__mkutils_echo_e) \
        "$(call Colorize,LIGHT_GREEN,Passed: $(words $(__mkutils_passed)))"
	@$$(ECHO) $(__mkutils_echo_e) \
        "$(call Colorize,LIGHT_RED,Failed: $(words $(__mkutils_failed)))"
	@$$(ECHO) $(__mkutils_echo_e) "$(call Colorize,LIGHT_CYAN,$(LINE))"
	@$$(ECHO) $(__mkutils_echo_e) \
        "$(call Colorize,YELLOW,Total: $(words \
            $(__mkutils_passed) $(__mkutils_failed) \
        ))"
endef

##
# TestInfo $1
# -----------------------------------------------------------------------------
# $1 - test name
# -----------------------------------------------------------------------------
# Print info that $1 tests are now running.
TestInfo = $(strip \
    $(call Print) \
    $(call LightColorPrint,BLUE,Running $1 tests) \
    $(call LightColorPrint,BLUE,$(LINE)) \
)

##
# TestFunc1 $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - function name
# $2 - 1st argument
# $3 - expected result
# -----------------------------------------------------------------------------
# Test whether $1($2) == $3.
TestFunc1 = $(strip \
    $(call Print,Checking if $1('$2') == '$3': ,-n) \
    $(eval __mkutils_test_temp := '$(call $1,$2)') \
    $(call __mkutils_eval_test_result,Equal_,'$3') \
)

##
# TestFunc2 $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - function name
# $2 - 1st argument
# $3 - 2nd argument
# $4 - expected result
# -----------------------------------------------------------------------------
# Test whether $1($2, $3) == $4.
TestFunc2 = $(strip \
    $(call Print,Checking if $1('$2', '$3') == '$4': ,-n) \
    $(eval __mkutils_test_temp := '$(call $1,$2,$3)') \
    $(call __mkutils_eval_test_result,Equal_,'$4') \
)

##
# TestFunc3 $1 $2 $3 $4 $5
# -----------------------------------------------------------------------------
# $1 - function name
# $2 - 1st argument
# $3 - 2nd argument
# $4 - 3rd argument
# $5 - expected result
# -----------------------------------------------------------------------------
# Test whether $1($2, $3, $4) == $5.
TestFunc3 = $(strip \
    $(call Print,Checking if $1('$2', '$3', '$4') == '$5': ,-n) \
    $(eval __mkutils_test_temp := '$(call $1,$2,$3,$4)') \
    $(call __mkutils_eval_test_result,Equal_,'$5') \
)

##
# __mkutils_eval_test_result $1 $2
# -----------------------------------------------------------------------------
# $1 - comparison function
# $2 - expected result
# -----------------------------------------------------------------------------
# Evaluate test as successful if $1($(__mkutils_test_temp), $2) is true.
# Otherwise, test is evaluated as failed. For internal use only.
__mkutils_eval_test_result = $(strip \
    $(if $(call $1,$(__mkutils_test_temp),$2), \
        $(eval __mkutils_passed += x) \
        $(call LightColorPrint,GREEN,OK), \
        $(eval __mkutils_failed += x) \
        $(call LightColorPrint,RED,ERROR: $(__mkutils_test_temp) != $2) \
    ) \
)

## ============================================================================
## == 14) Managing variables                                                 ==
## ============================================================================

##
# AssociateVarWithTargets $1 $2
# -----------------------------------------------------------------------------
# $1 - user defined variable
# $2 - list of targets affected by $1
# -----------------------------------------------------------------------------
# Associate $1 with $2.
AssociateVarWithTargets = $(call KVSet, var2targets, $1, $2)

##
# GetTargetsAssociatedWithVar $1
# -----------------------------------------------------------------------------
# $1 - variable name
# -----------------------------------------------------------------------------
# Get a list of targets associated with $1.
GetTargetsAssociatedWithVar = $(call KVGet, var2targets, $1)

##
# DocVar $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - variable kind (`DVar` for default variable, `UVar` for users' variable)
# $2 - var=domain pair (`=domain` is optional)
# $3 - help text
# $4 - list of associated targets (optional)
# -----------------------------------------------------------------------------
# Generate commands that print help lines associated with $2.
DocVar = $(call $(0)_,$1,$(call Head_,$(subst =, ,$2)),$2,$3,$4)
DocVar_ = $(strip \
    $(call AssociateVarWithTargets, $2, $5) \
    $(call FormatHelp, $($(strip $1)NSQ).$2, $4) \
    $(call GenerateHelpLines, $1, $3, GhlVarIntro GhlText) \
)

##
# DocDefaultVar $1 $2
# -----------------------------------------------------------------------------
# $1 - var=domain pair (`=domain` is optional)
# $2 - help text
# -----------------------------------------------------------------------------
# Generate commands that print help lines associated with $2. This macro is
# intended for documenting mkutils predefined variables.
DocDefaultVar = $(call DocVar, DVar, $1, $2)

##
# DocUserVar $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - var=domain pair (`=domain` is optional)
# $2 - help text
# $3 - list of associated targets (optional)
# -----------------------------------------------------------------------------
# Generate commands that print help lines associated with $2. This macro is
# intended for documenting variables defined by user.
DocUserVar = $(call DocVar, UVar, $1, $2, $3)

##
# ShowVar $1
# -----------------------------------------------------------------------------
# $1 - variable name
# -----------------------------------------------------------------------------
# Show $1's value.
ShowVar = $(call $(0)_,$(strip $1))
ShowVar_ = $(if $(call Equal_,$(origin $1),undefined),undefined,'$($1)')

##
# AddTool $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - tool name (should be name of the binary without suffix)
# $2 - variable name (optional)
# $3 - help text (optional)
# -----------------------------------------------------------------------------
# Add tool $1 to Makefile. The added tool is accessible through $2. If $2 is
# not given, uppercased $1 is used. If $3 is missing and $2 contains more than
# 1 word, $3 is considered to be $2 and instead of $2 uppercased $1 is used.
AddTool = $(call $(0)_,$(strip $1),$(strip $2),$(strip $3))
AddTool_ = $(strip \
    $(if $3, \
        $(call $(0)a,$1,$(if $2,$2,$(call ToUpper,$1)),$3) \
    ,$(if $(call Ge_,$(words $2),2), \
        $(call $(0)a,$1,$(call ToUpper,$1),$2) \
    , \
        $(call $(0)a,$1,$(if $2,$2,$(call ToUpper,$1))) \
    )) \
)
AddTool_a = $(strip \
    $(if $3,$(call DocUserVar, $2=PATH, $3)) \
    $(eval $2 ?= $$(TOOLS_PREFIX)$(1)$$(TOOLS_EXESUFF)) \
)

##
# AddToolW $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - tool name (should be name of the binary without suffix)
# $2 - variable name (optional)
# $3 - help text (optional)
# -----------------------------------------------------------------------------
# Invoke AddTool only if MS Windows environment was detected.
AddToolW = $(call $(0)_$(MSWINDOWS),$1,$2,$3)
AddToolW_0 =
AddToolW_1 = $(call AddTool,$1,$2,$3)

##
# AddToolX $1 $2 $3
# -----------------------------------------------------------------------------
# $1 - tool name (should be name of the binary without suffix)
# $2 - variable name (optional)
# $3 - help text (optional)
# -----------------------------------------------------------------------------
# Invoke AddTool only if other than MS Windows environment was detected.
AddToolX = $(call $(0)_$(MSWINDOWS),$1,$2,$3)
AddToolX_0 = $(call AddTool,$1,$2,$3)
AddToolX_1 =

##
# AddVar $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - variable name (possibly with specified domain)
# $2 - value
# $3 - help text (optional)
# $4 - list of associated targets (optional)
# -----------------------------------------------------------------------------
# Define $1 with $2 as its value if $1 was not previously defined.
AddVar = $(call $(0)_,$(call Head_,$(subst =, ,$1)),$1,$2,$(strip $3),$4)
AddVar_ = $(if $4,$(call DocUserVar, $2, $4, $5))$(eval $1 ?= $3)

##
# AddVarW $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - variable name (possibly with specified domain)
# $2 - value
# $3 - help text (optional)
# $4 - list of associated targets (optional)
# -----------------------------------------------------------------------------
# Invoke AddVar only if MS Windows environment was detected.
AddVarW = $(call $(0)_$(MSWINDOWS),$1,$2,$3,$4)
AddVarW_0 =
AddVarW_1 = $(call AddVar,$1,$2,$3,$4)

##
# AddVarX $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - variable name (possibly with specified domain)
# $2 - value
# $3 - help text (optional)
# $4 - list of associated targets (optional)
# -----------------------------------------------------------------------------
# Invoke AddVar only if other than MS Windows environment was detected.
AddVarX = $(call $(0)_$(MSWINDOWS),$1,$2,$3,$4)
AddVarX_0 = $(call AddVar,$1,$2,$3,$4)
AddVarX_1 =

##
# DefVar $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - variable name (possibly with specified domain)
# $2 - value
# $3 - help text (optional)
# $4 - list of associated targets (optional)
# -----------------------------------------------------------------------------
# Define $1 with $2 as its value.
DefVar = $(call $(0)_,$(call Head_,$(subst =, ,$1)),$1,$2,$(strip $3),$4)
DefVar_ = $(if $4,$(call DocUserVar, $2, $4, $5))$(eval $1 = $3)

##
# DefVarW $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - variable name (possibly with specified domain)
# $2 - value
# $3 - help text (optional)
# $4 - list of associated targets (optional)
# -----------------------------------------------------------------------------
# Invoke DefVar only if MS Windows environment was detected.
DefVarW = $(call $(0)_$(MSWINDOWS),$1,$2,$3,$4)
DefVarW_0 =
DefVarW_1 = $(call DefVar,$1,$2,$3,$4)

##
# DefVarX $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - variable name (possibly with specified domain)
# $2 - value
# $3 - help text (optional)
# $4 - list of associated targets (optional)
# -----------------------------------------------------------------------------
# Invoke DefVar only if other than MS Windows environment was detected.
DefVarX = $(call $(0)_$(MSWINDOWS),$1,$2,$3,$4)
DefVarX_0 = $(call DefVar,$1,$2,$3,$4)
DefVarX_1 =

##
# SetVar $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - variable name (possibly with specified domain)
# $2 - value
# $3 - help text (optional)
# $4 - list of associated targets (optional)
# -----------------------------------------------------------------------------
# Evaluate $2 and assing the result to $1.
SetVar = $(call $(0)_,$(call Head_,$(subst =, ,$1)),$1,$2,$(strip $3),$4)
SetVar_ = $(if $4,$(call DocUserVar, $2, $4, $5))$(eval $1 := $3)

##
# SetVarW $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - variable name (possibly with specified domain)
# $2 - value
# $3 - help text (optional)
# $4 - list of associated targets (optional)
# -----------------------------------------------------------------------------
# Invoke SetVar only if MS Windows environment was detected.
SetVarW = $(call $(0)_$(MSWINDOWS),$1,$2,$3,$4)
SetVarW_0 =
SetVarW_1 = $(call SetVar,$1,$2,$3,$4)

##
# SetVarX $1 $2 $3 $4
# -----------------------------------------------------------------------------
# $1 - variable name (possibly with specified domain)
# $2 - value
# $3 - help text (optional)
# $4 - list of associated targets (optional)
# -----------------------------------------------------------------------------
# Invoke SetVar only if other than MS Windows environment was detected.
SetVarX = $(call $(0)_$(MSWINDOWS),$1,$2,$3,$4)
SetVarX_0 = $(call SetVar,$1,$2,$3,$4)
SetVarX_1 =

# Document variables defined by mkutils:
$(call DocDefaultVar, TOOLS_PREFIX=PATH, \
    specify the path to the directory with tools used by /n \
    $(__mkutils_name__); the default value of PATH is read from PREFIX /n \
    variable \
)
$(call DocDefaultVar, PREFIX=PATH, \
    specify the path to the directory with executables /n \
    used by $(__mkutils_name__); without PREFIX$(,) executables are /n \
    searched in system default locations \
)
$(call DocDefaultVar, TOOLS_EXESUFF=SUFFIX, \
    specify the suffix of tools used by $(__mkutils_name__); the /n \
    default value of SUFFIX is read from EXESUFF variable \
)
$(call DocDefaultVar, EXESUFF=SUFFIX, \
    specify the suffix of executables used by $(__mkutils_name__) /n \
    $([)e.g. '.py'$(]) \
)
$(call DocDefaultVar, TRUE=PATH, \
    override the path to 'true'; the new 'true' should be /n \
    compatible with POSIX 'true' \
)
$(call DocDefaultVar, FALSE=PATH, \
    override the path to 'false'; the new 'false' should /n \
    be compatible with POSIX 'false' \
)
$(call DocDefaultVar, ECHO=PATH, \
    override the path to 'echo'; the new 'echo' should /n \
    at least support -n and -e options \
)
$(call DocDefaultVar, TEST=PATH, \
    override the path to 'test'; the new 'test' should /n \
    be compatible with POSIX 'test'; at least$(,) 'test' /n \
    should support -t$(,) -eq$(,) -ne$(,) -lt$(,) -gt$(,) -le$(,) -ge /n \
    options \
)
$(call DocDefaultVar, WHICH=PATH, \
    override the path to 'which'; 'which foo' should print /n \
    the path to 'foo' to stdout if 'foo' exists in standard /n \
    system location for executables and return 0 or return 1 /n \
    if 'foo' cannot be found \
)
$(call DocDefaultVar, PRINTF=PATH, \
    override the path to 'printf'; the new 'printf' /n \
    should be compatible with POSIX 'printf'; at least$(,) /n \
    the format string should support left-justify flag /n \
    $([)-$(])$(,) field width$(,) 's' $([)string$(]) conversion specifier /n \
    and new-line escape sequence $([)\\\\n$(]) \
)
$(call DocDefaultVar, EXPR=PATH, \
    override the path to 'expr'; the new 'expr' should /n \
    be compatible with POSIX 'expr' plus should support /n \
    'length' operator; at least$(,) these operators should /n \
    be implemented: /n \
    +$(,) -$(,) *$(,) /$(,) %%$(,) length \
)
$(call DocDefaultVar, MSWINDOWS=[0|1], \
    set to 1 if the environment is MS Windows specific \
)
$(call DocDefaultVar, ISATTY=[0|1], \
    set to 1 if $(MAKE) is run from terminal \
)
$(call DocDefaultVar, NOCOLORS=VALUE, \
    define NOCOLORS to be an arbitrary value if colors /n \
    should be disabled while displaying the messages \
)
$(call DocDefaultVar, V=VALUE, \
    define V to be an arbitrary value if more help should /n \
    be displayed \
)

endif
