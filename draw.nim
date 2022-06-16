import display, gmath, matrix, std/algorithm, std/math, std/tables, strutils, symtab

type
    Vertex = tuple[x, y, z: float]
    
    ShadingType* = enum
        flat,
        gouraud,
        phong

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

proc addNormals(n: var Matrix, x0, y0, z0, x1, y1, z1, x2, y2, z2: float) =
    n.addPoint x0, y0, z0
    n.addPoint x1, y1, z1
    n.addPoint x2, y2, z2

proc addTCoords(t: var seq[(string, float, float)], s: string, x0, y0, x1, y1, x2, y2: float) =
    t.add((s, x0, y0))
    t.add((s, x1, y1))
    t.add((s, x2, y2))

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

proc addMtl*(path: string, s: var seq[SymTab]) =
    let f = open(path, fmRead)
    var 
        line: string
        newMat: SymTab
    while(f.readLine(line)):
        let arg: seq[string] = line.splitWhitespace()
        if arg.len > 0:
            case arg[0]:
            of "newmtl":
                if newMat != nil:
                    s.add(newMat)
                new(newMat)
                newMat.name = arg[1]
                newMat.kind = symConstants
                newMat.c = Constants(r: [0.0, 0.0, 0.0, 0.0], g: [0.0, 0.0, 0.0, 0.0], b: [0.0, 0.0, 0.0, 0.0], red: 0.0, green: 0.0, blue: 0.0)
            of "Ka":
                newMat.c.r[0] = parseFloat(arg[1])
                newMat.c.g[0] = parseFloat(arg[2])
                newMat.c.b[0] = parseFloat(arg[3])
            of "Kd":
                newMat.c.r[1] = parseFloat(arg[1])
                newMat.c.g[1] = parseFloat(arg[2])
                newMat.c.b[1] = parseFloat(arg[3])
            of "Ks":
                newMat.c.r[2] = parseFloat(arg[1])
                newMat.c.g[2] = parseFloat(arg[2])
                newMat.c.b[2] = parseFloat(arg[3])
            of "map_Ka":
                newMat.c.mapKa = arg[1]
            of "map_Kd":
                newMat.c.mapKd = arg[1]
            of "map_Ks":
                newMat.c.mapKs = arg[1]
            else:
                discard
    
    if newMat != nil:
        s.add(newMat)


