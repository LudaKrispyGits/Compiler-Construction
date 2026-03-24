CC     = gcc
CFLAGS = -Wall -g

all: Prep1

# Step 1 — bison first, produces Prep1.tab.h that the lexer needs
Prep1.tab.c Prep1.tab.h: Prep1.y
	bison -d Prep1.y

# Step 2 — flex depends on Prep1.tab.h so always runs after bison
lex.yy.c: Prep1.l Prep1.tab.h
	flex Prep1.l

# Step 3 — compile both generated C files into the final executable
Prep1: Prep1.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o Prep1 Prep1.tab.c lex.yy.c

# Remove all generated files for a clean rebuild
clean:
	rm -f Prep1 Prep1.tab.c Prep1.tab.h lex.yy.c