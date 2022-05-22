import matrix

type
    tKind = enum
        tMatrix,
        tConstants,
        tLight,
        tValue

    Constants = object
        r: array[4, float]
        g: array[4, float]
        b: array[4, float]
        red, green, blue: float
    
    Light = object
        l: array[4, float]
        c: array[4, float]

    SymTab* = object
        name: char
        case kind: tKind
        of tMatrix: m: Matrix
        of tConstants: c: Constants
        of tLight: l: Light
        of tValue: value: float
        