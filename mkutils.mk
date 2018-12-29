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
, := ,
define nl =

endef

##
# Help to specify the location of tools used by mkutils. TOOLS_PREFIX should
# be an absolute path to the tools directory (must ends with `/`),
# TOOLS_EXESUFF specifies the tool's extension (i.e. `.exe`). If TOOLS_PREFIX
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

# Auxiliary internal variables
__mkutils_temp :=

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
## == 4) Evaluating expressions                                              ==
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

##
# Strlen $1
# -----------------------------------------------------------------------------
# $1 - string
# -----------------------------------------------------------------------------
# Return the length of $1 or report an error.
Strlen = $(call EvalExpr,length "$(strip $1)")

## ============================================================================
## == 5) Comparations                                                        ==
## ============================================================================

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
## == 6) Assertions                                                          ==
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
## == 7) Printing                                                            ==
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
## == 8) Running programs                                                    ==
## ============================================================================

__mkutils_Run_output :=
__mkutils_Run_exitcode := 0

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
# Run $1 quietly. Destroys __mkutils_temp's content.
SoftRun = $(eval __mkutils_temp := $(shell $1 >/dev/null 2>&1))

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
## == 9) Probing Python interpreter                                          ==
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
## == 10) Targets                                                            ==
## ============================================================================

__mkutils_help_targets :=
__mkutils_help_env :=
__mkutils_help_descname :=
__mkutils_help_l_i := 2
__mkutils_help_l_w := 1
__mkutils_help_l_s := *
__mkutils_help_l_j :=
__mkutils_help_l_t := 4
__mkutils_help_l_n :=
__mkutils_help_l_g = $(__mkutils_help_l_s)

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
        $(eval export HELP$(2)FIRSTCOLWIDTH) \
        $(eval HELP$(2)PADDING := 0) \
        $(eval export HELP$(2)PADDING) \
    ) \
    $(if $(call Gt_,$1,$(HELP$(2)FIRSTCOLWIDTH)), \
        $(eval HELP$(2)FIRSTCOLWIDTH := $1) \
        $(eval HELP$(2)PADDING := $(call Add, $1, 3)) \
    ) \
)

##
# AddToHelpLine $1 $2
# -----------------------------------------------------------------------------
# $1 - target name
# $2 - words
# -----------------------------------------------------------------------------
# Add $2 to __mkutils_help_$1_line_<N>, where <N> is the current value of
# __mkutils_counter_a counter. If __mkutils_help_$1_line_<N> was not previously
# defined, define it and add it to __mkutils_help_$1_lines list. Also define
# __mkutils_help_$1_lines if it was not defined previously. This macro works
# as a helper for FormatHelp.
AddToHelpLine = $(strip \
    $(if $(__mkutils_help_$(strip $1)_lines),, \
        $(call Reset_,a,1) \
        $(eval __mkutils_help_$(strip $1)_lines :=) \
    ) \
    $(if $(__mkutils_help_$(strip $1)_line_$(call Value, a)),, \
        $(eval __mkutils_help_$(strip $1)_line_$(call Value, a) :=) \
        $(eval __mkutils_help_$(strip $1)_lines += \
            __mkutils_help_$(strip $1)_line_$(call Value, a) \
        ) \
    ) \
    $(eval __mkutils_help_$(strip $1)_line_$(call Value, a) += $2) \
)

