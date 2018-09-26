#
#! \file    ~/tests.mk
#! \author  Jiří Kučera, <sanczes AT gmail.com>
#! \stamp   2018-09-23 13:43:47 +0200
#! \project mkutils - Makefile Utilities
#! \license MIT
#! \version 0.0.0
#! \brief   mkutils test suite.
#

include $(CURDIR)/mkutils.mk

CALL_PROXY := $(MAKE) -f $(CURDIR)/call-proxy.mk

TestAssert = $(strip \
    $(call TestFunc2,ExitsWith,$(call TestAssert_,$1,$2,$3,$4,$5),2,X) \
    $(call ShowStatus) \
)
TestAssert_ = $(CALL_PROXY) _0="$1" _1="$2" _2="$3" _3="$4" $5

$(call TestsBegin)

# Identity
$(call TestInfo,Identity)
$(call TestFunc1,Identity,,)
$(call TestFunc1,Identity, ,)
$(call TestFunc1,Identity, x  y  ,x y)
$(call TestFunc1,Identity_,,)
$(call TestFunc1,Identity_, , )
$(call TestFunc1,Identity_,  x   y   ,  x   y   )

# Not
$(call TestInfo,Not)
$(call TestFunc1,Not,,X)
$(call TestFunc1,Not, ,X)
$(call TestFunc1,Not, a,)
$(call TestFunc1,Not_,,X)
$(call TestFunc1,Not_, ,)
$(call TestFunc1,Not_, a,)

# Head
$(call TestInfo,Head)
$(call TestFunc1,Head,a,a)
$(call TestFunc1,Head, 1  b ,1)
$(call TestFunc1,Head_,3 4,3)
$(call TestFunc1,Head_, 5,5)

# Tail
$(call TestInfo,Tail)
$(call TestFunc1,Tail, 1,)
$(call TestFunc1,Tail, 1  w  f ,w f)
$(call TestFunc1,Tail, a b c d,b c d)
$(call TestFunc1,Tail_,2,)
$(call TestFunc1,Tail_, ef gh i,gh i)

# Eq
$(call TestInfo,Eq)
$(call TestFunc2,Eq,1,1,X)
$(call TestFunc2,Eq,2,5,)
$(call TestFunc2,Eq,5,2,)

# Ne
$(call TestInfo,Ne)
$(call TestFunc2,Ne,1,1,)
$(call TestFunc2,Ne,2,5,X)
$(call TestFunc2,Ne,5,2,X)

# Lt
$(call TestInfo,Lt)
$(call TestFunc2,Lt,1,1,)
$(call TestFunc2,Lt,1,2,X)
$(call TestFunc2,Lt,2,1,)

# Gt
$(call TestInfo,Gt)
$(call TestFunc2,Gt,1,1,)
$(call TestFunc2,Gt,1,2,)
$(call TestFunc2,Gt,2,1,X)

# Le
$(call TestInfo,Le)
$(call TestFunc2,Le,1,1,X)
$(call TestFunc2,Le,1,2,X)
$(call TestFunc2,Le,2,1,)

# Ge
$(call TestInfo,Ge)
$(call TestFunc2,Ge,1,1,X)
$(call TestFunc2,Ge,1,2,)
$(call TestFunc2,Ge,2,1,X)

# Equal
$(call TestInfo,Equal)
$(call TestFunc2,Equal,,,X)
$(call TestFunc2,Equal, a,a,X)
$(call TestFunc2,Equal, aa, a,)
$(call TestFunc2,Equal, a, aa,)
$(call TestFunc2,Equal,xaa,xa,)
$(call TestFunc2,Equal,xa,xaa,)
$(call TestFunc2,Equal,abc,abc,X)

# NotEqual
$(call TestInfo,NotEqual)
$(call TestFunc2,NotEqual,,,)
$(call TestFunc2,NotEqual, a,a,)
$(call TestFunc2,NotEqual, aa, a,xaa)
$(call TestFunc2,NotEqual, a, aa,axa)
$(call TestFunc2,NotEqual,xaa,xa,xxaa)
$(call TestFunc2,NotEqual,xa,xaa,axxa)
$(call TestFunc2,NotEqual,abc,abc,)

