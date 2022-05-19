import matrix

type
    constants = object
        r: array[4, float]
        g: array[4, float]
        b: array[4, float]
        red, green, blue: float
    
    light = object
        l: array[4, float]
        c: array[4, float]

    sym {.union.} = object
        m: Matrix
        c: constants
        l: light
        value: float

    SymTab = object
        name: char
        tType: int
        s: sym

