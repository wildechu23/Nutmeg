all: main display draw gmath matrix mdl parser stack symtab

main: main.nim display.nim draw.nim matrix.nim stack.nim
	nim c main.nim

display: display.nim
	nim c display.nim

draw: draw.nim display.nim gmath.nim matrix.nim
	nim c draw.nim

gmath: gmath.nim matrix.nim
	nim c gmath.nim

matrix: matrix.nim
	nim c matrix.nim

mdl: mdl.nim
	nim c mdl.nim

parser: parser.nim display.nim draw.nim matrix.nim
	nim c parser.nim

stack: stack.nim matrix.nim
	nim c stack.nim

symtab: symtab.nim
	nim c symtab.nim

run:
	./main

clean:
	rm main display draw gmath matrix mdl parser stack symtab
	rm *.ppm
	rm *.png