proc addMesh*(m, n: var Matrix, t: var seq[(string, float, float)], path: string, s: var seq[SymTab]) =
    let f = open(path, fmRead)
    defer: f.close()
    var 
        line: string
        v: seq[Vertex]
        currentMtl: string = ""
        vt: seq[(float, float)]
        vn: seq[Vertex]
    while(f.readLine(line)):
        let arg: seq[string] = line.splitWhitespace()
        # echo arg
        if arg.len > 0:
            case arg[0]:
            of "mtllib":
                addMtl(arg[1], s)
            of "usemtl":
                currentMtl = arg[1]
            of "v":
                v.add((parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3])))
            of "vt":
                vt.add((parseFloat(arg[1]), parseFloat(arg[2])))
            of "vn":
                vn.add((parseFloat(arg[1]), parseFloat(arg[2]), parseFloat(arg[3])))
            of "f":
                var 
                    verts: seq[int]
                    texs: seq[int]
                    norms: seq[int]
                for i in arg[1..^1]:
                    let info = i.split("/")
                    verts.add(parseInt(info[0]) - 1)
                    if info.len > 1 and info[1] != "":
                        texs.add(parseInt(info[1]) - 1)
                    if info.len > 2:
                        norms.add(parseInt(info[2]) - 1)
                case arg.len:
                of 4:
                    addPolygon(m, v[verts[0]][0], v[verts[0]][1], v[verts[0]][2], v[verts[1]][0], v[verts[1]][1], v[verts[1]][2], v[verts[2]][0], v[verts[2]][1], v[verts[2]][2])
                    if vn.len > 0:
                        if norms.len > 0:
                            addNormals(n, vn[norms[0]][0], vn[norms[0]][1], vn[norms[0]][2], vn[norms[1]][0], vn[norms[1]][1], vn[norms[1]][2], vn[norms[2]][0], vn[norms[2]][1], vn[norms[2]][2])
                        else:
                            addNormals(n, vn[verts[0]][0], vn[verts[0]][1], vn[verts[0]][2], vn[verts[1]][0], vn[verts[1]][1], vn[verts[1]][2], vn[verts[2]][0], vn[verts[2]][1], vn[verts[2]][2])
                    if vt.len > 0:
                        addTCoords(t, currentMtl, vt[texs[0]][0], vt[texs[0]][1], vt[texs[1]][0], vt[texs[1]][1], vt[texs[2]][0], vt[texs[2]][1])
                of 5:
                    addPolygon(m, v[verts[0]][0], v[verts[0]][1], v[verts[0]][2], v[verts[1]][0], v[verts[1]][1], v[verts[1]][2], v[verts[2]][0], v[verts[2]][1], v[verts[2]][2])
                    addPolygon(m, v[verts[0]][0], v[verts[0]][1], v[verts[0]][2], v[verts[2]][0], v[verts[2]][1], v[verts[2]][2], v[verts[3]][0], v[verts[3]][1], v[verts[3]][2])
                else:
                    discard
            else:
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

    
proc cmpHashY(p, q: (seq[float], seq[float])): int =
    cmp(p[0][1], q[0][1])

proc cmpHashY(p, q: (seq[float], (string, float, float))): int =
    cmp(p[0][1], q[0][1])

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
    # deleted the + 1 in xb - xa + 1
    let dz: float = (if (xb - xa) != 0: (zb - za) / float(xb - xa) else: 0)
    z = za
    for x in xa..xb:
        plot(s, zbuffer, c, x, y, z)
        z += dz

proc drawScanline(x0: int, z0: float, x1: int, z1: float, y: int, s: var Screen, zbuffer: var ZBuffer, n: tuple, tx0, tx1, ty0, ty1: float, view: tuple, light: Matrix, ambient: Color, areflect, dreflect, sreflect: tuple, maps: array[3, TextureArrayRef]) =
    var 
        xa: int
        xb: int
        za: float
        zb: float
        z: float
        txa: float
        txb: float
        tya: float
        tyb: float
        tx: float
        ty: float
    if x0 > x1:
        xa = x1
        xb = x0
        za = z1
        zb = z0
        txa = tx1
        txb = tx0
        tya = ty1
        tyb = ty0
    else:
        xa = x0
        xb = x1
        za = z0
        zb = z1
        txa = tx0
        txb = tx1
        tya = ty0
        tyb = ty1
    # deleted the + 1 in xb - xa + 1
    let dz: float = (if (xb - xa) != 0: (zb - za) / float(xb - xa) else: 0)
    let dtx: float = (if (xb - xa) != 0: (txb - txa) / float(xb - xa) else: 0)
    let dty: float = (if (xb - xa) != 0: (tyb - tya) / float(xb - xa) else: 0)
    z = za
    tx = txa
    ty = tya
    for x in xa..xb:
        let ct = getTLighting(n, view, ambient, light, areflect, dreflect, sreflect, tx, ty, maps)
        plot(s, zbuffer, ct, x, y, z)
        z += dz
        tx += dtx
        ty += dty

