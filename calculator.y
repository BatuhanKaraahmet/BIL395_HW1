%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* Symbol table entry definition */
typedef struct symrec {
    char *name;
    double value;
    struct symrec *next;
} symrec;

symrec *sym_table = NULL;  /* Head of linked list for symbol table */

/* Lookup variable; return pointer or NULL if not found */
symrec* findsym(const char *name) {
    symrec *ptr = sym_table;
    while (ptr != NULL) {
        if (strcmp(ptr->name, name) == 0)
            return ptr;
        ptr = ptr->next;
    }
    return NULL;
}

/* Get or create variable symbol */
symrec* getsym(char *name) {
    symrec *ptr = findsym(name);
    if (ptr != NULL) {
        /* Variable already exists, free the passed name (duplicate) */
        free(name);
        return ptr;
    }
    /* Create new symbol table entry */
    ptr = (symrec *) malloc(sizeof(symrec));
    ptr->name = name;      /* Take ownership of the provided name */
    ptr->value = 0.0;
    ptr->next = sym_table;
    sym_table = ptr;
    return ptr;
}

/* Error handler for Yacc */
void yyerror(const char *msg) {
    fprintf(stderr, "Error: %s\n", msg);
}
%}

/* Define token types and their semantic types */
%union {
    double dval;   /* For numeric values */
    char*  sval;   /* For identifier strings */
}

%token <dval> NUMBER    /* Numeric literal token */
%token <sval> ID        /* Identifier (variable name) token */
%token EOL              /* End-of-line token */

/* Declare operator precedences to resolve ambiguity (lowest to highest) */
%right '='              /* Assignment is right-associative and lowest precedence */
%left '+' '-'           /* + and - have next higher precedence (left-associative) */
%left '*' '/'           /* * and / have higher precedence than + - (left-associative) */
%right '^'              /* ^ (exponentiation) has highest precedence (right-associative) */

%type <dval> expr       /* Non-terminal for expressions will carry a double value */

%%

/* Grammar rules and associated actions */

input:
    /* empty */ 
  | input line           /* Allow multiple lines of input */
  ;

line:
    expr EOL  {
                 /* Successfully parsed an expression line, print the result */
                 printf("%g\n", $1);
             }
  | error EOL {
                 /* On syntax/semantic error, skip to end of line */
                 yyerrok;   /* Reset error state for next line */
             }
  ;

expr:
    expr '+' expr   { $$ = $1 + $3; }
  | expr '-' expr   { $$ = $1 - $3; }
  | expr '*' expr   { $$ = $1 * $3; }
  | expr '/' expr   { 
                      if ($3 == 0) {
                          yyerror("division by zero");
                          YYERROR;    /* Trigger error recovery for division by zero */
                      } else {
                          $$ = $1 / $3;
                      }
                    }
  | expr '^' expr   { $$ = pow($1, $3); }
  | '(' expr ')'    { $$ = $2; }
  | ID '=' expr     { 
                      symrec *s = getsym($1);   /* Get or create variable */
                      s->value = $3;            /* Assign the value */
                      $$ = $3;                  /* Expression value is the assigned value */
                    }
  | ID              { 
                      symrec *s = findsym($1);
                      if (!s) {
                          /* Undefined variable usage */
                          char errbuf[100];
                          snprintf(errbuf, sizeof(errbuf), "undefined variable '%s'", $1);
                          yyerror(errbuf);
                          YYERROR;
                      } else {
                          $$ = s->value;
                      }
                      free($1);  /* Free the identifier string allocated by Lex */
                    }
  | NUMBER          { $$ = $1; }
  ;

%%

/* Main function to start the parser */
int main(void) {
    printf("Simple Calculator (type Ctrl+D to exit)\n");
    yyparse();
    return 0;
}
