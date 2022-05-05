import display, matrix, std/math

proc normalize(v: var tuple) =
    let magnitude: float = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2])
    for i in v:
        i /= magnitude

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

proc calculateAmbient(alight: Color, areflect: tuple): Color =
    result.red = alight.red * areflect[0]
    result.green = alight.green * areflect[1]
    result.blue = alight.blue * areflect[2]

proc calculateDiffuse(light: Matrix, dreflect, normal: tuple): Color =
    let 
        n: tuple = normal
        l: tuple = (light[0][0], light[0][1], light[0][2])
    normalize(n)
    normalize(l)
    result.red = light[1][0] * dreflect[0] * dotProduct(normal, l)
    result.green = light[1][1] * dreflect[1] * dotProduct(normal, l)
    result.blue = light[1][2] * dreflect[2] * dotProduct(normal, l)

proc calculateSpecular(light: Matrix, sreflect, view, normal: tuple): Color =
    discard

proc getLighting(normal, view: tuple, alight: Color, light: Matrix, areflect, dreflect, sreflect: tuple): Color =
    discard