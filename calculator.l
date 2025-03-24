%{
#include "y.tab.h"   /* Include token definitions from Yacc/Bison */
#include <stdlib.h>  /* For atof */
%}

/* Define regular expressions for tokens */
%%

[0-9]+(\.[0-9]+)?      { 
    /* Match integer or float number */
    yylval.dval = atof(yytext);       /* Convert lexeme to double */
    return NUMBER; 
}

[A-Za-z][A-Za-z0-9]*   { 
    /* Match variable identifiers (start with letter, followed by letters or digits) */
    yylval.sval = strdup(yytext);     /* Copy the lexeme for use in parser */
    return ID; 
}

"^"    { return '^'; }
"="    { return '='; }
"+"    { return '+'; }
"-"    { return '-'; }
"*"    { return '*'; }
"/"    { return '/'; }
"("    { return '('; }
")"    { return ')'; }
"\n"   { return EOL; }      /* End-of-line token to separate expressions */
[ \t]+ { /* Ignore whitespace (spaces and tabs) */ }

.      { 
    /* Catch any other single character (unrecognized token) */
    printf("Ignoring unrecognized character: %c\n", yytext[0]); 
    /* Skip it and continue */
}

%%

int yywrap(void) {
    return 1;  /* Indicate end of input to Lex */
}

