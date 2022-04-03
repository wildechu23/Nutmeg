import matrix

proc normalize(v: tuple) =
    return

proc dotProduct*(a, b: tuple): float =
    a[0]*b[0] + a[1]*b[1] + a[2]*b[2]

proc calculateNormal*(m: Matrix, i: int): tuple =
    let
        p0 = m[i]
        p1 = m[i+1]
        p2 = m[i+2]
        a: tuple = (p1[0]-p0[0], p1[1]-p0[1], p1[2]-p0[2])
        b: tuple = (p2[0]-p0[0], p2[1]-p0[1], p2[2]-p0[2])
    (a[1]*b[2] - a[2]*b[1], a[2]*b[0] - a[0]*b[2], a[0]*b[1] - a[1]*b[0])
    