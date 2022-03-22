import display, matrix, std/math

proc addPoint*(m: var Matrix, x, y, z: float) =
    m.add newSeq[float](4)
    m[len(m)-1][0] = x
    m[len(m)-1][1] = y
    m[len(m)-1][2] = z
    m[len(m)-1][3] = 1


proc addEdge*(m: var Matrix, x0, y0, z0, x1, y1, z1: float) =
    m.addPoint x0, y0, z0
    m.addPoint x1, y1, z1


proc addCircle*(m: var Matrix, cx, cy, cz, r, step: float) =
    var 
        t: float = step
        x: float = r + cx
        y: float = cy
        oX, oY: float
    while t <= 1:
        oX = x
        oY = y
        x = r*float(cos(2*PI*t)) + cx
        y = r*float(sin(2*PI*t)) + cy
        addEdge(m, ox, oy, cz, x, y, cz)
        t += step
      
proc addCurve*(m: var Matrix, x0, y0, x1, y1, x2, y2, x3, y3, step: float, typ: char) =
    var 
        t: float = step
        x: float = x0
        y: float = y0 
        oX, oY: float
        cx, cy: Matrix
    
    case typ:
        of 'h':
            cx = generateCurveCoefs(x0, x1, x2, x3, 'h')
            cy = generateCurveCoefs(y0, y1, y2, y3, 'h')
        of 'b':
            cx = generateCurveCoefs(x0, x1, x2, x3, 'b')
            cy = generateCurveCoefs(y0, y1, y2, y3, 'b')
        else: raise newException(ValueError, "Curve not type h or b")

    # floating point +step/2 stuff
    while t < 1+step/2:
        oX = x
        oY = y
        x = cx[0][0]*t^3 + cx[0][1]*t^2 + cx[0][2]*t + cx[0][3]
        y = cy[0][0]*t^3 + cy[0][1]*t^2 + cy[0][2]*t + cy[0][3]
        addEdge(m, ox, oy, 0, x, y, 0)
        t += step  

proc addBox*(m: var Matrix, x, y, z, width, height, depth: float) =
    addEdge(m, x, y, z, x + width, y, z)
    addEdge(m, x, y, z, x, y - height, z)
    addEdge(m, x, y, z, x, y, z - depth)
    addEdge(m, x + width, y - height, z, x, y - height, z)
    addEdge(m, x + width, y - height, z, x + width, y, z)
    addEdge(m, x + width, y - height, z, x + width, y - height, z - depth)
    addEdge(m, x + width, y, z - depth, x, y, z - depth)
    addEdge(m, x + width, y, z - depth, x + width, y - height, z - depth)
    addEdge(m, x + width, y, z - depth, x + width, y, z)
    addEdge(m, x, y - height, z - depth, x + width, y - height, z - depth)
    addEdge(m, x, y - height, z - depth, x, y, z - depth)
    addEdge(m, x, y - height, z - depth, x, y - height, z)

proc generateSphere(cx, cy, cz, r: float, step: int): Matrix =
    var 
        m: Matrix = newMatrix(0, 0)
        i: int = 0
        j: int = 0
    while i < 20:
        while j < 20:
            let
                x = r * cos(PI * float(j/20)) + cx
                y = r * sin(PI * float(j/20)) * cos(2 * PI * float(i/20)) + cy
                z = r * sin(PI * float(j/20)) * sin(2 * PI * float(i/20)) + cz
            addPoint(m, x, y, z)
            j += step
        i += step
        j = 0
    return m

proc addSphere*(m: var Matrix, cx, cy, cz, r: float, step: int) =
    for i in generateSphere(cx, cy, cz, r, step):
        addEdge(m, i[0], i[1], i[2], i[0], i[1], i[2])

proc addTorus(m: var Matrix, cx, cy, cz, r1, r2: float, step: int) =
    return

proc generateTorus(cx, cy, cz, r1, r2: float, step: int): Matrix =
    return

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
                if x == 0:
                    echo "x 0"
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