proc drawGScanline*(x0: int, z0: float, x1: int, z1: float, y: int, s: var Screen, zbuffer: var ZBuffer, i0, i1: Color) =
    var 
        xa: int
        xb: int
        za: float
        zb: float
        z: float
        ia: Color
        ib: Color
        c: Color
    if x0 > x1:
        xa = x1
        xb = x0
        za = z1
        zb = z0
        ia = i1
        ib = i0
    else:
        xa = x0
        xb = x1
        za = z0
        zb = z1
        ia = i0
        ib = i1
    # deleted the + 1 in xb - xa + 1
    let dz: float = (if (xb - xa) != 0: (zb - za) / float(xb - xa) else: 0)
    let dc: Color = (if not cmp(ia, ib): (ib - ia) / float(xb - xa) else: (red: 0.0, green: 0.0, blue: 0.0))
    z = za
    c = ia
    for x in xa..xb:
        plot(s, zbuffer, c, x, y, z)
        z += dz
        c = c + dc

proc drawGScanline*(x0: int, z0: float, x1: int, z1: float, y: int, s: var Screen, zbuffer: var ZBuffer, i0, i1: Color, n: tuple, tx0, tx1, ty0, ty1: float, view: tuple, light: Matrix, ambient: Color, areflect, dreflect, sreflect: tuple, maps: array[3, TextureArrayRef]) =
    var 
        xa: int
        xb: int
        za: float
        zb: float
        z: float
        ia: Color
        ib: Color
        c: Color
        txa: float
        txb: float
        tya: float
        tyb: float
        tx: float
        ty: float
    if x0 > x1:
        xa = x1
        xb = x0
        za = z1
        zb = z0
        ia = i1
        ib = i0
        txa = tx1
        txb = tx0
        tya = ty1
        tyb = ty0
    else:
        xa = x0
        xb = x1
        za = z0
        zb = z1
        ia = i0
        ib = i1
        txa = tx0
        txb = tx1
        tya = ty0
        tyb = ty1
    # deleted the + 1 in xb - xa + 1
    let dz: float = (if (xb - xa) != 0: (zb - za) / float(xb - xa) else: 0)
    let dc: Color = (if not cmp(ia, ib): (ib - ia) / float(xb - xa) else: (red: 0.0, green: 0.0, blue: 0.0))
    let dtx: float = (if (xb - xa) != 0: (txb - txa) / float(xb - xa) else: 0)
    let dty: float = (if (xb - xa) != 0: (tyb - tya) / float(xb - xa) else: 0)
    z = za
    c = ia
    tx = txa
    ty = tya
    for x in xa..xb:
        let ct = getTLighting(n, view, ambient, light, areflect, dreflect, sreflect, tx, ty, maps)
        plot(s, zbuffer, ct, x, y, z)
        z += dz
        c = c + dc

proc drawPScanline*(x0: int, z0: float, x1: int, z1: float, y: int, s: var Screen, zbuffer: var ZBuffer, n0, n1: tuple, view: tuple, light: Matrix, ambient: Color, areflect, dreflect, sreflect: tuple) =
    var 
        xa: int
        xb: int
        za: float
        zb: float
        z: float
        na: (float, float, float)
        nb: (float, float, float)
        n: (float, float, float)
    if x0 > x1:
        xa = x1
        xb = x0
        za = z1
        zb = z0
        na = n1
        nb = n0
    else:
        xa = x0
        xb = x1
        za = z0
        zb = z1
        na = n0
        nb = n1
    # deleted the + 1 in xb - xa + 1
    let dz: float = (if (xb - xa) != 0: (zb - za) / float(xb - xa) else: 0)
    let dn: tuple = (if not cmp(na, nb): (nb - na) / float(xb - xa) else: (red: 0.0, green: 0.0, blue: 0.0))
    z = za
    n = na
    for x in xa..xb:
        let c = getLighting(n, view, ambient, light, areflect, dreflect, sreflect)
        plot(s, zbuffer, c, x, y, z)
        z += dz
        n = n + dn

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

