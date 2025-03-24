# BIL395_HW1

Build and Run Instructions

  Requirements: 
    Ensure that Lex/Flex and Yacc/Bison are installed on your system (common on Unix-like systems).

Compile the Lexer and Parser:
  Run Lex on the lexical analyzer:

    lex calculator.l
    This produces a C source file (e.g. lex.yy.c).

  Run Yacc (or Bison) on the parser:
    yacc -d calculator.y
    This produces y.tab.c (the parser implementation in C) and y.tab.h (token definitions).

  Note: If using Bison, you can use bison -d -o calculator.tab.c calculator.y to generate calculator.tab.c and calculator.tab.h. Make sure to adjust the include in calculator.l accordingly (to     "calculator.tab.h").

  Compile the generated C code with the C compiler along with the Lex and Yacc libraries:
    cc lex.yy.c y.tab.c -o calc -ll -ly
    This creates an executable named calc.

  Run the Calculator: Execute the compiled program:
    ./calc

You will see a prompt or header message, after which you can type expressions. Press Enter after each expression. The result (or an error message) will be printed on the next line. Continue entering expressions or assignments as needed. To exit, send an end-of-file (Ctrl+D on Unix/Linux, Ctrl+Z on Windows followed by Enter).
