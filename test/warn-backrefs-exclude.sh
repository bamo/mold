#!/bin/bash
. $(dirname $0)/common.inc

# --warn-backrefs-exclude=NAME suppresses the warning when the DEFINER's
# basename matches NAME (lld semantics).

cat <<EOF | $CC -c -xc -o $t/a.o -
int foo(void);
int main(void) { return foo(); }
EOF

cat <<EOF | $CC -c -xc -o $t/b.o -
int foo(void) { return 0; }
EOF

ar rcs $t/libb.a $t/b.o

# Without exclude (sanity): warning fires.
$CC -B. -o $t/exe $t/libb.a $t/a.o -Wl,--warn-backrefs 2>$t/stderr.no_excl
grep -F 'backward reference' $t/stderr.no_excl

# Exclude b.o (the member that defines foo): no warning.
$CC -B. -o $t/exe $t/libb.a $t/a.o -Wl,--warn-backrefs,--warn-backrefs-exclude=b.o 2>$t/stderr.excl
not grep -F 'backward reference' $t/stderr.excl

# Excluding an unrelated name: warning still fires.
$CC -B. -o $t/exe $t/libb.a $t/a.o -Wl,--warn-backrefs,--warn-backrefs-exclude=unrelated.o 2>$t/stderr.other
grep -F 'backward reference' $t/stderr.other
