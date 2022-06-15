import display, draw, matrix, stack, std/strutils, std/osproc, std/strformat

type
    varyNode* = ref object
        name: string
        value: float

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

    cSymTab* {.importc: "SYMTAB" , header: "symtab.h".} = object
        name: cstring
        t {.importc: "type".} : cint
        s: cSym

    
    symKind = enum
        symMatrix,
        symConstants,
        symLight,
        symValue,
        symFile,
        symString

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
        of symString: discard
        of symFile: discard

    SymTab* = ref SymTabObj

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

    cCommand* {.importc: "struct command", header: "parser.h".} = object
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

    Command* = ref object
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
            meshName: string
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
    ShadingType* = enum
        flat,
        gouraud,
        phong

proc `$`(v: varyNode): string =
    &"(name: {v.name}, value: {v.value})"
        
proc getKnobNode(knobs: seq[seq[varyNode]], numFrames: int, knobName: string): int =
    for i in 0..<knobs.len:
        for j in 0..<numFrames:
            if knobs[i][j].name == knobName:
                return i
    return -1

proc addNode(knobs: var seq[varyNode], knobName:  string) =
    knobs.add(varyNode(name: knobName, value: 0))

proc firstPass*(opTab: seq[Command], numFrame: var int, name: var string) =
    var 
        bname: string
        nFrames: float
        varyCheck: bool
    for i in opTab:
        case i.kind:
        of basename:
            bname = i.basenamep.name
        of frames:
            nFrames = i.num_frames
        of vary:
            varyCheck = true
        else:
            discard

    if varyCheck and nFrames == 0:
        quit("Vary with no specified number of frames")
    if nFrames != 0 and bname == "":
        bname = "default"
        echo "Default name used for basename"

    numFrame = int(nFrames)
    name = bname

proc secondPass*(opTab: seq[Command], numFrames: int): seq[seq[varyNode]] =
    var knobs: seq[seq[varyNode]]
    for i in opTab:
        if i.kind == vary:
            var s: seq[varyNode]
            if getKnobNode(knobs, numFrames, i.varyp.name) == -1:
                s = newSeq[varyNode](numFrames)
            else:
                s = knobs[getKnobNode(knobs, numFrames, i.varyp.name)]
            for j in 0..<int(i.varyStartFrame):
                if s[j] == nil:
                    s[j] = varyNode(name: i.varyp.name, value: i.startVal)
            for j in int(i.varyStartFrame)..int(i.varyEndFrame):
                let c = (i.endVal - i.startVal) / (i.varyEndFrame - i.varyStartFrame)
                s[j] = varyNode(name: i.varyp.name, value: i.startVal + c * (float(j) - i.varyStartFrame))
            for j in int(i.varyEndFrame+1)..<numFrames:
                if s[j] == nil:
                    s[j] = varyNode(name: i.varyp.name, value: i.endVal)
            if getKnobNode(knobs, numFrames, i.varyp.name) == -1:
                knobs.add(s)
            else:
                knobs[getKnobNode(knobs, numFrames, i.varyp.name)] = s
    return knobs

proc printConstants(p: Constants) =
    echo &"\tRed -\t Ka: {p.r[0]} Kd: {p.r[1]} Ks: {p.r[2]}" 
    echo &"\tGreen -\t Ka: {p.g[0]} Kd: {p.g[1]} Ks: {p.g[2]}"
    echo &"\tBlue -\t Ka: {p.b[0]} Kd: {p.b[1]} Ks: {p.b[2]}"

proc printLight(p: Light) =
    echo &"\tLocation -\t {p.l[0]} {p.l[1]} {p.l[2]}"
    echo &"\tBrightness -\t r:{p.c[0]} g:{p.c[1]} b:{p.c[2]}"


proc printSymTab*(p: seq[SymTab]) =
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
        of symFile, symString:
            echo i.name

proc cSymtoSym*(ctab: cSymTab): SymTab = 
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
        # echo "CONSTANT"
        s.kind = symConstants
        let 
            cConst: cconstants = ctab.s.c
            nConst: Constants = Constants(
                r: cConst.r, g: cConst.g, b: cConst.b,
                red: cConst.red, green: cConst.green, blue: cConst.blue
            )
        # echo "cConst: " & $cConst.r
        # echo "nConst: " & $nConst.r
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
    return s

proc lookUpcSym(p: ptr cSymTab, s: seq[SymTab]): SymTab = 
    let name = $p[].name
    for i in s:
        if name == i.name:
            return i
    
proc checkSym(p: ptr cSymTab, s: seq[SymTab]): SymTab = 
    result = if p == nil: nil else: lookUpcSym(p, s)
    # if result != nil:
    #     echo result.name

