#lang brag

top : NL* definition*
definition : ID NL field+
field : TAB+ ID COLON [ID | STRING | NL] [FIELD]
