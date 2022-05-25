import display, draw, matrix, parser, stack, std/random

type
    cmatrix {.importc: "struct matrix", header: "matrix.h".} = object
        m: ptr ptr cdouble
        rows, cols: cint
        lastcol: cint
    
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
    
    symKind* = enum
        symMatrix,
        symConstants,
        symLight,
        symValue,
        symFile

    Constants* = object
        r: array[4, float]
        g: array[4, float]
        b: array[4, float]
        red, green, blue: float
    
    Light* = object
        l: array[4, float]
        c: array[4, float]

    SymTabObj* = object
        name: string
        case kind: symKind
        of symMatrix: m: Matrix
        of symConstants: c: Constants
        of symLight: l: Light
        of symValue: value: float

    SymTab* = ref SymTabObj

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
    proc parseC(path: cstring): ptr UncheckedArray[cSymTab] {.importc: "parseC", header: "y.tab.c".}
    proc getSymlen(): cint {.importc: "get_symlen", header: "parser.h".}



    let 
        c: ptr UncheckedArray[cSymTab] =  parseC("face.mdl")
        symTabLen: cint = getSymlen()
    var 
        counter = 0
        symTab: seq[SymTab] = @[]

    while counter < symTabLen:
        let ctab = c[counter]
        var s: SymTab
        new(s)
        s.name = $ctab.name
        case ctab.t:
        of 1:
            s.kind = symMatrix
            s.m = ctab.s.m
        of 2:
            s.kind = symValue
            s.value = ctab.s.value
        of 3:
            s.kind = symConstants
            let 
                cConst = ctab.s.c
                nConst: Constants = Constants(
                    r: cConst.r, g: cConst.g, b: cConst.b,
                    red: cConst.red, green: cConst.green, blue: cConst.blue
                )
            s.c = nConst
        of 4:
            s.kind = symLight
            let 
                cLight = ctab.s.l
                nLight: Light = Light(l: cLight.l, c: cLight.c)
            s.l = nLight
        of 5:
            s.kind = symFile
        # echo c[counter].t

        counter += 1
    
    # parseFile("script", edges, polygons, cs, s, zb, view, ambient, light, areflect, dreflect, sreflect)
    # echo mdlParse("sphere 0 10 20 30")

    # let 
    #     script: string = readFile("script")
    #     parsed: seq[Command] = mdlParse(script)
    # echo parsed


main()
