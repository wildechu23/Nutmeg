import display, draw, matrix, parser, stack, std/random

type
    cmatrix {.importc: "struct matrix", header: "matrix.h".} = object
        rows, cols: cint
        lastcol: cint
        m: ptr ptr cdouble
    
    cconstants {.importc: "struct constants", header: "symtab.h".} = object
        r, g, b: array[4, cdouble]
        red, green, blue: cdouble

    clight {.importc: "struct light", header: "symtab.h".} = object
        l, c: array[4, cdouble]


    cSym = object {.union.}
        m: cmatrix
        c: cconstants
        l: clight
        value: cdouble

    cSymTab {.importc: "SYMTAB" , header: "symtab.h"} = object
        name: cstring
        t {.importc: "type".} : cint
        s: cSym

proc main() =
    randomize()

    var 
        s: Screen[XRES, YRES]
        ambient: Color
        # m1: Matrix
        # m2: Matrix
        # t: Matrix
        edges, polygons, light: Matrix
        cs: Stack[Matrix]
        zb: ZBuffer[XRES, YRES]
        view: tuple =  (0.0, 0.0, 1.0)
        areflect: tuple = (0.1, 0.1, 0.1)
        dreflect: tuple = (0.5, 0.5, 0.5)
        sreflect: tuple = (0.5, 0.5, 0.5)
        
    ambient.red = 50
    ambient.green = 50
    ambient.blue = 50

    light = newMatrix(2, 3)
    light[0][0] = 0.5
    light[0][1] = 0.75
    light[0][2] = 1

    light[1][0] = 0
    light[1][1] = 255
    light[1][2] = 255

    # t = newMatrix()
    cs = newStack[Matrix]()
    edges = newMatrix(0, 0)
    polygons = newMatrix(0, 0)
    clearScreen(s)
    clearZBuffer(zb)

    {.compile: "matrix.c", passL: "-lm".}
    proc parseC(path: cstring): cint {.importc: "parseC", header: "y.tab.c".}


    echo parseC("face.mdl")
    
    # parseFile("script", edges, polygons, cs, s, zb, view, ambient, light, areflect, dreflect, sreflect)
    # echo mdlParse("sphere 0 10 20 30")

    # let 
    #     script: string = readFile("script")
    #     parsed: seq[Command] = mdlParse(script)
    # echo parsed


main()
