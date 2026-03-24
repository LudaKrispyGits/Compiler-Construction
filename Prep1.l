%{
#include "Prep1.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap

%%

"int"  { return INT; }
"float"   { return FLOAT; }
"string"  { return STRING; }
"double"  { return DOUBLE; }
"char"    { return CHAR;   }
"void"    { return VOID;   }
"bool"    { return BOOL;   }
"char" { return CHAR; }
"void" { return VOID; }
"TrueOrFalse" {return BOOL; }
"print" {return PRINT; }


[a-zA-Z_][a-zA-Z0-9_]*  { yylval.sval = strdup(yytext); return ID; } 

[0-9]+\.[0-9]+           { yylval.fval = atof(yytext);   return FLOAT_LIT; }
[0-9]+                   { yylval.ival = atoi(yytext);   return INT_LIT; }
\"[^\"]*\"  { yytext[yyleng - 1] = '\0';          /* remove closing " */ 
            yylval.sval = strdup(yytext + 1);   /* skip opening "   */
            return STRING_LIT;
}

"="   { return ASSIGN; }
"equals" { return ASSIGN; }
"+"   { return PLUS;   }
"plus" { return PLUS; }
"add" { return PLUS; }
"-"   { return MINUS;  }
"minus" { return MINUS; }
"*"   { return TIMES;  }
"times" { return TIMES; } 
"/"   { return DIVIDE; }
"divide" { return DIVIDE; }
";"   { return SEMICOLON;   }
"end" { return SEMICOLON; }
"("   { return LPAREN; }
")"   { return RPAREN; }

"%" {return MOD;}
"mod" { return MOD; }






[ \t\n\r]+ { /* sjipping white spaces */ }


. { fprintf(stderr, "unknown char: %s\n", yytext[0]); }

%%

