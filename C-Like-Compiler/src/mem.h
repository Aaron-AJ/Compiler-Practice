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
/* mem.h                                                                      */
/* Helper functions for maintaining a linked-list of data values that will    */
/* be used as memory fills in the emitted assembly code. For cc442, these     */
/* will be .stringz directives only, used for string literals in the input    */
/* program.                                                                   */
/******************************************************************************/

#ifndef _MEM_H_
#define _MEM_H_

#include "tnmarch.h"

typedef struct mem_entry_type {
    char * label;

    /* payload */
    char    *svalue;

    struct mem_entry_type * next;
} mem_entry_t;

mem_entry_t * new_mem_entry(char *,char *);
void insert_data(mem_entry_t*);

extern  mem_entry_t *data_list;

#endif