# Assert
$(call TestInfo,Assert)
$(call TestAssert,Assert,,Assertion condition is false)
$(call TestFunc2,Assert,X,Assertion condition is false,)

# AssertVar
$(call TestInfo,AssertVar)
$(call TestAssert,AssertVar,UNDEFINED)
$(call TestAssert,AssertVar,EMPTY)
$(call TestFunc1,AssertVar,SPACE,)
$(call TestFunc1,AssertVar,ECHO,)

# AssertEq
$(call TestInfo,AssertEq)
$(call TestAssert,AssertEq,1,2)
$(call TestAssert,AssertEq,2,1)
$(call TestFunc2,AssertEq,1,1,)

# AssertNe
$(call TestInfo,AssertNe)
$(call TestAssert,AssertNe,1,1)
$(call TestFunc2,AssertNe,3,4,)
$(call TestFunc2,AssertNe,4,3,)

# AssertLt
$(call TestInfo,AssertLt)
$(call TestAssert,AssertLt,1,1)
$(call TestFunc2,AssertLt,1,2,)
$(call TestAssert,AssertLt,2,1)

# AssertGt
$(call TestInfo,AssertGt)
$(call TestAssert,AssertGt,1,1)
$(call TestAssert,AssertGt,1,2)
$(call TestFunc2,AssertGt,2,1,)

# AssertLe
$(call TestInfo,AssertLe)
$(call TestFunc2,AssertLe,1,1,)
$(call TestFunc2,AssertLe,1,2,)
$(call TestAssert,AssertLe,2,1)

# AssertGe
$(call TestInfo,AssertGe)
$(call TestFunc2,AssertGe,1,1,)
$(call TestAssert,AssertGe,1,2)
$(call TestFunc2,AssertGe,2,1)

# AssertEqual
$(call TestInfo,AssertEqual)
$(call TestFunc2,AssertEqual,,,)
$(call TestFunc2,AssertEqual,abc,abc,)
$(call TestAssert,AssertEqual,,abc)
$(call TestAssert,AssertEqual,abc,)
$(call TestAssert,AssertEqual,ab,abc)
$(call TestAssert,AssertEqual,abc,ab)
$(call TestAssert,AssertEqual,abc,xyz)

# AssertNotEqual
$(call TestInfo,AssertNotEqual)
$(call TestAssert,AssertNotEqual,,)
$(call TestAssert,AssertNotEqual,abc,abc)
$(call TestFunc2,AssertNotEqual,,abc,)
$(call TestFunc2,AssertNotEqual,abc,,)
$(call TestFunc2,AssertNotEqual,ab,abc,)
$(call TestFunc2,AssertNotEqual,abc,ab,)
$(call TestFunc2,AssertNotEqual,abc,xyz,)

# Run
$(call TestInfo,Run)
$(call Run, $(TEST) 0 -ge 1)
$(call TestFunc2,Equal,$(__mkutils_Run_output),,X)
$(call TestFunc2,Equal,$(__mkutils_Run_exitcode),1,X)
$(call Run, $(ECHO) "beep beep")
$(call TestFunc2,Equal,$(__mkutils_Run_output),beep beep,X)
$(call TestFunc2,Equal,$(__mkutils_Run_exitcode),0,X)

# SoftRun
$(call TestInfo,SoftRun)
$(call TestFunc1,SoftRun,$(ECHO) "Hello!",)

# RunWithHooks
$(call TestInfo,RunWithHooks)
$(call TestFunc3,RunWithHooks,$(ECHO) "beep",Identity,Identity,beep)
$(call TestFunc3,RunWithHooks,$(TEST) 1 -ge 2,Identity,Identity,1)

# WhenOk
$(call TestInfo,WhenOk)
$(call TestFunc2,WhenOk,$(ECHO) "beep",Identity,beep)
$(call TestFunc2,WhenOk,$(TEST) 1 -ge 2,Identity,)

# WhenFail
$(call TestInfo,WhenFail)
$(call TestFunc2,WhenFail,$(ECHO) "beep",Identity,)
$(call TestFunc2,WhenFail,$(TEST) 1 -ge 2,Identity,1)

# ExitsWith
$(call TestInfo,ExitsWith)
$(call TestFunc2,ExitsWith,$(TEST) 0 -ge 1,0,)
$(call TestFunc2,ExitsWith,$(TEST) 2 -ge 1,0,X)

