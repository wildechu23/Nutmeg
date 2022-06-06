import display, gmath, matrix, std/algorithm, std/math, std/random

proc addPoint*(m: var Matrix, x, y, z: float) =
    m.add newSeq[float](4)
    let i = len(m) - 1
    m[i][0] = x
    m[i][1] = y
    m[i][2] = z
    m[i][3] = 1

proc addEdge*(m: var Matrix, x0, y0, z0, x1, y1, z1: float) =
    m.addPoint x0, y0, z0
    m.addPoint x1, y1, z1


proc addPolygon(m: var Matrix, x0, y0, z0, x1, y1, z1, x2, y2, z2: float) =
    m.addPoint x0, y0, z0
    m.addPoint x1, y1, z1
    m.addPoint x2, y2, z2
    # echo m

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
    # addEdge(m, x, y, z, x + width, y, z)
    # addEdge(m, x, y, z, x, y - height, z)
    # addEdge(m, x, y, z, x, y, z - depth)
    # addEdge(m, x + width, y - height, z, x, y - height, z)
    # addEdge(m, x + width, y - height, z, x + width, y, z)
    # addEdge(m, x + width, y - height, z, x + width, y - height, z - depth)
    # addEdge(m, x + width, y, z - depth, x, y, z - depth)
    # addEdge(m, x + width, y, z - depth, x + width, y - height, z - depth)
    # addEdge(m, x + width, y, z - depth, x + width, y, z)
    # addEdge(m, x, y - height, z - depth, x + width, y - height, z - depth)
    # addEdge(m, x, y - height, z - depth, x, y, z - depth)
    # addEdge(m, x, y - height, z - depth, x, y - height, z)
    addPolygon(m, x, y, z, x + width, y, z, x, y, z - depth)
    addPolygon(m, x, y, z, x, y - height, z, x + width, y, z)
    addPolygon(m, x, y, z, x, y, z - depth, x, y - height, z)
    addPolygon(m, x + width, y - height, z, x, y - height, z, x + width, y - height, z - depth)
    addPolygon(m, x + width, y - height, z, x + width, y, z, x, y - height, z)
    addPolygon(m, x + width, y - height, z, x + width, y - height, z - depth, x + width, y, z)
    addPolygon(m, x + width, y, z - depth, x, y, z - depth, x + width, y, z)
    addPolygon(m, x + width, y, z - depth, x + width, y - height, z - depth, x, y, z - depth)
    addPolygon(m, x + width, y, z - depth, x + width, y, z, x + width, y - height, z - depth)
    addPolygon(m, x, y - height, z - depth, x + width, y - height, z - depth, x, y - height, z)
    addPolygon(m, x, y - height, z - depth, x, y, z - depth, x + width, y - height, z - depth)
    addPolygon(m, x, y - height, z - depth, x, y - height, z, x, y, z - depth)


proc generateSphere(cx, cy, cz, r: float, step: int): Matrix =
    var 
        m: Matrix = newMatrix(0, 0)
        i: int = 0
        j: int = 0
    const n = DEFAULT_POLYGON_N
    while i < n:
        while j <= n:
            let
                x = r * cos(PI * float(j/n)) + cx
                y = r * sin(PI * float(j/n)) * cos(2 * PI * float(i/n)) + cy
                z = r * sin(PI * float(j/n)) * sin(2 * PI * float(i/n)) + cz
            addPoint(m, x, y, z)
            j += step
        i += step
        j = 0
    return m

proc addSphere*(m: var Matrix, cx, cy, cz, r: float, step: int) =
    var i = 0
    let p = generateSphere(cx, cy, cz, r, step)
    const n = DEFAULT_POLYGON_N
    while i < p.len - n - 1:
        addPolygon(m, p[i][0], p[i][1], p[i][2], p[i+1][0], p[i+1][1], p[i+1][2], p[i+n+2][0], p[i+n+2][1], p[i+n+2][2])
        for j in i+1..<i+n-1:
            addPolygon(m, p[j][0], p[j][1], p[j][2], p[j+1][0], p[j+1][1], p[j+1][2], p[j+n+2][0], p[j+n+2][1], p[j+n+2][2])
            addPolygon(m, p[j][0], p[j][1], p[j][2], p[j+n+2][0], p[j+n+2][1], p[j+n+2][2], p[j+n+1][0], p[j+n+1][1], p[j+n+1][2])
        i += n - 1
        addPolygon(m, p[i][0], p[i][1], p[i][2], p[i+n+2][0], p[i+n+2][1], p[i+n+2][2], p[i+n+1][0], p[i+n+1][1], p[i+n+1][2])
        i += 2

    addPolygon(m, p[i][0], p[i][1], p[i][2], p[i+1][0], p[i+1][1], p[i+1][2], p[1][0], p[1][1], p[1][2])
    for j in i+1..<i+n-1:
        addPolygon(m, p[j][0], p[j][1], p[j][2], p[j+1][0], p[j+1][1], p[j+1][2], p[j-i+1][0], p[j-i+1][1], p[j-i+1][2])
        addPolygon(m, p[j][0], p[j][1], p[j][2], p[j-i+1][0], p[j-i+1][1], p[j-i+1][2], p[j-i][0], p[j-i][1], p[j-i][2])
    i += n - 1
    addPolygon(m, p[i][0], p[i][1], p[i][2], p[n][0], p[n][1], p[n][2], p[n-1][0], p[n-1][1], p[n-1][2])

