#include <stdio.h>

#include "parser.h"
#include "symtab.h"
#include "y.tab.h"


int get_symtab() {
    // printf(iter_symtab(0));
    return iter_symtab(0);
    // return 0;
}