# NotExitsWith
$(call TestInfo,NotExitsWith)
$(call TestFunc2,NotExitsWith,$(TEST) 0 -ge 1,0,x0x1)
$(call TestFunc2,NotExitsWith,$(TEST) 2 -ge 1,0,)

# Which
$(call TestInfo,Which)
$(call TestFunc1,Which,test,X)
$(call TestFunc1,Which,foobarbaz,)

# FindProgram
$(call TestInfo,FindProgram)
$(call TestFunc1,FindProgram,,)
$(call TestFunc1,FindProgram,test,test)
$(call TestFunc1,FindProgram,test foo,test)
$(call TestFunc1,FindProgram,test foo bar,test)
$(call TestFunc1,FindProgram,foo,)
$(call TestFunc1,FindProgram,foo test,test)
$(call TestFunc1,FindProgram,foo bar test,test)
$(call TestFunc1,FindProgram,foo bar test baz,test)
$(call TestFunc1,FindProgram,foo bar test baz make,test)

# PyVersion
$(call TestInfo,PyVersion)
# - auxiliary macros
__py2list :=
__py3list :=
__addpython = $(strip \
    $(eval __py$(1)list += python$(1)$(2) python$(1).$(2)) \
    $(eval __py_python$(1)$(2)_major := $1) \
    $(eval __py_python$(1).$(2)_major := $1) \
    $(eval __py_python$(1)$(2)_minor := $2) \
    $(eval __py_python$(1).$(2)_minor := $2) \
)
__pyver = $(__py_$1)
# - add pythons
$(foreach x,7 6 5 4 3 2 1,$(call __addpython,2,$x))
$(foreach x,6 5 4 3 2 1,$(call __addpython,3,$x))
# - find interpreters and guess their versions
__py2 := $(call FindProgram, $(__py2list))
$(call AssertVar,__py2)
__py3 := $(call FindProgram, $(__py3list))
$(call AssertVar,__py3)
__py2major := $(call __pyver,$(__py2)_major)
__py2minor := $(call __pyver,$(__py2)_minor)
__py3major := $(call __pyver,$(__py3)_major)
__py3minor := $(call __pyver,$(__py3)_minor)
# - run tests
$(call TestFunc2,PyVersion,$(TEST),major,)
$(call TestFunc2,PyVersion,$(TRUE),major,)
$(call TestFunc2,PyVersion,$(__py2),foo,)
$(call TestFunc2,PyVersion,$(__py2),major,$(__py2major))
$(call TestFunc2,PyVersion,$(__py2),minor,$(__py2minor))
$(call TestFunc2,PyVersion,$(__py3),foo,)
$(call TestFunc2,PyVersion,$(__py3),major,$(__py3major))
$(call TestFunc2,PyVersion,$(__py3),minor,$(__py3minor))

# NeedPython
$(call TestInfo,NeedPython)
# - handy macros
TestNeedPythonCrash = $(call TestAssert,NeedPython,$1,$2,,$1="$($1)" $2=$($2))
# - handy constants
__py2ver = 26
__py3ver = 34
__pylist_0 :=
__pylist_1 := $(TRUE)
__pylist_2 := python3
__pylist_3 := $(FALSE) python3
__pylist_4 := $(TRUE) $(FALSE) python3
__pylist_5 := python26 python2.6 python2.7 python27 python2 python3.3 python3
__pylist_5 += python3.7 python
__pylist_6 := python2 python
# - tests
$(call TestNeedPythonCrash,__pylist_0,EMPTY)
$(call TestNeedPythonCrash,__pylist_0,__py3ver)
$(call TestNeedPythonCrash,__pylist_1,__py3ver)
$(call TestFunc2,NeedPython,__pylist_2,__py3ver,python3)
$(call TestFunc2,NeedPython,__pylist_3,__py3ver,python3)
$(call TestFunc2,NeedPython,__pylist_4,__py3ver,python3)
$(call TestFunc2,NeedPython,__pylist_5,__py2ver,python2.7)
$(call TestFunc2,NeedPython,__pylist_5,__py3ver,python3)
$(call TestFunc2,NeedPython,__pylist_6,__py2ver,python2)
$(call TestNeedPythonCrash,__pylist_6,__py3ver)

$(call TestsEnd)
