CC = gcc
SCANNER = flex
PARSER = bison

TOP = .

OPTIMIZATION = -O3 
#FLAGS = -g -DYYDEBUG
FLAGS = -g 

WARN = -Wall


CFLAGS = $(OPTIMIZATION) $(FLAGS) $(WARN)


CC442_OBJ = $(TOP)/obj/lex.yy.o \
	$(TOP)/obj/mem.o \
	$(TOP)/obj/inst.o \
	$(TOP)/obj/output.o \
	$(TOP)/obj/symtab.o \
	$(TOP)/obj/util.o \
	$(TOP)/obj/parser.tab.o

# All sources ###############################################################

$(TOP)/bin/cc442: $(CC442_OBJ)
	$(CC) -o $(TOP)/bin/cc442 $(CFLAGS) $(CC442_OBJ)

# CC compile ################################################################

$(TOP)/src/lex.yy.c : $(TOP)/src/scanner.l $(TOP)/src/parser.tab.h $(TOP)/src/tnmarch.h
	$(SCANNER) -o$(TOP)/src/lex.yy.c $(TOP)/src/scanner.l

$(TOP)/obj/lex.yy.o : $(TOP)/src/lex.yy.c
	$(CC) $(CFLAGS) -c $(TOP)/src/lex.yy.c -o $(TOP)/obj/lex.yy.o 

$(TOP)/src/parser.tab.c : $(TOP)/src/parser.y $(TOP)/src/mem.h $(TOP)/src/inst.h $(TOP)/src/output.h $(TOP)/src/tnmarch.h $(TOP)/src/symtab.h $(TOP)/src/pdefs.h $(TOP)/src/util.h
	$(PARSER) -v -d $(TOP)/src/parser.y -o$(TOP)/src/parser.tab.c

$(TOP)/src/parser.tab.h : $(TOP)/src/parser.y $(TOP)/src/mem.h $(TOP)/src/inst.h $(TOP)/src/output.h $(TOP)/src/tnmarch.h $(TOP)/src/symtab.h $(TOP)/src/pdefs.h $(TOP)/src/util.h
	$(PARSER) -v -d $(TOP)/src/parser.y -o$(TOP)/src/parser.tab.c

$(TOP)/obj/parser.tab.o : $(TOP)/src/parser.tab.c $(TOP)/src/parser.tab.h
	$(CC) $(CFLAGS) -c $(TOP)/src/parser.tab.c -o $(TOP)/obj/parser.tab.o 

$(TOP)/obj/mem.o : $(TOP)/src/mem.c $(TOP)/src/mem.h $(TOP)/src/tnmarch.h $(TOP)/src/pdefs.h
	$(CC) $(CFLAGS) -c $(TOP)/src/mem.c -o $(TOP)/obj/mem.o 

$(TOP)/obj/inst.o : $(TOP)/src/inst.c $(TOP)/src/inst.h $(TOP)/src/tnmarch.h $(TOP)/src/pdefs.h
	$(CC) $(CFLAGS) -c $(TOP)/src/inst.c -o $(TOP)/obj/inst.o 

$(TOP)/obj/output.o : $(TOP)/src/output.c $(TOP)/src/output.h $(TOP)/src/tnmarch.h $(TOP)/src/mem.h $(TOP)/src/inst.h $(TOP)/src/symtab.h $(TOP)/src/pdefs.h
	$(CC) $(CFLAGS) -c $(TOP)/src/output.c -o $(TOP)/obj/output.o 

$(TOP)/obj/symtab.o : $(TOP)/src/symtab.c $(TOP)/src/symtab.h $(TOP)/src/pdefs.h
	$(CC) $(CFLAGS) -c $(TOP)/src/symtab.c -o $(TOP)/obj/symtab.o 

$(TOP)/obj/util.o : $(TOP)/src/util.c $(TOP)/src/util.h 
	$(CC) $(CFLAGS) -c $(TOP)/src/util.c -o $(TOP)/obj/util.o 


# Cleanup ###################################################################

 
clean:
	rm -f $(TOP)/bin/* $(CC442_OBJ) $(TOP)/src/lex.yy.c $(TOP)/src/parser.tab.* $(TOP)/src/parser.output
