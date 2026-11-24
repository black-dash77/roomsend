#!/usr/bin/env bash
# Plays a stretch of real traffic from the peers of room-peers.py to one RoomSend, a few minutes
# apart, so its History shows transfers spread over time. Needs `room-peers.py serve` running and,
# on the receiving RoomSend, "Accept automatically" on and "Ask for a PIN" off.
#
#   appstore/tools/room-activity.sh 127.0.0.1:53317 [pause-seconds]
set -euo pipefail

readonly TOOLS="$(cd "$(dirname "$0")" && pwd)"
readonly TARGET="${1:?host:port of the receiving RoomSend}"
readonly PAUSE="${2:-90}"

send_text() { python3 "${TOOLS}/room-peers.py" send "$1" "${TARGET}" --text "$2"; sleep "${PAUSE}"; }
send_file() { python3 "${TOOLS}/room-peers.py" send "$1" "${TARGET}" --file "$2"; sleep "${PAUSE}"; }

send_file cherry "${TOOLS}/media/IMG_4211.jpg"
send_text fresa "Here is the code for the guest Wi-Fi: BLUE-HARBOR-58"
send_file litchi "${TOOLS}/media/Seating plan.pdf"
send_file zitrone "${TOOLS}/media/IMG_4212.jpg"
send_text lime "The slides are in the shared folder, version 3."
send_file pesca "${TOOLS}/media/IMG_4213.jpg"
send_text raisin "Running ten minutes late, start without me."
