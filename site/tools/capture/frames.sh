#!/bin/zsh
# Frames of a transfer in progress, each in light then dark, at set times after it starts.
# Usage: frames.sh <lang> <prefix> <final name> <t1> <t2> ... <t_final>  (seconds from now)
set -euo pipefail
here=${0:A:h}
lang=$1; prefix=$2; final=$3; shift 3
times=($@)
start=$(python3 -c "import time; print(time.time())")
index=0
for at in $times; do
  index=$(( index + 1 ))
  python3 -c "import time,sys; d=float(sys.argv[1])+float(sys.argv[2])-time.time(); time.sleep(max(0,d))" "$start" "$at"
  name=$prefix-$index
  (( index == ${#times} )) && name=$final
  ROOMSEND_SETTLE=0.45 "$here/capture.sh" shot "$lang" "$name" >/dev/null
  echo "$name at $(python3 -c "import time,sys; print(round(time.time()-float(sys.argv[1]),1))" "$start")s"
done
