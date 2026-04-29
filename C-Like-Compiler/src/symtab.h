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
/* symtab.h                                                                   */
/* Functions to implement the symbol table.                                   */
/******************************************************************************/

#ifndef _SYMTAB_H_
#define _SYMTAB_H_

#define SYMTAB_NENTRIES 13

// there's a binary pattern to the symbol table 
// constants, the lowest nybble indicates the 
// data type, and the upper nybble indicates 
// local vs global
#define SYMTAB_ISINT    0x01
#define SYMTAB_ISSTR    0x02
#define SYMTAB_ISARR    0x04
#define SYMTAB_ISFUNC   0x08
#define SYMTAB_ISLOCAL  0x10
#define SYMTAB_ISGLOBAL 0x20

// create the constants actually used by the symbol table 
// to indicate types of each name in the symbol table, 
// these will be combinations of the bit values from 
// above
typedef enum {
    SYMTAB_INTLOCAL    = SYMTAB_ISLOCAL  | SYMTAB_ISINT,
    SYMTAB_STRLOCAL    = SYMTAB_ISLOCAL  | SYMTAB_ISSTR,
    SYMTAB_ARRAYLOCAL  = SYMTAB_ISLOCAL  | SYMTAB_ISARR,
    SYMTAB_INTGLOBAL   = SYMTAB_ISGLOBAL | SYMTAB_ISINT,
    SYMTAB_STRGLOBAL   = SYMTAB_ISGLOBAL | SYMTAB_ISSTR,
    SYMTAB_ARRAYGLOBAL = SYMTAB_ISGLOBAL | SYMTAB_ISARR,
    SYMTAB_FUNC        = SYMTAB_ISGLOBAL | SYMTAB_ISFUNC
} symtab_type_t;

// data type for one symbol table entry, which 
// will be a node in a 1D array of singly-linked 
// lists
typedef struct symtab_entry_type {
    char * name;
    symtab_type_t type;
    void *payload; 
    struct symtab_entry_type * next;
} symtab_entry_t;

// data type that will eventually be used to 
// hold meta-data related to functions
typedef struct function_type {
    int numargs; // the number of args of a function
    symtab_type_t *argtypes; // an array of data types, one for each argument
    char **argnames;
} function_t;

typedef struct args_data_type {
    symtab_type_t argtype;
    char *name;
} args_data_t;

typedef struct sheaf_type {
    symtab_entry_t **symbol_table;
    struct sheaf_type *next;
} sheaf_t;

// prototypes for handling the symbol table, the 
// descriptions of the functions appear in symtab.c
void symtab_new(char*, symtab_type_t);
void symtab_update(char*, void*);
void *symtab_lookup(char*);
symtab_type_t symtab_type(char*);
int hash(char*);
symtab_entry_t *search_local(char*);
symtab_entry_t *search_global(char*);
void dump_symtab();
void new_symbol_table();
void free_sheaf();
void pop_sheaf();


#endif
