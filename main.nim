import display, draw, matrix, parser, stack, std/random, std/strformat, std/strutils, std/osproc, os, symtab

proc main() =
    var 
        s: ScreenRef[XRES, YRES]
        ambient: Color
        edges, polygons, normals, light: Matrix
        t: seq[(string, float, float)]
        cs: Stack[Matrix]
        ns: Stack[Matrix]
        zb: ZBufferRef[XRES, YRES]
        view: tuple =  (0.0, 0.0, 1.0)
        areflect: tuple = (0.1, 0.1, 0.1)
        dreflect: tuple = (0.5, 0.5, 0.5)
        sreflect: tuple = (0.5, 0.5, 0.5)
        color: Color
        shadingType: ShadingType = flat

    color.red = 255
    color.green = 255
    color.blue = 255
        
    ambient.red = 50
    ambient.green = 50
    ambient.blue = 50

    light = newMatrix(2, 3)
    light[0][0] = 0
    light[0][1] = 20
    light[0][2] = 10

    light[1][0] = 200
    light[1][1] = 200
    light[1][2] = 200

    # t = newMatrix()
    cs = newStack[Matrix]()
    ns = newStack[Matrix]()
    edges = newMatrix(0, 0)
    polygons = newMatrix(0, 0)
    normals = newMatrix(0, 0)
    s = newScreen()
    zb = newZBuffer()

    {.compile: "matrix.c", passL: "-lm".}
    proc parseC(path: cstring){.importc: "parseC", header: "y.tab.c".}
    proc getSym(): ptr UncheckedArray[cSymTab] {.importc: "get_sym", header: "y.tab.c".}
    proc getOp(): ptr UncheckedArray[cCommand] {.importc: "get_ops", header: "y.tab.c".}
    proc getSymlen(): cint {.importc: "get_symlen", header: "parser.h".}
    proc getOplen(): cint {.importc: "get_oplen", header: "parser.h".}

    if paramCount() > 0:
        let p = paramStr(1)
        parseC(cstring(p))
    else:
        parseC("tests/texture.mdl")

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

    # printSymTab(symTab)

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
            execOp(symTab, opTab, knobs, f, nFrames, edges, polygons, normals, t, shadingType, ns, cs, s[], zb[], color, view, light, ambient, areflect, dreflect, sreflect)
            savePpm(s[], "img.ppm")
            let c: string = align($f, 3, '0')
            discard execCmd(&"convert img.ppm anim/{basename}{c}.png")
            clearScreen(s)
            clearZBuffer(zb)
            cs = newStack[Matrix]()
            ns = newStack[Matrix]()
        discard execCmd(&"convert -delay 1.7 anim/{basename}* {basename}.gif")
    else:
        execOp(symTab, opTab, knobs, 0, nFrames, edges, polygons, normals, t, shadingType, ns, cs, s[], zb[], color, view, light, ambient, areflect, dreflect, sreflect)
    # parseFile("script", edges, polygons, cs, s, zb, view, ambient, light, areflect, dreflect, sreflect)
    # echo mdlParse("sphere 0 10 20 30")

    # let 
    #     script: string = readFile("script")
    #     parsed: seq[Command] = mdlParse(script)
    # echo parsed

main()
