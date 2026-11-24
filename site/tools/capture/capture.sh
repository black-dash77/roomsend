#!/bin/zsh
# Drives the capture simulator for the site's screenshots. Every capture is the real app,
# compiled from this repository, talking to real LocalSend peers (peers.py).
#
#   capture.sh install <app path>    install RoomSend, clean status bar, port 53321
#   capture.sh launch <lang>         (re)launch RoomSend in a language, Auto appearance
#   capture.sh peers <count>         run that many test peers (0 stops them)
#   capture.sh inbox                 put three photos in the share inbox
#   capture.sh share                 inbox, then bring RoomSend back to the front: the send sheet opens
#   capture.sh offer                 Witty Peach proposes three photos to RoomSend
#   capture.sh shot <lang> <name>    save the screen in light and in dark
#   capture.sh shotone <lang> <theme> <name>   save the screen as it is, in one appearance
set -euo pipefail

here=${0:A:h}
udid=${ROOMSEND_SIM:-6D658E37-F54A-4ED0-BF1E-0BDBDD60C846}
bundle=app.roomsend.ios
port=53321
raw=$here/raw
state=$here/.state
photos=$here/photos
settle=${ROOMSEND_SETTLE:-1.2}

locale_for() {
  case $1 in
    en) echo en_US ;; fr) echo fr_CH ;; de) echo de_CH ;; es) echo es_ES ;; it) echo it_IT ;; pt) echo pt_PT ;;
    *) echo "unknown language $1" >&2; exit 1 ;;
  esac
}

pause() { python3 -c "import time,sys; time.sleep(float(sys.argv[1]))" "$1"; }

case ${1:?command} in
  install)
    xcrun simctl install "$udid" "${2:?app path}"
    xcrun simctl status_bar "$udid" override --time "9:41" --dataNetwork wifi --wifiMode active --wifiBars 3 \
      --cellularMode active --cellularBars 4 --operatorName "" --batteryState charged --batteryLevel 100
    xcrun simctl spawn "$udid" defaults write "$bundle" network.port -int $port
    xcrun simctl privacy "$udid" grant photos-add "$bundle" || true
    ;;
  launch)
    lang=${2:?lang}
    xcrun simctl ui "$udid" appearance light
    xcrun simctl launch --terminate-running-process "$udid" "$bundle" \
      -AppleLanguages "($lang)" -AppleLocale "$(locale_for "$lang")" >/dev/null
    ;;
  peers)
    count=${2:?count}
    mkdir -p "$state"
    if [[ -f $state/peers.pid ]]; then kill "$(cat "$state/peers.pid")" 2>/dev/null || true; rm -f "$state/peers.pid"; fi
    if (( count > 0 )); then
      nohup python3 "$here/peers.py" serve --count "$count" --rate "${ROOMSEND_RATE:-350000}" > "$state/peers.log" 2>&1 &
      echo $! > "$state/peers.pid"
    fi
    ;;
  inbox)
    group=$(xcrun simctl get_app_container "$udid" "$bundle" group.app.roomsend.ios)
    batch=$group/Inbox/$(uuidgen)
    mkdir -p "$batch"
    cp "$photos"/*.jpg "$batch"/
    ;;
  share)
    "$0" inbox
    xcrun simctl launch "$udid" com.apple.Preferences >/dev/null
    pause 1.5
    xcrun simctl launch "$udid" "$bundle" >/dev/null
    ;;
  offer)
    nohup python3 "$here/peers.py" offer --to "127.0.0.1:$port" --files "$photos"/*.jpg > "$state/offer.log" 2>&1 &
    echo $! > "$state/offer.pid"
    ;;
  shot)
    lang=${2:?lang}; name=${3:?name}
    for theme in light dark; do
      mkdir -p "$raw/$lang/$theme"
      xcrun simctl ui "$udid" appearance "$theme"
      pause "$settle"
      xcrun simctl io "$udid" screenshot --type=png "$raw/$lang/$theme/$name.png" >/dev/null 2>&1
    done
    xcrun simctl ui "$udid" appearance light
    echo "$lang/$name"
    ;;
  shotone)
    lang=${2:?lang}; theme=${3:?theme}; name=${4:?name}
    mkdir -p "$raw/$lang/$theme"
    xcrun simctl io "$udid" screenshot --type=png "$raw/$lang/$theme/$name.png" >/dev/null 2>&1
    echo "$lang/$theme/$name"
    ;;
  *)
    echo "unknown command $1" >&2; exit 1 ;;
esac
