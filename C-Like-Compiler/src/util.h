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
/* util.h                                                                     */
/* Just one helper function that generates randomized assembly labels. These  */
/* will be used to label branch/jump targets, and to label string literals.   */
/* These names will never go into the symbol table.                           */
/******************************************************************************/

#ifndef _UTIL_H_
#define _UTIL_H_

#include "inst.h"
char *internal_name();

#endif
