import std/strformat

type
    Color* = tuple[red, green, blue: int]
    Screen*[XRES, YRES: static[int]] = array[XRES, array[YRES, Color]]
    ZBuffer*[XRES, YRES: static[int]] = array[XRES, array[YRES, float]]

const
    XRES*: int = 500
    YRES*: int = 500
    DEFAULT_COLOR*: int = 255
    DEFAULT_POLYGON_N*: int = 20
    MAX_COLOR*: int = 255

proc `+`*(a, b: Color): Color =
    result.red = a.red + b.red
    result.green = a.green + b.green
    result.blue = a.blue + b.blue

proc clampColor*(c: var Color) =
    c.red = (c.red).clamp(0, 255)
    c.green = (c.green).clamp(0, 255)
    c.blue = (c.blue).clamp(0, 255)

proc plot*(s: var Screen[XRES, YRES], zb: var ZBuffer, c: Color, x, y: int, z: float) = 
    let ny = YRES - 1 - y
    if x >= 0 and x < XRES and ny >= 0 and ny < YRES and z > zb[x][ny]:
    # if x >= 0 and x < XRES and ny >= 0 and ny < YRES:
        s[x][ny] = c
        # if zb[x][ny] != NegInf:
        #     echo $x & ", " & $ny
        zb[x][ny] = z

proc clearScreen*(s: var Screen) =
    let c: Color = (red: DEFAULT_COLOR, green: DEFAULT_COLOR, blue: DEFAULT_COLOR)
    for y in 0..<YRES:
        for x in 0..<XRES:
            s[x][y] = c

proc clearZBuffer*(zb: var ZBuffer) =
    for y in 0..<YRES:
        for x in 0..<XRES:
            zb[x][y] = NegInf

proc saveAsciiPpm*(s: Screen, path: string) =
    let f = open(path, fmWrite)
    f.write(
        &"P3\n{XRES} {YRES}\n{MAX_COLOR}\n"
    )

    for y in 0..<YRES:
        for x in 0..<XRES:
            f.write(&"{s[x][y].red} {s[x][y].green} {s[x][y].blue}  ")
        f.write("\n")
    f.close()

proc savePpm*(s: Screen, path: string) = 
    let f = open(path, fmWrite)
    f.write(
        &"P6\n{XRES} {YRES}\n{MAX_COLOR}\n"
    )

    # OH MY GOD I LOVE P6
    for y in 0..<YRES:
        for x in 0..<XRES:
            f.write(char(s[x][y].red))
            f.write(char(s[x][y].green))
            f.write(char(s[x][y].blue))
    f.close()