proc scanLine(m: Matrix, t: seq[(string, float, float)], symTab: seq[SymTab], i: int, s: var Screen, zb: var ZBuffer, n: tuple, c: Color, view: tuple, light: Matrix, ambient: Color, areflect, dreflect, sreflect: tuple) =
    var 
        p: Matrix = m[3*i .. 3*i + 2]
        q = newOrderedTable[seq[float], (string, float, float)]()
        flip = 0
        maps: array[3, TextureArrayRef]

    let 
        mat: SymTab = findName(symTab, t[2*i][0])

        
    for j in 0..<3:
        q[m[3*i + j]] = t[3*i + j]
    
    if mat.c.mapKa != "":
        maps[0] = readPpm(mat.c.mapKa)
    if mat.c.mapKd != "":
        maps[1] = readPpm(mat.c.mapKd)
    if mat.c.mapKs != "":
        maps[2] = readPpm(mat.c.mapKs)
        
    p.sort(cmpY)
    # q.sort(cmpHashY)
    # bottom: p[0], middle: p[1], top: p[2]

    let
        qtx0 = q[p[0]][1]
        qty0 = q[p[0]][2]
        qtx1 = q[p[1]][1]
        qty1 = q[p[1]][2]
        qtx2 = q[p[2]][1]
        qty2 = q[p[2]][2]

    var
        x0 = p[0][0]
        x1 = p[0][0]
        z0 = p[0][2]
        z1 = p[0][2]
        y: int = int(p[0][1])
        tx0 = qtx0
        tx1 = qtx0
        ty0 = qty0
        ty1 = qty0

    let
        dist0 = int(p[2][1]) - y + 1
        dist1 = int(p[1][1]) - y + 1
        dist2 = int(p[2][1]) - int(p[1][1]) + 1

        # distt0 = qty2 - qty0 + 1
        # distt1 = qty1 - qty0 + 1
        # distt2 = qty2 - qty1 + 1

        dx0 = (if dist0 > 0: (p[2][0] - p[0][0]) / float(dist0) else: 0)
        dz0 = (if dist0 > 0: (p[2][2] - p[0][2]) / float(dist0) else: 0)
        dtx0 = (if dist0 > 0: (qtx2 - qtx0) / float(dist0) else: 0)
        dty0 = (if dist0 > 0: (qty2 - qty0) / float(dist0) else: 0)

    var
        dx1 = (if dist1 > 0: (p[1][0] - p[0][0]) / float(dist1) else: 0)
        dz1 = (if dist1 > 0: (p[1][2] - p[0][2]) / float(dist1) else: 0)
        dtx1 = (if dist1 > 0: (qtx1 - qtx0) / float(dist1) else: 0)
        dty1 = (if dist0 > 0: (qty1 - qty0) / float(dist1) else: 0)

    while y <= int(p[2][1]):
        if flip == 0 and y >= int(p[1][1]):
            flip = 1
            dx1 = (if dist2 > 0: (p[2][0] - p[1][0]) / float(dist2) else: 0)
            dz1 = (if dist2 > 0: (p[2][2] - p[1][2]) / float(dist2) else: 0)
            dtx1 = (if dist2 > 0: (qtx2 - qtx1) / float(dist2) else: 0)
            dty1 = (if dist0 > 0: (qty2 - qty1) / float(dist2) else: 0)
            x1 = p[1][0]
            z1 = p[1][2]
            tx1 = qtx1
            ty1 = qty1
        drawScanline(int(x0), z0, int(x1), z1, y, s, zb, c, tx0, tx1, ty0, ty1, view, light, ambient, areflect, dreflect, sreflect, maps)
        x0 += dx0
        x1 += dx1
        z0 += dz0
        z1 += dz1
        y += 1
        tx0 += dtx0
        tx1 += dtx1
        ty0 += dty0
        ty1 += dty1

