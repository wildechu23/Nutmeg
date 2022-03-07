import display, draw, matrix, std/strutils, std/osproc, std/strformat

# line: add a line to the point matrix - takes 6 arguemnts (x0, y0, z0, x1, y1, z1)
# ident: set the transform matrix to the identity matrix
# scale: create a scale matrix, then multiply the transform matrix by the scale matrix - takes 3 arguments (sx, sy, sz)
# move: create a translation matrix, then multiply the transform matrix by the translation matrix - takes 3 arguments (tx, ty, tz)
# rotate: create a rotation matrix, then multiply the transform matrix by the rotation matrix - takes 2 arguments (axis theta)
# apply: apply the current transformation matrix to the edge matrix
# display: clear the screen, draw the lines of the point matrix to the screen, display the screen
# save: clear the screen, draw the lines of the point matrix to the screen/frame save the screen/frame to a file - takes 1 argument (file name)

proc parseFile*(path: string, t, edges: var Matrix, s: var Screen) = 
    let f = open(path, fmRead)
    defer: f.close()
    var line: string
    var n: int = 1
    while(f.readLine(line)):
        # echo line
        case line:
        of "line":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            if len(arg) != 6:
                echo "Line " & $n & ": line has the wrong number of arguments"
                return
            else:
                addEdge(edges, parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3]), parseFloat(arg[4]), parseFloat(arg[5]))
            n += 2
            # printMatrix(edges)
        of "ident":
            t.identMatrix()
            n += 1
            # printMatrix(t)
        of "scale":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            if len(arg) != 3:
                echo "Line " & $n & ": scale has the wrong number of arguments"
                return
            else:
                let m: Matrix = makeScale(parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]))
                # printMatrix(m)
                mul(m, t)
            n += 2
        of "move":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            if len(arg) != 3:
                echo "Line " & $n & ": move has the wrong number of arguments"
                return
            else:
                let m: Matrix = makeTranslate(parseFloat(arg[0]), parseFloat(arg[1]), parseFloat(arg[2]))
                mul(m, t)
            n += 2
        of "rotate":
            let 
                nextLine = f.readLine()
                arg: seq[string] = nextLine.split(' ')
            if len(arg) != 2:
                echo "Line " & $n & ": rotate has the wrong number of arguments"
                return
            else:
                let m = block:
                    case arg[0] 
                        of "x": makeRotX(parseFloat(arg[1])) 
                        of "y": makeRotY(parseFloat(arg[1])) 
                        of "z": makeRotZ(parseFloat(arg[1])) 
                        else: 
                            echo "Line " & $n & ": rotate axis not x, y, or z"
                            return
                mul(m, t)
            n += 2
        of "apply":
            # printMatrix(t)
            # printMatrix(edges)
            mul(t, edges)
            n += 1
        of "display":
            clearScreen(s)
            var c: Color
            c.red = 255
            c.green = 255
            c.blue = 255
            drawLines(edges, s, c)
            savePpm(s, "img.ppm")
            let errC = execCmd("convert img.ppm img.png && display img.png")
            n += 1
        of "save":
            clearScreen(s)
            var nLine: string
            if f.readLine(nLine):
                var c: Color
                c.red = 255
                c.green = 255
                c.blue = 255
                drawLines(edges, s, c)
                let 
                    l: string = nLine[0 .. ^5]
                    cmd: string = &"convert {l}.ppm {l}.png"
                savePpm(s, l & ".ppm")
                # echo nLine[0 .. ^5]
                let errC = execCmd(cmd)
            else:
                echo "Line " & $n & ": save has no output file"
                return
            n += 2