proc cOptoOp*(otab: cCommand, symTab: seq[SymTab]): Command =
    var newOp: Command
    new(newOp)
    newOp.opcode = otab.opcode
    case otab.opcode:
    of 258:
        discard
    of 262:
        newOp.kind = OpKind.constants
        newOp.constantsp = checkSym(otab.op.constants.p, symTab)
    of 265:
        newOp.kind = OpKind.sphere
        newOP.sphereConstants = checkSym(otab.op.sphere.constants, symTab)
        newOp.sphered = otab.op.sphere.d
        newOp.spherer = otab.op.sphere.r
        newOP.sphereCS = checkSym(otab.op.sphere.cs, symTab)
    of 266:
        newOp.kind = OpKind.torus
        newOp.torusConstants = checkSym(otab.op.torus.constants, symTab)
        newOp.torusd = otab.op.torus.d
        newOp.torusr0 = otab.op.torus.r0
        newOp.torusr1 = otab.op.torus.r1
        newOp.torusCS = checkSym(otab.op.torus.cs, symTab)
    of 267:
        newOp.kind = OpKind.box
        newOp.boxConstants = checkSym(otab.op.box.constants, symTab)
        newOp.boxd0 = otab.op.box.d0
        newOp.boxd1 = otab.op.box.d1
    of 268:
        newOp.kind = OpKind.line
        newOp.lineConstants = checkSym(otab.op.line.constants, symTab)
        newOp.linecs0 = checkSym(otab.op.line.cs0, symTab)
        newOp.linecs1 = checkSym(otab.op.line.cs1, symTab)
        newOp.linep0 = otab.op.line.p0
        newOp.linep1 = otab.op.line.p1
    of 270:
        newOp.kind = OpKind.mesh
        newOp.meshConstants = checkSym(otab.op.mesh.constants, symTab)
        newOp.meshCS = checkSym(otab.op.mesh.cs, symTab)
        newOp.meshName = $otab.op.mesh.name
    of 274:
        newOp.kind = OpKind.move
        newOp.moved = otab.op.move.d
        newOp.movep = checkSym(otab.op.move.p, symTab)
    of 275: 
        newOp.kind = OpKind.scale
        newOp.scaled = otab.op.scale.d
        newOp.scalep = checkSym(otab.op.scale.p, symTab)
    of 276:
        newOp.kind = OpKind.rotate
        newOp.axis = otab.op.rotate.axis
        newOp.degrees = otab.op.rotate.degrees
        newOp.rotatep = checkSym(otab.op.rotate.p, symTab)
    of 277:
        newOp.kind = OpKind.basename
        newOp.basenamep = checkSym(otab.op.basename.p, symTab)
    of 280:
        newOp.kind = OpKind.frames
        newOp.numFrames = otab.op.frames.num_frames
    of 281:
        newOp.kind = OpKind.vary
        newOp.varyp = checkSym(otab.op.vary.p, symTab)
        newOp.varyStartFrame = otab.op.vary.start_frame
        newOp.varyEndFrame = otab.op.vary.end_frame
        newOp.startVal = otab.op.vary.start_val
        newOp.endVal = otab.op.vary.end_val
    of 282:
        newOp.kind = OpKind.push
    of 283:
        newOp.kind = OpKind.pop
    of 284:
        newOp.kind = OpKind.save
        newOp.savep = checkSym(otab.op.save.p, symTab)
    of 286:
        newOp.kind = OpKind.shading
        newOp.shadingp = checkSym(otab.op.shading.p, symTab)
    of 290:
        newOp.kind = OpKind.displayOp
    else:
        discard
    return newOp

