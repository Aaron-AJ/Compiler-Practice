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
/* pdefs.h                                                                    */
/* Just the prototypes and externs of things that are used/called from auto-  */
/* generated code in the scanner and parser.                                  */
/******************************************************************************/

#ifndef _PDEFS_H_
#define _PDEFS_H_

/* declarations for yacc types */
int yylex();
int yyerror(const char *s);
extern void yyrestart(FILE*);

extern int yylineno;

#endif
