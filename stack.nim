import matrix

type
    Stack*[T] = seq[T]
    StackEmpty* = object of CatchableError

proc newStack*[T](): Stack[T] =
    var 
        s = newSeq[T](0)
        m: Matrix = newMatrix()
    identMatrix(m)
    s.add(m)
    s

proc isEmpty*[T](s: Stack[T]): bool =
    s.len() == 0

proc push*[T](s: var Stack[T], e: T) =
    s.add(e)

proc pop*[T](s: var Stack[T]): T =
    if not s.isEmpty:
        result = s[^1]
        s.setLen s.len - 1
    else:
        raise newException(StackEmpty, "Cannot pop empty stack")

proc peek*[T](s: Stack[T]): T =
    if not s.isEmpty:
        result = s[^1]
    else:
        raise newException(StackEmpty, "Cannot peek empty stack")

proc clear*[T](s: var Stack[T]) =
    if not s.isEmpty:
        s.setLen 0

proc `$`*[T](s: Stack[T]): string =
    result = "["
    if not s.isEmpty:
        for i in 0..s.high()-1:
            result &= $s[s.high - i]
            result &= ", "
        result &= $s[0]
    result &= "]"

proc printStack*[T](s: Stack[T]) =
    echo $s