proc gScanLine(m, n: Matrix, i: int, s: var Screen, zb: var ZBuffer, view: tuple, light: Matrix, ambient: Color, areflect, dreflect, sreflect: tuple) =
    var 
        p: Matrix = m[3*i .. 3*i + 2]
        q = newOrderedTable[seq[float], seq[float]]()
        flip = 0

    for j in 0..<3:
        q[m[3*i + j]] = n[3*i + j]

    p.sort(cmpY)
    q.sort(cmpHashY)
    # bottom: p[0], middle: p[1], top: p[2]

    let 
        n0 = (q[p[0]][0], q[p[0]][1], q[p[0]][2])
        n1 = (q[p[1]][0], q[p[1]][1], q[p[1]][2])
        n2 = (q[p[2]][0], q[p[2]][1], q[p[2]][2])
        i0: Color = getLighting(n0, view, ambient, light, areflect, dreflect, sreflect)
        i1: Color = getLighting(n1, view, ambient, light, areflect, dreflect, sreflect)
        i2: Color = getLighting(n2, view, ambient, light, areflect, dreflect, sreflect)

    var
        x0 = p[0][0]
        x1 = p[0][0]
        z0 = p[0][2]
        z1 = p[0][2]
        y: int = int(p[0][1])
        c0: Color = i0
        c1: Color = i0

    let
        dist0 = int(p[2][1]) - y + 1
        dist1 = int(p[1][1]) - y + 1
        dist2 = int(p[2][1]) - int(p[1][1]) + 1

        dx0 = (if dist0 > 0: (p[2][0] - p[0][0]) / float(dist0) else: 0)
        dz0 = (if dist0 > 0: (p[2][2] - p[0][2]) / float(dist0) else: 0)
        dc0 = (if dist0 > 0: (i2 - i0) / float(dist0) else: (red: 0.0, green: 0.0, blue: 0.0))

    var
        dx1 = (if dist1 > 0: (p[1][0] - p[0][0]) / float(dist1) else: 0)
        dz1 = (if dist1 > 0: (p[1][2] - p[0][2]) / float(dist1) else: 0)
        dc1 = (if dist1 > 0: (i1 - i0) / float(dist1) else: (red: 0.0, green: 0.0, blue: 0.0))

    while y <= int(p[2][1]):
        if flip == 0 and y >= int(p[1][1]):
            flip = 1
            dx1 = (if dist2 > 0: (p[2][0] - p[1][0]) / float(dist2) else: 0)
            dz1 = (if dist2 > 0: (p[2][2] - p[1][2]) / float(dist2) else: 0)
            dc1 = (if dist2 > 0: (i2 - i1) / float(dist2) else: (red: 0.0, green: 0.0, blue: 0.0))
            x1 = p[1][0]
            z1 = p[1][2]
            c1 = i1
        drawGScanline(int(x0), z0, int(x1), z1, y, s, zb, c0, c1)
        x0 += dx0
        x1 += dx1
        z0 += dz0
        z1 += dz1
        c0 = c0 + dc0
        c1 = c1 + dc1
        y += 1