proc execOp*(opTab: seq[Command], knobs: seq[seq[varyNode]], f: int, numFrames: int, edges, polygons, normals: var Matrix, shadingType: var ShadingType, cs: var Stack[Matrix], s: var Screen, zb: var ZBuffer, color: Color, view: tuple, light: Matrix, ambient: Color, areflect, dreflect, sreflect: tuple) =
    for i in opTab:
        # if i.opcode == 265:
        case i.kind:
        of box:
            addBox(polygons, i.boxd0[0], i.boxd0[1], i.boxd0[2], i.boxd1[0], i.boxd1[1], i.boxd1[2])
            mul(cs[^1], polygons)
            if i.boxConstants == nil:
                drawPolygons(polygons, s, zb, color, view, light, ambient, areflect, dreflect, sreflect)
            else:
                var nColor: Color
                nColor.red = (i.boxConstants.c.red)
                nColor.green = (i.boxConstants.c.green)
                nColor.blue = (i.boxConstants.c.blue)
                var
                    nAmbient: tuple = (i.boxConstants.c.r[0], i.boxConstants.c.g[0], i.boxConstants.c.b[0])
                    nDiffuse: tuple = (i.boxConstants.c.r[1], i.boxConstants.c.g[1], i.boxConstants.c.b[1])
                    nSpec: tuple = (i.boxConstants.c.r[2], i.boxConstants.c.g[2], i.boxConstants.c.b[2])
                drawPolygons(polygons, s, zb, nColor, view, light, ambient, nAmbient, nDiffuse, nSpec)
            polygons = newMatrix(0,0)
        of sphere:
            addSphere(polygons, i.sphered[0], i.sphered[1], i.sphered[2], i.spherer, 1)
            mul(cs[^1], polygons)
            # echo i.sphereConstants == nil
            if i.sphereConstants == nil:
                drawPolygons(polygons, s, zb, color, view, light, ambient, areflect, dreflect, sreflect)
            else:
                var nColor: Color
                nColor.red = (i.sphereConstants.c.red)
                nColor.green = (i.sphereConstants.c.green)
                nColor.blue = (i.sphereConstants.c.blue)
                var
                    nAmbient: tuple = (i.sphereConstants.c.r[0], i.sphereConstants.c.g[0], i.sphereConstants.c.b[0])
                    nDiffuse: tuple = (i.sphereConstants.c.r[1], i.sphereConstants.c.g[1], i.sphereConstants.c.b[1])
                    nSpec: tuple = (i.sphereConstants.c.r[2], i.sphereConstants.c.g[2], i.sphereConstants.c.b[2])
                drawPolygons(polygons, s, zb, nColor, view, light, ambient, nAmbient, nDiffuse, nSpec)
            polygons = newMatrix(0,0)
        of torus:
            addTorus(polygons, i.torusd[0], i.torusd[1], i.torusd[2], i.torusr0, i.torusr1, 1)
            mul(cs[^1], polygons)
            if i.torusConstants == nil:
                drawPolygons(polygons, s, zb, color, view, light, ambient, areflect, dreflect, sreflect)
            else:
                var nColor: Color
                nColor.red = (i.torusConstants.c.red)
                nColor.green = (i.torusConstants.c.green)
                nColor.blue = (i.torusConstants.c.blue)
                var
                    nAmbient: tuple = (i.torusConstants.c.r[0], i.torusConstants.c.g[0], i.torusConstants.c.b[0])
                    nDiffuse: tuple = (i.torusConstants.c.r[1], i.torusConstants.c.g[1], i.torusConstants.c.b[1])
                    nSpec: tuple = (i.torusConstants.c.r[2], i.torusConstants.c.g[2], i.torusConstants.c.b[2])
                drawPolygons(polygons, s, zb, nColor, view, light, ambient, nAmbient, nDiffuse, nSpec)
            polygons = newMatrix(0,0)
        of mesh:
            addMesh(polygons, normals, i.meshName)
            mul(cs[^1], polygons)
            if i.meshConstants == nil:
                drawPolygons(polygons, s, zb, color, view, light, ambient, areflect, dreflect, sreflect)
            else:
                var nColor: Color
                nColor.red = (i.meshConstants.c.red)
                nColor.green = (i.meshConstants.c.green)
                nColor.blue = (i.meshConstants.c.blue)
                var
                    nAmbient: tuple = (i.meshConstants.c.r[0], i.meshConstants.c.g[0], i.meshConstants.c.b[0])
                    nDiffuse: tuple = (i.meshConstants.c.r[1], i.meshConstants.c.g[1], i.meshConstants.c.b[1])
                    nSpec: tuple = (i.meshConstants.c.r[2], i.meshConstants.c.g[2], i.meshConstants.c.b[2])
                drawPolygons(polygons, s, zb, nColor, view, light, ambient, nAmbient, nDiffuse, nSpec)
            polygons = newMatrix(0,0)
        of Opkind.move:
            var
                x = i.moved[0]
                y = i.moved[1]
                z = i.moved[2]
            if i.movep != nil:
                let k = knobs[getKnobNode(knobs, numFrames, i.movep.name)]
                x *= k[f].value
                y *= k[f].value
                z *= k[f].value
            var m: Matrix = makeTranslate(x, y, z)
            mul(cs[^1], m)
            cs[^1] = m
        of scale:
            var
                x = i.scaled[0]
                y = i.scaled[1]
                z = i.scaled[2]
            if i.scalep != nil:
                let k = knobs[getKnobNode(knobs, numFrames, i.scalep.name)]
                x *= k[f].value
                y *= k[f].value
                z *= k[f].value
            var m: Matrix = makeScale(x, y, z)
            mul(cs[^1], m)
            cs[^1] = m
        of rotate:
            var d = i.degrees
            if i.rotatep != nil:
                let k = knobs[getKnobNode(knobs, numFrames, i.rotatep.name)]
                d *= k[f].value
            var m = block:
                case i.axis:
                of 0: makeRotX(d) 
                of 1: makeRotY(d) 
                of 2: makeRotZ(d) 
                else: raise newException(ValueError, "Axis not x, y, or z")
            mul(cs[^1], m)
            cs[^1] = m
        of Opkind.push:
            cs.push(cs[^1])
        of Opkind.pop:
            discard cs.pop
        of shading:
            case i.shadingp.name:
            of "flat":
                shadingType = flat
            of "gouraud":
                shadingType = gouraud
            of "phong":
                shadingType = phong
            else:
                discard
        of displayOp:
            savePpm(s, "img.ppm")
            discard execCmd("convert img.ppm img.png && display img.png")
        of save:
            let 
                name: string = i.savep.name
                l: string = name[0 .. ^5]
                cmd: string = &"convert img.ppm {l}.png"
            savePpm(s, "img.ppm")
            discard execCmd(cmd)
        else:
            discard