##
# FormatHelp $1 $2
# -----------------------------------------------------------------------------
# $1 - target name
# $2 - help text
# -----------------------------------------------------------------------------
# Split $2 to lines. If $2 is non-empty, introduce a list of lines,
# __mkutils_help_$1_lines, that contains variables of the form
# __mkutils_help_$1_line_<N>, where <N> stands for positive integer. Each
# variable, __mkutils_help_$1_line_<N>, that is newly introduced represents
# a one line of a help text. A help text is a list of words and commands.
# Commands supported so far are
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
# behaviour. If $2 is empty, no new variables are introduced. As a side effect,
# this macro erase the content of __mkutils_temp and resets __mkutils_counter_a
# to 0.
FormatHelp = $(strip \
    $(eval __mkutils_temp :=) \
    $(eval __mkutils_help_env :=) \
    $(eval __mkutils_help_descname :=) \
    $(foreach w,$2,$(call $(0)_a,$1,$w)) \
    $(if $(__mkutils_temp), \
        $(call AddToHelpLine, $1, $(__mkutils_temp)) \
        $(eval __mkutils_temp :=) \
    ) \
    $(eval __mkutils_help_env :=) \
    $(eval __mkutils_help_descname :=) \
    $(call Reset_,a) \
)
# Note on formatting: read ",$(if ..." as "else if ..." and standalone "," as
# "else".
FormatHelp_a = $(strip \
    $(if $(call Equal_,$(__mkutils_temp),/p), \
        $(call AddToHelpLine, $1, $2) \
        $(eval __mkutils_temp :=) \
    ,$(if $(call Equal_,$(__mkutils_temp),/d), \
        $(call Inc_,a) \
        $(call AddToHelpLine, $1, /d $2) \
        $(eval __mkutils_help_env := /d) \
        $(eval __mkutils_help_descname := $2) \
        $(eval __mkutils_temp :=) \
    ,$(if $(call Equal_,$(__mkutils_temp),/i), \
        $(call Inc_,a) \
        $(call UpdatePadding, $2, $(__mkutils_help_descname)) \
        $(call AddToHelpLine, $1, /i $2) \
        $(eval __mkutils_temp :=) \
    ,$(if $(call Equal_,$2,/p), \
        $(eval __mkutils_temp := $2) \
    ,$(if $(call Equal_,$2,/n), \
        $(call Inc_,a) \
    ,$(if $(call Equal_,$2,//), \
        $(call Inc_,a) \
        $(call AddToHelpLine, $1, $2) \
    ,$(if $(call Equal_,$2,/l), \
        $(call Inc_,a) \
        $(call AddToHelpLine, $1, $2) \
        $(eval __mkutils_help_env := $2) \
    ,$(if $(call Equal_,$2,/d), \
        $(eval __mkutils_temp := $2) \
    ,$(if $(call Equal_,$2,/i), \
        $(if $(call Equal_,$(__mkutils_help_env),/d), \
            $(eval __mkutils_temp := $2) \
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
# GenerateHelpLines $1
# -----------------------------------------------------------------------------
# $1 - target name
# -----------------------------------------------------------------------------
# From __mkutils_help_$1_lines, generate help-$1-1, help-$1-2, ..., help-$1-N
# targets that print 1st, 2nd, ..., Nth line from __mkutils_help_$1_lines,
# respectively. Additionally, generate help-$1 that print all lines from
# __mkutils_help_$1_lines. May modify __mkutils_temp and __mkutils_counter_b.
GenerateHelpLines = $(call $(0)_,$(strip $1))
GenerateHelpLines_ = $(call GenerateHelpLines_a,$1,$(__mkutils_help_$1_lines))
GenerateHelpLines_a = $(if $2,$(call GenerateHelpLines_b,$1,$2))
GenerateHelpLines_b = $(call GenerateHelpLines_c,$1,$(foreach w,$2, \
    help-$1-$(subst __mkutils_help_$1_line_,,$w) \
))
GenerateHelpLines_c = $(strip \
    $(eval __mkutils_help_targets += help-$1) \
    $(call UpdatePadding, $1) \
    $(call GenerateHelpLines_d,$1,$(call Head_,$2),$2) \
    $(foreach w,$(call Tail_,$2),$(call GenerateHelpLines_e,$1,$w)) \
)
GenerateHelpLines_d = $(eval $(call $(0)_,$1,$2,$3,HELP_FIRSTCOLWIDTH,$(strip \
    $(__mkutils_help_$1_line_1) \
)))
define GenerateHelpLines_d_ =
.PHONY: help-$1
help-$1: $3
.PHONY: $3
$2:
	@$(PRINTF) "  %-$$($4)s - $(subst . ,.  ,$5)\n" "$1"
endef
GenerateHelpLines_e = $(call GenerateHelpLines_f,$1,$(subst help-$1-,,$2),$2)
GenerateHelpLines_f = $(call GenerateHelpLines_g,$3,$(strip \
    $(__mkutils_help_$1_line_$2) \
))
GenerateHelpLines_g = $(call GenerateHelpLines_h,$1,$2,$(call Head_,$2))
GenerateHelpLines_h = $(strip \
    $(if $(call Equal_,$3,//), \
        $(call GenerateHelpLines_i,$1,$(call Tail_,$2)) \
    ,$(if $(call Equal_,$3,/l), \
        $(eval __mkutils_help_env := $3) \
        $(call GenerateHelpLines_j_1) \
        $(foreach x,$(call Tail_,$2),$(call GenerateHelpLines_j_2,$x)) \
        $(eval __mkutils_temp :=) \
        $(call GenerateHelpLines_j_3) \
        $(call GenerateHelpLines_j_4,$1,$(__mkutils_help_l_n)) \
    ,$(if $(call Equal_,$3,/d), \
        $(eval __mkutils_help_env := $3) \
        $(eval __mkutils_help_descname := $(call Elem_,$2,2)) \
        $(call GenerateHelpLines_k,$1) \
    ,$(if $(call Equal_,$3,/i), \
        $(if $(call Equal_,$(__mkutils_help_env),/d), \
            $(call GenerateHelpLines_l_1,$1, \
                $(call Elem_,$2,2),$(call Slice_,$2,3) \
            ) \
        , \
            $(call Inc_,b) \
            $(call GenerateHelpLines_l_2,$1,$(call Tail_,$2)) \
        ) \
    ,$(if $(call Equal_,$3,/|), \
        $(call GenerateHelpLines_m,$1,$(call Tail_,$2)) \
    ,$(if $(call Equal_,$3,/e), \
        $(call GenerateHelpLines_n,$1,$(call Tail_,$2)) \
        $(call GenerateHelpLines_j_1) \
        $(eval __mkutils_help_env :=) \
        $(eval __mkutils_help_descname :=) \
    , \
        $(call GenerateHelpLines_o,$1,$2) \
    )))))) \
)
GenerateHelpLines_i = $(eval $(call $(0)_$(if $2,1,2),$1,$2))
define GenerateHelpLines_i_1 =
$1:
	@$(PRINTF) "\n  %-$$(HELP_PADDING)s$(subst . ,.  ,$2)\n" ""
endef
define GenerateHelpLines_i_2 =
$1:
	@$(ECHO) ""
endef
GenerateHelpLines_j_1 = $(strip \
    $(eval __mkutils_help_l_i := 2) \
    $(eval __mkutils_help_l_w := 1) \
    $(eval __mkutils_help_l_s := *) \
    $(eval __mkutils_help_l_j :=) \
    $(eval __mkutils_help_l_t := 4) \
    $(eval __mkutils_help_l_n :=) \
    $(eval __mkutils_help_l_g = $$(__mkutils_help_l_s)) \
    $(eval __mkutils_temp :=) \
    $(call Reset_,b) \
)
GenerateHelpLines_j_2 = $(strip \
    $(if $(call Equal_,$(__mkutils_temp),-i), \
        $(eval __mkutils_help_l_i := $1) \
        $(eval __mkutils_temp :=) \
    ,$(if $(call Equal_,$(__mkutils_temp),-w), \
        $(eval __mkutils_help_l_w := $1) \
        $(eval __mkutils_temp :=) \
    ,$(if $(call Equal_,$(__mkutils_temp),-s), \
        $(eval __mkutils_help_l_s := $1) \
        $(eval __mkutils_temp :=) \
    ,$(if $(call Equal_,$(__mkutils_temp),-t), \
        $(eval __mkutils_help_l_t := $1) \
        $(eval __mkutils_temp :=) \
    ,$(if $(call Equal_,$1,-i), \
        $(eval __mkutils_temp := $1) \
    ,$(if $(call Equal_,$1,-w), \
        $(eval __mkutils_temp := $1) \
    ,$(if $(call Equal_,$1,-s), \
        $(eval __mkutils_temp := $1) \
    ,$(if $(call Equal_,$1,-l), \
        $(eval __mkutils_help_l_j := -) \
    ,$(if $(call Equal_,$1,-r), \
        $(eval __mkutils_help_l_j :=) \
    ,$(if $(call Equal_,$1,-t), \
        $(eval __mkutils_temp := $1) \
    ,$(if $(call Equal_,$1,-n), \
        $(eval __mkutils_help_l_n := n) \
    ))))))))))) \
)
GenerateHelpLines_j_3 = $(strip \
    $(if $(findstring 1,$(__mkutils_help_l_s)), \
        $(eval __mkutils_help_l_g = $$(call GenerateHelpLines_j_5,1, \
            GenerateHelpLines_j_6 \
        )) \
    ,$(if $(findstring a,$(__mkutils_help_l_s)), \
        $(eval __mkutils_help_l_g = $$(call GenerateHelpLines_j_5,a, \
            GenerateHelpLines_j_7 \
        )) \
    ,$(if $(findstring A,$(__mkutils_help_l_s)), \
        $(eval __mkutils_help_l_g = $$(call GenerateHelpLines_j_5,A, \
            GenerateHelpLines_j_8 \
        )) \
    , \
        $(eval __mkutils_help_l_g = $$(__mkutils_help_l_s)) \
    ))) \
)
GenerateHelpLines_j_4 = $(eval $(call $(0)_$2,$1))
define GenerateHelpLines_j_4_ =
$1:
	@$(ECHO) ""
endef
define GenerateHelpLines_j_4_n =
$1:
	@$(TRUE) ""
endef
GenerateHelpLines_j_5 = $(subst $1,$(call $(strip $2)),$(__mkutils_help_l_s))
GenerateHelpLines_j_6 = $(call Value, b)
GenerateHelpLines_j_7 = $(word $(call Value, b), \
    a b c d e f g h i j k l m n o p q r s t u v w x y z \
)
GenerateHelpLines_j_8 = $(word $(call Value, b), \
    A B C D E F G H I J K L M N O P Q R S T U V W X Y Z \
)
GenerateHelpLines_k = $(eval $(call $(0)_,$1))
define GenerateHelpLines_k_ =
$1:
	@$(ECHO) ""
endef
GenerateHelpLines_l_1 = $(eval $(call $(0)_,$1,$2,$3,HELP_PADDING,$(strip \
    HELP_$(__mkutils_help_descname)_FIRSTCOLWIDTH \
)))
define GenerateHelpLines_l_1_ =
$1:
	@$(PRINTF) "  %-$$($4)s  %-$$($5)s - $(subst . ,.  ,$(strip $3))\n" \
	           "" "$(strip $2)"
endef
GenerateHelpLines_l_2 = $(eval $(call $(0)_,$1,$2,HELP_PADDING,$(call \
    GenerateHelpLines_l_3),$(__mkutils_help_l_j),$(__mkutils_help_l_w),$(call \
    __mkutils_help_l_g), \
))
define GenerateHelpLines_l_2_ =
$1:
	@$(PRINTF) "  %-$$($3)s$(4)%$(5)$(6)s $(subst . ,.  ,$2)\n" \
	           "" $(if $4,"") "$7"
endef
GenerateHelpLines_l_3 = $(strip \
    $(if $(call Gt_,0$(__mkutils_help_l_i),0),%-$(__mkutils_help_l_i)s) \
)
GenerateHelpLines_m = $(strip \
    $(if $(call Equal_,$(__mkutils_help_env),/d), \
        $(call GenerateHelpLines_m_1,$1,$2,HELP_PADDING,$(strip \
            HELP_$(__mkutils_help_descname)_PADDING \
        )) \
    , \
        $(call GenerateHelpLines_m_2,$1,$2,HELP_PADDING,$(strip \
            $(call Add, $(__mkutils_help_l_i), $(__mkutils_help_l_t)) \
        )) \
    ) \
)
GenerateHelpLines_m_1 = $(eval $(call $(0)_,$1,$2,$3,$4))
define GenerateHelpLines_m_1_ =
$1:
	@$(PRINTF) "  %-$$($3)s  %-$$($4)s$(subst . ,.  ,$2)\n" "" ""
endef
GenerateHelpLines_m_2 = $(call \
    GenerateHelpLines_m_$(if $(call Gt_,$4,0),4,3),$1,$2,$3,$4, \
)
GenerateHelpLines_m_3 = $(eval $(call $(0)_,$1,$2,$3))
define GenerateHelpLines_m_3_ =
$1:
	@$(PRINTF) "  %-$$($3)s$(subst . ,.  ,$2)\n" ""
endef
GenerateHelpLines_m_4 = $(eval $(call $(0)_,$1,$2,$3,$4))
define GenerateHelpLines_m_4_ =
$1:
	@$(PRINTF) "  %-$$($3)s%-$(4)s$(subst . ,.  ,$2)\n" "" ""
endef
GenerateHelpLines_n = $(call $(0)_1_$(call $(0)_2)$(if $2,y,n),$1,$2)
GenerateHelpLines_n_1_nn = $(eval $(call $(0)_,$1,$2))
define GenerateHelpLines_n_1_nn_ =
$1:
	@$(TRUE)
endef
GenerateHelpLines_n_1_yn = $(eval $(call $(0)_,$1,$2))
define GenerateHelpLines_n_1_yn_ =
$1:
	@$(ECHO) ""
endef
GenerateHelpLines_n_1_ny = $(eval $(call $(0)_,$1,$2))
define GenerateHelpLines_n_1_ny_ =
$1:
	@$(PRINTF) "  %-$$(HELP_PADDING)s$(subst . ,.  ,$2)\n" ""
endef
GenerateHelpLines_n_1_yy = $(eval $(call $(0)_,$1,$2))
define GenerateHelpLines_n_1_yy_ =
$1:
	@$(PRINTF) "\n  %-$$(HELP_PADDING)s$(subst . ,.  ,$2)\n" ""
endef
GenerateHelpLines_n_2 = $(strip \
    $(if $(call Equal_,$(__mkutils_help_env),/d), \
        y,$(if $(__mkutils_help_l_n),n,y) \
    ) \
)
GenerateHelpLines_o = $(eval $(call $(0)_,$1,$2,HELP_PADDING))
define GenerateHelpLines_o_ =
$1:
	@$(PRINTF) "  %-$$($3)s$(subst . ,.  ,$2)\n" ""
endef

##
# DefaultTarget $1
# -----------------------------------------------------------------------------
# $1 - target name
# -----------------------------------------------------------------------------
# Set the default target (goal).
DefaultTarget = $(eval .DEFAULT_GOAL := $(strip $1))

##
# Target $1 $2
# -----------------------------------------------------------------------------
# $1 - target name
# $2 - help text
# -----------------------------------------------------------------------------
# Define $1 with help $2.
Target = $(eval $(call $(0)_,$(strip $1),$(strip $2)))$(strip $1):
define Target_ =
$(call FormatHelp, $1, $2)
$(call GenerateHelpLines, $1)
.PHONY: $1
endef

##
# GenerateHelp
# -----------------------------------------------------------------------------
# Define `help` target that prints help for all targets defined by Target.
GenerateHelp = $(eval $(call $(0)_))
define GenerateHelp_ =
__mkutils_help_targets += help-help
__mkutils_help_targets := $$(sort $$(__mkutils_help_targets))
.PHONY: help-help
help-help:
	@$(PRINTF) "  %-$$(HELP_FIRSTCOLWIDTH)s - print this help\n" help
.PHONY: help_prologue
help_prologue:
	@$(ECHO) "Usage: $(MAKE) <target>"
	@$(ECHO) "where <target> is one of"
	@$(ECHO) ""
.PHONY: help_epilogue
help_epilogue:
	@$(ECHO) ""
.PHONY: help
help: help_prologue $$(__mkutils_help_targets) help_epilogue
endef

## ============================================================================
## == 11) Testing                                                            ==
## ============================================================================

__mkutils_passed :=
__mkutils_failed :=

##
# TestsBegin
# -----------------------------------------------------------------------------
# Prepare for running the tests. Clears __mkutils_temp.
TestsBegin = $(strip \
    $(eval __mkutils_temp :=) \
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
	@$(ECHO) ""
	@$(ECHO) $(__mkutils_echo_e) "$(call Colorize,LIGHT_CYAN,Test Results)"
	@$(ECHO) $(__mkutils_echo_e) "$(call Colorize,LIGHT_CYAN,$(DLINE))"
	@$(ECHO) $(__mkutils_echo_e) \
        "$(call Colorize,LIGHT_GREEN,Passed: $(words $(__mkutils_passed)))"
	@$(ECHO) $(__mkutils_echo_e) \
        "$(call Colorize,LIGHT_RED,Failed: $(words $(__mkutils_failed)))"
	@$(ECHO) $(__mkutils_echo_e) "$(call Colorize,LIGHT_CYAN,$(LINE))"
	@$(ECHO) $(__mkutils_echo_e) \
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
# Test whether $1($2) == $3. Modifies __mkutils_temp.
TestFunc1 = $(strip \
    $(call Print,Checking if $1('$2') == '$3': ,-n) \
    $(eval __mkutils_temp := '$(call $1,$2)') \
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
# Test whether $1($2, $3) == $4. Modifies __mkutils_temp.
TestFunc2 = $(strip \
    $(call Print,Checking if $1('$2', '$3') == '$4': ,-n) \
    $(eval __mkutils_temp := '$(call $1,$2,$3)') \
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
# Test whether $1($2, $3, $4) == $5. Modifies __mkutils_temp.
TestFunc3 = $(strip \
    $(call Print,Checking if $1('$2', '$3', '$4') == '$5': ,-n) \
    $(eval __mkutils_temp := '$(call $1,$2,$3,$4)') \
    $(call __mkutils_eval_test_result,Equal_,'$5') \
)

##
# __mkutils_eval_test_result $1 $2
# -----------------------------------------------------------------------------
# $1 - comparison function
# $2 - expected result
# -----------------------------------------------------------------------------
# Evaluate test as successful if $1($(__mkutils_temp), $2) is true. Otherwise,
# test is evaluated as failed. For internal use only.
__mkutils_eval_test_result = $(strip \
    $(if $(call $1,$(__mkutils_temp),$2), \
        $(eval __mkutils_passed += x) \
        $(call LightColorPrint,GREEN,OK), \
        $(eval __mkutils_failed += x) \
        $(call LightColorPrint,RED,ERROR: $(__mkutils_temp) != $2) \
    ) \
)

endif