proc gScanLine(m, n: Matrix, t: seq[(string, float, float)], symTab: seq[SymTab], i: int, s: var Screen, zb: var ZBuffer, normal, view: tuple, light: Matrix, ambient: Color, areflect, dreflect, sreflect: tuple) =
    var 
        p: Matrix = m[3*i .. 3*i + 2]
        q = newOrderedTable[seq[float], (seq[float], (string, float, float))]()
        flip = 0
        maps: array[3, TextureArrayRef]

    let 
        mat: SymTab = findName(symTab, t[2*i][0])
    
    for j in 0..<3:
        q[m[3*i + j]] = (n[3*i + j], t[3*i + j])

    if mat.c.mapKa != "":
        maps[0] = readPpm(mat.c.mapKa)
    if mat.c.mapKd != "":
        maps[1] = readPpm(mat.c.mapKd)
    if mat.c.mapKs != "":
        maps[2] = readPpm(mat.c.mapKs)

    p.sort(cmpY)
    # q.sort(cmpHashY)
    # bottom: p[0], middle: p[1], top: p[2]
    # q(coords) = ((normals), (matname, texCoords))

    let 
        n0 = (q[p[0]][0][0], q[p[0]][0][1], q[p[0]][0][2])
        n1 = (q[p[1]][0][0], q[p[1]][0][1], q[p[1]][0][2])
        n2 = (q[p[2]][0][0], q[p[2]][0][1], q[p[2]][0][2])
        qtx0 = q[p[0]][1][1]
        qty0 = q[p[0]][1][2]
        qtx1 = q[p[1]][1][1]
        qty1 = q[p[1]][1][2]
        qtx2 = q[p[2]][1][1]
        qty2 = q[p[2]][1][2]
        i0: Color = getLighting(n0, view, ambient, light, areflect, dreflect, sreflect)
        i1: Color = getLighting(n1, view, ambient, light, areflect, dreflect, sreflect)
        i2: Color = getLighting(n2, view, ambient, light, areflect, dreflect, sreflect)

    var
        x0 = p[0][0]
        x1 = p[0][0]
        z0 = p[0][2]
        z1 = p[0][2]
        y: int = int(p[0][1])
        c0: Color = i0
        c1: Color = i0
        tx0 = qtx0
        tx1 = qtx0
        ty0 = qty0
        ty1 = qty0

    let
        dist0 = int(p[2][1]) - y + 1
        dist1 = int(p[1][1]) - y + 1
        dist2 = int(p[2][1]) - int(p[1][1]) + 1

        dx0 = (if dist0 > 0: (p[2][0] - p[0][0]) / float(dist0) else: 0)
        dz0 = (if dist0 > 0: (p[2][2] - p[0][2]) / float(dist0) else: 0)
        dc0 = (if dist0 > 0: (i2 - i0) / float(dist0) else: (red: 0.0, green: 0.0, blue: 0.0))
        dtx0 = (if dist0 > 0: (qtx2 - qtx0) / float(dist0) else: 0)
        dty0 = (if dist0 > 0: (qty2 - qty0) / float(dist0) else: 0)

    var
        dx1 = (if dist1 > 0: (p[1][0] - p[0][0]) / float(dist1) else: 0)
        dz1 = (if dist1 > 0: (p[1][2] - p[0][2]) / float(dist1) else: 0)
        dc1 = (if dist1 > 0: (i1 - i0) / float(dist1) else: (red: 0.0, green: 0.0, blue: 0.0))
        dtx1 = (if dist1 > 0: (qtx1 - qtx0) / float(dist1) else: 0)
        dty1 = (if dist0 > 0: (qty1 - qty0) / float(dist1) else: 0)

    while y <= int(p[2][1]):
        if flip == 0 and y >= int(p[1][1]):
            flip = 1
            dx1 = (if dist2 > 0: (p[2][0] - p[1][0]) / float(dist2) else: 0)
            dz1 = (if dist2 > 0: (p[2][2] - p[1][2]) / float(dist2) else: 0)
            dc1 = (if dist2 > 0: (i2 - i1) / float(dist2) else: (red: 0.0, green: 0.0, blue: 0.0))
            dtx1 = (if dist2 > 0: (qtx2 - qtx1) / float(dist2) else: 0)
            dty1 = (if dist0 > 0: (qty2 - qty1) / float(dist2) else: 0)
            x1 = p[1][0]
            z1 = p[1][2]
            c1 = i1
            tx1 = qtx1
            ty1 = qty1
        drawGScanline(int(x0), z0, int(x1), z1, y, s, zb, c0, c1, normal, tx0, tx1, ty0, ty1, view, light, ambient, areflect, dreflect, sreflect, maps)
        x0 += dx0
        x1 += dx1
        z0 += dz0
        z1 += dz1
        c0 = c0 + dc0
        c1 = c1 + dc1
        y += 1
        tx0 += dtx0
        tx1 += dtx1
        ty0 += dty0
        ty1 += dty1

