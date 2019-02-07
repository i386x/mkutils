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

UPPER := ABCDEFGHIJKLMNOPQRSTUVWXYZ
LOWER := abcdefghijklmnopqrstuvwxyz

CALL_PROXY := $(MAKE) -f $(CURDIR)/call-proxy.mk

TestVarValue = $($1)

IfOrigin = $(if $(call Equal_,$(origin $1),$2),$3,$4)

TestMapExists = $(call IfOrigin,__mkutils_map_$1_keys,undefined,0,1)
TestKeyExists = $(call IfOrigin,__mkutils_map_$1[$2],undefined,0,1)
TestTagExists = $(call IfOrigin,__mkutils_map_$1[$2]_,undefined,0,1)

TestKVApplyFn = $(eval $4 += $3-$2-$1)

TestAssert = $(strip \
    $(call TestFunc2,ExitsWith,$(call $(0)_,$1,$2,$3,$4,$5),2,X) \
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

# Elem
$(call TestInfo,Elem)
$(call TestFunc2,Elem, ,,)
$(call TestFunc2,Elem, ,2,)
$(call TestFunc2,Elem, a, 2,)
$(call TestFunc2,Elem, a b, 2,b)
$(call TestFunc2,Elem, a b,,a)

# Tail
$(call TestInfo,Tail)
$(call TestFunc1,Tail, 1,)
$(call TestFunc1,Tail, 1  w  f ,w f)
$(call TestFunc1,Tail, a b c d,b c d)
$(call TestFunc1,Tail_,2,)
$(call TestFunc1,Tail_, ef gh i,gh i)

# Slice
$(call TestInfo,Slice)
$(call TestFunc3,Slice, , 1, ,)
$(call TestFunc3,Slice, , 2, ,)
$(call TestFunc3,Slice, , 3, ,)
$(call TestFunc3,Slice, , 1, 1,)
$(call TestFunc3,Slice, , 2, 2,)
$(call TestFunc3,Slice, , 3, 3,)
$(call TestFunc3,Slice, , 1, 2,)
$(call TestFunc3,Slice, , 2, 3,)
$(call TestFunc3,Slice, , 3, 4,)
$(call TestFunc3,Slice, , 1, 3,)
$(call TestFunc3,Slice, , 2, 4,)
$(call TestFunc3,Slice, , 3, 5,)
$(call TestFunc3,Slice, , 2, 1,)
$(call TestFunc3,Slice, , 3, 2,)
$(call TestFunc3,Slice, , 4, 3,)
$(call TestFunc3,Slice, , 3, 1,)
$(call TestFunc3,Slice, , 4, 2,)
$(call TestFunc3,Slice, , 5, 3,)
$(call TestFunc3,Slice, a, 1, ,a)
$(call TestFunc3,Slice, a, 2, ,)
$(call TestFunc3,Slice, a, 3, ,)
$(call TestFunc3,Slice, a, 1, 1,a)
$(call TestFunc3,Slice, a, 2, 2,)
$(call TestFunc3,Slice, a, 3, 3,)
$(call TestFunc3,Slice, a, 1, 2,a)
$(call TestFunc3,Slice, a, 2, 3,)
$(call TestFunc3,Slice, a, 3, 4,)
$(call TestFunc3,Slice, a, 1, 3,a)
$(call TestFunc3,Slice, a, 2, 4,)
$(call TestFunc3,Slice, a, 3, 5,)
$(call TestFunc3,Slice, a, 2, 1,)
$(call TestFunc3,Slice, a, 3, 2,)
$(call TestFunc3,Slice, a, 4, 3,)
$(call TestFunc3,Slice, a, 3, 1,)
$(call TestFunc3,Slice, a, 4, 2,)
$(call TestFunc3,Slice, a, 5, 3,)
$(call TestFunc3,Slice, a b, 1, ,a b)
$(call TestFunc3,Slice, a b, 2, ,b)
$(call TestFunc3,Slice, a b, 3, ,)
$(call TestFunc3,Slice, a b, 1, 1,a)
$(call TestFunc3,Slice, a b, 2, 2,b)
$(call TestFunc3,Slice, a b, 3, 3,)
$(call TestFunc3,Slice, a b, 1, 2,a b)
$(call TestFunc3,Slice, a b, 2, 3,b)
$(call TestFunc3,Slice, a b, 3, 4,)
$(call TestFunc3,Slice, a b, 1, 3,a b)
$(call TestFunc3,Slice, a b, 2, 4,b)
$(call TestFunc3,Slice, a b, 3, 5,)
$(call TestFunc3,Slice, a b, 2, 1,)
$(call TestFunc3,Slice, a b, 3, 2,)
$(call TestFunc3,Slice, a b, 4, 3,)
$(call TestFunc3,Slice, a b, 3, 1,)
$(call TestFunc3,Slice, a b, 4, 2,)
$(call TestFunc3,Slice, a b, 5, 3,)
$(call TestFunc3,Slice, a b c, 1, ,a b c)
$(call TestFunc3,Slice, a b c, 2, ,b c)
$(call TestFunc3,Slice, a b c, 3, ,c)
$(call TestFunc3,Slice, a b c, 1, 1,a)
$(call TestFunc3,Slice, a b c, 2, 2,b)
$(call TestFunc3,Slice, a b c, 3, 3,c)
$(call TestFunc3,Slice, a b c, 1, 2,a b)
$(call TestFunc3,Slice, a b c, 2, 3,b c)
$(call TestFunc3,Slice, a b c, 3, 4,c)
$(call TestFunc3,Slice, a b c, 1, 3,a b c)
$(call TestFunc3,Slice, a b c, 2, 4,b c)
$(call TestFunc3,Slice, a b c, 3, 5,c)
$(call TestFunc3,Slice, a b c, 2, 1,)
$(call TestFunc3,Slice, a b c, 3, 2,)
$(call TestFunc3,Slice, a b c, 4, 3,)
$(call TestFunc3,Slice, a b c, 3, 1,)
$(call TestFunc3,Slice, a b c, 4, 2,)
$(call TestFunc3,Slice, a b c, 5, 3,)

# Strlen
$(call TestInfo,Strlen)
$(call TestFunc1,Strlen,,0)
$(call TestFunc1,Strlen, ,0)
$(call TestFunc1,Strlen, a ,1)
$(call TestFunc1,Strlen, a b,3)
$(call TestFunc1,Strlen,a  b,3)
$(call TestFunc1,Strlen,abcdef,6)

# ToLower
$(call TestInfo,ToLower)
$(call TestFunc1,ToLower,$(UPPER),$(LOWER))

# ToUpper
$(call TestInfo,ToUpper)
$(call TestFunc1,ToUpper,$(LOWER),$(UPPER))

# MakeMap
$(call TestInfo,MakeMap)
$(call TestFunc1,TestMapExists,foo1,0)
$(call TestFunc1,MakeMap,foo1,)
$(call TestFunc1,TestMapExists,foo1,1)

# MapKeys
$(call TestInfo,MapKeys)
$(call TestFunc1,MapKeys, foo2,)
$(call TestFunc3,KVSet, foo2, A, 1,)
$(call TestFunc1,MapKeys, foo2, A)
$(call TestFunc3,KVSet, foo2, B, 2,)
$(call TestFunc1,MapKeys, foo2, A B)
$(call TestFunc3,KVSet, foo2, B, 3,)
$(call TestFunc1,MapKeys, foo2, A B)
$(call TestFunc3,KVSet, foo2, D, 4,)
$(call TestFunc1,MapKeys, foo2, A B D)

# MapSize
$(call TestInfo,MapSize)
$(call TestFunc1,MapSize, foo3,0)
$(call TestFunc3,KVSet, foo3, width, 1pt,)
$(call TestFunc1,MapSize, foo3,1)
$(call TestFunc3,KVSet, foo3, width, 2pt,)
$(call TestFunc1,MapSize, foo3,1)
$(call TestFunc3,KVSet, foo3, wwidth, 3pt,)
$(call TestFunc1,MapSize, foo3,2)
$(call TestFunc1,MapSize, bar,0)

# KVSetKey
$(call TestInfo,KVSetKey)
$(call KVSet, foo4, abc, 123)
$(call TestFunc3,KVSetKey,foo4,abc,234,)
$(call TestFunc2,KVGetKey,foo4,abc,234)
$(call TestFunc3,KVSetKey,foo4,abc,def,)
$(call TestFunc2,KVGetKey,foo4,abc,def)

# KVGetKey
$(call TestInfo,KVGetKey)
$(call TesFunc2,KVGetKey,foo5,ice,)
$(call TestFunc3,KVSet, foo5, ice, snow,)
$(call TesFunc2,KVGetKey,foo5,ice,snow)

# KVHasKey
$(call TestInfo,KVHasKey)
$(call TestFunc2,KVHasKey,foo6,pi,)
$(call TestFunc3,KVSet, foo6, pi, 3.14,)
$(call TestFunc2,KVHasKey,foo6,pi,pi)
$(call TestFunc2,KVHasKey,foo6,to,)
$(call TestFunc3,KVSet, foo6, to, do,)
$(call TestFunc2,KVHasKey,foo6,to,to)
$(call TestFunc2,KVHasKey,foo6,,)
$(call TestFunc3,KVSet, foo6, pipipi, 314,)
$(call TestFunc2,KVHasKey,foo6,pipi,)
$(call TestFunc2,KVHasKey,foo6,pipipi,pipipi)

# KVAddKey
$(call TestInfo,KVAddKey)
$(call TestFunc3,KVSet, foo7, k1, g,)
$(call TestFunc2,KVGetKey,foo7,k1,g)
$(call TestFunc3,KVSet, foo7, k1, h,)
$(call TestFunc2,KVGetKey,foo7,k1,h)
$(call TestFunc3,KVSet, foo7, k2, i,)
$(call TestFunc2,KVGetKey,foo7,k2,i)
$(call TestFunc1,MapKeys, foo7, k1 k2)

# KVTagKey
$(call TestInfo,KVTagKey)
$(call TestFunc2,KVTagKey,foo8,K,)
$(call TestFunc2,TestTagExists,foo8,K,0)
$(call TestFunc3,KVSet, foo8, K, lm,)
$(call TestFunc2,TestTagExists,foo8,K,0)
$(call TestFunc2,KVIsTagged,foo8,K,)
$(call TestFunc2,KVTagKey,foo8,K,)
$(call TestFunc2,KVIsTagged,foo8,K,1)
$(call TestFunc2,TestTagExists,foo8,K,1)

# KVIsTagged
$(call TestInfo,KVIsTagged)
$(call TestFunc2,KVIsTagged,foo9,k9,)
$(call TestFunc3,KVSet, foo9, k9, l10,)
$(call TestFunc2,KVIsTagged,foo9,k9,)
$(call TestFunc3,KVTagKey,foo9,k9,)
$(call TestFunc2,KVIsTagged,foo9,k9,1)

# KVUntagKey
$(call TestInfo,KVUntagKey)
$(call TestFunc3,KVSet, foo10, x11, y21,)
$(call TestFunc2,KVTagKey,foo10,x11,)
$(call TestFunc2,KVIsTagged,foo10,x11,1)
$(call TestFunc2,KVUntagKey,foo10,x11,)
$(call TestFunc2,KVIsTagged,foo10,x11,)
$(call TestFunc2,KVUntagKey,foo10,x12,)
$(call TestFunc2,TestTagExists,foo10,x11,1)
$(call TestFunc2,TestTagExists,foo10,x12,0)

# KVRemoveKey
$(call TestInfo,KVRemoveKey)
$(call TestFunc3,KVSet, foo11, E, 123,)
$(call TestFunc2,KVGetKey,foo11,E,123)
$(call TestFunc1,MapKeys,foo11, E)
$(call TestFunc2,KVDel, foo11, E,)
$(call TestFunc2,KVGetKey,foo11,E,)
$(call TestFunc1,MapKeys,foo11,)

# KVSet
$(call TestInfo,KVSet)
# KVSet(foo12, , abc)
$(call TestFunc3,KVSet, foo12, , abc,)
$(call TestFunc1,TestMapExists,foo12,0)
$(call TestFunc2,TestKeyExists,foo12,,0)
$(call TestFunc2,TestTagExists,foo12,,0)
# KVSet(foo12, Q, 222)
$(call TestFunc3,KVSet, foo12, Q, 222,)
$(call TestFunc2,TestKeyExists,foo12,Q,1)
$(call TestFunc2,TestTagExists,foo12,Q,0)
$(call TestFunc2,KVGetKey,foo12,Q,222)
$(call TestFunc1,MapKeys,foo12, Q)
# KVSet(foo12, P, )
$(call TestFunc3,KVSet, foo12, P, ,)
$(call TestFunc2,TestKeyExists,foo12,P,1)
$(call TestFunc2,TestTagExists,foo12,P,0)
$(call TestFunc2,KVGetKey,foo12,P,)
$(call TestFunc1,MapKeys,foo12, Q P)
# KVSet(foo12, Q, )
$(call TestFunc3,KVSet, foo12, Q, ,)
$(call TestFunc2,TestKeyExists,foo12,Q,1)
$(call TestFunc2,TestTagExists,foo12,Q,0)
$(call TestFunc2,KVGetKey,foo12,Q,)
$(call TestFunc1,MapKeys,foo12, Q P)
# KVSet(foo12, P, 432)
$(call TestFunc3,KVSet, foo12, P, 432,)
$(call TestFunc2,TestKeyExists,foo12,P,1)
$(call TestFunc2,TestTagExists,foo12,P,0)
$(call TestFunc2,KVGetKey,foo12,P,432)
$(call TestFunc1,MapKeys,foo12, Q P)
# KVTagKey(foo12,P)
$(call TestFunc2,KVTagKey,foo12,P,)
$(call TestFunc2,TestKeyExists,foo12,P,1)
$(call TestFunc2,TestTagExists,foo12,P,1)
$(call TestFunc2,KVIsTagged,foo12,P,1)
$(call TestFunc2,KVGetKey,foo12,P,432)
$(call TestFunc1,MapKeys,foo12, Q P)
# KVSet(foo12, P, 432)
$(call TestFunc3,KVSet, foo12, P, 432,)
$(call TestFunc2,TestKeyExists,foo12,P,1)
$(call TestFunc2,TestTagExists,foo12,P,1)
$(call TestFunc2,KVIsTagged,foo12,P,)
$(call TestFunc2,KVGetKey,foo12,P,432)
$(call TestFunc1,MapKeys,foo12, Q P)

# KVGet
$(call TestInfo,KVGet)
$(call TestFunc2,TestKeyExists,foo13,A20,0)
$(call TestFunc2,KVGet, foo13, A20,)
$(call TestFunc3,KVSet, foo13, A20, 20.d,)
$(call TestFunc2,TestKeyExists,foo13,A20,1)
$(call TestFunc2,KVIsTagged,foo13,A20,)
$(call TestFunc2,KVGet, foo13, A20,20.d)
$(call TestFunc2,KVTagKey,foo13,A20,)
$(call TestFunc2,TestKeyExists,foo13,A20,1)
$(call TestFunc2,KVIsTagged,foo13,A20,1)
$(call TestFunc2,KVGet, foo13, A20,20.d)
$(call TestFunc3,KVSet, foo13, A20, ,)
$(call TestFunc2,TestKeyExists,foo13,A20,1)
$(call TestFunc2,KVIsTagged,foo13,A20,)
$(call TestFunc2,KVGet, foo13, A20,)

# KVHas
$(call TestInfo,KVHas)
$(call TestFunc2,TestKeyExists,foo14,X,0)
$(call TestFunc2,KVHas,foo14,X,)
$(call TestFunc3,KVSet, foo14, X, ,)
$(call TestFunc2,TestKeyExists,foo14,X,1)
$(call TestFunc2,KVHas,foo14,X,X)
$(call TestFunc3,KVSet, foo14, X, Y,)
$(call TestFunc2,TestKeyExists,foo14,X,1)
$(call TestFunc2,KVHas,foo14,X,X)
$(call TestFunc2,KVTagKey,foo14,X,)
$(call TestFunc2,TestKeyExists,foo14,X,1)
$(call TestFunc2,KVHas,foo14,X,X)

# KVDel
$(call TestInfo,KVDel)
# KVDel(foo15, Z), Z is not in foo15
$(call TestFunc1,TestMapExists,foo15,0)
$(call TestFunc2,TestKeyExists,foo15,Z,0)
$(call TestFunc2,TestTagExists,foo15,Z,0)
$(call TestFunc2,KVDel, foo15, Z,)
$(call TestFunc1,TestMapExists,foo15,0)
$(call TestFunc2,TestKeyExists,foo15,Z,0)
$(call TestFunc2,TestTagExists,foo15,Z,0)
# KVSet(foo15, Z1, a), KVDel(foo15, Z1), KVDel(foo15, Z1)
$(call TestFunc1,MapKeys,foo15,)
$(call TestFunc2,TestKeyExists,foo15,Z1,0)
$(call TestFunc2,TestTagExists,foo15,Z1,0)
$(call TestFunc3,KVSet, foo15, Z1, a,)
$(call TestFunc1,MapKeys,foo15, Z1)
$(call TestFunc2,TestKeyExists,foo15,Z1,1)
$(call TestFunc2,KVGetKey,foo15,Z1,a)
$(call TestFunc2,TestTagExists,foo15,Z1,0)
$(call TestFunc2,KVDel,foo15,Z1,)
$(call TestFunc1,MapKeys,foo15,)
$(call TestFunc2,TestKeyExists,foo15,Z1,1)
$(call TestFunc2,KVGetKey,foo15,Z1,)
$(call TestFunc2,TestTagExists,foo15,Z1,0)
$(call TestFunc2,KVDel,foo15,Z1,)
$(call TestFunc1,MapKeys,foo15,)
$(call TestFunc2,TestKeyExists,foo15,Z1,1)
$(call TestFunc2,KVGetKey,foo15,Z1,)
$(call TestFunc2,TestTagExists,foo15,Z1,0)
# KVSet(foo15, Z2, b), KVTagKey(foo15, Z2), KVDel(foo15, Z2), KVDel(foo15, Z2)
$(call TestFunc1,MapKeys,foo15,)
$(call TestFunc2,TestKeyExists,foo15,Z2,0)
$(call TestFunc2,TestTagExists,foo15,Z2,0)
$(call TestFunc3,KVSet, foo15, Z2, b,)
$(call TestFunc1,MapKeys,foo15, Z2)
$(call TestFunc2,TestKeyExists,foo15,Z2,1)
$(call TestFunc2,KVGetKey,foo15,Z2,b)
$(call TestFunc2,TestTagExists,foo15,Z2,0)
$(call TestFunc2,KVTagKey,foo15,Z2,)
$(call TestFunc1,MapKeys,foo15, Z2)
$(call TestFunc2,TestKeyExists,foo15,Z2,1)
$(call TestFunc2,KVGetKey,foo15,Z2,b)
$(call TestFunc2,TestTagExists,foo15,Z2,1)
$(call TestFunc2,KVIsTagged,foo15,Z2,1)
$(call TestFunc2,KVDel,foo15,Z2)
$(call TestFunc1,MapKeys,foo15,)
$(call TestFunc2,TestKeyExists,foo15,Z2,1)
$(call TestFunc2,KVGetKey,foo15,Z2,)
$(call TestFunc2,TestTagExists,foo15,Z2,1)
$(call TestFunc2,KVIsTagged,foo15,Z2,)
$(call TestFunc2,KVDel,foo15,Z2)
$(call TestFunc1,MapKeys,foo15,)
$(call TestFunc2,TestKeyExists,foo15,Z2,1)
$(call TestFunc2,KVGetKey,foo15,Z2,)
$(call TestFunc2,TestTagExists,foo15,Z2,1)
$(call TestFunc2,KVIsTagged,foo15,Z2,)
# KVTagKey(foo15, Z1)
$(call TestFunc2,KVTagKey,foo15,Z1,)
$(call TestFunc1,MapKeys,foo15,)
$(call TestFunc2,TestKeyExists,foo15,Z1,1)
$(call TestFunc2,KVGetKey,foo15,Z1,)
$(call TestFunc2,TestTagExists,foo15,Z1,0)
# KVTagKey(foo15, Z2)
$(call TestFunc2,KVTagKey,foo15,Z2,)
$(call TestFunc1,MapKeys,foo15,)
$(call TestFunc2,TestKeyExists,foo15,Z2,1)
$(call TestFunc2,KVGetKey,foo15,Z2,)
$(call TestFunc2,TestTagExists,foo15,Z2,1)
$(call TestFunc2,KVIsTagged,foo15,Z2,)
# KVUntagKey(foo15, Z1)
$(call TestFunc2,KVUntagKey,foo15,Z1,)
$(call TestFunc1,MapKeys,foo15,)
$(call TestFunc2,TestKeyExists,foo15,Z1,1)
$(call TestFunc2,KVGetKey,foo15,Z1,)
$(call TestFunc2,TestTagExists,foo15,Z1,0)
# KVUntagKey(foo15, Z2)
$(call TestFunc2,KVUntagKey,foo15,Z2,)
$(call TestFunc1,MapKeys,foo15,)
$(call TestFunc2,TestKeyExists,foo15,Z2,1)
$(call TestFunc2,KVGetKey,foo15,Z2,)
$(call TestFunc2,TestTagExists,foo15,Z2,1)
$(call TestFunc2,KVIsTagged,foo15,Z2,)
# KVSet(foo15, A, 1), KVSet(foo15, B, 2), KVSet(foo15, C, 3), KVDel(foo15, B),
# KVSet(foo15, B, 4)
$(call TestFunc2,KVHas, foo15, A,)
$(call TestFunc3,KVSet, foo15, A, 1)
$(call TestFunc1,MapKeys,foo15, A)
$(call TestFunc2,TestKeyExists,foo15,A,1)
$(call TestFunc2,KVHas, foo15, A,A)
$(call TestFunc2,KVGetKey,foo15,A,1)
$(call TestFunc3,KVSet, foo15, B, 2)
$(call TestFunc1,MapKeys,foo15, A B)
$(call TestFunc2,TestKeyExists,foo15,B,1)
$(call TestFunc2,KVHas, foo15, B,B)
$(call TestFunc2,KVGetKey,foo15,B,2)
$(call TestFunc3,KVSet, foo15, C, 3)
$(call TestFunc1,MapKeys,foo15, A B C)
$(call TestFunc2,TestKeyExists,foo15,C,1)
$(call TestFunc2,KVHas, foo15, C,C)
$(call TestFunc2,KVGetKey,foo15,C,3)
$(call TestFunc2,KVDel,foo15,B,)
$(call TestFunc1,MapKeys,foo15,A C )
$(call TestFunc2,TestKeyExists,foo15,B,1)
$(call TestFunc2,KVHas, foo15, B,)
$(call TestFunc2,KVGetKey,foo15,B,)
$(call TestFunc3,KVSet, foo15, B, 4)
$(call TestFunc1,MapKeys,foo15,A C  B)
$(call TestFunc2,TestKeyExists,foo15,B,1)
$(call TestFunc2,KVHas, foo15, B,B)
$(call TestFunc2,KVGetKey,foo15,B,4)

# KVHide
$(call TestInfo,KVHide)
$(call TestFunc3,KVSet, foo16, G, g,)
$(call TestFunc2,TestKeyExists,foo16,G,1)
$(call TestFunc2,TestTagExists,foo16,G,0)
$(call TestFunc2,KVHide,foo16,G,)
$(call TestFunc2,TestTagExists,foo16,G,1)
$(call TestFunc2,KVIsTagged,foo16,G,1)

# KVIsHidden
$(call TestInfo,KVIsHidden)
$(call TestFunc3,KVSet, foo17, H, h,)
$(call TestFunc2,KVIsHidden, foo17, H,)
$(call TestFunc2,KVHide, foo17, H,)
$(call TestFunc2,KVIsHidden, foo17, H,1)

# KVUnhide
$(call TestInfo,KVUnhide)
$(call TestFunc3,KVSet, foo18, I, i,)
$(call TestFunc2,KVIsHidden, foo18, I,)
$(call TestFunc2,KVHide, foo18, I,)
$(call TestFunc2,KVIsHidden, foo18, I,1)
$(call TestFunc2,KVUnhide, foo18, I,)
$(call TestFunc2,KVIsHidden, foo18, I,)

# KVApply
$(call TestInfo,KVApply)
$(eval result :=)
$(call TestFunc3,KVApply, foo19, TestKVApplyFn, result,)
$(call TestFunc1,TestVarValue,result,)
$(call TestFunc3,KVSet, foo19, X, a,)
$(call TestFunc3,KVSet, foo19, Y, b,)
$(call TestFunc3,KVSet, foo19, Z, c,)
$(call TestFunc2,KVHide, foo19, Y,)
$(call TestFunc3,KVApply, foo19, TestKVApplyFn, result,)
$(call TestFunc1,TestVarValue,result, foo19-X-a foo19-Z-c)

# KVApplyHidden
$(call TestInfo,KVApplyHidden)
$(eval result :=)
$(call TestFunc3,KVApplyHidden, foo20, TestKVApplyFn, result,)
$(call TestFunc1,TestVarValue,result,)
$(call TestFunc3,KVSet, foo20, X, a,)
$(call TestFunc3,KVSet, foo20, Y, b,)
$(call TestFunc3,KVSet, foo20, Z, c,)
$(call TestFunc2,KVHide, foo20, Y,)
$(call TestFunc3,KVApplyHidden, foo20, TestKVApplyFn, result,)
$(call TestFunc1,TestVarValue,result, foo20-Y-b)

# KVApplyAll
$(call TestInfo,KVApplyAll)
$(eval result :=)
$(call TestFunc3,KVApplyAll, foo21, TestKVApplyFn, result,)
$(call TestFunc1,TestVarValue,result,)
$(call TestFunc3,KVSet, foo21, X, a,)
$(call TestFunc3,KVSet, foo21, Y, b,)
$(call TestFunc3,KVSet, foo21, Z, c,)
$(call TestFunc2,KVHide, foo21, Y,)
$(call TestFunc3,KVApplyAll, foo21, TestKVApplyFn, result,)
$(call TestFunc1,TestVarValue,result, foo21-X-a foo21-Y-b foo21-Z-c)

# EvalExpr
$(call TestInfo,EvalExpr)
$(call TestFunc1,EvalExpr,1 + 2,3)
$(call TestAssert,EvalExpr,1.0 + 2.5)

# Reset
$(call TestInfo,Reset)
$(call TestFunc2,Reset, a, 7,)
$(call TestFunc1,Value, a,7)
$(call TestFunc1,Reset, a,)
$(call TestFunc1,Value, a,0)
$(call TestAssert,Reset, x)

# Value
$(call TestInfo,Value)
$(call TestFunc1,Value, a,0)
$(call TestFunc1,Value, b,0)
$(call TestFunc1,Value, c,0)
$(call TestFunc1,Value, d,0)
$(call TestFunc1,Value, e,0)
$(call TestFunc1,Value, f,0)
$(call TestFunc1,Value, g,0)
$(call TestFunc1,Value, h,0)
$(call TestFunc1,Value, i,0)
$(call TestFunc1,Value, j,0)
$(call TestAssert,Value, k)

# IsZero
$(call TestInfo,IsZero)
$(call TestFunc1,IsZero, a,X)
$(call TestFunc2,Reset, a, 1,)
$(call TestFunc1,IsZero, a,)
$(call TestFunc1,Reset, a,)
$(call TestFunc1,IsZero, a,X)
$(call TestAssert,IsZero, k)

# Inc
$(call TestInfo,Inc)
$(call TestFunc1,Reset, a,)
$(call TestFunc1,Value, a,0)
$(call TestFunc1,Inc, a,)
$(call TestFunc1,Value, a,1)
$(call TestFunc1,Inc, a,)
$(call TestFunc1,Value, a,2)
$(call TestAssert,Inc, k)
$(call TestFunc1,Inc, a,)
$(call TestFunc1,Value, a,3)
$(call TestFunc1,Reset, a,)
$(call TestFunc1,Value, a,0)

# Dec
$(call TestInfo,Dec)
$(call TestFunc2,Reset, a, 3,)
$(call TestFunc1,Value, a,3)
$(call TestFunc1,Dec, a,)
$(call TestFunc1,Value, a,2)
$(call TestFunc1,Dec, a,)
$(call TestFunc1,Value, a,1)
$(call TestAssert,Dec, k)
$(call TestFunc1,Value, a,1)
$(call TestFunc1,Dec, a,)
$(call TestFunc1,Value, a,0)
$(call TestFunc1,Dec, a,)
$(call TestFunc1,Value, a,0)
$(call TestFunc1,Dec, a,)
$(call TestFunc1,Value, a,0)
$(call TestFunc2,Reset, a, -2,)
$(call TestFunc1,Value, a,-2)
$(call TestFunc1,Dec, a,)
$(call TestFunc1,Value, a,0)

# Add
$(call TestInfo,Add)
$(call TestFunc2,Add,1,2,3)

# Sub
$(call TestInfo,Sub)
$(call TestFunc2,Sub,2,5,-3)

# Mul
$(call TestInfo,Mul)
$(call TestFunc2,Mul,3,4,12)
$(call TestFunc2,Mul,0,5,0)

# Div
$(call TestInfo,Div)
$(call TestFunc2,Div,14,2,7)
$(call TestFunc2,Div,14,4,3)
$(call TestAssert,Div,14,0)
$(call TestFunc2,Div,0,2,0)
$(call TestFunc2,Div,1,2,0)

# Mod
$(call TestInfo,Mod)
$(call TestFunc2,Mod,1,2,1)
$(call TestFunc2,Mod,12,2,0)
$(call TestFunc2,Mod,25,3,1)
$(call TestFunc2,Mod,0,12,0)
$(call TestAssert,Mod,10,0)

# IfEmpty
$(call TestInfo,IfEmpty)
$(call TestFunc2,IfEmpty, a, b,a)
$(call TestFunc2,IfEmpty, , b,b)
$(call TestFunc2,IfEmpty, , ,)

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
$(call TestFunc1,Run, $(TEST) 0 -ge 1,)
$(call TestFunc2,Equal,$(__mkutils_Run_output),,X)
$(call TestFunc2,Equal,$(__mkutils_Run_exitcode),1,X)
$(call TestFunc1,Run, $(ECHO) "beep beep")
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
