import nimly, patty

variant Token:
    FLOAT
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
    SHADINGTYPE
    SETKNOBS
    FOCAL
    DISPLAY
    WEB
    CO
    STRING


niml lexer[Token]:
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
    
    r"setknobs":
        return SETKNOBS()
    r"focal":
        return FOCAL()
    r"display":
        return DISPLAY()
    r"web":
        return WEB()
    r":":
        return CO()
    r"[a..zA..Z][\.a..zA..Z0..9_]*":
        return STRING()

