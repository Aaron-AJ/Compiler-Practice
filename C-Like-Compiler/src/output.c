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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "tnmarch.h"
#include "output.h"
#include "inst.h"
#include "mem.h"
#include "symtab.h"
#include "pdefs.h"


// formats just one TNM assembly instruction, saves to the 
// char buffer passed in as the first arg (assumed to already 
// have memory allocated)
void sprint_asm(char *buff, instruction_t *inst){
    assert(buff);
    assert(inst);
    switch (inst->mnemonic){
        case ADD_OPCODE:
            sprintf(buff,"add $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case ADDI_OPCODE:
            sprintf(buff,"addi $r%d, $r%d, %d",inst->rdest,inst->rsrc1,inst->imm);
            break;
        case AND_OPCODE:
            sprintf(buff,"and $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case ANDI_OPCODE:
            sprintf(buff,"andi $r%d, $r%d, 0x%x",inst->rdest,inst->rsrc1,inst->imm);
            break;
        case DIV_OPCODE:
            sprintf(buff,"div $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case DIVI_OPCODE:
            sprintf(buff,"divi $r%d, $r%d, %d",inst->rdest,inst->rsrc1,inst->imm);
            break;
        case LA_OPCODE:
            sprintf(buff,"la $r%d, %s",inst->rdest,inst->tgt);
            break;
        case LI_OPCODE:
            sprintf(buff,"li $r%d, 0x%x",inst->rdest,inst->imm);
            break;
        case MULT_OPCODE:
            sprintf(buff,"mult $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case MULTI_OPCODE:
            sprintf(buff,"multi $r%d, $r%d, %d",inst->rdest,inst->rsrc1,inst->imm);
            break;
        case NOP_OPCODE:
            sprintf(buff,"nop");
            break;
        case NOT_OPCODE:
            sprintf(buff,"not $r%d, $r%d",inst->rdest,inst->rsrc1);
            break;
        case OR_OPCODE:
            sprintf(buff,"or $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case ORI_OPCODE:
            sprintf(buff,"ori $r%d, $r%d, 0x%x",inst->rdest,inst->rsrc1,inst->imm);
            break;
        case SLT_OPCODE:
            sprintf(buff,"slt $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case SLTI_OPCODE:
            sprintf(buff,"slti $r%d, $r%d, %d",inst->rdest,inst->rsrc1,inst->imm);
            break;
        case SGT_OPCODE:
            sprintf(buff,"sgt $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case SGTI_OPCODE:
            sprintf(buff,"sgti $r%d, $r%d, %d",inst->rdest,inst->rsrc1,inst->imm);
            break;
        case SLTE_OPCODE:
            sprintf(buff,"slte $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case SLTEI_OPCODE:
            sprintf(buff,"sltei $r%d, $r%d, %d",inst->rdest,inst->rsrc1,inst->imm);
            break;
        case SGTE_OPCODE:
            sprintf(buff,"sgte $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case SGTEI_OPCODE:
            sprintf(buff,"sgtei $r%d, $r%d, %d",inst->rdest,inst->rsrc1,inst->imm);
            break;
        case SEQ_OPCODE:
            sprintf(buff,"seq $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case SEQI_OPCODE:
            sprintf(buff,"seqi $r%d, $r%d, %d",inst->rdest,inst->rsrc1,inst->imm);
            break;
        case SNE_OPCODE:
            sprintf(buff,"sne $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case SNEI_OPCODE:
            sprintf(buff,"snei $r%d, $r%d, %d",inst->rdest,inst->rsrc1,inst->imm);
            break;
        case SLL_OPCODE:
            sprintf(buff,"sll $r%d, $r%d, %d",inst->rdest,inst->rsrc1,inst->imm);
            break;
        case SLLR_OPCODE:
            sprintf(buff,"sllr $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case SRA_OPCODE:
            sprintf(buff,"sra $r%d, $r%d, %d",inst->rdest,inst->rsrc1,inst->imm);
            break;
        case SRAR_OPCODE:
            sprintf(buff,"srar $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case SRL_OPCODE:
            sprintf(buff,"srl $r%d, $r%d, %d",inst->rdest,inst->rsrc1,inst->imm);
            break;
        case SRLR_OPCODE:
            sprintf(buff,"srlr $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case SUB_OPCODE:
            sprintf(buff,"sub $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case XOR_OPCODE:
            sprintf(buff,"xor $r%d, $r%d, $r%d",inst->rdest,inst->rsrc1,inst->rsrc2);
            break;
        case BEQ_OPCODE:
            sprintf(buff,"beq $r%d, $r%d, %s",inst->rsrc1,inst->rsrc2,inst->tgt);
            break;
        case BNE_OPCODE:
            sprintf(buff,"bne $r%d, $r%d, %s",inst->rsrc1,inst->rsrc2,inst->tgt);
            break;
        case J_OPCODE:
            sprintf(buff,"j %s",inst->tgt);
            break;
        case JAL_OPCODE:
            sprintf(buff,"jal %s",inst->tgt);
            break;
        case RET_OPCODE:
            sprintf(buff,"ret"); 
            break;
        case SYSCALL_OPCODE:
            sprintf(buff,"syscall");
            break;
        case LB_OPCODE:
            sprintf(buff,"lb $r%d, %d($r%d)",inst->rdest,inst->imm,inst->rsrc1);
            break;
        case LW_OPCODE:
            sprintf(buff,"lw $r%d, %d($r%d)",inst->rdest,inst->imm,inst->rsrc1);
            break;
        case SB_OPCODE:
            sprintf(buff,"sb $r%d, %d($r%d)",inst->rsrc1,inst->imm,inst->rsrc2);
            break;
        case SW_OPCODE:
            sprintf(buff,"sw $r%d, %d($r%d)",inst->rsrc1,inst->imm,inst->rsrc2);
            break;
        default:
            yyerror("Bad mnemonic when trying to print instruction asm");
            break;
    }
}


// open the output assembly file, whose name was passed in.
// iterate through the lists of instructions and data values. 
// in the case of data values, in cc442, there should only be 
// the string literals from the input program. so, print the 
// .data directive and the starting address of the read-only 
// data segment, 0x00400000, then print the label and assembler 
// directive for each .stringz, followed by the string literal
//
// for instructions, print the .text directive, allocate a buffer, 
// and then call the sprint_asm function to format the assembly 
// and print out
void write_asm(char * file) {
    FILE *fp = fopen(file,"w");
    if (!fp){
        yyerror("Unable to open output file.");
    }

    if (inst_list) fprintf(fp,".text\n");

    // boop the instruction list
    instruction_t *iworking = inst_list;
    while (iworking){
        char buff[100];
        if (iworking->label){
            fprintf(fp,"%s:\n",iworking->label);
        }

        sprint_asm(buff,iworking);
        fprintf(fp, "%s\n", buff);
        
        iworking = iworking->next;
    }

    // yeet the data list
    if (data_list){
        fprintf(fp,"\n# read-only data (string literal values)\n"); 
        fprintf(fp,".data 0x%08x\n",0x00400000); 
    }
    mem_entry_t *dworking = data_list;
    while (dworking) {
        fprintf(fp,"%s: ",dworking->label);
        if (dworking->svalue) fprintf(fp,".stringz \"%s\"\n",dworking->svalue);
        else                  yyerror("found a mem_entry_t node that has no string literal\n");
        dworking = dworking->next;
    }
    fclose(fp);
}