proc generateTorus(cx, cy, cz, r1, r2: float, step: int): Matrix =
    var 
        m: Matrix = newMatrix(0, 0)
        i: int = 0
        j: int = 0
    const n = DEFAULT_POLYGON_N
    while i < n:
        while j < n:
            let
                x = (r1 * cos(2 * PI * float(j/n)) + r2) * cos(2 * PI * float(i/n)) + cx
                y = r1 * sin(2 * PI * float(j/n)) + cy
                z = (r1 * cos(2 * PI * float(j/n)) + r2) * -1 * sin(2 * PI * float(i/n)) + cz
            addPoint(m, x, y, z)
            j += step
        i += step
        j = 0
    return m

proc addTorus*(m: var Matrix, cx, cy, cz, r1, r2: float, step: int) =
    var i = 0
    let p = generateTorus(cx, cy, cz, r1, r2, step)
    const n = DEFAULT_POLYGON_N
    while i < p.len - n:
        for j in i..<i+n-1:
            addPolygon(m, p[j][0], p[j][1], p[j][2], p[j+n+1][0], p[j+n+1][1], p[j+n+1][2], p[j+1][0], p[j+1][1], p[j+1][2])
            addPolygon(m, p[j][0], p[j][1], p[j][2], p[j+n][0], p[j+n][1], p[j+n][2], p[j+n+1][0], p[j+n+1][1], p[j+n+1][2])
        addPolygon(m, p[i+n-1][0], p[i+n-1][1], p[i+n-1][2], p[i+n][0], p[i+n][1], p[i+n][2], p[i][0], p[i][1], p[i][2])
        addPolygon(m, p[i+n-1][0], p[i+n-1][1], p[i+n-1][2], p[i+2*n-1][0], p[i+2*n-1][1], p[i+2*n-1][2], p[i+n][0], p[i+n][1], p[i+n][2])
        i += n
    
    for j in i..<i+n-1:
        addPolygon(m, p[j][0], p[j][1], p[j][2], p[j-i+1][0], p[j-i+1][1], p[j-i+1][2], p[j+1][0], p[j+1][1], p[j+1][2])
        addPolygon(m, p[j][0], p[j][1], p[j][2], p[j-i][0], p[j-i][1], p[j-i][2], p[j-i+1][0], p[j-i+1][1], p[j-i+1][2])
    addPolygon(m, p[i+n-1][0], p[i+n-1][1], p[i+n-1][2], p[0][0], p[0][1], p[0][2], p[i][0], p[i][1], p[i][2])
    addPolygon(m, p[i+n-1][0], p[i+n-1][1], p[i+n-1][2], p[n-1][0], p[n-1][1], p[n-1][2], p[0][0], p[0][1], p[0][2])

proc addMesh(m: var Matrix, file: string) =
    discard

proc diagLine(x0, y0: int, z0: float, x1, y1: int, z1: float, s: var Screen, zb: var ZBuffer, c: Color) =
    let
        a: int = 2*(y1 - y0) # A
        b: int = 2*(x1 - x0) # -B
        deltaZ: float = z1 - z0

    var
        x: int = x0
        y: int = y0
        z: float = z0
        D: int
        dz: float
        
    if abs(y1-y0) <= abs(x1-x0): # dy < dx
        if y1 > y0:
            # octant 1
            D = a - (x1 - x0) # 2dy - dx
            dz = deltaZ / float(x1 - x0 + 1)
            while x <= x1:
                plot(s, zb, c, x, y, z)
                if D > 0:
                    inc y
                    D -= b
                inc x
                D += a
                z += dz
            # echo "z: " & $z
            # echo "z1: " & $z1
        else:
            # octant 8
            D = a - (x1 - x0) # 2dy - dx
            dz = deltaZ / float(x1 - x0 + 1)
            while x <= x1:
                plot(s, zb, c, x, y, z)
                if D > 0:
                    dec y
                    D -= b
                inc x
                D -= a
                z += dz
    else:
        if y1 > y0:
            # octant 2
            D = b - (y1 - y0) # 2dx - dy
            dz = deltaZ / float(y1 - y0 + 1)
            while y <= y1:
                plot(s, zb, c, x, y, z)
                if D > 0:
                    inc x
                    D -= a
                inc y
                D += b
                z += dz
        else:
            # octant 7
            D = b - (y0 - y1) # 2dy - dx
            dz = deltaZ / float(y1 - y0 + 1)
            while y >= y1:
                plot(s, zb, c, x, y, z)
                if D > 0:
                    inc x
                    D += a
                dec y
                D += b
                z += dz

