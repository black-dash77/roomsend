#!/bin/zsh
# One carousel position: wait for the centring to settle, capture both appearances, print who
# is in the centre of each (Vision text recognition). Usage: step.sh <lang> <name>
set -euo pipefail
here=${0:A:h}
python3 -c "import time; time.sleep(0.6)"
ROOMSEND_SETTLE=0.8 "$here/capture.sh" shot "$1" "$2" >/dev/null
echo "$2: $("$here/.state/ocr" "$here/raw/$1/light/$2.png" 0.445 0.475) / $("$here/.state/ocr" "$here/raw/$1/dark/$2.png" 0.445 0.475)"
