import nimly, parser, patty, strutils

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
    STRING


niml Lexer[Token]:
    r"-?\d+":
        return FLOAT(parseFloat(token.token))
    # r"-?\d+\.":
    #     return FLOAT(parseFloat(token.token))
    # r"-?\d+\.\d+":
    #     return FLOAT(parseFloat(token.token))
    # r"-?\.\d+":
    #     return FLOAT(parseFloat(token.token))
    # r"//.*":
    #     return COMMENT()
    # r"light":
    #     return LIGHT()
    # r"constants":
    #     return CONSTANTS()
    # r"save_coord_system":
    #     return SAVECOORDS()
    # r"camera":
    #     return CAMERA()
    # r"ambient":
    #     return AMBIENT()
    # r"torus":
    #     return TORUS()
    r"sphere":
        return SPHERE()
    # r"box":
    #     return BOX()
    # r"line":
    #     return LINE()
    # r"mesh":
    #     return MESH()
    # r"texture":
    #     return TEXTURE()
    # r"set":
    #     return SET()
    # r"move":
    #     return MOVE()
    # r"scale":
    #     return SCALE()
    # r"rotate":
    #     return ROTATE()
    # r"basename":
    #     return BASENAME()
    # r"save_knobs":
    #     return SAVEKNOBS()
    # r"tween":
    #     return TWEEN()
    # r"frames":
    #     return FRAMES()
    # r"vary":
    #     return VARY()
    # r"push":
    #     return PUSH()
    # r"pop":
    #     return POP()
    # r"save":
    #     return SAVE()
    # r"generate_rayfiles":
    #     return GENERATERAYFILES()
    # r"shading":
    #     return SHADING()
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
    #     return CO()
    # r"\w*":
    #     return STRING()

nimy Parser[Token]:
    top[seq[Command]]:
        SPHERE FLOAT FLOAT FLOAT FLOAT:
            let a: array[4, float] = [($2).val, ($3).val, ($4).val, 0]
            #     sphere: SphereOp
            # sphere = SphereOp(constants: nil, cs: nil, d: a, r: ($5).val)
            var op: Command = Command(kind: sphere, sphereConstants: nil, sphereCS: nil, sphered: a, spherer: ($5).val)
            return @[op]