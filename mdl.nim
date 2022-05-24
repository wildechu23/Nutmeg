import matrix, nimly, parser, patty, strutils, symtab, unittest

variantp Token:
    FLOAT(val: float)
    COMMENT
    LIGHT
    CONSTANTS
    SAVECOORDS
    CAMERA
    AMBIENT
    TORUS
    SPHERE
    BOX
    LINE
    MESH
    TEXTURE
    SET
    MOVE
    SCALE
    ROTATE
    BASENAME
    SAVEKNOBS
    TWEEN
    FRAMES
    VARY
    PUSH
    POP
    SAVE
    GENERATERAYFILES
    SHADING
    SHADINGTYPE(shadeType: string)
    SETKNOBS
    FOCAL
    DISPLAY
    WEB
    CO
    STRING(str: string)
    IGNORE

var p: seq[SymTab] = @[]

niml mdlLex[Token]:
    # r"-?\d+":
    #     return FLOAT(parseFloat(token.token))
    # r"-?\d+\.":
    #     return FLOAT(parseFloat(token.token))
    # r"-?\d+\.\d+":
    #     return FLOAT(parseFloat(token.token))
    # r"-?\.\d+":
    #     return FLOAT(parseFloat(token.token))
    # r"//.*":
    #     return COMMENT()
    r"light":
        return LIGHT()
    r"constants":
        return CONSTANTS()
    r"save_coord_system":
        return SAVECOORDS()
    r"camera":
        return CAMERA()
    r"ambient":
        return AMBIENT()
    r"torus":
        return TORUS()
    r"sphere":
        return SPHERE()
    r"box":
        return BOX()
    r"line":
        return LINE()
    r"mesh":
        return MESH()
    r"texture":
        return TEXTURE()
    r"set":
        return SET()
    r"move":
        return MOVE()
    r"scale":
        return SCALE()
    r"rotate":
        return ROTATE()
    r"basename":
        return BASENAME()
    r"save_knobs":
        return SAVEKNOBS()
    r"tween":
        return TWEEN()
    r"frames":
        return FRAMES()
    r"vary":
        return VARY()
    r"push":
        return PUSH()
    r"pop":
        return POP()
    r"save":
        return SAVE()
    r"generate_rayfiles":
        return GENERATERAYFILES()
    r"shading":
        return SHADING()
    # r"phong":
    #     return SHADINGTYPE(token.token)
    # r"flat":
    #     return SHADINGTYPE(token.token)
    # r"gouraud":
    #     return SHADINGTYPE(token.token)
    # r"raytrace":
    #     return SHADINGTYPE(token.token)
    # r"wireframe":
    #     return SHADINGTYPE(token.token)
    # r"setknobs":
    #     return SETKNOBS()
    # r"focal":
    #     return FOCAL()
    # r"display":
    #     return DISPLAY()
    # r"web":
    #     return WEB()
    # r":":
        # return CO()
    # r"\w*":
    #     return STRING(token.token)
    # r"\s":
    #     return IGNORE()

