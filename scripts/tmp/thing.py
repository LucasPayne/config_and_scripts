thing = list("&^ABCB?ADCBAE*CCBBAC!CCDA#AABBAACC/CDBA&DBB*BCA!ADBCABA,DBBB_AACBAACAC@C(BC/ACABBB%BCAB&ACBCAACABB.BCBCAAB.BCBCBAC! DBC!D?")
print(thing)
n = len(thing)
abc = len([c for c in thing if c in list("ABC")])
print(n)
print(abc)
print(abc / n)
