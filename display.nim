import std/strformat, std/sequtils, strutils

type
    Color* = tuple[red, green, blue: float]
    Screen*[XRES, YRES: static[int]] = array[XRES, array[YRES, Color]]
    ScreenRef*[XRES, YRES: static[int]] = ref Screen[XRES, YRES]
    TextureArray* = seq[seq[Color]]
    TextureArrayRef* = ref TextureArray
    ZBuffer*[XRES, YRES: static[int]] = array[XRES, array[YRES, float]]
    ZBufferRef*[XRES, YRES: static[int]] = ref ZBuffer[XRES, YRES]

const
    XRES*: int = 500
    YRES*: int = 500
    DEFAULT_COLOR*: float = 255.0
    DEFAULT_POLYGON_N*: int = 20
    MAX_COLOR*: int = 255

proc assignToRef[T](x: T): ref T =
  new result # allocate the ref object, any type works
  result[] = x # assign it x
  
proc newScreen*(): ScreenRef[XRES, YRES] =
    var t: array[XRES, array[YRES, Color]]
    let c: Color = (red: DEFAULT_COLOR, green: DEFAULT_COLOR, blue: DEFAULT_COLOR)
    for y in 0..<YRES:
        for x in 0..<XRES:
            t[x][y] = c
    assignToRef(t)  

proc newZBuffer*(): ZBufferRef[XRES, YRES] =
    var t: array[XRES, array[YRES, float]]
    for y in 0..<YRES:
        for x in 0..<XRES:
            t[x][y] = NegInf
    assignToRef(t)

proc newTArray*(xs, ys: int): TextureArrayRef =
    var t = newSeqWith(ys, newSeq[Color](xs))
    for y in 0..<ys:
        for x in 0..<xs:
            t[x][y] = (0.0, 0.0, 0.0)
    assignToRef(t)

proc `$`*(t: TextureArray): string =
    for i in 0..<len(t[0]):
        for j in 0..<len(t)-1:
            result &= $t[j][i]
            result &= " "
        result &= $t[len(t)-1][i]
        result &= "\n"

proc printTArray*(t: var TextureArray) =
    echo $t

proc `+`*(a, b: Color): Color =
    result.red = a.red + b.red
    result.green = a.green + b.green
    result.blue = a.blue + b.blue
    
proc `*`*(a, b: Color): Color =
    result.red = a.red * b.red
    result.green = a.green * b.green
    result.blue = a.blue * b.blue

proc `*`*(a: Color, b: float): Color =
    result.red = a.red * b
    result.green = a.green * b
    result.blue = a.blue * b

proc `-`*(a, b: Color): Color =
    result.red = a.red - b.red
    result.green = a.green - b.green
    result.blue = a.blue - b.blue
    
proc `/`*(a: Color, b: float): Color =
    result.red = a.red / b
    result.green = a.green / b
    result.blue =  a.blue / b

proc cmp*(a, b: Color): bool =
    (a.red == b.red) and (a.green == b.green) and (a.blue == b.blue)

proc clampColor*(c: var Color) =
    c.red = (c.red).clamp(0, 255)
    c.green = (c.green).clamp(0, 255)
    c.blue = (c.blue).clamp(0, 255)

proc clampTColor*(c: var Color) =
    c.red = (c.red).clamp(0, 1)
    c.green = (c.green).clamp(0, 1)
    c.blue = (c.blue).clamp(0, 1)


proc plot*(s: var Screen[XRES, YRES], zb: var ZBuffer, c: Color, x, y: int, z: float) = 
    let ny = YRES - 1 - y
    if x >= 0 and x < XRES and ny >= 0 and ny < YRES and z > zb[x][ny]:
    # if x >= 0 and x < XRES and ny >= 0 and ny < YRES:
        s[x][ny] = c
        # if zb[x][ny] != NegInf:
        #     echo $x & ", " & $ny
        zb[x][ny] = z

proc clearScreen*(s: var ScreenRef) =
    let c: Color = (red: DEFAULT_COLOR, green: DEFAULT_COLOR, blue: DEFAULT_COLOR)
    for y in 0..<YRES:
        for x in 0..<XRES:
            s[x][y] = c

proc clearZBuffer*(zb: var ZBufferRef) =
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

proc readPpm*(path: string): TextureArrayRef =
    let f = open(path, fmRead)
    defer: f.close()
    var line: string
    discard f.readLine(line)
    discard f.readLine(line)
    let 
        dim = line.splitWhitespace()
        xs: int = parseInt(dim[0])
        ys: int = parseInt(dim[1])
    discard f.readLine(line)
    var 
        c: array[3, char]
        s: TextureArrayRef = newTArray(xs, ys)
        x = 0
        y = 0
    while(f.readChars(c) > 0 and y < ys):
        s[x][ys-y-1].red = float(c[0])
        # echo s[x][y].red
        s[x][ys-y-1].green = float(c[1])
        s[x][ys-y-1].blue = float(c[2])
        x += 1
        if x > xs - 1:
            x = 0
            y += 1
    s