nimy mdlPar[Token]:
    top[seq[Command]]:
        SPHERE FLOAT FLOAT FLOAT FLOAT:
            let a: array[4, float] = [($2).val, ($3).val, ($4).val, 0]
            var op: Command = Command(kind: sphere, sphereConstants: nil, sphereCS: nil, sphered: a, spherer: ($5).val)
            return @[op]
        SPHERE FLOAT FLOAT FLOAT FLOAT STRING:
            let a: array[4, float] = [($2).val, ($3).val, ($4).val, 0]
            var 
                m: Matrix = newMatrix(4,4)
                cs: SymTab = addSymbol(p, ($6).str, symMatrix, cast[pointer](m))
                op: Command = Command(kind: sphere, sphereConstants: nil, sphereCS: cs, sphered: a, spherer: ($5).val)
            return @[op]
        SPHERE STRING FLOAT FLOAT FLOAT FLOAT:
            let a: array[4, float] = [($3).val, ($4).val, ($5).val, 0]
            var 
                c: Constants = newConstants()
                cons: SymTab = addSymbol(p, ($2).str, symConstants, addr(c))
                op: Command = Command(kind: sphere, sphereConstants: cons, sphereCS: nil, sphered: a, spherer: ($6).val)
            return @[op]
        SPHERE STRING FLOAT FLOAT FLOAT FLOAT STRING:
            let a: array[4, float] = [($3).val, ($4).val, ($5).val, 0]
            var 
                m: Matrix = newMatrix(4,4)
                cs: SymTab = addSymbol(p, ($7).str, symMatrix, cast[pointer](m))
                c: Constants = newConstants()
                cons: SymTab = addSymbol(p, ($2).str, symConstants, addr(c))
                op: Command = Command(kind: sphere, sphereConstants: cons, sphereCS: cs, sphered: a, spherer: ($6).val)
            return @[op]
        TORUS FLOAT FLOAT FLOAT FLOAT FLOAT:
            let a: array[4, float] = [($2).val, ($3).val, ($4).val, 0]
            var op: Command = Command(kind: torus, torusConstants: nil, torusCS: nil, torusd: a, torusr0: ($5).val, torusr1: ($6).val)
            return @[op]
        TORUS FLOAT FLOAT FLOAT FLOAT FLOAT STRING:
            let a: array[4, float] = [($2).val, ($3).val, ($4).val, 0]
            var 
                m: Matrix = newMatrix(4,4)
                cs: SymTab = addSymbol(p, ($7).str, symMatrix, cast[pointer](m))
                op: Command = Command(kind: torus, torusConstants: nil, torusCS: cs, torusd: a, torusr0: ($5).val, torusr1: ($6).val)
            return @[op]
        TORUS STRING FLOAT FLOAT FLOAT FLOAT FLOAT:
            let a: array[4, float] = [($3).val, ($4).val, ($5).val, 0]
            var 
                c: Constants = newConstants()
                cons: SymTab = addSymbol(p, ($2).str, symConstants, addr(c))
                op: Command = Command(kind: torus, torusConstants: cons, torusCS: nil, torusd: a, torusr0: ($6).val, torusr1: ($7).val)
            return @[op]
        TORUS STRING FLOAT FLOAT FLOAT FLOAT FLOAT STRING:
            let a: array[4, float] = [($3).val, ($4).val, ($5).val, 0]
            var 
                m: Matrix = newMatrix(4,4)
                cs: SymTab = addSymbol(p, ($8).str, symMatrix, cast[pointer](m))
                c: Constants = newConstants()
                cons: SymTab = addSymbol(p, ($2).str, symConstants, addr(c))
                op: Command = Command(kind: torus, torusConstants: cons, torusCS: cs, torusd: a, torusr0: ($6).val, torusr1: ($7).val)
            return @[op]
        BOX FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT:
            let 
                a: array[4, float] = [($2).val, ($3).val, ($4).val, 0]
                b: array[4, float] = [($5).val, ($6).val, ($7).val, 0]
            var op: Command = Command(kind: box, boxConstants: nil, boxCS: nil, boxd0: a, boxd1: b)
            return @[op]
        BOX FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT STRING:
            let 
                a: array[4, float] = [($2).val, ($3).val, ($4).val, 0]
                b: array[4, float] = [($5).val, ($6).val, ($7).val, 0]
            var  
                m: Matrix = newMatrix(4,4)
                cs: SymTab = addSymbol(p, ($8).str, symMatrix, cast[pointer](m))
                op: Command = Command(kind: box, boxConstants: nil, boxCS: cs, boxd0: a, boxd1: b)
            return @[op]
        BOX STRING FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT:
            let 
                a: array[4, float] = [($3).val, ($4).val, ($5).val, 0]
                b: array[4, float] = [($6).val, ($7).val, ($8).val, 0]
            var  
                c: Constants = newConstants()
                cons: SymTab = addSymbol(p, ($2).str, symConstants, addr(c))
                op: Command = Command(kind: box, boxConstants: cons, boxCS: nil, boxd0: a, boxd1: b)
            return @[op]
        BOX STRING FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT STRING:
            let 
                a: array[4, float] = [($3).val, ($4).val, ($5).val, 0]
                b: array[4, float] = [($6).val, ($7).val, ($8).val, 0]
            var  
                m: Matrix = newMatrix(4,4)
                cs: SymTab = addSymbol(p, ($9).str, symMatrix, cast[pointer](m))
                c: Constants = newConstants()
                cons: SymTab = addSymbol(p, ($2).str, symConstants, addr(c))
                op: Command = Command(kind: box, boxConstants: cons, boxCS: cs, boxd0: a, boxd1: b)
            return @[op]
        LINE FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT:
            let 
                a: array[4, float] = [($2).val, ($3).val, ($4).val, 0]
                b: array[4, float] = [($5).val, ($6).val, ($7).val, 0]
            var op: Command = Command(kind: line, lineConstants: nil, linecs0: nil, linecs1: nil, linep0: a, linep1: b)
            return @[op]
        LINE FLOAT FLOAT FLOAT STRING FLOAT FLOAT FLOAT:
            let 
                a: array[4, float] = [($2).val, ($3).val, ($4).val, 0]
                b: array[4, float] = [($6).val, ($7).val, ($8).val, 0]
            var 
                m: Matrix = newMatrix(4,4)
                cs0: SymTab = addSymbol(p, ($5).str, symMatrix, cast[pointer](m))
                op: Command = Command(kind: line, lineConstants: nil, linecs0: cs0, linecs1: nil, linep0: a, linep1: b)
            return @[op]
        LINE FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT STRING:
            let 
                a: array[4, float] = [($2).val, ($3).val, ($4).val, 0]
                b: array[4, float] = [($5).val, ($6).val, ($7).val, 0]
            var 
                m: Matrix = newMatrix(4,4)
                cs1: SymTab = addSymbol(p, ($8).str, symMatrix, cast[pointer](m))
                op: Command = Command(kind: line, lineConstants: nil, linecs0: nil, linecs1: cs1, linep0: a, linep1: b)
            return @[op]
        LINE FLOAT FLOAT FLOAT STRING FLOAT FLOAT FLOAT STRING:
            let 
                a: array[4, float] = [($2).val, ($3).val, ($4).val, 0]
                b: array[4, float] = [($6).val, ($7).val, ($8).val, 0]
            var 
                m: Matrix = newMatrix(4,4)
                cs0: SymTab = addSymbol(p, ($5).str, symMatrix, cast[pointer](m))
                cs1: SymTab = addSymbol(p, ($9).str, symMatrix, cast[pointer](m))
                op: Command = Command(kind: line, lineConstants: nil, linecs0: cs0, linecs1: cs1, linep0: a, linep1: b)
            return @[op]
        LINE STRING FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT:
            let 
                a: array[4, float] = [($3).val, ($4).val, ($5).val, 0]
                b: array[4, float] = [($6).val, ($7).val, ($8).val, 0]
            var 
                c: Constants = newConstants()
                cons: SymTab = addSymbol(p, ($2).str, symConstants, addr(c))
                op: Command = Command(kind: line, lineConstants: cons, linecs0: nil, linecs1: nil, linep0: a, linep1: b)
            return @[op]
        LINE STRING FLOAT FLOAT FLOAT STRING FLOAT FLOAT FLOAT:
            let 
                a: array[4, float] = [($3).val, ($4).val, ($5).val, 0]
                b: array[4, float] = [($7).val, ($8).val, ($9).val, 0]
            var 
                m: Matrix = newMatrix(4,4)
                cs0: SymTab = addSymbol(p, ($6).str, symMatrix, cast[pointer](m))
                c: Constants = newConstants()
                cons: SymTab = addSymbol(p, ($2).str, symConstants, addr(c))
                op: Command = Command(kind: line, lineConstants: cons, linecs0: cs0, linecs1: nil, linep0: a, linep1: b)
            return @[op]
        LINE STRING FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT STRING:
            let 
                a: array[4, float] = [($3).val, ($4).val, ($5).val, 0]
                b: array[4, float] = [($6).val, ($7).val, ($8).val, 0]
            var 
                m: Matrix = newMatrix(4,4)
                cs1: SymTab = addSymbol(p, ($9).str, symMatrix, cast[pointer](m))
                c: Constants = newConstants()
                cons: SymTab = addSymbol(p, ($2).str, symConstants, addr(c))
                op: Command = Command(kind: line, lineConstants: cons, linecs0: nil, linecs1: cs1, linep0: a, linep1: b)
            return @[op]
        LINE STRING FLOAT FLOAT FLOAT STRING FLOAT FLOAT FLOAT STRING:
            let 
                a: array[4, float] = [($3).val, ($4).val, ($5).val, 0]
                b: array[4, float] = [($7).val, ($8).val, ($9).val, 0]
            var 
                m: Matrix = newMatrix(4,4)
                cs0: SymTab = addSymbol(p, ($6).str, symMatrix, cast[pointer](m))
                cs1: SymTab = addSymbol(p, ($10).str, symMatrix, cast[pointer](m))
                c: Constants = newConstants()
                cons: SymTab = addSymbol(p, ($2).str, symConstants, addr(c))
                op: Command = Command(kind: line, lineConstants: cons, linecs0: cs0, linecs1: cs1, linep0: a, linep1: b)
            return @[op]

# test "test Lexer":
#   var lexer = mdlLex.newWithString("sphere 0 50 100 200")
#   lexer.ignoreIf = proc(r: Token): bool = r.kind == TokenKind.IGNORE
  
#   mdlPar.init()
#   echo mdlPar.parse(lexer)

proc mdlParse*(str: string): seq[Command] =
    var lexer = mdlLex.newWithString(str)
    lexer.ignoreIf = proc(r: Token): bool = r.kind == TokenKind.IGNORE

    mdlPar.init()
    return mdlPar.parse(lexer)