proc pScanLine(m, n: Matrix, i: int, s: var Screen, zb: var ZBuffer, view: tuple, light: Matrix, ambient: Color, areflect, dreflect, sreflect: tuple) =
    var 
        p: Matrix = m[3*i .. 3*i + 2]
        q = newOrderedTable[seq[float], seq[float]]()
        flip = 0

    for j in 0..<3:
        q[m[3*i + j]] = n[3*i + j]

    p.sort(cmpY)
    q.sort(cmpHashY)
    # bottom: p[0], middle: p[1], top: p[2]

    let 
        n0 = (q[p[0]][0], q[p[0]][1], q[p[0]][2])
        n1 = (q[p[1]][0], q[p[1]][1], q[p[1]][2])
        n2 = (q[p[2]][0], q[p[2]][1], q[p[2]][2])

    var
        x0 = p[0][0]
        x1 = p[0][0]
        z0 = p[0][2]
        z1 = p[0][2]
        y: int = int(p[0][1])
        nx0 = n0
        nx1 = n0

    let
        dist0 = int(p[2][1]) - y + 1
        dist1 = int(p[1][1]) - y + 1
        dist2 = int(p[2][1]) - int(p[1][1]) + 1

        dx0 = (if dist0 > 0: (p[2][0] - p[0][0]) / float(dist0) else: 0)
        dz0 = (if dist0 > 0: (p[2][2] - p[0][2]) / float(dist0) else: 0)
        dn0 = (if dist0 > 0: (n2 - n0) / float(dist0) else: (0.0, 0.0, 0.0))

    var
        dx1 = (if dist1 > 0: (p[1][0] - p[0][0]) / float(dist1) else: 0)
        dz1 = (if dist1 > 0: (p[1][2] - p[0][2]) / float(dist1) else: 0)
        dn1 = (if dist1 > 0: (n1 - n0) / float(dist1) else: (0.0, 0.0, 0.0))

    while y <= int(p[2][1]):
        if flip == 0 and y >= int(p[1][1]):
            flip = 1
            dx1 = (if dist2 > 0: (p[2][0] - p[1][0]) / float(dist2) else: 0)
            dz1 = (if dist2 > 0: (p[2][2] - p[1][2]) / float(dist2) else: 0)
            dn1 = (if dist2 > 0: (n2 - n1) / float(dist2) else: (0.0, 0.0, 0.0))
            x1 = p[1][0]
            z1 = p[1][2]
            nx1 = n1
        drawPScanline(int(x0), z0, int(x1), z1, y, s, zb, nx0, nx1, view, light, ambient, areflect, dreflect, sreflect)
        x0 += dx0
        x1 += dx1
        z0 += dz0
        z1 += dz1
        nx0 = nx0 + dn0
        nx1 = nx1 + dn1
        y += 1

proc drawGPolygons*(m, n: var Matrix, s: var Screen, zb: var ZBuffer, view: tuple, light: Matrix, ambient: Color, areflect, dreflect, sreflect: tuple) =
    # echo m
    for i in 0..<(m.len div 3):
        let fnormal = ((n[3*i][0] + n[3*i + 1][0] + n[3*i + 2][0]) / 3, (n[3*i][1] + n[3*i + 1][1] + n[3*i + 2][1]) / 3, (n[3*i][2] + n[3*i + 1][2] + n[3*i + 2][2]) / 3)
        if dotProduct(fnormal, (0.0, 0.0, 1.0)) > 0:
            gScanLine(m, n, i, s, zb, view, light, ambient, areflect, dreflect, sreflect)

