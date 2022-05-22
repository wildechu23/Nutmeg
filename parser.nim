import display, draw, matrix, stack, std/strutils, std/osproc, std/strformat, symtab

type
    OpKind* = enum
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

    Command* = object
        case kind*: OpKind
        of light:
            lightp*: SymTab
            lightc*: array[4, float]
        of ambient:
            ambientc*: array[4, float]
        of constants:
            constantsp*: SymTab
        of saveCoordinateSystem:
            saveCSp*: SymTab
        of camera:
            eye*, aim*: array[4, float]
        of sphere:
            sphereConstants*, sphereCS*: SymTab
            sphered*: array[4, float]
            spherer*: float
        of texture:
            texConstants*, texp*: SymTab
            texd0*, texd1*, texd2*, texd3*: array[3, float]
        of torus:
            torusConstants*, torusCS*: SymTab
            torusd*: array[4, float]
            torusr0*, torusr1*: float
        of box:
            boxConstants*, boxCS*: SymTab
            boxd0*, boxd1*: array[4, float]
        of line:
            lineConstants*, linecs0*, linecs1*: SymTab
            linep0*, linep1*: array[4, float]
        of mesh:
            meshConstants*, meshCS*: SymTab
            name*: string
        of set:
            setp*: SymTab
            setval*: float
        of move:
            movep*: SymTab
            moved*: array[4, float]
        of scale:
            scalep*: SymTab
            scaled*: array[4, float]
        of rotate:
            rotatep*: SymTab
            axis*, degrees*: float
        of basename:
            basenamep*: SymTab
        of saveKnobs:
            saveKnobsp*: SymTab
        of tween:
            tweenStartFrame*, tweenEndFrame*: float
            knobList0*, knobList1*: SymTab
        of frames:
            numFrames*: float
        of vary:
            varyp*: SymTab
            varyStartFrame*, varyEndFrame*, startVal*, endVal*: float
        of save:
            savep*: SymTab
        of shading:
            shadingp*: SymTab
        of setKnobs:
            setKnobsValue*: float
        of focal:
            focalValue*: float

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
