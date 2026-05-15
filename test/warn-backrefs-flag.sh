#!/bin/bash
. $(dirname $0)/common.inc

# Trivial program; verify the flag is accepted without behavior change.
cat <<EOF | $CC -c -xc -o $t/a.o -
int main(void) { return 0; }
EOF

$CC -B. -o $t/exe $t/a.o -Wl,--warn-backrefs
$CC -B. -o $t/exe $t/a.o -Wl,--no-warn-backrefs
$CC -B. -o $t/exe $t/a.o -Wl,--warn-backrefs,--warn-backrefs-exclude=foo.o
$CC -B. -o $t/exe $t/a.o -Wl,--warn-backrefs -Wl,--warn-backrefs-exclude=foo.o -Wl,--warn-backrefs-exclude=bar.o
