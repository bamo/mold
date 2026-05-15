#!/bin/bash
. $(dirname $0)/common.inc

# Weak undef ref should NOT trigger --warn-backrefs.

cat <<EOF | $CC -c -xc -o $t/a.o -
__attribute__((weak)) int foo(void);
int main(void) { return foo ? foo() : 0; }
EOF

cat <<EOF | $CC -c -xc -o $t/b.o -
int foo(void) { return 0; }
EOF

ar rcs $t/libb.a $t/b.o

$CC -B. -o $t/exe $t/libb.a $t/a.o -Wl,--warn-backrefs 2>$t/stderr
not grep -F 'backward reference' $t/stderr
