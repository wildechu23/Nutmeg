import display, draw, matrix, stack, std/strutils, std/osproc, std/strformat

proc parseFile*(path: string, edges, polygons: var Matrix, cs: var Stack[Matrix], s: var Screen, zb: ZBuffer) = 
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
        # of "clear":
        #     edges = newMatrix(0, 0)
        #     polygons = newMatrix(0, 0)
        of "box":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addBox(polygons, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), parseFloat(arg[4]), parseFloat(arg[5]))
            mul(cs[^1], polygons)
            drawPolygons(polygons, s, zb, c)
            polygons = newMatrix(0, 0)
        of "sphere":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addSphere(polygons, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), 1)
            mul(cs[^1], polygons)
            drawPolygons(polygons, s, zb, c)
            polygons = newMatrix(0, 0)
        of "torus":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addTorus(polygons, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), parseFloat(arg[4]), 1)
            mul(cs[^1], polygons)
            drawPolygons(polygons, s, zb, c)
            polygons = newMatrix(0, 0)
        of "push":
            cs.push(cs[^1])
        of "pop":
            discard cs.pop
        else:
            if line[0] == '#':
                continue
            raise newException(ValueError, "Unrecognized command")