import std/strformat

type
    Color* = tuple[red, green, blue: uint8]
    Screen*[XRES, YRES: static[int]] = array[XRES, array[YRES, Color]]

const
    XRES*: int = 500
    YRES*: int = 500
    DEFAULT_COLOR*: uint8 = 0
    MAX_COLOR*: int = 255

proc plot*(s: var Screen[XRES, YRES], c: Color, x, y: int) = 
    let ny = YRES - 1 - y
    if x >= 0 and x < XRES and ny >= 0 and ny < YRES:
        s[x][ny] = c

proc clearScreen*(s: var Screen) =
    let c: Color = (red: DEFAULT_COLOR, green: DEFAULT_COLOR, blue: DEFAULT_COLOR)
    for y in 0..<YRES:
        for x in 0..<XRES:
            s[x][y] = c

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
