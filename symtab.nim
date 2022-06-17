import matrix, std/strformat

type
    symKind* = enum
        symMatrix,
        symConstants,
        symLight,
        symValue,
        symFile,
        symString

    Constants* = object
        r*: array[4, float]
        g*: array[4, float]
        b*: array[4, float]
        red*, green*, blue*: float
        mapKa*, mapKd*, mapKs*: string
    
    Light* = object
        l*: array[4, float]
        c*: array[4, float]

    SymTabObj = object
        name*: string
        case kind*: symKind
        of symMatrix: m*: Matrix
        of symConstants: c*: Constants
        of symLight: l*: Light
        of symValue: value*: float
        of symString: discard
        of symFile: discard

    SymTab* = ref SymTabObj

proc findName*(p: seq[SymTab], s: string): SymTab = 
    for i in p:
        if i.name == s:
            return i
    return nil

proc printConstants(p: Constants) =
    echo &"\tRed -\t Ka: {p.r[0]} Kd: {p.r[1]} Ks: {p.r[2]}" 
    echo &"\tGreen -\t Ka: {p.g[0]} Kd: {p.g[1]} Ks: {p.g[2]}"
    echo &"\tBlue -\t Ka: {p.b[0]} Kd: {p.b[1]} Ks: {p.b[2]}"

proc printLight(p: Light) =
    echo &"\tLocation -\t {p.l[0]} {p.l[1]} {p.l[2]}"
    echo &"\tBrightness -\t r:{p.c[0]} g:{p.c[1]} b:{p.c[2]}"


proc printSymTab*(p: seq[SymTab]) =
    for i in p:
        case i.kind:
        of symMatrix:
            printMatrix(i.m)
        of symConstants:
            echo i.name
            printConstants(i.c)
        of symLight:
            printLight(i.l)
        of symValue:
            echo i.value
        of symFile, symString:
            echo i.name
