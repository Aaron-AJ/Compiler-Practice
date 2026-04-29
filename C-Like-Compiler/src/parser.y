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
    /* parser.y                                                                   */
    /* The parser rules and actions for the cc442 parser.                         */
    /*                                                                            */
    /******************************************************************************/


%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "tnmarch.h"
#include "inst.h"
#include "mem.h"
#include "output.h"
#include "symtab.h"
#include "pdefs.h"
#include "util.h"


/* set to 1 to trace the parser when you run cc442 on input program */
#define YYDEBUG 0

/* a variable you can use to access as many virtual regs as you need,
   just remember to vreg++ every time you use another one */
int vreg = 6;

/* a variable you can use to keep track of how many global
   variables there are (to give offsets from the global pointer */
int nglobals = 0;
/* and the locals too */
int nlocals = 0;
extern int yylineno;
extern int islocal;
int isMain = 1;
int nArgs = 0;
int isGlobal = 1;

%}

// the union of possible yylval types and parser types
%union {
    char *string;
    int ivalue;
    struct instruction_type *instr;
    struct expr_result_type *exres;
    struct function_type *arguments;
    struct args_data_type *arg_data;
    struct expr_list_type *params;
}


// scanner tokens (terminals)
%token IFKEY WHILEKEY DOKEY
%token SEMI

%token INTKEY STRKEY
%token EXIT PUTINT PUTS GETINT GETS MALLOC

%token PLUS MINUS MULTIPLY DIVIDE
%token ASSIGN

%token <string> IDENT
%token <ivalue> INTLIT
%token <string> STRINGLIT

%token LBRACE RBRACE
%token LPAREN RPAREN
%token COLON COMMA
%token LBRACKET RBRACKET

%token LOGICALAND LOGICALOR LOGICALNOT
%token BITWISEAND BITWISEOR BITWISEXOR BITWISENOT
%token LESSTHAN GREATERTHAN LESSTHANEQUAL GREATERTHANEQUAL EQUALS

%token SIZEOFKEY

%token ELSEKEY
%token MODULUS
%token NOTEQUALS
%token BITSHIFTLEFT BITSHIFTRIGHT
%token VOIDKEY MAINKEY RETURNKEY
%token UNKNOWN

// parser non-terminals
%type <exres> logic_or logic_and bit_or bit_xor bit_and eq relation bit_shift value factor term expr call
%type <instr> statement sequence block function_main fun function
%type <arguments> args arglist
%type <arg_data> arg
%type <params> calls call_list
%type dec declarations
%type prog

%%

// top-level of a cc442 program:
prog: declarations {isGlobal = 0;} function_main fun {
        instruction_t *combined = append_inst($3, $4);
        inst_list = combined;
    };

declarations: dec declarations {
}
|;

// add names to symbol table. int and string
// variables are global for now, need to
// differentiate once functions are implemented
dec: INTKEY IDENT SEMI {
        if(islocal) {
            symtab_new($2, SYMTAB_INTLOCAL);
            int *offset = (int*) malloc(sizeof(int));
            if(isMain) {
                *offset = nlocals * 4;
            } else {
                *offset = (nlocals + 1 + nArgs) * 4;
            }
            nlocals++;
            symtab_update($2,offset);
        } else {
            symtab_new($2, SYMTAB_INTGLOBAL);
            int *offset = (int*) malloc(sizeof(int));
            *offset = nglobals * 4;
            nglobals++;
            symtab_update($2,offset);
        }
    }
    | STRKEY IDENT SEMI {
        if(islocal) {
            symtab_new($2, SYMTAB_STRLOCAL);
            int *offset = (int*) malloc(sizeof(int));
            if(isMain) {
                *offset = nlocals * 4;
            } else {
                *offset = (nlocals + 1 + nArgs) * 4;
            }
            nlocals++;
            symtab_update($2,offset);
        } else {
            symtab_new($2, SYMTAB_STRGLOBAL);
            int *offset = (int*) malloc(sizeof(int));
            *offset = nglobals * 4;
            nglobals++;
            symtab_update($2,offset);
        }
    }
    | INTKEY IDENT LBRACKET RBRACKET SEMI {
        if(islocal) {
            symtab_new($2, SYMTAB_ARRAYLOCAL);
            int *offset = (int*) malloc(sizeof(int));
            if(isMain) {
                *offset = nlocals * 4;
            } else {
                *offset = (nlocals + 1 + nArgs) * 4;
            }
            nlocals++;
            symtab_update($2,offset);
        } else {
            symtab_new($2, SYMTAB_ARRAYGLOBAL);
            int *offset = (int*) malloc(sizeof(int));
            *offset = nglobals * 4;
            nglobals++;
            symtab_update($2,offset);
        }
    }
    | INTKEY IDENT LPAREN args RPAREN SEMI {
        if(!isGlobal) {
            yyerror("Cannot declare functions here");
        }

        symtab_new($2, SYMTAB_FUNC);
        symtab_update($2, $4);
    };

fun: function fun {
        $$ = append_inst($1, $2);
    }
    | {
        $$ = NULL;
    };

function_main: VOIDKEY MAINKEY LPAREN RPAREN LBRACE block RBRACE {
        // generate the exit system call and add to
        // tail of list of instructions
        instruction_t *push_stack = new_instruction(NULL, ADDI_OPCODE, REG_SP, REG_SP, 0, -nlocals* 4, NULL);
        instruction_t *pop_stack = new_instruction(NULL, ADDI_OPCODE, REG_SP, REG_SP, 0, nlocals * 4, NULL);
        instruction_t *syscode = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, SYSCALL_EXIT, NULL);
        instruction_t *arg = new_instruction(NULL, SW_OPCODE, 0, syscode->rdest, REG_SP, 0, NULL);
        instruction_t *sysc = new_instruction(NULL, SYSCALL_OPCODE, 0, 0, 0, 0, NULL);
        instruction_t *combined;
        combined = append_inst(push_stack, $6);
        combined = append_inst(combined, pop_stack);
        combined = append_inst(combined, syscode);
        combined = append_inst(combined, arg);
        combined = append_inst(combined, sysc);

        nlocals = 0;
        isMain = 0;

        $$ = combined;
    };

