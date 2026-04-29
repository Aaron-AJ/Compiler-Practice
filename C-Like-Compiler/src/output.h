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
/* output.c                                                                   */
/* Writes the assembly syntax of the parsed cc442 program.                    */
/******************************************************************************/

#ifndef _OUTPUT_H_
#define _OUTPUT_H_

#include "inst.h"

void sprint_asm(char *, instruction_t *);
void write_asm(char *);

#endif
