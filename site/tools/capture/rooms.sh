#!/bin/zsh
# The Room screen with 0 to 4 test peers, in each language, light and dark. No touch needed:
# RoomSend opens on the Room screen and finds the peers by itself.
set -euo pipefail
here=${0:A:h}
wait_for_room=${ROOMSEND_ROOM_WAIT:-7}
for lang in ${@:-en fr de es it pt}; do
  for count in 0 1 2 3 4; do
    "$here/capture.sh" peers $count
    python3 -c "import time; time.sleep(1)"
    "$here/capture.sh" launch $lang
    python3 -c "import time,sys; time.sleep(float(sys.argv[1]))" $wait_for_room
    "$here/capture.sh" shot $lang room-$count
  done
done
"$here/capture.sh" peers 0
echo "rooms done"
