// This is another actual C program that you 
// can use to get you started on testing your 
// implementation of the symbol table functions, 
// without relying on the full cc442 compiler.
// This is not an exhaustive test, you should 
// add more tests to ensure your symbol table 
// functions correctly.
//
// to compile: gcc -I../src/ ./symtab_driver.c ../src/symtab.c -o symtab_test
// then run with: ./symtab_test
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

int yyerror(const char *);

int main() {
    int *offset = (int *) malloc(sizeof(int));
		*offset = -8;
    int *payload;
    char *name1 = strdup("variable1");
    char *name2 = strdup("variable2");
		char *name3 = strdup("variable3");
    char *name4 = strdup("variable4");
		char *name5 = strdup("variable5");
    char *name6 = strdup("variable6");
    
		symtab_new(name1, SYMTAB_INTGLOBAL);
    symtab_new(name2, SYMTAB_INTGLOBAL);
		symtab_new(name3, SYMTAB_INTGLOBAL);

    symtab_update(name1, offset);
    payload = (int*) symtab_lookup(name1);

    // should see both variable1 and variable2 printed
    dump_symtab();

    if ((*payload) == -8) printf("pass!\n");
    else          printf("fail\n");

		new_symbol_table();

		int *offset2 = (int *) malloc(sizeof(int));
		*offset2 = -16;

		symtab_new(name1, SYMTAB_INTLOCAL); //create local variable with same name
		symtab_new(name4, SYMTAB_INTLOCAL);
		symtab_update(name3, offset); //update global variable
		symtab_update(name1, offset2); //update local variable
		
		printf("Payload for name1 is %d\n", *(int*) symtab_lookup(name1));
		printf("Payload for name3 is %d\n", *(int*) symtab_lookup(name3));

		dump_symtab();

		pop_sheaf();

		printf("Payload for name1 is %d\n", *(int*) symtab_lookup(name1));
		
		symtab_new(name4, SYMTAB_INTGLOBAL); //reuse name from local variabke
		symtab_new(name5, SYMTAB_INTGLOBAL);
		symtab_new(name6, SYMTAB_INTGLOBAL);

		dump_symtab();

    // the following should error
    symtab_new(name1, SYMTAB_INTGLOBAL);

    return 0;
}

// An implementation of yyerror, some symtab functions 
// will call yyerror, and the implementation is in the 
// cc442 parser (which we don't want with this stand-
// alone symtab test). Notice this implementation won't 
// bomb this driver program out.
int yyerror(const char *s){
    fprintf(stderr,"YYERROR: %s\n",s);
}





