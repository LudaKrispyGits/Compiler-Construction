%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int  yylex(void);

/* ── Symbol Table ───────────────────────────── */
#define MAX_VARS 64

typedef struct {
    char  name[64];
    float value;
    int   declared;
} Variable;                  /* struct closed BEFORE %} */

Variable symtable[MAX_VARS];
int      sym_count = 0;

/* find variable — returns index or -1 */
int sym_find(const char *name) {
    for (int i = 0; i < sym_count; i++)
        if (strcmp(symtable[i].name, name) == 0)
            return i;
    return -1;
}

/* declare a new variable */
void sym_declare(const char *name) {
    if (sym_find(name) != -1) {
        fprintf(stderr, "Error: '%s' already declared\n", name);
        return;
    }
    int i = sym_count++;
    strncpy(symtable[i].name, name, 63);
    symtable[i].value    = 0;
    symtable[i].declared = 1;
}

/* store a value */
void sym_set(const char *name, float val) {
    int i = sym_find(name);
    if (i == -1) {
        fprintf(stderr, "Error: '%s' undeclared\n", name);
        return;
    }
    symtable[i].value = val;
}

/* retrieve a value */
float sym_get(const char *name) {
    int i = sym_find(name);
    if (i == -1) {
        fprintf(stderr, "Error: '%s' undeclared\n", name);
        return 0;
    }
    return symtable[i].value;
}
%}

%union {
    int    ival;
    float  fval;
    char  *sval;
}

%token <ival> INT_LIT
%token <fval> FLOAT_LIT
%token <sval> STRING_LIT
%token <sval> ID
%token INT FLOAT DOUBLE CHAR VOID STRING BOOL
%token ASSIGN SEMICOLON LPAREN RPAREN
%token PLUS MINUS TIMES DIVIDE MOD
%token PRINT 

%left  PLUS MINUS
%left  TIMES DIVIDE MOD
%nonassoc UMINUS

%type <fval> expr
%type <sval> type

%%

program:
    statement_list
|   /* empty */
    ;

statement_list:
    statement_list statement
|   statement
    ;

statement:
    /* int x;  */
    type ID SEMICOLON {
        sym_declare($2);
        fprintf(stderr, "Declared %s variable: '%s'\n", $1, $2);
      }

    /* int x = y;  */
|   type ID ASSIGN ID SEMICOLON {
        sym_declare($2);
        float val = sym_get($4);
        sym_set($2, val);
        fprintf(stderr, "Declared %s '%s' = '%s' (%g)\n", $1, $2, $4, val);
      }

    /* int x = expr;  */
|   type ID ASSIGN expr SEMICOLON {
        sym_declare($2);
        sym_set($2, $4);
        fprintf(stderr, "Declared %s '%s' = %g\n", $1, $2, $4);
      }

    /* x = expr;  */
|   ID ASSIGN expr SEMICOLON {
        sym_set($1, $3);
        fprintf(stderr, "Assigned %g to '%s'\n", $3, $1);
      }

    /* print expr;  */
|   PRINT expr SEMICOLON {
        fprintf(stdout, ">> %g\n", $2);
      }

    /* print x;  */
|   PRINT ID SEMICOLON {
        float val = sym_get($2);
        fprintf(stdout, ">> %g\n", val);
      }

    /* print(expr);  */
|   PRINT LPAREN expr RPAREN SEMICOLON {
        fprintf(stdout, ">> %g\n", $3);
      }

    /* print(x);  */
|   PRINT LPAREN ID RPAREN SEMICOLON {
        float val = sym_get($3);
        fprintf(stdout, ">> %g\n", val);
      }

    /* print("hello");  */
|   PRINT LPAREN STRING_LIT RPAREN SEMICOLON {
        fprintf(stdout, ">> %s\n", $3);
      }

|   PRINT LPAREN type RPAREN SEMICOLON {
        fprintf(stdout, ">> %s\n", $3);
      }

|   expr SEMICOLON {
        fprintf(stderr, "Result: %g\n", $1);
      }
    ;

type:
    INT    { $$ = "int";    }
|   FLOAT  { $$ = "float";  }
|   DOUBLE { $$ = "double"; }
|   CHAR   { $$ = "char";   }
|   VOID   { $$ = "void";   }
|   STRING { $$ = "string"; }
|   BOOL   { $$ = "bool";   }
    ;

expr:
    expr PLUS   expr { $$ = $1 + $3; }
|   expr MINUS  expr { $$ = $1 - $3; }
|   expr TIMES  expr { $$ = $1 * $3; }
|   expr DIVIDE expr {
        if ($3 == 0) { yyerror("Division by zero"); exit(1); }
        $$ = $1 / $3;
      }
|   expr MOD expr    { $$ = (int)$1 % (int)$3; }
|   MINUS expr %prec UMINUS { $$ = -$2; }
|   LPAREN expr RPAREN      { $$ = $2;  }
|   INT_LIT                 { $$ = $1;  }
|   FLOAT_LIT               { $$ = $1;  }
|   ID {
        $$ = sym_get($1);     /* now actually looks up value */
        fprintf(stderr, "Variable '%s' = %g\n", $1, $$);
      }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(void) {
    fprintf(stdout, "Project Prep 1: Simple Calculator in C syntax\n\n");
    return yyparse();
}