proc parseFile*(path: string, edges, polygons: var Matrix, cs: var Stack[Matrix], s: var Screen, zb: var ZBuffer, view: tuple, ambient: Color, light: Matrix, areflect, dreflect, sreflect: tuple) = 
    var c: Color
    c.red = 255
    c.green = 255
    c.blue = 255
    
    let f = open(path, fmRead)
    defer: f.close()
    var line: string
    while(f.readLine(line)):
        case line:
        of "line":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addEdge(edges, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), parseFloat(arg[4]), parseFloat(arg[5]))
            mul(cs[^1], edges)
            drawLines(edges, s, zb, c)
            edges = newMatrix(0, 0)
        # of "ident":
        #     t.identMatrix()
        of "scale":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            var
                m: Matrix = makeScale(parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]))
            mul(cs[^1], m)
            cs[^1] = m
        of "move":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            var
                m: Matrix = makeTranslate(parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]))
            mul(cs[^1], m)
            cs[^1] = m
        of "rotate":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            var m = block:
                case arg[0] 
                    of "x": makeRotX(parseFloat(arg[1])) 
                    of "y": makeRotY(parseFloat(arg[1])) 
                    of "z": makeRotZ(parseFloat(arg[1])) 
                    else: raise newException(ValueError, "Axis not x, y, or z")
            mul(cs[^1], m)
            cs[^1] = m
        # of "apply":
        #     mul(t, edges)
        #     mul(t, polygons)
        of "display":
            var c: Color
            c.red = 255
            c.green = 255
            c.blue = 255
            savePpm(s, "img.ppm")
            let errC = execCmd("convert img.ppm img.png && display img.png")
        of "save":
            var c: Color
            c.red = 255
            c.green = 255
            c.blue = 255
            let 
                nLine: string = f.readLine()
                l: string = nLine[0 .. ^5]
                cmd: string = &"convert img.ppm {l}.png"
            savePpm(s, "img.ppm")
            let errC = execCmd(cmd)
        of "circle":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addCircle(edges, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), 0.01)
            mul(cs[^1], edges)
            drawLines(edges, s, zb, c)
            edges = newMatrix(0, 0)
        of "hermite":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addCurve(edges, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), parseFloat(arg[4]), parseFloat(arg[5]), parseFloat(arg[6]), parseFloat(arg[7]), 0.01, 'h')
            mul(cs[^1], edges)
            drawLines(edges, s, zb, c)
            edges = newMatrix(0, 0)
        of "bezier":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addCurve(edges, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), parseFloat(arg[4]), parseFloat(arg[5]), parseFloat(arg[6]), parseFloat(arg[7]), 0.01, 'b')
            mul(cs[^1], edges)
            drawLines(edges, s, zb, c)
            edges = newMatrix(0, 0)
        of "clear":
        #     edges = newMatrix(0, 0)
        #     polygons = newMatrix(0, 0)
            clearScreen(s)
            clearZBuffer(zb)
        of "box":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addBox(polygons, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), parseFloat(arg[4]), parseFloat(arg[5]))
            mul(cs[^1], polygons)
            drawPolygons(polygons, s, zb, c, view, light, ambient, areflect, dreflect, sreflect)
            polygons = newMatrix(0, 0)
        of "sphere":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addSphere(polygons, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), 1)
            mul(cs[^1], polygons)
            drawPolygons(polygons, s, zb, c, view, light, ambient, areflect, dreflect, sreflect)
            polygons = newMatrix(0, 0)
        of "torus":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addTorus(polygons, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), parseFloat(arg[4]), 1)
            mul(cs[^1], polygons)
            drawPolygons(polygons, s, zb, c, view, light, ambient, areflect, dreflect, sreflect)
            polygons = newMatrix(0, 0)
        of "push":
            cs.push(cs[^1])
        of "pop":
            discard cs.pop
        else:
            if line[0] == '#':
                continue
            raise newException(ValueError, "Unrecognized command")