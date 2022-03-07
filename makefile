all: main display draw matrix parser

main: main.nim display.nim draw.nim matrix.nim 
	nim c main.nim

display: display.nim
	nim c display.nim

draw: draw.nim display.nim matrix.nim
	nim c draw.nim

matrix: matrix.nim
	nim c matrix.nim

parser: parser.nim display.nim draw.nim matrix.nim
	nim c parser.nim

run:
	./main

clean:
	rm main display draw matrix parser
	rm *.ppm
	rm *.png