function: INTKEY IDENT LPAREN args RPAREN LBRACE {
            function_t *check = (function_t*) symtab_lookup($2);
            int numargs_check = check -> numargs;
            symtab_type_t *a_check = check -> argtypes;

            int numargs = $4 -> numargs;
            if(numargs != numargs_check) {
                yyerror("Missing arguments");
            }
            symtab_type_t *a = $4 -> argtypes;
            char **names = $4 -> argnames;
            for(int i = 0; i < numargs; i++) {
                if(a[i] != a_check[i]) {
                    int len = snprintf(NULL, 0, "Inproper argument type in position %d", i);
                    char *buf = malloc(len + 1);

                    snprintf(buf, len + 1, "Inproper argument type in position %d", i);
                    yyerror(buf);
                }
                symtab_new(names[i], a[i]);
                int *offset = (int *) malloc(sizeof(int));
                *offset = i * 4;
                symtab_update(names[i], offset);
            }
            nArgs = numargs;
        } block RBRACE {

        int framesize = (nArgs + 1 + nlocals) * 4;
        int ra_offset = nArgs * 4;

        instruction_t *store_ra = new_instruction(NULL, SW_OPCODE, 0, REG_RA, REG_FP, -ra_offset, NULL);
        instruction_t *load_ra = new_instruction(NULL, LW_OPCODE, REG_RA, REG_FP, 0, -ra_offset, NULL);
        instruction_t *push_stack = new_instruction(NULL, ADDI_OPCODE, REG_SP, REG_SP, 0, -framesize, NULL);
        instruction_t *pop_stack = new_instruction(NULL, ADDI_OPCODE, REG_SP, REG_SP, 0, framesize, NULL);
        instruction_t *nop = new_instruction($2,NOP_OPCODE,0,0,0,0,NULL);
        instruction_t *ret = new_instruction(NULL, RET_OPCODE, 0,0,0,0,NULL);

        instruction_t *combined = append_inst(nop, push_stack);
        combined = append_inst(combined, store_ra);

        combined = append_inst(combined, $8);

        combined = append_inst(combined, load_ra);
        combined = append_inst(combined, pop_stack);
        combined = append_inst(combined, ret);

        nlocals = 0;
        nArgs = 0;

        $$ = combined;
    };

//arguments are in a reversed list
args: arg arglist {
        function_t *f;
        if ($2 == NULL) {
            f = (function_t*) malloc(sizeof(function_t));
            f->numargs = 1;
            f->argtypes = (symtab_type_t*) malloc(sizeof(symtab_type_t));
            f->argtypes[0] = $1 -> argtype;
            f->argnames = (char**) malloc(sizeof(char*));
            f->argnames[0] = $1 -> name;
        } else {
            f = $2;
            f->numargs++;
            f->argtypes = realloc(f->argtypes, f->numargs * sizeof(symtab_type_t));
            f->argtypes[f->numargs - 1] = $1 -> argtype;
            f->argnames = realloc(f->argnames, sizeof(char*) * f->numargs);
            f->argnames[f->numargs - 1] = $1 -> name;
        }

        $$ = f;
    }
	| {
        function_t *f = malloc(sizeof(function_t));
        f->numargs = 0;
        f->argtypes = NULL;
        $$ = f;
    };

arg: STRKEY IDENT{
        args_data_t *data = (args_data_t*) malloc(sizeof(args_data_t));
        data -> name = $2;
        data -> argtype = SYMTAB_STRLOCAL;
        $$ = data;
    }
    | INTKEY IDENT{
        args_data_t *data = (args_data_t*) malloc(sizeof(args_data_t));
        data -> name = $2;
        data -> argtype = SYMTAB_INTLOCAL;
        $$ = data;
    }
    | INTKEY IDENT LBRACKET RBRACKET {
        args_data_t *data = (args_data_t*) malloc(sizeof(args_data_t));
        data -> name = $2;
        data -> argtype = SYMTAB_ARRAYLOCAL;
        $$ = data;
    };

arglist: COMMA arg arglist {
        function_t *f;
        if ($3 == NULL) {
            f = (function_t*) malloc(sizeof(function_t));
            f->numargs = 1;
            f->argtypes = (symtab_type_t*) malloc(sizeof(symtab_type_t));
            f->argtypes[0] = $2 -> argtype;
            f->argnames = (char**) malloc(sizeof(char*));
            f->argnames[0] = $2 -> name;
        } else {
            f = $3;
            f->numargs++;
            f->argtypes = realloc(f->argtypes, f->numargs * sizeof(symtab_type_t));
            f->argtypes[f->numargs - 1] = $2 -> argtype;
            f->argnames = realloc(f->argnames, sizeof(char*) * f->numargs);
            f->argnames[f->numargs - 1] = $2 -> name;
        }

        $$ = f;
    }
    | {
        $$ = NULL;
    };

block: declarations sequence {
    $$ = $2;
    };


// gather statement lists and concatenate when needed
sequence: statement sequence {
        $$ = append_inst($1,$2);
    }
    | {
        $$ = NULL;
    };

