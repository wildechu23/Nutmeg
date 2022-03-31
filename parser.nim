import display, draw, matrix, std/strutils, std/osproc, std/strformat

# line: add a line to the point matrix - takes 6 arguemnts (x0, y0, z0, x1, y1, z1)
# ident: set the transform matrix to the identity matrix
# scale: create a scale matrix, then multiply the transform matrix by the scale matrix - takes 3 arguments (sx, sy, sz)
# move: create a translation matrix, then multiply the transform matrix by the translation matrix - takes 3 arguments (tx, ty, tz)
# rotate: create a rotation matrix, then multiply the transform matrix by the rotation matrix - takes 2 arguments (axis theta)
# apply: apply the current transformation matrix to the edge matrix
# display: clear the screen, draw the lines of the point matrix to the screen, display the screen
# save: clear the screen, draw the lines of the point matrix to the screen/frame save the screen/frame to a file - takes 1 argument (file name)

proc parseFile*(path: string, t, edges, polygons: var Matrix, s: var Screen) = 
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
        of "ident":
            t.identMatrix()
        of "scale":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
                m: Matrix = makeScale(parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]))
            mul(m, t)
        of "move":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
                m: Matrix = makeTranslate(parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]))
            mul(m, t)
        of "rotate":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            let m = block:
                case arg[0] 
                    of "x": makeRotX(parseFloat(arg[1])) 
                    of "y": makeRotY(parseFloat(arg[1])) 
                    of "z": makeRotZ(parseFloat(arg[1])) 
                    else: raise newException(ValueError, "Axis not x, y, or z")
            mul(m, t)
        of "apply":
            mul(t, edges)
            mul(t, polygons)
        of "display":
            clearScreen(s)
            var c: Color
            c.red = 255
            c.green = 255
            c.blue = 255
            drawLines(edges, s, c)
            drawPolygons(polygons, s, c)
            savePpm(s, "img.ppm")
            let errC = execCmd("convert img.ppm img.png && display img.png")
        of "save":
            clearScreen(s)
            var c: Color
            c.red = 255
            c.green = 255
            c.blue = 255
            drawLines(edges, s, c)
            drawPolygons(polygons, s, c)
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
        of "hermite":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addCurve(edges, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), parseFloat(arg[4]), parseFloat(arg[5]), parseFloat(arg[6]), parseFloat(arg[7]), 0.01, 'h')
        of "bezier":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addCurve(edges, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), parseFloat(arg[4]), parseFloat(arg[5]), parseFloat(arg[6]), parseFloat(arg[7]), 0.01, 'b')
        of "clear":
            edges = newMatrix(0, 0)
        of "box":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addBox(polygons, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), parseFloat(arg[4]), parseFloat(arg[5]))
        of "sphere":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addSphere(polygons, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), 1)
        of "torus":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            addTorus(edges, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), parseFloat(arg[4]), 1)
        else:
            if line[0] == '#':
                continue
            raise newException(ValueError, "Unrecognized command")