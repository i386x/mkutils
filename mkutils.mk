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

# mkutils version
__mkutils_version__ := 0.0.0

# Detect if are running under MS Windows
ifneq ($(PATHEXT),)
__mkutils_mswindows := 1
endif

# Detect for coloured output support
ifneq ($(__mkutils_mswindows),)
__mkutils_color = $1
else ifneq ($(COLORTERM),)
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

# The user has the last word
ifdef NOCOLORS
__mkutils_color =
export NOCOLORS
endif

# Enable `-e` option for $(ECHO) only if coloring is supported
__mkutils_echo_e := $(call __mkutils_color,-e)

##
# Handy constants.
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
LINE := ---------------------------------------
LINE := $(LINE)$(LINE)-
DLINE := =======================================
DLINE := $(DLINE)$(DLINE)=

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
# $1 - color name (without ANSI_COLOR_ prefix)
# $2 - text
# -----------------------------------------------------------------------------
# Make $2 $1-colored.
Colorize = $(ANSI_COLOR_$1)$2$(ANSI_COLOR_OFF)

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

# Set default goal's name
.DEFAULT_GOAL := all
.PHONY: all

# Auxiliary internal variables
__mkutils_temp :=

## ============================================================================
## == 1) Boolean operations                                                  ==
## ============================================================================

##
# Identity $1
# -----------------------------------------------------------------------------
# $1 - value
# -----------------------------------------------------------------------------
# Return $1.
Identity = $(call Identity_,$(strip $1))
Identity_ = $1

##
# Not $1
# -----------------------------------------------------------------------------
# $1 - value
# -----------------------------------------------------------------------------
# Return true (non-empty value) if $1 is false (empty) and vice versa.
Not = $(call Not_,$(strip $1))
Not_ = $(if $1,,X)

## ============================================================================
## == 2) List operations                                                     ==
## ============================================================================

##
# Head $1
# -----------------------------------------------------------------------------
# $1 - list
# -----------------------------------------------------------------------------
# Return first element of $1.
Head = $(call Head_,$(strip $1))
Head_ = $(firstword $1)

##
# Tail $1
# -----------------------------------------------------------------------------
# $1 - list
# -----------------------------------------------------------------------------
# Return the list equal to $1 without first element.
Tail = $(call Tail_,$(strip $1))
Tail_ = $(wordlist 2,$(words $1),$1)

## ============================================================================
## == 3) Comparations                                                        ==
## ============================================================================

##
# Eq $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Return true if $1 == $2.
Eq = $(call Eq_,$(strip $1),$(strip $2))
Eq_ = $(call ExitsWith,$(TEST) $1 -eq $2,0)

##
# Ne $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Return true if $1 != $2.
Ne = $(call Ne_,$(strip $1),$(strip $2))
Ne_ = $(call ExitsWith,$(TEST) $1 -ne $2,0)

##
# Lt $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Return true if $1 < $2.
Lt = $(call Lt_,$(strip $1),$(strip $2))
Lt_ = $(call ExitsWith,$(TEST) $1 -lt $2,0)

##
# Gt $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Return true if $1 > $2.
Gt = $(call Gt_,$(strip $1),$(strip $2))
Gt_ = $(call ExitsWith,$(TEST) $1 -gt $2,0)

##
# Le $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Return true if $1 <= $2.
Le = $(call Le_,$(strip $1),$(strip $2))
Le_ = $(call ExitsWith,$(TEST) $1 -le $2,0)

##
# Ge $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Return true if $1 >= $2.
Ge = $(call Ge_,$(strip $1),$(strip $2))
Ge_ = $(call ExitsWith,$(TEST) $1 -ge $2,0)

##
# Equal $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - strings
# -----------------------------------------------------------------------------
# Return true if $1 == $2.
Equal = $(call Equal_,$(strip $1),$(strip $2))
Equal_ = $(call Not_,$(call NotEqual_,$1,$2))

##
# NotEqual $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - strings
# -----------------------------------------------------------------------------
# Return true if $1 != $2.
NotEqual = $(call NotEqual_,$(strip $1),$(strip $2))
NotEqual_ = $(subst x$1,,x$2)$(subst x$2,,x$1)

## ============================================================================
## == 4) Assertions                                                          ==
## ============================================================================

##
# Assert $1 $2
# -----------------------------------------------------------------------------
# $1 - value
# $2 - error message
# -----------------------------------------------------------------------------
# Proceed with error and print $2 if $1 is false.
Assert = $(call Assert_,$(strip $1),$(strip $2))
Assert_ = $(if $1,,$(error $2))