// statements don't produce a value in a register, they
// are either assignments (save to memory), code blocks
// for control flow, or print system calls
statement: PUTINT LPAREN logic_or RPAREN SEMI {
	    if($3 -> type != EXPR_INT) {
            yyerror("cannot use putint to print non-integer variable.");
        }
        instruction_t *syscode = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, SYSCALL_PRINT_INT, NULL);
        instruction_t *pushsys = new_instruction(NULL, SW_OPCODE, 0, syscode->rdest, REG_SP, 0, NULL);
        instruction_t *pushval = new_instruction(NULL, SW_OPCODE, 0, $3->reg, REG_SP, -4, NULL);
        instruction_t *sysc = new_instruction(NULL, SYSCALL_OPCODE, 0, 0, 0, 0, NULL);
        instruction_t *combined;
        combined = append_inst($3->list,syscode);
        combined = append_inst(combined,pushsys);
        combined = append_inst(combined,pushval);
        combined = append_inst(combined,sysc);
        free($3);
        $$ = combined;
    }
    | PUTS LPAREN logic_or RPAREN SEMI {
        if($3 -> type != EXPR_STRING) {
            yyerror("cannot use puts to print non-string variable.");
        }
        instruction_t *syscode = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, SYSCALL_PRINT_STRING, NULL);
        instruction_t *pushsys = new_instruction(NULL, SW_OPCODE, 0, syscode->rdest, REG_SP, 0, NULL);
        instruction_t *pushval = new_instruction(NULL, SW_OPCODE, 0, $3->reg, REG_SP, -4, NULL);
        instruction_t *sysc = new_instruction(NULL, SYSCALL_OPCODE, 0, 0, 0, 0, NULL);
        instruction_t *combined;
        combined = append_inst($3->list,syscode);
        combined = append_inst(combined,pushsys);
        combined = append_inst(combined,pushval);
        combined = append_inst(combined,sysc);
        free($3);
        $$ = combined;
    }
    | IDENT ASSIGN logic_or SEMI {
        symtab_type_t st = symtab_type($1);
        expr_type_t type = $3 -> type;
        if((st == SYMTAB_INTLOCAL || st == SYMTAB_INTGLOBAL) && type != EXPR_INT) {
            yyerror("cannot assign non-int expression to integer variable.");
        }
        if((st == SYMTAB_STRLOCAL || st == SYMTAB_STRGLOBAL) && (type != EXPR_STRING && type != EXPR_REF)) {
		    yyerror("cannot assign non-string expression to string variable.");
        }
        if((st == SYMTAB_ARRAYLOCAL || st == SYMTAB_ARRAYGLOBAL) && type != EXPR_REF) {
            yyerror("cannot assign non-array expression to array variable.");
        }
        if(st == SYMTAB_FUNC) {
            yyerror("Why are you trying to do that.");
        }

        if(st == SYMTAB_ARRAYGLOBAL || st == SYMTAB_INTGLOBAL || st == SYMTAB_STRGLOBAL ) {
            int *offset = symtab_lookup($1);
            instruction_t *first = $3->list;
            instruction_t *store = new_instruction(NULL, SW_OPCODE, 0, $3->reg, REG_GP, (*offset), NULL);
            instruction_t *combined;
            combined = append_inst(first,store);
            free($3);
            $$ = combined;
        } else {
            int *offset = symtab_lookup($1);
            instruction_t *first = $3->list;
            instruction_t *store = new_instruction(NULL, SW_OPCODE, 0, $3->reg, REG_FP, -(*offset), NULL);
            instruction_t *combined;
            combined = append_inst(first,store);
            free($3);
            $$ = combined;
        }
    }
    | EXIT LPAREN RPAREN SEMI {
        /*exit(); hehe*/
        instruction_t *syscode = new_instruction(NULL,LI_OPCODE,vreg++,0,0,SYSCALL_EXIT,NULL);
        instruction_t *pushsys = new_instruction(NULL,SW_OPCODE,0,syscode->rdest,REG_SP,0,NULL);
        instruction_t *sysc = new_instruction(NULL,SYSCALL_OPCODE,0,0,0,0,NULL);
        instruction_t *combined = append_inst(syscode,pushsys);
        combined = append_inst(combined,sysc);
        $$ = combined;
    }
    | IFKEY LPAREN logic_or RPAREN LBRACE block RBRACE {
	 if ($3 -> type != EXPR_INT) {
		yyerror("if condition must be an int expression");
	 }
         instruction_t *branch = new_instruction(NULL, BEQ_OPCODE, 0, $3->reg, REG_ZERO, 0, internal_name());
         instruction_t *target = new_instruction(branch->tgt, NOP_OPCODE, 0, 0, 0, 0, NULL);
         instruction_t *combined = append_inst($3->list, branch);
         combined = append_inst(combined, $6);
         combined = append_inst(combined, target);
         free($3);
         $$ = combined;
    }
    /* if (cond) { then } else { els } */
    | IFKEY LPAREN logic_or RPAREN LBRACE block RBRACE ELSEKEY LBRACE block RBRACE
    {
	/* require integer condition */
	if ($3->type != EXPR_INT) {
	yyerror("if condition must be an integer expression");
	}

	/* branch to ELSE when cond == 0 */
	instruction_t *bFalse = new_instruction(NULL,BEQ_OPCODE,0,$3->reg,REG_ZERO,0,internal_name());
	/* jump over ELSE to END after THEN finishes */
	instruction_t *jEnd = new_instruction(NULL,J_OPCODE,0,0,0,0,internal_name());
	/* place ELSE label at bFalse->tgt, END label at jEnd->tgt */
	instruction_t *elseLab = new_instruction(bFalse->tgt,NOP_OPCODE,0,0,0,0,NULL);
	instruction_t *endLab = new_instruction(jEnd->tgt,NOP_OPCODE,0,0,0,0,NULL);

	instruction_t *combined = append_inst($3->list,bFalse);  /* evaluate cond, branch to ELSE if false */
	combined = append_inst(combined,$6);                      /* THEN block */
	combined = append_inst(combined,jEnd);                    /* jump to END */
	combined = append_inst(combined,elseLab);                 /* ELSE: */
	combined = append_inst(combined,$10);                     /* ELSE block */
	combined = append_inst(combined,endLab);                  /* END: */

	free($3);
	$$ = combined; 
    }
    | WHILEKEY LPAREN logic_or RPAREN LBRACE block RBRACE
    {
        if ($3->type != EXPR_INT) {
            yyerror("while condition must be an integer expression");
        }

        /* jump back to this lable */
        char *Ltop = internal_name();

        /* loop top */
        instruction_t *topLab = new_instruction(Ltop, NOP_OPCODE, 0, 0, 0, 0, NULL);

        /* branc when cond == 0 */
        instruction_t *bFalse = new_instruction(NULL, BEQ_OPCODE, 0, $3->reg, REG_ZERO, 0, internal_name());

        /* unconditional jump back to TOP */
        instruction_t *jTop = new_instruction(NULL, J_OPCODE, 0, 0, 0, 0, Ltop);

        /* labeled NOP for Lend (use target in bFalse) */
        instruction_t *endLab = new_instruction(bFalse->tgt, NOP_OPCODE, 0, 0, 0, 0, NULL);

        /* TOP yo cond to beq to BODY to jTOP to Lend */
        instruction_t *combined = append_inst(topLab, $3->list);
        combined = append_inst(combined, bFalse);
        combined = append_inst(combined, $6);
        combined = append_inst(combined, jTop);
        combined = append_inst(combined, endLab);

        free($3);
        $$ = combined;
    }
    | DOKEY LBRACE block RBRACE WHILEKEY LPAREN logic_or RPAREN SEMI
    {
        if ($7->type != EXPR_INT) {
            yyerror("do-while condition must be an integer expression");
        }

        /* TOP label for start of BODY */
        char *Ltop = internal_name();
        instruction_t *topLab = new_instruction(Ltop, NOP_OPCODE, 0, 0, 0, 0, NULL);

        /* branch back to TOP while cond != 0 */
        instruction_t *bTrue = new_instruction(NULL, BNE_OPCODE, 0, $7->reg, REG_ZERO, 0, Ltop);

        /* TOP to BODY to cond to bne TOP */
        instruction_t *combined = append_inst(topLab, $3);
        combined = append_inst(combined, $7->list);
        combined = append_inst(combined, bTrue);

        free($7);
        $$ = combined;
    }
    | IDENT LBRACKET logic_or RBRACKET ASSIGN logic_or SEMI{
        int *offset = (int *) symtab_lookup($1);
        symtab_type_t type = symtab_type($1);
        if($3 -> type != EXPR_INT) {
            yyerror("Must use an integer to access an array");
        }
        if($6 -> type != EXPR_INT) {
            yyerror("Cannot add non integer values to an array");
        }
        if(type == SYMTAB_ARRAYGLOBAL) {
            instruction_t *get_address = new_instruction(NULL, LW_OPCODE, vreg++, REG_GP, 0, (*offset), NULL);
            instruction_t *calc_offset = new_instruction(NULL, MULTI_OPCODE, vreg++, $3->reg, 0, 4, NULL);
            instruction_t *location = new_instruction(NULL, ADD_OPCODE, vreg++, get_address->rdest, calc_offset->rdest, 0, NULL);
            instruction_t *nop = new_instruction(NULL, NOP_OPCODE, 0, 0, 0, 0, NULL);
            instruction_t *store_value = new_instruction(NULL, SW_OPCODE, 0, $6->reg, location->rdest, 0, NULL);

            instruction_t *combined = append_inst($3->list, get_address);
            combined = append_inst(combined, $6->list);
            combined = append_inst(combined, calc_offset);
            combined = append_inst(combined, location);
            combined = append_inst(combined, nop);
            combined = append_inst(combined, store_value);

            free($3);
            free($6);
            $$ = combined;
        } else if (type == SYMTAB_ARRAYLOCAL) {
            instruction_t *get_address = new_instruction(NULL, LW_OPCODE, vreg++, REG_FP, 0, -(*offset), NULL);
            instruction_t *calc_offset = new_instruction(NULL, MULTI_OPCODE, vreg++, $3->reg, 0, 4, NULL);
            instruction_t *location = new_instruction(NULL, ADD_OPCODE, vreg++, get_address->rdest, calc_offset->rdest, 0, NULL);
            instruction_t *nop = new_instruction(NULL, NOP_OPCODE, 0, 0, 0, 0, NULL);
            instruction_t *store_value = new_instruction(NULL, SW_OPCODE, 0, $6->reg, location->rdest, 0, NULL);

            instruction_t *combined = append_inst($3->list, get_address);
            combined = append_inst(combined, $6->list);
            combined = append_inst(combined, calc_offset);
            combined = append_inst(combined, location);
            combined = append_inst(combined, nop);
            combined = append_inst(combined, store_value);

            free($3);
            free($6);
            $$ = combined;
        } else {
            yyerror("Cannot do array ops on non-array variable");
        }
    }
    | RETURNKEY logic_or SEMI {
        if($2->type != EXPR_INT) {
            yyerror("Can only return int values");
        }
        int ra_offset = nArgs * 4;
        int framesize = (nArgs + 1 + nlocals) * 4;

        instruction_t *into_v0 = new_instruction(NULL, ADDI_OPCODE, REG_V0, $2->reg, 0, 0, NULL);
        instruction_t *ret = new_instruction(NULL, RET_OPCODE, 0,0,0,0,NULL);
        instruction_t *load_ra = new_instruction(NULL, LW_OPCODE, REG_RA, REG_FP, 0, -ra_offset, NULL);
        instruction_t *pop_stack = new_instruction(NULL, ADDI_OPCODE, REG_SP, REG_SP, 0, framesize, NULL);
        instruction_t *combined = append_inst($2->list, into_v0);
        combined = append_inst(combined, load_ra);
        combined = append_inst(combined, pop_stack);
        combined = append_inst(combined, ret);
        $$ = combined;
    };

