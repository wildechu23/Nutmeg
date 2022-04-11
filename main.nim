import std/math

import display, draw, matrix, parser, stack

proc main() =
    var 
        s: Screen[XRES, YRES]
        c: Color
        # m1: Matrix
        # m2: Matrix
        # t: Matrix
        edges: Matrix
        polygons: Matrix
        cs: Stack[Matrix]
    c.red = 255
    c.green = 255
    c.blue = 255

    # t = newMatrix()
    cs = newStack[Matrix]()
    edges = newMatrix(0, 0)
    polygons = newMatrix(0,0)
    
    parseFile("script", edges, polygons, cs, s)

main()