##
# AssertVar $1
# -----------------------------------------------------------------------------
# $1 - variable name
# -----------------------------------------------------------------------------
# Proceed with error if $1 is empty or undefined.
AssertVar = $(call AssertVar_,$(strip $1))
AssertVar_ = $(call Assert_,$($1),$1 is empty or undefined)

##
# AssertEq $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Proceed with error if $1 != $2.
AssertEq = $(call AssertEq_,$(strip $1),$(strip $2))
AssertEq_ = $(call Assert_,$(call Eq_,$1,$2),Assertion x == y failed: $1 != $2)

##
# AssertNe $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Proceed with error if $1 == $2.
AssertNe = $(call AssertNe_,$(strip $1),$(strip $2))
AssertNe_ = $(call Assert_,$(call Ne_,$1,$2),Assertion x != y failed: $1 == $2)

##
# AssertLt $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Proceed with error if $1 >= $2.
AssertLt = $(call AssertLt_,$(strip $1),$(strip $2))
AssertLt_ = $(call Assert_,$(call Lt_,$1,$2),Assertion x < y failed: $1 >= $2)

##
# AssertGt $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Proceed with error if $1 <= $2.
AssertGt = $(call AssertGt_,$(strip $1),$(strip $2))
AssertGt_ = $(call Assert_,$(call Gt_,$1,$2),Assertion x > y failed: $1 <= $2)

##
# AssertLe $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Proceed with error if $1 > $2.
AssertLe = $(call AssertLe_,$(strip $1),$(strip $2))
AssertLe_ = $(call Assert_,$(call Le_,$1,$2),Assertion x <= y failed: $1 > $2)

##
# AssertGe $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - integers
# -----------------------------------------------------------------------------
# Proceed with error if $1 < $2.
AssertGe = $(call AssertGe_,$(strip $1),$(strip $2))
AssertGe_ = $(call Assert_,$(call Ge_,$1,$2),Assertion x >= y failed: $1 < $2)

##
# AssertEqual $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - strings
# -----------------------------------------------------------------------------
# Proceed with error if $1 != $2.
AssertEqual = $(call AssertEqual_,$(strip $1),$(strip $2))
AssertEqual_ = $(call Assert_,$(call Equal_,$1,$2),$(strip \
    Assertion x == y failed: '$1' != '$2' \
))

##
# AssertNotEqual $1 $2
# -----------------------------------------------------------------------------
# $1, $2 - strings
# -----------------------------------------------------------------------------
# Proceed with error if $1 == $2.
AssertNotEqual = $(call AssertNotEqual_,$(strip $1),$(strip $2))
AssertNotEqual_ = $(call Assert_,$(call NotEqual_,$1,$2),$(strip \
    Assertion x != y failed: '$1' == '$2' \
))

## ============================================================================
## == 5) Running programs                                                    ==
## ============================================================================

__mkutils_Run_output :=
__mkutils_Run_exitcode := 0

##
# ShowOutput
# -----------------------------------------------------------------------------
# Show the output of the last command invoked by Run.
ShowOutput = $(shell $(ECHO) $(__mkutils_echo_e) \
    "$(call Colorize,LIGHT_GREEN,$(__mkutils_Run_output))" >&2 \
)