logic_or
  : logic_or LOGICALOR logic_and {
      if ($1->type != EXPR_INT || $3->type != EXPR_INT) {
        yyerror("logical || needs integer operands");
      }
      /*normalize both sides to 0/1*/
      instruction_t *n1 = new_instruction(NULL, SNE_OPCODE,  vreg++, $1->reg, REG_ZERO, 0, NULL);
      instruction_t *n2 = new_instruction(NULL, SNE_OPCODE,  vreg++, $3->reg, REG_ZERO, 0, NULL);
      /*boolean or*/
      instruction_t *or_inst= new_instruction(NULL, OR_OPCODE,  vreg++, n1->rdest, n2->rdest, 0, NULL);

      instruction_t *combined = append_inst($1->list, $3->list);
      combined = append_inst(combined, n1);
      combined = append_inst(combined, n2);
      combined = append_inst(combined, or_inst);
      free($1); 
      free($3);
      $$ = new_expr_result(or_inst->rdest, combined, EXPR_INT);
    }
  | logic_and {
      $$ = $1;
    };

logic_and
  : logic_and LOGICALAND bit_or {
      if ($1->type != EXPR_INT || $3->type != EXPR_INT) {
        yyerror("logical && needs integer operands");
      }
      /*normalise both sides to 0/1*/ 
      instruction_t *n1 = new_instruction(NULL, SNE_OPCODE,  vreg++, $1->reg, REG_ZERO, 0, NULL);
      instruction_t *n2 = new_instruction(NULL, SNE_OPCODE,  vreg++, $3->reg, REG_ZERO, 0, NULL);
      /*boolean and*/
      instruction_t *and_inst = new_instruction(NULL, AND_OPCODE, vreg++, n1->rdest, n2->rdest, 0, NULL);

      instruction_t *combined = append_inst($1->list, $3->list);
      combined = append_inst(combined, n1);
      combined = append_inst(combined, n2);
      combined = append_inst(combined, and_inst);
      free($1); 
      free($3);
      $$ = new_expr_result(and_inst->rdest, combined, EXPR_INT);
    }
  | bit_or {
      $$ = $1;
    };