proc drawGPolygons*(m, n: var Matrix, t: seq[(string, float, float)], symTab: seq[SymTab], s: var Screen, zb: var ZBuffer, view: tuple, light: Matrix, ambient: Color, areflect, dreflect, sreflect: tuple) =
    # echo m
    for i in 0..<(m.len div 3):
        let fnormal = ((n[3*i][0] + n[3*i + 1][0] + n[3*i + 2][0]) / 3, (n[3*i][1] + n[3*i + 1][1] + n[3*i + 2][1]) / 3, (n[3*i][2] + n[3*i + 1][2] + n[3*i + 2][2]) / 3)
        if dotProduct(fnormal, (0.0, 0.0, 1.0)) > 0:
            gScanLine(m, n, t, symTab, i, s, zb, fnormal, view, light, ambient, areflect, dreflect, sreflect)

proc drawPPolygons*(m, n: var Matrix, s: var Screen, zb: var ZBuffer, view: tuple, light: Matrix, ambient: Color, areflect, dreflect, sreflect: tuple) =
    # echo m
    for i in 0..<(m.len div 3):
        let fnormal = ((n[3*i][0] + n[3*i + 1][0] + n[3*i + 2][0]) / 3, (n[3*i][1] + n[3*i + 1][1] + n[3*i + 2][1]) / 3, (n[3*i][2] + n[3*i + 1][2] + n[3*i + 2][2]) / 3)
        if dotProduct(fnormal, (0.0, 0.0, 1.0)) > 0:
            pScanLine(m, n, i, s, zb, view, light, ambient, areflect, dreflect, sreflect)

proc drawPPolygons*(m, n: var Matrix, t: seq[(string, float, float)], symTab: seq[SymTab], s: var Screen, zb: var ZBuffer, view: tuple, light: Matrix, ambient: Color, areflect, dreflect, sreflect: tuple) =
    # echo m
    for i in 0..<(m.len div 3):
        let fnormal = ((n[3*i][0] + n[3*i + 1][0] + n[3*i + 2][0]) / 3, (n[3*i][1] + n[3*i + 1][1] + n[3*i + 2][1]) / 3, (n[3*i][2] + n[3*i + 1][2] + n[3*i + 2][2]) / 3)
        if dotProduct(fnormal, (0.0, 0.0, 1.0)) > 0:
            pScanLine(m, n, i, s, zb, view, light, ambient, areflect, dreflect, sreflect)

proc drawPolygons*(m, n: var Matrix, t: seq[(string, float, float)], symTab: seq[SymTab], shadingType: ShadingType, s: var Screen, zb: var ZBuffer, color: Color, view: tuple, light: Matrix, ambient: Color, areflect, dreflect, sreflect: tuple) =
    if t.len > 0:
        case shadingType:
        of gouraud:
            drawGPolygons(m, n, t, symTab, s, zb, view, light, ambient, areflect, dreflect, sreflect)
        of phong:
            drawPPolygons(m, n, t, symTab, s, zb, view, light, ambient, areflect, dreflect, sreflect)
        of flat:
            for i in 0..<(m.len div 3):
                let n = calculateNormal(m, 3*i)
                if dotProduct(n, (0.0, 0.0, 1.0)) > 0:
                    # drawLine(int(a[0]), int(a[1]), a[2], int(b[0]), int(b[1]), b[2], s, zb, color)
                    # drawLine(int(b[0]), int(b[1]), b[2], int(c[0]), int(c[1]), c[2], s, zb, color)
                    # drawLine(int(c[0]), int(c[1]), c[2], int(a[0]), int(a[1]), a[2], s, zb, color)
                    let il: Color = getLighting(n, view, ambient, light, areflect, dreflect, sreflect)
                    scanLine(m, t, symTab, i, s, zb, n, il, view, light, ambient, areflect, dreflect, sreflect);
        else:
            discard
    else:
        case shadingType:
        of gouraud:
            drawGPolygons(m, n, s, zb, view, light, ambient, areflect, dreflect, sreflect)
        of phong:
            drawPPolygons(m, n, s, zb, view, light, ambient, areflect, dreflect, sreflect)
        of flat:
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
                    scanLine(m, i, s, zb, il);
        else:
            discard