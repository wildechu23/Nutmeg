#include <stdio.h>

#include "parser.h"
#include "symtab.h"
#include "y.tab.h"


SYMTAB* get_symtab() {
    return symtab;
}

int get_symlen() {
    return lastsym;
}