bit_or: bit_or BITWISEOR bit_xor {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *bitor_inst = new_instruction(NULL, OR_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined;
        combined = append_inst(first, second);
        combined = append_inst(combined, bitor_inst);

        free($1);
        free($3);
        $$ = new_expr_result(bitor_inst->rdest, combined,EXPR_INT);
    }
    | bit_xor {
        $$ = $1;
    };

bit_xor: bit_xor BITWISEXOR bit_and {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *bitxor_inst = new_instruction(NULL, XOR_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined;
        combined = append_inst(first, second);
        combined = append_inst(combined, bitxor_inst);

        free($1);
        free($3);
        $$ = new_expr_result(bitxor_inst->rdest, combined, EXPR_INT);
    }
    | bit_and {
        $$ = $1;
    };

bit_and: bit_and BITWISEAND eq {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *bitand_inst = new_instruction(NULL, AND_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined;
        combined = append_inst(first, second);
        combined = append_inst(combined, bitand_inst);

        free($1);
        free($3);
        $$ = new_expr_result(bitand_inst->rdest, combined,EXPR_INT);
    }
    | eq {
        $$ = $1;
    };

eq: eq EQUALS relation {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *eq_inst = new_instruction(NULL, SEQ_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined;
        combined = append_inst(first, second);
        combined = append_inst(combined, eq_inst);

        free($1);
        free($3);
        $$ = new_expr_result(eq_inst->rdest, combined,EXPR_INT);
    }
    | eq NOTEQUALS relation {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *neq_inst = new_instruction(NULL, SNE_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined;
        combined = append_inst(first, second);
        combined = append_inst(combined, neq_inst);

        free($1);
        free($3);
        $$ = new_expr_result(neq_inst->rdest, combined,EXPR_INT);
    }
    | relation {
        $$ = $1;
    };

relation: relation LESSTHAN bit_shift {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *lt_inst = new_instruction(NULL, SLT_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined;
        combined = append_inst(first, second);
        combined = append_inst(combined, lt_inst);

        free($1);
        free($3);
        $$ = new_expr_result(lt_inst->rdest, combined,EXPR_INT);
    }
    | relation LESSTHANEQUAL bit_shift {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *lte_inst = new_instruction(NULL, SLTE_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined;
        combined = append_inst(first, second);
        combined = append_inst(combined, lte_inst);

        free($1);
        free($3);
        $$ = new_expr_result(lte_inst->rdest, combined,EXPR_INT);
    }
    | relation GREATERTHAN bit_shift {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *gt_inst = new_instruction(NULL, SGT_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined;
        combined = append_inst(first, second);
        combined = append_inst(combined, gt_inst);

        free($1);
        free($3);
        $$ = new_expr_result(gt_inst->rdest, combined,EXPR_INT);
    }
    | relation GREATERTHANEQUAL bit_shift {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *gte_inst = new_instruction(NULL, SGTE_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined;
        combined = append_inst(first, second);
        combined = append_inst(combined, gte_inst);

        free($1);
        free($3);
        $$ = new_expr_result(gte_inst->rdest, combined,EXPR_INT);
    }
    | bit_shift {
        $$ = $1;
    };

bit_shift: bit_shift BITSHIFTLEFT expr {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *bitleft_inst = new_instruction(NULL, SLLR_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined;
        combined = append_inst(first, second);
        combined = append_inst(combined, bitleft_inst);

        free($1);
        free($3);
        $$ = new_expr_result(bitleft_inst->rdest, combined,EXPR_INT);
    }
    | bit_shift BITSHIFTRIGHT expr {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *bitright_inst = new_instruction(NULL, SRAR_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined;
        combined = append_inst(first, second);
        combined = append_inst(combined, bitright_inst);

        free($1);
        free($3);
        $$ = new_expr_result(bitright_inst->rdest, combined,EXPR_INT);
    }
    | expr {
        $$ = $1;
    };

// expressions, terms, and factors will have sequences of
// instructions that produce a value in a register, thus
// use an expr_result_t to pass up to statements
expr: expr PLUS term {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *add_inst = new_instruction(NULL, ADD_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined;
        combined = append_inst(first, second);
        combined = append_inst(combined, add_inst);

        free($1);
        free($3);
        $$ = new_expr_result(add_inst->rdest, combined,EXPR_INT);
    }
    | expr MINUS term {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *sub_inst = new_instruction(NULL,SUB_OPCODE,vreg++,$1->reg,$3->reg,0,NULL);
        instruction_t *combined = append_inst(first,second);
        combined = append_inst(combined,sub_inst);

        free($1);
        free($3);
        $$ = new_expr_result(sub_inst->rdest,combined,EXPR_INT);

    }
    | term {
        $$ = $1;
    };

// higher in precedence than expr
term: term MULTIPLY factor {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *mult_inst = new_instruction(NULL, MULT_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined;
        combined = append_inst(first, second);
        combined = append_inst(combined, mult_inst);

        free($1);
        free($3);
        $$ = new_expr_result(mult_inst->rdest, combined, EXPR_INT);
    }
	| term DIVIDE factor {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
		instruction_t *first = $1->list;
		instruction_t *second = $3->list;
		instruction_t *div_inst = new_instruction(NULL,DIV_OPCODE,vreg++,$1->reg,$3->reg,0,NULL);
		instruction_t *combined = append_inst(first,second);
		combined = append_inst(combined,div_inst);
		free($1);
		free($3);
		$$ = new_expr_result(div_inst->rdest,combined,EXPR_INT);
	}
	| term MODULUS factor {
        if(($1 -> type != EXPR_INT) || ($3 -> type != EXPR_INT)) {
            yyerror("cannot use string variable in expressions.");
        }
		// q = a/b
		instruction_t *first = $1->list;
		instruction_t *second = $3->list;
		instruction_t *q = new_instruction(NULL,DIV_OPCODE,vreg++,$1->reg,$3->reg,0,NULL);
		// p = q*b
		instruction_t *p = new_instruction(NULL,MULT_OPCODE,vreg++,q->rdest,$3->reg,0,NULL);
		// r = a-p -> a%b
		instruction_t *r = new_instruction(NULL,SUB_OPCODE,vreg++,$1->reg,p->rdest,0,NULL);
		instruction_t *combined = append_inst(first,second);
		combined = append_inst(combined,q);
		combined = append_inst(combined,p);
		combined = append_inst(combined,r);
		free($1);
		free($3);
		$$ = new_expr_result(r->rdest,combined,EXPR_INT);
    }
    | factor {
        $$ = $1;
    };

factor: LPAREN logic_or RPAREN {
        if($2 -> type != EXPR_INT) {
            yyerror("cannot use string variable in expressions.");
        }
		$$ = $2;
	  }
      | LOGICALNOT factor {
        if ($2->type != EXPR_INT) yyerror("logical ! needs an integer operand");
        /* !x → 1 iff x == 0 */
        instruction_t *not_inst = new_instruction(NULL, SEQ_OPCODE, vreg++, $2->reg, REG_ZERO, 0, NULL);
        instruction_t *combined = append_inst($2->list, not_inst);
        free($2);
        $$ = new_expr_result(not_inst->rdest, combined, EXPR_INT);
    }
	  | MINUS factor {
        if($2 -> type != EXPR_INT) {
            yyerror("cannot use string variable in expressions.");
        }
		instruction_t *neg = new_instruction(NULL,SUB_OPCODE,vreg++,REG_ZERO,$2->reg,0,NULL);
		instruction_t *combined = append_inst($2->list,neg);
		free($2);
		$$ = new_expr_result(neg->rdest,combined,EXPR_INT);
	  }
	  | BITWISENOT value {
        if($2 -> type != EXPR_INT) {
            yyerror("cannot use string variable in expressions.");
        }
        instruction_t *bitnot = new_instruction(NULL,NOT_OPCODE,vreg++,$2->reg,0,0,NULL);
		instruction_t *combined = append_inst($2->list,bitnot);
		free($2);
		$$ = new_expr_result(bitnot->rdest,combined,EXPR_INT);
	  }
	  | value {
		$$ = $1;
	  };

value: INTLIT {
        instruction_t * inst = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, $1, NULL);
        $$ = new_expr_result(inst->rdest, inst, EXPR_INT);
    }
    | STRINGLIT {
        mem_entry_t *data = new_mem_entry(internal_name(),$1);
        instruction_t *inst = new_instruction(NULL, LA_OPCODE, vreg++, 0, 0, 0, data->label);
        insert_data(data);
        $$ = new_expr_result(inst->rdest, inst, EXPR_STRING);
    }
    | GETINT LPAREN RPAREN {
        instruction_t *syscode = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, SYSCALL_READ_INT, NULL);
        instruction_t *pushsys = new_instruction(NULL, SW_OPCODE, 0, syscode->rdest, REG_SP, 0, NULL);
        instruction_t *syscall = new_instruction(NULL, SYSCALL_OPCODE, 0, 0, 0, 0, NULL);
        instruction_t *move = new_instruction(NULL, ADDI_OPCODE, vreg++, REG_V0, 0, 0, NULL);
        instruction_t *combined;
        combined = append_inst(syscode, pushsys);
        combined = append_inst(combined, syscall);
        combined = append_inst(combined, move);

        $$ = new_expr_result(move->rdest, combined, EXPR_INT);
    }
    | SIZEOFKEY LPAREN INTKEY RPAREN {
        instruction_t * inst = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, 4, NULL);
        $$ = new_expr_result(inst->rdest, inst, EXPR_INT);
    }
    | MALLOC LPAREN expr RPAREN {
        if ($3->type != EXPR_INT) {
            yyerror("malloc(size) requires an integer size");
        }
        instruction_t *syscode = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, SYSCALL_SBRK, NULL);
        instruction_t *pushsys = new_instruction(NULL, SW_OPCODE, 0, syscode->rdest, REG_SP, 0, NULL);
        instruction_t *pushsz  = new_instruction(NULL, SW_OPCODE, 0, $3->reg,       REG_SP, -4, NULL);
        instruction_t *sysc    = new_instruction(NULL, SYSCALL_OPCODE, 0, 0, 0, 0, NULL);
        instruction_t *move    = new_instruction(NULL, ADDI_OPCODE, vreg++, REG_V0, 0, 0, NULL);
        instruction_t *combined = append_inst($3->list, syscode);
        combined = append_inst(combined, pushsys);
        combined = append_inst(combined, pushsz);
        combined = append_inst(combined, sysc);
        combined = append_inst(combined, move);

        free($3);
        $$ = new_expr_result(move->rdest, combined, EXPR_REF);
    }
    | GETS LPAREN logic_or COMMA logic_or RPAREN {
        /* gets(buffer, maxlen) -> int (bytes read) */
        if ($3->type != EXPR_STRING) {
            yyerror("first argument to gets must be a string/address");
        }
        if ($5->type != EXPR_INT) {
            yyerror("second argument to gets must be an int");
        }

        /* build: code, buffer, maxlen, SYSCALL; result in v0 */
        instruction_t *syscode = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, SYSCALL_READ_STRING, NULL);
        instruction_t *pushsys = new_instruction(NULL, SW_OPCODE, 0, syscode->rdest, REG_SP, 0, NULL);
        instruction_t *pushbuf = new_instruction(NULL, SW_OPCODE, 0, $3->reg,       REG_SP, -4, NULL);
        instruction_t *pushlen = new_instruction(NULL, SW_OPCODE, 0, $5->reg,       REG_SP, -8, NULL);
        instruction_t *sysc    = new_instruction(NULL, SYSCALL_OPCODE, 0, 0, 0, 0, NULL);
        instruction_t *move    = new_instruction(NULL, ADDI_OPCODE, vreg++, REG_V0, 0, 0, NULL);

        instruction_t *combined = append_inst($3->list, $5->list);
        combined = append_inst(combined, syscode);
        combined = append_inst(combined, pushsys);
        combined = append_inst(combined, pushbuf);
        combined = append_inst(combined, pushlen);
        combined = append_inst(combined, sysc);
        combined = append_inst(combined, move);

        free($3);
        free($5);
        $$ = new_expr_result(move->rdest, combined, EXPR_INT);
    }
    | IDENT {
        int *offset = (int *) symtab_lookup($1);
        symtab_type_t type = symtab_type($1);
        if(type == SYMTAB_INTGLOBAL) {
            instruction_t * inst = new_instruction(NULL, LW_OPCODE, vreg++, REG_GP, 0, (*offset), NULL);
            $$ = new_expr_result(inst->rdest, inst, EXPR_INT);
        } else if (type == SYMTAB_INTLOCAL) {
            instruction_t * inst = new_instruction(NULL, LW_OPCODE, vreg++, REG_FP, 0, -(*offset), NULL);
            $$ = new_expr_result(inst->rdest, inst, EXPR_INT);
        } else if(type == SYMTAB_STRGLOBAL) {
            instruction_t * inst = new_instruction(NULL, LW_OPCODE, vreg++, REG_GP, 0, (*offset), NULL);
            $$ = new_expr_result(inst->rdest, inst, EXPR_STRING);
        } else if(type == SYMTAB_STRLOCAL) {
            instruction_t * inst = new_instruction(NULL, LW_OPCODE, vreg++, REG_FP, 0, -(*offset), NULL);
            $$ = new_expr_result(inst->rdest, inst, EXPR_STRING);
        } else if(type == SYMTAB_ARRAYGLOBAL) {
            instruction_t * inst = new_instruction(NULL, LW_OPCODE, vreg++, REG_GP, 0, (*offset), NULL);
            $$ = new_expr_result(inst->rdest, inst, EXPR_REF);
        } else if(SYMTAB_ARRAYLOCAL) {
            instruction_t * inst = new_instruction(NULL, LW_OPCODE, vreg++, REG_FP, 0, -(*offset), NULL);
            $$ = new_expr_result(inst->rdest, inst, EXPR_REF);
        } else {
            yyerror("Invalid type for access");
        }
    }
    | IDENT LBRACKET logic_or RBRACKET {
        int *offset = (int *) symtab_lookup($1);
        symtab_type_t type = symtab_type($1);
        if($3 -> type != EXPR_INT) {
            yyerror("Must use an integer to access an array");
        }
        if(type == SYMTAB_ARRAYGLOBAL) {
            instruction_t *get_address = new_instruction(NULL, LW_OPCODE, vreg++, REG_GP, 0, (*offset), NULL);
            instruction_t *calc_offset = new_instruction(NULL, MULTI_OPCODE, vreg++, $3->reg, 0, 4, NULL);
            instruction_t *location = new_instruction(NULL, ADD_OPCODE, vreg++, get_address->rdest, calc_offset->rdest, 0, NULL);
            instruction_t *get_value = new_instruction(NULL, LW_OPCODE, vreg++, location ->rdest, 0, 0, NULL);

            instruction_t *combined = append_inst($3->list, get_address);
            combined = append_inst(combined, calc_offset);
            combined = append_inst(combined, location);
            combined = append_inst(combined, get_value);
            free($3);
            $$ = new_expr_result(get_value -> rdest, combined, EXPR_INT);
        } else if(type == SYMTAB_ARRAYLOCAL) {
            instruction_t *get_address = new_instruction(NULL, LW_OPCODE, vreg++, REG_FP, 0, -(*offset), NULL);
            instruction_t *calc_offset = new_instruction(NULL, MULTI_OPCODE, vreg++, $3->reg, 0, 4, NULL);
            instruction_t *location = new_instruction(NULL, ADD_OPCODE, vreg++, get_address->rdest, calc_offset->rdest, 0, NULL);
            instruction_t *get_value = new_instruction(NULL, LW_OPCODE, vreg++, location ->rdest, 0, 0, NULL);

            instruction_t *combined = append_inst($3->list, get_address);
            combined = append_inst(combined, calc_offset);
            combined = append_inst(combined, location);
            combined = append_inst(combined, get_value);
            free($3);
            $$ = new_expr_result(get_value -> rdest, combined, EXPR_INT);
        } else {
            yyerror("Cannot access elements from non-array variable");
        }
    }
    | IDENT LPAREN calls RPAREN {
        function_t* exists = (function_t*) symtab_lookup($1);

        int numargs = exists -> numargs;
        symtab_type_t *a = exists -> argtypes;

        expr_list_t *current = $3;

        instruction_t *combined = NULL;
        for(int i = 0; i < numargs; i++) {
            if(current == NULL) {
                int len = snprintf(NULL, 0, "Missing argument in position %d", i);
                char *buf = malloc(len + 1);

                snprintf(buf, len + 1, "Missing argument in position %d", i);
                yyerror(buf);
            }
            int etype = current -> exp -> type;
            int stype = a[i];
            if(etype == EXPR_INT && !(stype == SYMTAB_INTLOCAL || stype == SYMTAB_INTGLOBAL)) {
                int len = snprintf(NULL, 0, "Inproper argument type in position %d", i);
                char *buf = malloc(len + 1);

                snprintf(buf, len + 1, "Inproper argument type in position %d", i);
                yyerror(buf);
            } else if(etype == EXPR_STRING && !(stype == SYMTAB_STRLOCAL || stype == SYMTAB_STRGLOBAL)) {
                int len = snprintf(NULL, 0, "Inproper argument type in position %d", i);
                char *buf = malloc(len + 1);

                snprintf(buf, len + 1, "Inproper argument type in position %d", i);
                yyerror(buf);
            } else if(etype == EXPR_REF && !(stype == SYMTAB_ARRAYLOCAL || stype == SYMTAB_ARRAYGLOBAL)) {
                int len = snprintf(NULL, 0, "Inproper argument type in position %d", i);
                char *buf = malloc(len + 1);

                snprintf(buf, len + 1, "Inproper argument type in position %d", i);
                yyerror(buf);
            }
            int offset = i * 4;

            instruction_t *store_argument = new_instruction(NULL, SW_OPCODE, 0, current->exp->reg, REG_SP, -offset, NULL);
            combined = append_inst(combined, current->exp->list);
            combined = append_inst(combined, store_argument);

            current = current -> next;
        }

        int shift_ammount = 0;

        if(isMain) {
            shift_ammount = nlocals * 4;
        } else {
            shift_ammount = (nlocals + 1 + nArgs) * 4;
        }

        instruction_t *shift_fp = new_instruction(NULL, ADDI_OPCODE, REG_FP, REG_FP, 0, -shift_ammount, NULL);
        instruction_t *fix_fp = new_instruction(NULL, ADDI_OPCODE, REG_FP, REG_FP, 0, shift_ammount, NULL);
        instruction_t *jal = new_instruction(NULL, JAL_OPCODE, 0, 0, 0, 0, $1);
        instruction_t *return_val = new_instruction(NULL, ADDI_OPCODE, vreg++, REG_V0, 0, 0, NULL);

        combined = append_inst(combined, shift_fp);
        combined = append_inst(combined, jal);
        combined = append_inst(combined, fix_fp);
        combined = append_inst(combined, return_val);

        $$ = new_expr_result(return_val->rdest, combined, EXPR_INT);
	};

calls: call call_list {
        expr_list_t *new = (expr_list_t*) malloc(sizeof(expr_list_t));
        new -> next = NULL;
        new -> exp = $1;
        if($2 == NULL) {
            $$ = new;
        } else {
            expr_list_t *current = $2;
            while(current -> next) {
                current = current -> next;
            }
            current -> next = new;
            $$ = $2;
        }
    }
	| {
        $$ = NULL;
	};

call: logic_or {
        $$ = $1;
    };

call_list: COMMA call call_list {
        expr_list_t *new = (expr_list_t*) malloc(sizeof(expr_list_t));
        new -> next = NULL;
        new -> exp = $2;
        if($3 == NULL) {
            $$ = new;
        } else {
            expr_list_t *current = $3;
            while(current -> next) {
                current = current -> next;
            }
            current -> next = new;
            $$ = $3;
        }
    }
	| {
        $$ = NULL;
	};
%%

int yydebug = 1;
char * current_file = NULL;

// the cheesiest main function evar!
int main(int argc, char *argv[]){
    FILE *fd;
    yylineno = -1;
    if (argc == 2) {
        current_file = strdup(argv[1]);
        // open the input program file
        fd = fopen(current_file,"r");
        // and parse that dawg
        if (fd){
            yyrestart(fd);
            yylineno = 1;
            yyparse();
        }
        else{
            yyerror("Could not open input program file");
        }
        fclose(fd);
    }
    else {
        yyerror("Input program file name must be passed at the command-line");
    }

    //dump_symtab();

    // got super lazy, and hard-coded the output assembly file
    //  normally gcc writes a default a.out... but since this
    //  output will be assembly, it's a.s... get it?
    write_asm("a.s");

    return EXIT_SUCCESS;
}

// definition of yyerror, needed by auto-generated parser code
int yyerror(const char *s){
    fprintf(stderr, "error: %s\n\tfile: %s\tline: %d\n", s, current_file, yylineno);
    exit(EXIT_FAILURE);
}
