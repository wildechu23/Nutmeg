import std/sequtils, std/math

# IMPORTANT: m[x][y]

type
    Matrix* = seq[seq[float]]

proc newMatrix*(r: int = 4, c: int = 4): Matrix =
    var m: Matrix
    m = newSeqWith(r, newSeq[float](c))
    for i in 0..<r:
        for j in 0..<c:
            m[i][j] = 0
    return m

proc identMatrix*(m: var Matrix) =
    for i in 0..<len(m):
        for j in 0..<len(m[0]):
            if i == j:
                m[i][j] = 1
            else:
                m[i][j] = 0

proc `$`*(m: Matrix): string =
    for i in 0..<len(m[0]):
        for j in 0..<len(m)-1:
            result &= $m[j][i]
            result &= " "
        result &= $m[len(m)-1][i]
        result &= "\n"

proc printMatrix*(m: Matrix) =
    echo $m

proc mul*(a: Matrix, b: var Matrix) = 
    # echo a.len
    # echo b.len
    for i in 0..<len(b):
        var col: seq[float]
        for j in 0..<len(b[0]):
            # echo b[i][j]
            var sum: float
            for x in 0..3:
                sum += a[x][j] * b[i][x]
            col.add sum
        for j in 0..<len(b[0]):
            b[i][j] = col[j]
            # echo b[i][j]

# proc invert4x4(m: var Matrix) =
#     var n: Matrix
#     m = newSeqWith(4, newSeq[float](4))
#     n[0][0] = m[1][1]*m[2][2]*m[3][3] - m[1][1]*m[2][3]*m[3][2] - m[2][1]*m[1][2]*m[3][3] + m[2][1]*m[1][3]*m[3][2] + m[3][1]*m[1][2]*m[2][3] - m[3][1]*m[1][3]*m[2][2]
#     n[1][0] = -m[1][0]*m[2][2]*m[3][3] + m[1][0]*m[2][3]*m[3][2] + m[2][0]*m[1][2]*m[3][3] - m[2][0]*m[1][3]*m[3][2] - m[3][0]*m[1][2]*m[2][3] + m[3][0]*m[1][3]*m[2][2]
#     n[2][0] = m[1][0]*m[2][1]*m[3][3] - m[1][0]*m[2][3]*m[3][1] - m[2][0]*m[1][1]*m[3][3] + m[2][0]*m[1][3]*m[3][1] + m[3][0]*m[1][1]*m[2][3] - m[3][0]*m[1][3]*m[2][1]
#     n[3][0] = -m[1][0]*m[2][1]*m[3][2] + m[1][0]*m[2][2]*m[3][1] + m[2][0]*m[1][1]*m[3][2] - m[2][0]*m[1][2]*m[3][1] - m[3][0]*m[1][1]*m[2][2] + m[3][0]*m[2]
#     let det = m[0][0]

# proc invertRotation(m: var Matrix) =
#     var n: Matrix = newMatrix()
#     identMatrix(n)
#     let 
#         det = m[0][0]*(m[1][1]*m[2][2] - m[2][1]*m[1][2]) - m[0][1]*(m[1][0]*m[2][2]-m[1][2]*m[2][0]) + m[0][2]*(m[1][0]*m[2][1] - m[1][1]*m[2][0])
#         invdet = 1/det
#     n[0][0] = (m[1][1]*m[2][2]-m[2][1]*m[1][2]) * invdet
#     n[1][0] = -(m[0][1]*m[2][2]-m[0][2]*m[2][1]) * invdet
#     n[2][0] = (m[0][1]*m[1][2]-m[0][2]*m[1][1]) * invdet
#     n[0][1] = -(m[1][0]*m[2][2]-m[1][2]*m[2][0]) * invdet
#     n[1][1] = (m[0][0]*m[2][2]-m[0][2]*m[2][0]) * invdet
#     n[2][1] = -(m[0][0]*m[1][2]-m[1][0]*m[0][2]) * invdet
#     n[0][2] = (m[1][0]*m[2][1]-m[2][0]*m[1][1]) * invdet
#     n[1][2] = -(m[0][0]*m[2][1]-m[2][0]*m[0][1]) * invdet
#     n[2][2] = (m[0][0]*m[1][1]-m[1][0]*m[0][1]) * invdet

proc transposeMatrix*(m: var Matrix) =
    var n: Matrix = newMatrix()
    identMatrix(n)
    for i in 0..<m.len:
        for j in 0..<m[0].len:
            n[i][j] = m[j][i];
    m = n

proc invertRotation(m: var Matrix) =
    discard


proc makeTranslate*(x, y, z: float): Matrix =
    var m: Matrix = newMatrix()
    identMatrix(m)
    m[3][0] = x
    m[3][1] = y
    m[3][2] = z
    return m

proc makeScale*(x, y, z: float): Matrix =
    var m: Matrix = newMatrix()
    for i in 0..<len(m):
        for j in 0..<len(m[0]):
            if i == j:
                case i
                of 0:
                    m[i][j] = x
                of 1:
                    m[i][j] = y
                of 2:
                    m[i][j] = z
                else:
                    m[i][j] = 1
            else:
                m[i][j] = 0
    return m

proc makeRotX*(theta: float): Matrix =
    var m: Matrix = newMatrix()
    identMatrix(m)
    let
        t = theta * PI / 180
        s = sin(t)
        c = cos(t)
    m[1][1] = c
    m[1][2] = s
    m[2][1] = -s
    m[2][2]  = c
    return m

proc makeRotY*(theta: float): Matrix =
    var m: Matrix = newMatrix()
    identMatrix(m)
    let
        t = theta * PI / 180
        s = sin(t)
        c = cos(t)
    m[0][0] = c
    m[2][0] = s
    m[0][2] = -s
    m[2][2]  = c
    return m

proc makeRotZ*(theta: float): Matrix =
    var m: Matrix = newMatrix()
    identMatrix(m)
    let
        t = theta * PI / 180
        s = sin(t)
        c = cos(t)
    m[0][0] = c
    m[0][1] = s
    m[1][0] = -s
    m[1][1]  = c
    return m

proc makeBezier*(): Matrix =
    var m: Matrix = newMatrix()
    m[0][0] = -1
    m[1][0] = 3
    m[0][1] = 3
    m[2][0] = -3
    m[1][1] = -6
    m[0][2] = -3
    m[3][0] = 1
    m[2][1] = 3
    m[1][2] = 3
    m[0][3] = 1
    return m


proc makeHermite*(): Matrix =
    var m: Matrix = newMatrix()
    m[0][0] = 2
    m[1][0] = -2
    m[2][0] = 1
    m[3][0] = 1
    m[0][1] = -3
    m[1][1] = 3
    m[2][1] = -2
    m[3][1] = -1
    m[2][2] = 1
    m[0][3] = 1
    return m

proc generateCurveCoefs*(p0, p1, p2, p3: float, t: char): Matrix =
    var g: Matrix = newMatrix()
    g[0][0] = p0
    g[0][1] = p1
    g[0][2] = p2
    g[0][3] = p3
    case t:
        of 'h':
            mul(makeHermite(), g)
        of 'b':
            mul(makeBezier(), g)
        else: raise newException(ValueError, "Curve not type h or b")
    return g