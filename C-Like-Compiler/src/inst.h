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
/* inst.h                                                                     */
/* Helper functions for maintaining a linked-list of instructions.            */
/******************************************************************************/

#ifndef _INST_H_
#define _INST_H_

#include "tnmarch.h"

// the big booya instruction data type
typedef struct instruction_type{
    char *label; // used when this instruction is the _target_ of a 
                 // branch or jump, NULL otherwise

    int mnemonic;
    int rdest;
    int rsrc1;
    int rsrc2;
    int imm;
    char *tgt; // used by branch and jump intsructions to give the 
               // name of the target, NULL for other instruction types
    
    struct instruction_type * next; // this is a singly-linked list
} instruction_t;

typedef enum {
    EXPR_INT,
    EXPR_STRING,
    EXPR_REF
} expr_type_t;

// used to pass instructions from one expression to another (and 
// factors and other things)
typedef struct expr_result_type {
    int reg;  // the virtual register number that holds the result 
              // value of the instructions in this expression
    expr_type_t type;

    instruction_t *list; // points to the head of instructions
                         // in this expression
} expr_result_t;

// used for function call argument lists, a linked list 
// of expressions. this defines the node type
typedef struct expr_list_type {
    expr_result_t *exp;
    struct expr_list_type *next;
} expr_list_t;

// prototypes, see inst.c for description of arguments
instruction_t * new_instruction(char*, int, int, int, int, int, char*);
expr_result_t * new_expr_result(int, instruction_t*, expr_type_t);
instruction_t * append_inst(instruction_t*, instruction_t*);

// external reference for head pointer to linked list of 
// all instructions of the entire input program
extern  instruction_t *inst_list;

#endif
