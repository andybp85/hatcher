#lang brag

top : /NL* definition*
definition : [QUALIFIER] ID /NL field+
field : /TAB+ @kvpair /NL*
kvpair : ID /COLON (@value | /NL field)
value : (STRING | NUMBER)
