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
/* util.c                                                                     */
/* Just one helper function that generates randomized assembly labels. These  */
/* will be used to label branch/jump targets, and to label string literals.   */
/* These names will never go into the symbol table.                           */
/******************************************************************************/

#include <stdlib.h>
#include <stdio.h>

char *internal_name(){
    int i;
    char *retval = (char*)malloc(sizeof(char)*20);
    sprintf(retval,"__internal_"); // starts with __internal_
    for (i=11;i<20;i++){
        retval[i] = 'a' + (random()%26); // generates a random character from a-z thereafter
    }
    return retval;
}