proc drawLine*(x0, y0: int, z0: float, x1, y1: int, z1: float, s: var Screen, zb: var ZBuffer, c: Color) =
    var z, dz: float
    if x0 == x1:
        dz = (z1 - z0) / float(y1 - y0)
        if y1 > y0:
            z = z0
            for y in y0..y1:
                plot(s, zb, c, x0, y, z + float(y - y0)*dz)
        else:
            z = z1
            for y in y1..y0:
                plot(s, zb, c, x0, y, z + float(y - y0)*dz)
    elif y0 == y1:
        dz = (z1 - z0) / float(x1 - x0)
        if x1 > x0:
            z = z0
            for x in x0..x1:
                plot(s, zb, c, x, y0, z + float(x - x0)*dz)
        else:
            z = z1
            for x in x1..x0:
                plot(s, zb, c, x, y0, z + float(x - x0)*dz)
    else:
        if x1 > x0:
            diagLine(x0, y0, z0, x1, y1, z1, s, zb, c)
        else:
            diagLine(x1, y1, z1, x0, y0, z0, s, zb, c)

proc drawLines*(m: Matrix, s: var Screen, zb: var ZBuffer, c: Color) =
    for i in 0..<(len(m) div 2):
        let
            a = m[2*i]
            b = m[2*i + 1]
        drawLine(int(a[0]), int(a[1]), a[2], int(b[0]), int(b[1]), b[2], s, zb, c)

proc cmpY(p, q: seq[float]): int =
    cmp(p[1], q[1])

proc drawScanline(x0: int, z0: float, x1: int, z1: float, y: int, s: var Screen, zbuffer: var ZBuffer, c: Color) =
    var 
        xa: int
        xb: int
        za: float
        zb: float
        z: float
    if x0 > x1:
        xa = x1
        xb = x0
        za = z1
        zb = z0
    else:
        xa = x0
        xb = x1
        za = z0
        zb = z1
    let dz: float = (if (xb - xa) != 0: (zb - za) / float(xb - xa + 1) else: 0)
    z = za
    for x in xa..xb:
        plot(s, zbuffer, c, x, y, z)
        z += dz

proc scanLine(m: Matrix, i: int, s: var Screen, zb: var ZBuffer, c: Color) =
    var 
        p: Matrix = m[3*i .. 3*i + 2]
        flip = 0
        
    p.sort(cmpY)
    # bottom: p[0], middle: p[1], top: p[2]

    var
        x0 = p[0][0]
        x1 = p[0][0]
        z0 = p[0][2]
        z1 = p[0][2]
        y: int = int(p[0][1])

    let
        dist0 = int(p[2][1]) - y + 1
        dist1 = int(p[1][1]) - y + 1
        dist2 = int(p[2][1]) - int(p[1][1]) + 1

        dx0 = (if dist0 > 0: (p[2][0] - p[0][0]) / float(dist0) else: 0)
        dz0 = (if dist0 > 0: (p[2][2] - p[0][2]) / float(dist0) else: 0)

    var
        dx1 = (if dist1 > 0: (p[1][0] - p[0][0]) / float(dist1) else: 0)
        dz1 = (if dist1 > 0: (p[1][2] - p[0][2]) / float(dist1) else: 0)

    while y <= int(p[2][1]):
        if flip == 0 and y >= int(p[1][1]):
            flip = 1
            dx1 = (if dist2 > 0: (p[2][0] - p[1][0]) / float(dist2) else: 0)
            dz1 = (if dist2 > 0: (p[2][2] - p[1][2]) / float(dist2) else: 0)
            x1 = p[1][0]
            z1 = p[1][2]
        drawScanline(int(x0), z0, int(x1), z1, y, s, zb, c)
        x0 += dx0
        x1 += dx1
        z0 += dz0
        z1 += dz1
        y += 1

proc drawPolygons*(m: var Matrix, s: var Screen, zb: var ZBuffer, color: Color, view: tuple, light: Matrix, ambient: Color, areflect, dreflect, sreflect: tuple) =
    # echo m
    for i in 0..<(m.len div 3):
        let
            a = m[3*i]
            b = m[3*i + 1]
            c = m[3*i + 2]
            n = calculateNormal(m, 3*i)
        if dotProduct(n, (0.0, 0.0, 1.0)) > 0:
            # drawLine(int(a[0]), int(a[1]), a[2], int(b[0]), int(b[1]), b[2], s, zb, color)
            # drawLine(int(b[0]), int(b[1]), b[2], int(c[0]), int(c[1]), c[2], s, zb, color)
            # drawLine(int(c[0]), int(c[1]), c[2], int(a[0]), int(a[1]), a[2], s, zb, color)
            let il: Color = getLighting(n, view, ambient, light, areflect, dreflect, sreflect)
            scanLine(m, i, s, zb, il)
