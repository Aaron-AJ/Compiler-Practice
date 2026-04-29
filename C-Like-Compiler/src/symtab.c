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
/* symtab.c                                                                   */
/* Functions to implement the symbol table.                                   */
/******************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "symtab.h"
#include "pdefs.h"

sheaf_t *sheaf = NULL;

// Insert a new symbol table entry with given name and type. 
// This should first check to make sure the name doesn't 
// already exist at the scope determined by entry_type (it's 
// ok to have the same name at different scope once scoping is 
// implemented). Once you're sure the name doesn't already 
// exist, then allocate a new symtab_entry_t, a node in one of 
// the singly-linked lists, based on your indexing function, 
// and link it into the list. If the name already exists, then 
// yyerror out.
void symtab_new(char* name, symtab_type_t entry_type){
    if(sheaf == NULL) {
        new_symbol_table();
    }
    if(search_local(name)){
        int bufsize = strlen(name) + strlen("variable  already exists at current scope") + 1;
        char message[bufsize];
        sprintf(message, "variable %s already exists at current scope", name);
        yyerror(message);
    } else {
        int location = hash(name);

        //need to copy string an dynamically allocate to make sure I can free it later in the free function
        char *dynamic_name = (char *) malloc(sizeof(char) * strlen(name) + 1);
        strcpy(dynamic_name, name);

        symtab_entry_t *new = (symtab_entry_t*) malloc(sizeof(symtab_entry_t));
        new -> name = dynamic_name;
        new -> type = entry_type;
        new -> payload = NULL;
        new -> next = sheaf -> symbol_table[location];
        sheaf -> symbol_table[location] = new;
    }
}

// Update the "payload" associated with a name. The 
// payload is an offset (an int value) for a local 
// variable or a function_t instance if the name is 
// related to a function definition. 
//
// This function should check that the name exists 
// first, and gives a yyerror if the name isn't defined. 
void symtab_update(char* name, void *payload){
    symtab_entry_t *current = search_global(name);
    if(current == NULL) {
        int bufsize = strlen(name) + strlen("Cannot update variable. Variable  does not exist at any scope.") + 1;
        char message[bufsize];
        sprintf(message, "Cannot update variable. Variable %s does not exist at any scope", name);
        yyerror(message);
	return;
    } else {
        current -> payload = payload;
    }
}

// Return the "payload" associated with a name. If 
// the name doesn't exist, then yyerror out.
void *symtab_lookup(char* name){
    symtab_entry_t *current = search_global(name);
    if(current == NULL) {
        int bufsize = strlen(name) + strlen("Cannot find variable payload. Variable  does not exist at any scope") + 1;
        char message[bufsize];
        sprintf(message, "Cannot find variable payload. Variable %s does not exist at any scope", name);
        yyerror(message);
	return NULL;
    }
    return current -> payload;
}

// Return the type (local int variable, vs global int variable, 
// etc) for  a given name. Call yyerror if the name 
// isn't found
symtab_type_t symtab_type(char* name){
    symtab_entry_t *current = search_global(name);
    if(current == NULL) {
        int bufsize = strlen(name) + strlen("Cannot find variable type. Variable  does not exist at any scope") + 1;
        char message[bufsize];
        sprintf(message, "Cannot find variable type. Variable %s does not exist at any scope", name);
        yyerror(message);
    }   
    return current -> type;
}

//returns node or NULL after looking through only current scope (symbol table at top of the sheaf);
symtab_entry_t *search_local(char *name) {
    if (sheaf == NULL) {
        return NULL;
    }
    symtab_entry_t *current = sheaf -> symbol_table[hash(name)];
    while(current){
        if(strcmp(current -> name, name) == 0){
            return current;
        }
        current = current -> next;
    }
    return NULL;
}

//returns node or NULL after looking through all symbol tables starting with most local one
symtab_entry_t *search_global(char *name) {
    sheaf_t *current = sheaf;
    while(current) {
        symtab_entry_t *entry = current -> symbol_table[hash(name)];
        while(entry){
            if(strcmp(entry -> name, name) == 0){
               return entry;
            }
            entry = entry -> next;
        }
        current = current -> next;
    }
    return NULL;
}

// This is just a debugging helper function to just 
// dump the contents of the symbol table to stdout. 
// the main function in the parser has a call to this 
// function, commented out. Uncomment to dump the symbol 
// table after your compiler parses the entire input program.
void dump_symtab(){
    sheaf_t *current = sheaf;
    int j = 1;
    while(current) {
        printf("Printing Symbol Table %d\n", j);
        for(int i = 0; i < SYMTAB_NENTRIES; i++) {
            printf("  ROW %d\n", i);
            symtab_entry_t *entry = current -> symbol_table[i];
            while(entry){
                printf("    Name = %s, Type = %d, Payload Address = %p\n", entry -> name, entry -> type, entry -> payload);
                entry = entry -> next;
            }
        }
        printf("\n\n");
        current = current -> next;
        j++;
    }
}

//"hashes" the key and returns index position into map
int hash(char *name) {
    return name[0] % SYMTAB_NENTRIES;
}

//adds new symbol table to top of the stack (front of the list)
void new_symbol_table() {
    sheaf_t *new = (sheaf_t*) malloc(sizeof(sheaf_t));
    new -> symbol_table = (symtab_entry_t **) malloc(sizeof(symtab_entry_t *) * SYMTAB_NENTRIES);
    for(int i = 0; i < SYMTAB_NENTRIES; i++) {
        new -> symbol_table[i] = NULL;
    }
    new -> next = sheaf;
    sheaf = new;
}

//removes top symbol table from stack when it leaves that scope
void pop_sheaf() {
    if(sheaf == NULL) {
		yyerror("Error. Cannot pop symbol table. No symbol tables in sheaf");
        return;
	}
	sheaf_t *tmp = sheaf;
    sheaf = sheaf -> next;

    for(int i = 0; i < SYMTAB_NENTRIES; i++) {
        symtab_entry_t *entry = tmp -> symbol_table[i];
        symtab_entry_t *prev_entry = NULL;
        while(entry){
            free(entry -> name);
            free(entry -> payload);

            prev_entry = entry;
            entry = entry -> next;
            free(prev_entry);
        }
    }
    free(tmp -> symbol_table);
    free(tmp);
}

//frees all symbol tables at all scopes
void free_sheaf() {
    sheaf_t *current = sheaf;
    sheaf_t *prev = NULL;
    while(current) {
        for(int i = 0; i < SYMTAB_NENTRIES; i++) {
            symtab_entry_t *entry = current -> symbol_table[i];
            symtab_entry_t *prev_entry = NULL;
            while(entry){
                free(entry -> name);
                free(entry -> payload);

                prev_entry = entry;
                entry = entry -> next;
                free(prev_entry);
            }
        }
        prev = current;
        current = current -> next;
        free(prev -> symbol_table);
        free(prev);
    }
}


