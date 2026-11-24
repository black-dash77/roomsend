#!/bin/zsh
# Opens the send sheet with three photos in a language, test peers running, and prints the
# carousel row as read on screen. Usage: open.sh <lang>
set -euo pipefail
here=${0:A:h}
pgrep -f "peers.py serve" >/dev/null || { "$here/capture.sh" peers 4; python3 -c "import time; time.sleep(1.5)"; }
"$here/capture.sh" inbox
"$here/capture.sh" launch "$1"
python3 -c "import time; time.sleep(8)"
xcrun simctl io "${ROOMSEND_SIM:-6D658E37-F54A-4ED0-BF1E-0BDBDD60C846}" screenshot "$here/.state/probe.png" >/dev/null 2>&1
echo "row: $("$here/.state/ocr" "$here/.state/probe.png" 0.43 0.48 0 1)"
