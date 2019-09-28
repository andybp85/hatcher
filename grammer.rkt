#lang brag

top : /NL* definition*
definition : [QUALIFIER] ID /NL field+
field : /TAB+ @kvpair /NL*
kvpair : (REGEX | ID) /COLON (@value | /NL field)
value : (STRING | NUMBER | PATH)
