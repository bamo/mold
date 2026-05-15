#!/bin/bash
. $(dirname $0)/common.inc

# Same back-ref shape as warn-backrefs-basic, but wrapped in --start-group.
# Inside a group, the user has explicitly opted into iterate-to-fixpoint
# resolution; --warn-backrefs should NOT warn.

cat <<EOF | $CC -c -xc -o $t/a.o -
int foo(void);
int main(void) { return foo(); }
EOF

cat <<EOF | $CC -c -xc -o $t/b.o -
int foo(void) { return 0; }
EOF

ar rcs $t/libb.a $t/b.o

# Inside --start-group: no warning.
$CC -B. -o $t/exe -Wl,--start-group $t/libb.a $t/a.o -Wl,--end-group -Wl,--warn-backrefs 2>$t/stderr.group
not grep -F 'backward reference' $t/stderr.group

# Sanity: outside --start-group, the warning DOES fire.
$CC -B. -o $t/exe $t/libb.a $t/a.o -Wl,--warn-backrefs 2>$t/stderr.no_group
grep -F 'backward reference' $t/stderr.no_group
