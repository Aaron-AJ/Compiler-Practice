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
/* mem.c                                                                      */
/* Helper functions for maintaining a linked-list of data values that will    */
/* be used as memory fills in the emitted assembly code. For cc442, these     */
/* will be .stringz directives only, used for string literals in the input    */
/* program.                                                                   */
/******************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "tnmarch.h"
#include "mem.h"
#include "pdefs.h"

// the head of the list of values
mem_entry_t *data_list = NULL;

// create a new list node, with the provided payload 
mem_entry_t * new_mem_entry(char *label, char *str){
    mem_entry_t * new_entry = (mem_entry_t *) malloc(sizeof(mem_entry_t));
    new_entry->label = label;
    new_entry->svalue = str;
    new_entry->next = NULL;

    return new_entry;
}

// add a new string to the read-only data section of memory, 
// this always adds the new node to the head of the list
void insert_data(mem_entry_t *data){
    if (data) {
        data->next = data_list;
        data_list = data;
    }
}

