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
/* inst.c                                                                     */
/* Helper functions for maintaining a linked-list of instructions.            */
/******************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "tnmarch.h"
#include "inst.h"
#include "pdefs.h"

// the head of the list of all cc442 program instructions
instruction_t *inst_list = NULL;

// create a new instruction with the provided mnemonic
//   label: is the label if this instruction should be the target of a branch or jump
//   mnemonic: the XXX_OPCODE for the instruction being created, see tnmarch.h
//   dest: is the destination register number, if needed, 0 otherwise
//   src1: is the first source register number, if needed, 0 otherwise
//   src2: is the second source register number, if needed, 0 otherwise
//   imm: an immediate value, if needed, 0 otherwise
//   target: the label that branches and jumps will use for taken-targets
//       see output.c to see which of these are used when cc442 eventually 
//       emits instructions, based on instruction type
instruction_t * new_instruction(char *label, int mnemonic, int dest, int src1, int src2, int imm, char *target){
    instruction_t * new_inst = (instruction_t*)malloc(sizeof(instruction_t));
    new_inst->label = label;
    new_inst->mnemonic = mnemonic;
    new_inst->rdest = dest;
    new_inst->rsrc1 = src1;
    new_inst->rsrc2 = src2;
    new_inst->imm = imm;
    new_inst->tgt = target;

    new_inst->next = NULL;

    return new_inst;
}

// create a new expression result
//   reg: the destination register number that holds the result value of this expression
//   ilist: the instruction linked-list that calculates this expression
//   type: whether this expression calculates an integer result, a string reference, or array reference
expr_result_t *new_expr_result(int reg, instruction_t *ilist, expr_type_t type){
    expr_result_t *ret = (expr_result_t*) malloc(sizeof(expr_result_t));
    ret->reg = reg;
    ret->type = type;
    ret->list = ilist;
    return ret;
}

// append two linked-lists of instructions into a single list, 
// return the address of the first node in the list. 
//
// four possibilities:
//    - both lists are NULL, empty lists, just return NULL
//    - first list is NULL, second has node(s), just return the second
//    - first list has node(s), second is NULL, just return the first
//    - both have nodes, concatenate into one list first then second, and return the 
//         first node of the appended list (this does not require creating 
//         any new nodes, just link the two lists together)
// this function just concatenates lists, you should not malloc 
// any new nodes
instruction_t *append_inst(instruction_t *first, instruction_t *second){
    if(first == NULL && second == NULL) {
        return NULL;
    } else if(first == NULL) {
        return second;
    } else if(second == NULL) {
        return first;
    } else {
        instruction_t *current = first;
        while(current -> next) {
            current = current -> next;
        }
        current -> next = second;
        return first;
    }
}

