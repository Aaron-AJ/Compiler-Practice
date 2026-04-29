// This is an actual C program that can be used as a 
// stand-alone test (i.e. outside of the cc442 compiler) 
// of your implementation of the append_inst() function.
// This driver program is not an exhaustive test, but 
// is intended to just give you ideas on how to test 
// your append_inst() without relying on the full cc442 
// compiler
//
// compile with: gcc -I../src/ append_driver.c ../src/inst.c -o append_test
// and then run with: ./append_test
#include <stdio.h>
#include <stdlib.h>
#include "tnmarch.h"
#include "inst.h"

int yyerror(const char *);

int main() {
    instruction_t *inst1 = new_instruction(NULL, NOP_OPCODE, 0, 0, 0, 0, NULL);
    instruction_t *inst2 = new_instruction(NULL, ADDI_OPCODE, 1, 0, 0, 10, NULL);
    instruction_t *combined;

    combined = append_inst(NULL, inst1);
    if (combined == inst1) printf("pass!\n");
    else                   printf("fail\n");
    inst1->next = NULL;

    combined = append_inst(inst1, NULL);
    if (combined == inst1) printf("pass!\n");
    else                   printf("fail\n");
    inst1->next = NULL;

    combined = append_inst(inst1, inst2);
    if (combined == inst1 && combined->next == inst2) printf("pass!\n");
    else                                              printf("fail\n");

    return 0;
}

// An implementation of yyerror, in case your append_inst calls 
// yyerror for some reason (mine didn't). But we need this since 
// the cc442 parser had the yyerror implementation
int yyerror(const char *s){
    fprintf(stderr,"YYERROR: %s\n",s);
}
