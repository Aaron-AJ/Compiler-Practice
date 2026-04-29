    /******************************************************************************/
    /* cc442: A Sweet C-Like Compiler for CS 442                                  */
    /*                                                                            */
    /* University of Wisconsin-La Crosse                                          */
    /* Department of Computer Science & Computer Engineering                      */
    /* (c) 2023-2025  Elliott Forbes (eforbes@uwlax.edu)                          */
    /*                                                                            */
    /* DO NOT DISTRIBUTE                                                          */
    /*                                                                            */
    /******************************************************************************/
    /* scanner.l                                                                  */
    /* The regular expressions for all of the bits and bobs for the cc442         */
    /* scanner.                                                                   */
    /******************************************************************************/

%option noyywrap yylineno

%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"
#include "tnmarch.h"
#include "symtab.h"

int islocal = 0;
%}

%%

    /* Operators */
\+		{return PLUS;}
\-		{return MINUS;}				
\*		{return MULTIPLY;}
\/		{return DIVIDE;}
=		{return ASSIGN;}
\%		{return MODULUS;}
!		{return LOGICALNOT;} 
~		{return BITWISENOT;}

    /* Code Blocks */
"if"		{return IFKEY;}
"else"		{return ELSEKEY;}
"while"		{return WHILEKEY;}
"do"		{return DOKEY;}

    /* Types */
"int"		{return INTKEY;}
"string"		{return STRKEY;}

    /* Syscalls */
"exit"		{return EXIT;}
"putint"		{return PUTINT;}
"puts"		{return PUTS;}
"getint"		{return GETINT;}
"gets"		{return GETS;}
"malloc"		{return MALLOC;}

"sizeof"      {return SIZEOFKEY;}

    /* Functions */
"void"		{return VOIDKEY;}
"main"		{return MAINKEY;}
"return"	{return RETURNKEY;}


    /* Literals */
[0-9]+			{yylval.ivalue = atoi(yytext); return INTLIT;}
0[xX][0-9a-fA-F]+	{sscanf(yytext,"%x",&(yylval.ivalue)); return INTLIT;}
\"([^\"\\\n]|\\.)*\"	{yylval.string = strndup(&yytext[1],strlen(yytext)-2); return STRINGLIT;} 


    /* Comments */
\/\/.*                           /* no action, just gobble up comments */

    /* Identifiers */
[a-zA-Z][a-zA-Z0-9_]*	{yylval.string = strdup(yytext);return IDENT;}

    /* Delimiter kinds of things */
\{  {
		new_symbol_table();
		islocal++;
		return LBRACE;
	}
\}  {
		pop_sheaf();
		islocal--;
		return RBRACE;
	}
\(	{return LPAREN;}
\)	{return RPAREN;}
:	{return COLON;}
,	{return COMMA;}
;	{return SEMI;}
"&"	{return BITWISEAND;}
"|"	{return BITWISEOR;}
"^"	{return BITWISEXOR;} 
"&&"	{return LOGICALAND;} 
"||"	{return LOGICALOR;} 
"<"	{return LESSTHAN;}
">"	{return GREATERTHAN;}
"<="	{return LESSTHANEQUAL;}
">="	{return GREATERTHANEQUAL;}
"=="	{return EQUALS;}
"!="	{return NOTEQUALS;}
\[	{return LBRACKET;}
\]	{return RBRACKET;}
"<<"	{return BITSHIFTLEFT;}
">>"	{return BITSHIFTRIGHT;}

    /* Misc */
[ \t]+                           /* whitespace -- do nothing */
[\n\r]+                          /* linefeed -- do nothing */
.	{return UNKNOWN;} // catch-all for anything else

%%

