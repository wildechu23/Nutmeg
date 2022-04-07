type
    Stack*[T] = seq[T]

proc newStack*[T](): Stack[T] =
    newSeq[T](0)

proc len*[T](s: Stack[T]): int =
    s.len()

proc isEmpty*[T](s: Stack[T]): bool =
    s.len() == 0

proc push*[T](s: Stack[T], e: T) =
    s.add(e)

proc pop*[T](s: Stack[T]): T =
    if not s.isEmpty:
        result = s[^1]
        s.setLen s.len - 1
    else:
        # raise newException

proc peek*[T](s: Stack[T]): T =
    if not s.isEmpty:
        result = s[^1]
    else:
        # raise newException

proc clear*[T](s: Stack[T]): seq[T] =
    return