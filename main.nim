import display, draw, matrix, parser, stack, std/random, std/strformat, std/strutils, std/osproc, os


proc main() =
    randomize()

    var 
        s: Screen[XRES, YRES]
        ambient: Color
        edges, polygons, normals, light: Matrix
        cs: Stack[Matrix]
        zb: ZBuffer[XRES, YRES]
        view: tuple =  (0.0, 0.0, 1.0)
        areflect: tuple = (0.1, 0.1, 0.1)
        dreflect: tuple = (0.5, 0.5, 0.5)
        sreflect: tuple = (0.5, 0.5, 0.5)
        color: Color

    color.red = 255
    color.green = 255
    color.blue = 255
        
    ambient.red = 50
    ambient.green = 50
    ambient.blue = 50

    light = newMatrix(2, 3)
    light[0][0] = 0.5
    light[0][1] = 0.75
    light[0][2] = 1

    light[1][0] = 255
    light[1][1] = 255
    light[1][2] = 255

    # t = newMatrix()
    cs = newStack[Matrix]()
    edges = newMatrix(0, 0)
    polygons = newMatrix(0, 0)
    normals = newMatrix(0, 0)
    clearScreen(s)
    clearZBuffer(zb)

    {.compile: "matrix.c", passL: "-lm".}
    proc parseC(path: cstring){.importc: "parseC", header: "y.tab.c".}
    proc getSym(): ptr UncheckedArray[cSymTab] {.importc: "get_sym", header: "y.tab.c".}
    proc getOp(): ptr UncheckedArray[cCommand] {.importc: "get_ops", header: "y.tab.c".}
    proc getSymlen(): cint {.importc: "get_symlen", header: "parser.h".}
    proc getOplen(): cint {.importc: "get_oplen", header: "parser.h".}

    parseC("tests/quad.mdl")

    let 
        c: ptr UncheckedArray[cSymTab] =  getSym()
        symTabLen: cint = getSymlen()
    var 
        nFrames: int
        basename: string
        vCheck: bool = false
        counter = 0
        knobs: seq[seq[varyNode]]
        symTab: seq[SymTab] = @[]

    while counter < symTabLen:
        let 
            ctab: cSymTab = c[counter]
            s = cSymtoSym(ctab)

        symTab.add(s)
        counter += 1

    printSymTab(symTab)

    let 
        o: ptr UncheckedArray[cCommand] = getOp()
        opTabLen: cint = getOplen()
    counter = 0
    var opTab: seq[Command] = @[]
    

    while counter < opTabLen:
        let 
            otab: cCommand = o[counter]
            s = cOptoOp(otab, symTab)

        opTab.add(s)
        counter += 1

    firstPass(opTab, nFrames, basename)
    knobs = secondPass(opTab, nFrames)
    if nFrames > 0:
        discard existsOrCreateDir("anim")
        for f in 0..<nFrames:
            execOp(opTab, knobs, f, nFrames, edges, polygons, normals, cs, s, zb, color, view, light, ambient, areflect, dreflect, sreflect)
            savePpm(s, "img.ppm")
            let c: string = align($f, 3, '0')
            discard execCmd(&"convert img.ppm anim/{basename}{c}.png")
            clearScreen(s)
            clearZBuffer(zb)
            cs = newStack[Matrix]()
        discard execCmd(&"convert -delay 1.7 anim/{basename}* {basename}.gif")
    else:
        execOp(opTab, knobs, 0, nFrames, edges, polygons, normals, cs, s, zb, color, view, light, ambient, areflect, dreflect, sreflect)
    # parseFile("script", edges, polygons, cs, s, zb, view, ambient, light, areflect, dreflect, sreflect)
    # echo mdlParse("sphere 0 10 20 30")

    # let 
    #     script: string = readFile("script")
    #     parsed: seq[Command] = mdlParse(script)
    # echo parsed

main()
