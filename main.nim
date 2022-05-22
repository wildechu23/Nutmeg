import std/math

import display, draw, matrix, mdl, parser, stack, std/random

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
    
    # parseFile("script", edges, polygons, cs, s, zb, view, ambient, light, areflect, dreflect, sreflect)
    echo mdlParse("sphere 0 10 20 30 bleh")

main()
