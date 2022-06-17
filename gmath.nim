import display, matrix, std/math

proc normalize(v: tuple): tuple =
    let magnitude: float = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2])
    var r: tuple = (0.0, 0.0, 0.0)
    r[0] = v[0] / magnitude
    r[1] = v[1] / magnitude
    r[2] = v[2] / magnitude
    return r

proc dotProduct*(a, b: tuple): float =
    a[0]*b[0] + a[1]*b[1] + a[2]*b[2]

proc subtract(t, u: tuple): tuple =
    var r: tuple = (0.0, 0.0, 0.0)
    r[0] = t[0] - u[0]  
    r[1] = t[1] - u[1]
    r[2] = t[2] - u[2]
    return r

proc scale(t: tuple, f: float): tuple =
    var r: tuple = (0.0, 0.0, 0.0)
    r[0] = t[0] * f    
    r[1] = t[1] * f
    r[2] = t[2] * f
    return r


proc calculateNormal*(m: Matrix, i: int): tuple =
    let
        p0 = m[i]
        p1 = m[i+1]
        p2 = m[i+2]
        a: tuple = (p1[0]-p0[0], p1[1]-p0[1], p1[2]-p0[2])
        b: tuple = (p2[0]-p0[0], p2[1]-p0[1], p2[2]-p0[2])
    (a[1]*b[2] - a[2]*b[1], a[2]*b[0] - a[0]*b[2], a[0]*b[1] - a[1]*b[0])

proc calculateAmbient(alight: Color, areflect: tuple): Color =
    result.red = (alight.red * areflect[0]).clamp(0, 255)
    result.green = (alight.green * areflect[1]).clamp(0, 255)
    result.blue = (alight.blue * areflect[2]).clamp(0, 255)

proc calculateDiffuse(light: Matrix, dreflect: tuple, normal: tuple): Color =
    var 
        n: tuple = normalize(normal)
        l: tuple = normalize((light[0][0], light[0][1], light[0][2]))
        d: float = dotProduct(n, l)
    
    result.red = (light[1][0] * dreflect[0] * d).clamp(0, 255)
    result.green = (light[1][1] * dreflect[1] * d).clamp(0, 255)
    result.blue = (light[1][2] * dreflect[2] * d).clamp(0, 255)

proc calculateSpecular*(light: Matrix, sreflect: tuple, view, normal: tuple): Color =
    var 
        n: tuple = normalize(normal)
        l: tuple = normalize((light[0][0], light[0][1], light[0][2]))
        v: tuple = normalize(view)
        d: float = dotProduct(subtract(scale(scale(n, 2), dotProduct(n, l)), l), v)
    result.red = (light[1][0] * sreflect[0] * d).clamp(0, 255)
    result.green = (light[1][1] * sreflect[1] * d).clamp(0, 255)
    result.blue = (light[1][2] * sreflect[2] * d).clamp(0, 255)

proc calculateTAmbient(alight: Color, areflect: tuple): Color =
    result.red = (alight.red / 255 * areflect[0])
    result.green = (alight.green / 255 * areflect[1])
    result.blue = (alight.blue / 255 * areflect[2])

proc calculateTDiffuse(light: Matrix, dreflect: tuple, normal: tuple): Color =
    var 
        n: tuple = normalize(normal)
        l: tuple = normalize((light[0][0], light[0][1], light[0][2]))
        d: float = dotProduct(n, l)
    
    result.red = (dreflect[0] * d).clamp(0, 1)
    result.green = (dreflect[1] * d).clamp(0, 1)
    result.blue = (dreflect[2] * d).clamp(0, 1)

# proc calculateTSpecular(light: Matrix, sreflect: tuple, view, normal: tuple): Color =
#     var 
#         n: tuple = normalize(normal)
#         l: tuple = normalize((light[0][0], light[0][1], light[0][2]))
#         v: tuple = normalize(view)
#         d: float = dotProduct(subtract(scale(scale(n, 2), dotProduct(n, l)), l), v)
#     result.red = (light[1][0] * sreflect[0] * d).clamp(0, 255)
#     result.green = (light[1][1] * sreflect[1] * d).clamp(0, 255)
#     result.blue = (light[1][2] * sreflect[2] * d).clamp(0, 255)

proc getLighting*(normal, view: tuple, alight: Color, light: Matrix, areflect, dreflect, sreflect: tuple): Color =
    let 
        a = calculateAmbient(alight, areflect)
        d = calculateDiffuse(light, dreflect, normal)
        s = calculateSpecular(light, sreflect, view, normal)
    # echo "dred " & $d.red
    # echo "dgreen " & $d.green
    result = a + d + s
    clampColor(result)

    
proc getTLighting*(normal, view: tuple, alight: Color, light: Matrix, areflect, dreflect, sreflect: tuple, tx, ty: float, maps: array[3, TextureArrayRef]): Color =
    let
        a = calculateTAmbient(alight, areflect)
        d = calculateTDiffuse(light, dreflect, normal)
        s = calculateSpecular(light, sreflect, view, normal)
        mapKd = maps[1]
        xs = mapKd[0].len
        ys = mapKd[].len
        td = mapKd[int(tx * float(xs-1))][int(ty * float(ys-1))]
    var x = a+d
    clampTColor(x)
    result = x * td + s
    clampColor(result)

# FOR GOURAUD WITH TEXTURES
proc getGTLighting*(normal: tuple, alight: Color, light: Matrix, areflect, dreflect, sreflect: tuple): Color =
    let
        a = calculateTAmbient(alight, areflect)
        d = calculateTDiffuse(light, dreflect, normal)
    result = a+d
    clampTColor(result)