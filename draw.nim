import display, matrix, std/math

proc addCurve(m: Matrix, x0, y0, x1, y1, x2, y2, x3, y3, step: float, t: int) =
    return

proc addPoint*(m: var Matrix, x, y, z: float) =
    m.add newSeq[float](4)
    m[len(m)-1][0] = x
    m[len(m)-1][1] = y
    m[len(m)-1][2] = z
    m[len(m)-1][3] = 1


proc addEdge*(m: var Matrix, x0, y0, z0, x1, y1, z1: float) =
    m.addPoint x0, y0, z0
    m.addPoint x1, y1, z1


proc addCircle(m: var Matrix, cx, cy, cz, r, step: float) =
    var 
        t: float = step
        x: float = cx
        y: float = cy 
        oX, oY: float
    while t <= 1:
        oX = x
        oY = y
        x = r*float(cos(2*PI*t)) + cx
        y = r*float(sin(2*PI*t)) + cy
        addEdge(m, ox, oy, cz, x, y, cz)
        t += step
        


proc diagLine(x0, y0, x1, y1: int, s: var Screen, c: Color) =
    let
        a: int = 2*(y1 - y0) # A
        b: int = 2*(x1 - x0) # -B

    var
        x: int = x0
        y: int = y0
        D: int
        
    if abs(y1-y0) <= abs(x1-x0): # dy < dx
        if y1 > y0:
            # octant 1
            D = a - (x1 - x0) # 2dy - dx
            while x <= x1:
                plot(s, c, x, y)
                if D > 0:
                    inc y
                    D -= b
                inc x
                D += a
        else:
            # octant 8
            D = a - (x1 - x0) # 2dy - dx
            while x <= x1:
                plot(s, c, x, y)
                if D > 0:
                    dec y
                    D -= b
                inc x
                D -= a
    else:
        if y1 > y0:
            # octant 2
            D = b - (y1 - y0) # 2dx - dy
            while y <= y1:
                plot(s, c, x, y)
                if D > 0:
                    inc x
                    D -= a
                inc y
                D += b
        else:
            # octant 7
            D = b - (y0 - y1) # 2dy - dx
            while y >= y1:
                plot(s, c, x, y)
                if D > 0:
                    inc x
                    D += a
                dec y
                D += b

proc drawLine*(x0, y0, x1, y1: int, s: var Screen, c: Color) =
    if x0 == x1:
        if y1 > y0:
            for y in y0..y1:
                plot(s, c, x0, y)
        else:
            for y in y1..y0:
                plot(s, c, x0, y)

    elif y0 == y1:
        if x1 > x0:
            for x in x0..x1:
                plot(s, c, x, y0)
        else:
            for x in x1..x0:
                plot(s, c, x, y0)
    else:
        if x1 > x0:
            diagLine(x0, y0, x1, y1, s, c)
        else:
            diagLine(x1, y1, x0, y0, s, c)

proc drawLines*(m: Matrix, s: var Screen, c: Color) =
    for i in 0..<(len(m) div 2):
        let
            a = m[2*i]
            b = m[2*i + 1]
        # echo $a[0] & " " & $a[1]
        # echo $b[0] & " " & $b[1]
        drawLine(int(a[0]), int(a[1]), int(b[0]), int(b[1]), s, c)
