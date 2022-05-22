import matrix, std/strformat

type
    symKind* = enum
        symMatrix,
        symConstants,
        symLight,
        symValue

    Constants = object
        r: array[4, float]
        g: array[4, float]
        b: array[4, float]
        red, green, blue: float
    
    Light = object
        l: array[4, float]
        c: array[4, float]

    SymTabObj* = object
        name: string
        case kind: symKind
        of symMatrix: m: Matrix
        of symConstants: c: Constants
        of symLight: l: Light
        of symValue: value: float

    SymTab* = ref SymTabObj

proc printConstants*(p: Constants) =
    echo &"\tRed -\t Ka: {p.r[0]} Kd: {p.r[1]} Ks: {p.r[2]}" 
    echo &"\tGreen -\t Ka: {p.g[0]} Kd: {p.g[1]} Ks: {p.g[2]}"
    echo &"\tBlue -\t Ka: {p.b[0]} Kd: {p.b[1]} Ks: {p.b[2]}"

proc printLight*(p: Light) =
    echo &"\tLocation -\t {p.l[0]} {p.l[1]} {p.l[2]}"
    echo &"\tBrightness -\t r:{p.c[0]} g:{p.c[1]} b:{p.c[2]}"

proc printSymTab*(p: seq[SymTab]) =
    for i in p:
        case i.kind:
        of symMatrix:
            printMatrix(i.m)
        of symConstants:
            printConstants(i.c)
        of symLight:
            printLight(i.l)
        of symValue:
            echo i.value

proc lookupSymbol*(p: seq[SymTab], name: string): SymTab =
    for i in p:
        if name == i.name:
            return i
    return nil

proc addSymbol*(p: var seq[SymTab], name: string, kind: symKind, data: pointer): SymTab = 
    var t: SymTab
    new(t)

    t.name = name
    t.kind = kind
    case kind:
    of symMatrix:
        t.m = cast[Matrix](data)
    of symConstants:
        t.c = cast[Constants](data)
    of symLight:
        t.l = cast[Light](data)
    of symValue:
        t.value = cast[float](data)

    p.add(t)
    return t

proc sesymValue*(p: SymTab, value: float) =
    p.value = value