#!/bin/sh

EXEFILE="$1"
PCFILE="${@:2}"

for a in $( cat $PCFILE ); do
  addr2line -a -p -C -f -i -e "$EXEFILE" $a
done
