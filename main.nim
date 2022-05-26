import display, draw, matrix, parser, stack, std/random, std/strformat

type
    cmatrix {.importc: "struct matrix", header: "matrix.h".} = ref object
        m: ptr ptr cdouble
        rows, cols: cint
        lastcol: cint
    
    cconstants {.importc: "struct constants", header: "symtab.h".} = ref object
        r, g, b: array[4, cdouble]
        red, green, blue: cdouble

    clight {.importc: "struct light", header: "symtab.h".} = ref object
        l, c: array[4, cdouble]


    cSym {.union.} = object
        m: cmatrix
        c: cconstants
        l: clight
        value: cdouble

    cSymTab {.importc: "SYMTAB" , header: "symtab.h".} = object
        name: cstring
        t {.importc: "type".} : cint
        s: cSym

    
    symKind = enum
        symMatrix,
        symConstants,
        symLight,
        symValue,
        symFile

    Constants = object
        r: array[4, float]
        g: array[4, float]
        b: array[4, float]
        red, green, blue: float
    
    Light = object
        l: array[4, float]
        c: array[4, float]

    SymTabObj = object
        name: string
        case kind: symKind
        of symMatrix: m: Matrix
        of symConstants: c: Constants
        of symLight: l: Light
        of symValue: value: float
        of symFile: discard

    SymTab = ref SymTabObj

    cOpLight = object
        p: ptr cSymTab
        c: array[4, cdouble]
    
    cOpAmbient = object
        c: array[4, cdouble]
    
    cOpConstants = object
        p: ptr cSymTab
    
    cOpSCS = object
        p: ptr cSymTab
    
    cOpCamera = object
        eye, aim: array[4, cdouble]
    
    cOpSphere = object
        constants: ptr cSymTab
        d: array[4, cdouble]
        r: cdouble
        cs: ptr cSymTab

    cOpTexture = object
        constants: ptr cSymTab
        d0, d1, d2, d3: array[4, cdouble]
        p: ptr cSymTab
        cs: ptr cSymTab

    cOpTorus = object
        constants: ptr cSymTab
        d: array[4, cdouble]
        r0, r1: cdouble
        cs: ptr cSymTab
    
    cOpBox = object
        constants: ptr cSymTab
        d0, d1: array[4, cdouble]
        cs: ptr cSymTab

    cOpLine = object
        constants: ptr cSymTab
        p0, p1: array[4, cdouble]
        cs0, cs1: ptr cSymTab

    cOpMesh = object
        constants: ptr cSymTab
        name: cstring
        cs: ptr cSymTab

    cOpSet = object
        p: ptr cSymTab
        val: cdouble

    cOpMove = object
        d: array[4, cdouble]
        p: ptr cSymTab

    cOpScale = object
        d: array[4, cdouble]
        p: ptr cSymTab
    
    cOpRotate = object
        axis, degrees: cdouble
        p: ptr cSymTab
    
    cOpBasename = object
        p: ptr cSymTab

    cOpSaveKnobs = object
        p: ptr cSymTab
    
    cOpTween = object
        start_frame, end_frame: cdouble
        knob_list0, knob_list1: ptr cSymTab
    
    cOpFrames = object
        num_frames: cdouble
    
    cOpVary = object
        p: ptr cSymTab
        start_frame, end_frame, start_val, end_val: cdouble

    cOpSave = object
        p: ptr cSymTab
    
    cOpShading = object
        p: ptr cSymTab

    cOpSetKnobs = object
        value: cdouble
    
    cOpFocal = object
        value: cdouble


    cOp {.union.} = object
        light: cOpLight
        ambient: cOpAmbient
        constants: cOpConstants
        save_coordinate_system: cOpSCS
        camera: cOpCamera
        sphere: cOpSphere
        texture: cOpTexture
        torus: cOpTorus
        box: cOpBox
        line: cOpLine
        mesh: cOpMesh
        set: cOpSet
        move: cOpMove
        scale: cOpScale
        rotate: cOpRotate
        basename: cOpBasename
        save_knobs: cOpSaveKnobs
        tween: cOpTween
        frames: cOpFrames
        vary: cOpVary
        save: cOpSave
        shading: cOpShading
        setknobs: cOpSetKnobs
        focal: cOpFocal

    cCommand {.importc: "struct command", header: "parser.h".} = object
        opcode: int
        op: cOp

    OpKind = enum
        light,
        ambient,
        constants,
        saveCoordinateSystem,
        camera,
        sphere,
        texture,
        torus,
        box,
        line,
        mesh,
        set,
        displayOp,
        pop,
        push,
        move,
        scale,
        rotate,
        basename,
        saveKnobs,
        tween,
        frames,
        vary,
        save,
        shading,
        setKnobs,
        focal

    Command = object
        opcode: int
        case kind: OpKind
        of light:
            lightp: SymTab
            lightc: array[4, float]
        of ambient:
            ambientc: array[4, float]
        of constants:
            constantsp: SymTab
        of saveCoordinateSystem:
            saveCSp: SymTab
        of camera:
            eye, aim: array[4, float]
        of sphere:
            sphereConstants, sphereCS: SymTab
            sphered: array[4, float]
            spherer: float
        of texture:
            texConstants, texp: SymTab
            texd0, texd1, texd2, texd3: array[3, float]
        of torus:
            torusConstants, torusCS: SymTab
            torusd: array[4, float]
            torusr0, torusr1: float
        of box:
            boxConstants, boxCS: SymTab
            boxd0, boxd1: array[4, float]
        of line:
            lineConstants, linecs0, linecs1: SymTab
            linep0, linep1: array[4, float]
        of mesh:
            meshConstants, meshCS: SymTab
            name: string
        of set:
            setp: SymTab
            setval: float
        of move:
            movep: SymTab
            moved: array[4, float]
        of scale:
            scalep: SymTab
            scaled: array[4, float]
        of rotate:
            rotatep: SymTab
            axis, degrees: float
        of basename:
            basenamep: SymTab
        of saveKnobs:
            saveKnobsp: SymTab
        of tween:
            tweenStartFrame, tweenEndFrame: float
            knobList0, knobList1: SymTab
        of frames:
            numFrames: float
        of vary:
            varyp: SymTab
            varyStartFrame, varyEndFrame, startVal, endVal: float
        of save:
            savep: SymTab
        of shading:
            shadingp: SymTab
        of setKnobs:
            setKnobsValue: float
        of focal:
            focalValue: float
        else:
            discard

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
    proc parseC(path: cstring){.importc: "parseC", header: "y.tab.c".}
    proc getSym(): ptr UncheckedArray[cSymTab] {.importc: "get_sym", header: "y.tab.c".}
    proc getOp(): ptr UncheckedArray[cCommand] {.importc: "get_ops", header: "y.tab.c".}
    proc getSymlen(): cint {.importc: "get_symlen", header: "parser.h".}
    proc getOplen(): cint {.importc: "get_oplen", header: "parser.h".}

    proc printConstants(p: Constants) =
        echo &"\tRed -\t Ka: {p.r[0]} Kd: {p.r[1]} Ks: {p.r[2]}" 
        echo &"\tGreen -\t Ka: {p.g[0]} Kd: {p.g[1]} Ks: {p.g[2]}"
        echo &"\tBlue -\t Ka: {p.b[0]} Kd: {p.b[1]} Ks: {p.b[2]}"

    proc printLight(p: Light) =
        echo &"\tLocation -\t {p.l[0]} {p.l[1]} {p.l[2]}"
        echo &"\tBrightness -\t r:{p.c[0]} g:{p.c[1]} b:{p.c[2]}"

    proc printSymTab(p: seq[SymTab]) =
        for i in p:
            case i.kind:
            of symMatrix:
                printMatrix(i.m)
            of symConstants:
                printConstants(i.c)
            of symLight:
                printLight(i.l)
            of symValue:
                echo i.value
            of symFile:
                echo i.name

    parseC("face.mdl")

    let 
        c: ptr UncheckedArray[cSymTab] =  getSym()
        symTabLen: cint = getSymlen()
    var 
        counter = 0
        symTab: seq[SymTab] = @[]

    while counter < symTabLen:
        let ctab: cSymTab = c[counter]
        var s: SymTab
        new(s)
        s.name = $ctab.name
        # echo ctab.s.m.type
        case ctab.t:
        of 1:
            s.kind = symMatrix
            let
                cMatrix: cmatrix = ctab.s.m
                cmm: seq[seq[cdouble]] = cast[seq[seq[cdouble]]](cMatrix.m)
            var
                nMatrix: Matrix = newMatrix(cMatrix.rows, cMatrix.cols)
                i = 0
            while i < cMatrix.rows:
                var j = 0
                while j < cMatrix.cols:
                    nMatrix[i][j] = cmm[i][j]
            s.m = nMatrix
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
        else:
            discard
        
        symTab.add(s)
        counter += 1

    printSymTab(symTab)


    let 
        o: ptr UncheckedArray[cCommand] = getOp()
        opTabLen = getOplen()
    counter = 0
    var opTab: seq[]

    
    # parseFile("script", edges, polygons, cs, s, zb, view, ambient, light, areflect, dreflect, sreflect)
    # echo mdlParse("sphere 0 10 20 30")

    # let 
    #     script: string = readFile("script")
    #     parsed: seq[Command] = mdlParse(script)
    # echo parsed


main()
