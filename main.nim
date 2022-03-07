import std/math

import display, draw, matrix, parser

proc main() =
    var 
        s: Screen[XRES, YRES]
        c: Color
        # m1: Matrix
        # m2: Matrix
        t: Matrix
        edges: Matrix

    t = newMatrix()
    edges = newMatrix()
    
    parseFile("script", t, edges, s)

main()
