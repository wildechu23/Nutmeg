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
    c.red = 255
    c.green = 255
    c.blue = 255

    t = newMatrix()
    edges = newMatrix(0, 0)
    # drawLine(100, 100, 200, 200, s, c)
    # addCurve(edges, 121, 305, 47, 32, 311, 37, 340, 278, 0.005, 'h')
    # addCurve(edges, 23, 29.7, 9, 500, 475.2, 486, 448, -16, 0.005, 'b')
    # addCircle(edges, 100, 200, 0, 50, 0.005)
    # drawLines(edges, s, c)
    # savePpm(s, "img.ppm")
    
    parseFile("script", t, edges, s)

main()
