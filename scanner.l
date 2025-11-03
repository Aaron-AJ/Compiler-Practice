%option noyywrap yylineno

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

static unsigned long letters = 0;
static unsigned long words = 0;
static unsigned long sentences = 0;
static unsigned long paragraphs = 0;

/* Count only alphabetic characters inside a matched word token */
static void count_letters_in(const char *s) {
    const unsigned char *p = (const unsigned char *)s;
    while (*p) {
        if (isalpha(*p)) { ++letters; }
        ++p;
    }
}

static void print_stats(void) {
    printf("letters: %lu\n", letters);
    printf("words: %lu\n", words);
    printf("sentences: %lu\n", sentences);
    printf("paragraphs: %lu\n", paragraphs);
}
%}

%%
\n\n                              { paragraphs++; }

[A-Za-z]+(['-][A-Za-z]+)*        { words++; count_letters_in(yytext); }

[.!?]                            { sentences++; }

[-,;:()']+                       { /* ignore */ }

[ \t\r]+                         { /* ignore */ }

\n                               { /* keep yylineno updated */ }

[0-9]+                           {
                                   print_stats();
                                   fprintf(stderr, "error on line %d: unexpected digits \"%s\"\n", yylineno, yytext);
                                   exit(EXIT_FAILURE);
                                 }

.                                {
                                   print_stats();
                                   fprintf(stderr, "error on line %d: unexpected character \"%s\"\n", yylineno, yytext);
                                   exit(EXIT_FAILURE);
                                 }
%%

int main(void) {
    yylex();
    print_stats();
    return EXIT_SUCCESS;
}
