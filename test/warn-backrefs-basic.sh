#!/bin/bash
. $(dirname $0)/common.inc

# Classic back-reference shape: libb.a (definer of foo) appears BEFORE
# a.o (referencer of foo) on the command line. mold/lld pull b.o in
# anyway; GNU ld would fail to resolve foo. --warn-backrefs flags this.

cat <<EOF | $CC -c -xc -o $t/a.o -
int foo(void);
int main(void) { return foo(); }
EOF

cat <<EOF | $CC -c -xc -o $t/b.o -
int foo(void) { return 0; }
EOF

ar rcs $t/libb.a $t/b.o

# Without --warn-backrefs: no message.
$CC -B. -o $t/exe $t/libb.a $t/a.o 2>$t/stderr.no_flag
not grep -F 'backward reference' $t/stderr.no_flag

# With --warn-backrefs: message present, references the symbol, both files.
$CC -B. -o $t/exe $t/libb.a $t/a.o -Wl,--warn-backrefs 2>$t/stderr.with_flag
grep -F 'backward reference detected:' $t/stderr.with_flag
grep -F 'foo' $t/stderr.with_flag
grep -E 'a\.o' $t/stderr.with_flag
grep -E 'b\.o' $t/stderr.with_flag

# Forward reference (a.o before libb.a) should NOT warn.
$CC -B. -o $t/exe $t/a.o $t/libb.a -Wl,--warn-backrefs 2>$t/stderr.forward
not grep -F 'backward reference' $t/stderr.forward