##
# ShowExitcode
# -----------------------------------------------------------------------------
# Show the exit code of the last command invoked by Run.
ShowExitcode = $(shell $(ECHO) $(__mkutils_echo_e) \
    "$(call Colorize,LIGHT_RED,[exit_code = $(__mkutils_Run_exitcode)])" >&2 \
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
SoftRun = $(eval __mkutils_temp := $(shell $1 >/dev/null 2>&1))

##
# RunWithHooks $1 $2 $3
# -----------------------------------------------------------------------------
# $1     - shell command
# $2, $3 - name of a function with one argument
# -----------------------------------------------------------------------------
# Run $1. If $1 succeeds, call $2 with $1's output. Otherwise, call $3 with
# $1's exit code. Return the value returned by $2 or $3.
RunWithHooks = $(call RunWithHooks_,$1,$(strip $2),$(strip $3))
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
WhenOk = $(call WhenOk_,$1,$(strip $2))
WhenOk_ = $(if $(call ExitsWith,$1,0),$(call $2,$(__mkutils_Run_output)))

##
# WhenFail $1 $2
# -----------------------------------------------------------------------------
# $1 - shell command
# $2 - name of a function with one argument
# -----------------------------------------------------------------------------
# Run $1. If $1 fails, call $2 with $1's exit code and return the value
# returned by $2. Otherwise, return false.
WhenFail = $(call WhenFail_,$1,$(strip $2))
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
FindProgram = $(call FindProgram_,$(strip $1))
FindProgram_ = $(if $1,$(strip \
    $(call FindProgram_a,$(call Head_,$1),$(call Tail_,$1)) \
))
FindProgram_a = $(if $(call Which,$1),$1,$(call FindProgram_,$2))

## ============================================================================
## == 6) Probing Python interpreter                                          ==
## ============================================================================

##
# PyVersion $1 $2
# -----------------------------------------------------------------------------
# $1 - Python interpreter
# $2 - `major` or `minor`
# -----------------------------------------------------------------------------
# Depending on $2's value, return major or minor version number of $1. On
# error, return false.
PyVersion = $(call WhenOk_,$(call PyVersion_a,$1,$(strip $2)),Identity)
PyVersion_a = $1 -c "import sys; sys.stdout.write(repr(sys.version_info.$2))"

##
# NeedPython $1 $2
# -----------------------------------------------------------------------------
# $1 - variable name with list of Python interpreters
# $2 - variable name with expected version
# -----------------------------------------------------------------------------
# Search $1 for a Python interpreter with version >= $2. If such an interpreter
# does not exist, proceed with error.
NeedPython = $(call NeedPython_,$(strip $1),$(strip $2))
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
## == 7) Targets                                                             ==
## ============================================================================

__mkutils_help_targets :=

##
# Width of column with targets names. Override this to set different value.
# Example: With HELP_FIRSTCOLWIDTH set to 8, the help will be displayed as
#
#   foo      - help for foo
#   bar      - help for bar
#   baaz     - help for baaz
#   ^^^^^^^^
#   (8 chars)
#
HELP_FIRSTCOLWIDTH := 8
export HELP_FIRSTCOLWIDTH

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
Target = $(eval $(call Target_,$(strip $1),$(strip $2)))$(strip $1):
define Target_ =
__mkutils_help_targets += help-$1
.PHONY: help-$1
help-$1:
	@$(PRINTF) "  %-$(HELP_FIRSTCOLWIDTH)s - $2\n" $1
.PHONY: $1
endef

##
# GenerateHelp
# -----------------------------------------------------------------------------
# Define `help` target that prints help for all targets defined by Target.
GenerateHelp = $(eval $(call GenerateHelp_))
define GenerateHelp_ =
__mkutils_help_targets += help-help
__mkutils_help_targets := $$(sort $$(__mkutils_help_targets))
.PHONY: help-help
help-help:
	@$(PRINTF) "  %-$(HELP_FIRSTCOLWIDTH)s - print this help\n" help
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
## == 8) Testing                                                             ==
## ============================================================================

__mkutils_passed :=
__mkutils_failed :=

##
# TestsBegin
# -----------------------------------------------------------------------------
# Prepare for running the tests.
TestsBegin = $(strip \
    $(eval __mkutils_temp :=) \
    $(eval __mkutils_passed :=) \
    $(eval __mkutils_failed :=) \
)

##
# TestsEnd
# -----------------------------------------------------------------------------
# Close the test phase, print overall statistics.
define TestsEnd =
all:;
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
    $(shell $(ECHO) "" >&2) \
    $(shell $(ECHO) $(__mkutils_echo_e) \
        "$(call Colorize,LIGHT_BLUE,Running $1 tests)" >&2 \
    ) \
    $(shell $(ECHO) $(__mkutils_echo_e) \
        "$(call Colorize,LIGHT_BLUE,$(LINE))" >&2 \
    ) \
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
    $(shell $(ECHO) -n "Checking if $1('$2') == '$3': " >&2) \
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
# Test whether $1($2, $3) == $4.
TestFunc2 = $(strip \
    $(shell $(ECHO) -n "Checking if $1('$2', '$3') == '$4': " >&2) \
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
# Test whether $1($2, $3, $4) == $5.
TestFunc3 = $(strip \
    $(shell $(ECHO) -n "Checking if $1('$2', '$3', '$4') == '$5': " >&2) \
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
        $(shell $(ECHO) $(__mkutils_echo_e) \
            "$(call Colorize,LIGHT_GREEN,OK)" >&2 \
        ), \
        $(eval __mkutils_failed += x) \
        $(shell $(ECHO) $(__mkutils_echo_e) \
            "$(call Colorize,LIGHT_RED,ERROR: $(__mkutils_temp) != $2)" >&2 \
        ) \
    ) \
)

endif
