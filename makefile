all: ccompile main

run: cparser
	./main

cparser: lex.yy.c y.tab.c y.tab.h symtab.o matrix.o print_pcode.o get_symtab.o
	gcc -c -g lex.yy.c y.tab.c symtab.o matrix.o print_pcode.o get_symtab.o

ccompile: lex.yy.o symtab.o print_pcode.o get_symtab.o

lex.yy.o: lex.yy.c symtab.h matrix.h print_pcode.c get_symtab.c
	gcc -c -g lex.yy.c

lex.yy.c: mdl.l y.tab.h
	flex -I mdl.l

y.tab.c: mdl.y symtab.h parser.h
	bison -d -y mdl.y

y.tab.h: mdl.y
	bison -d -y mdl.y

symtab.o: symtab.c parser.h matrix.h
	gcc -c -g symtab.c

print_pcode.o: print_pcode.c parser.h matrix.h
	gcc -c -g print_pcode.c

matrix.o: matrix.c matrix.h
	gcc -c -g matrix.c

get_symtab.o: get_symtab.c symtab.h parser.h matrix.h
	gcc -c -g get_symtab.c

main: main.nim display.nim draw.nim matrix.nim stack.nim
	nim c -l:lex.yy.o -l:symtab.o -l:get_symtab.o -d:nimOldCaseObjects -d:release main.nim 

display: display.nim
	nim c display.nim

draw: draw.nim display.nim gmath.nim matrix.nim
	nim c draw.nim

gmath: gmath.nim matrix.nim
	nim c gmath.nim

matrix: matrix.nim
	nim c matrix.nim

parser: parser.nim display.nim draw.nim matrix.nim
	nim c parser.nim

stack: stack.nim matrix.nim
	nim c stack.nim

clean: 
	rm -f *.ppm
	rm -f *.png
	rm -f *.o
	rm -f lex.yy.c
	rm -f y.tab.*
	rm -f anim/*
	rm -f main display draw gmath matrix parser stack
