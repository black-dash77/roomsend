#!/usr/bin/env bash
# Prepares the two capture simulators of RoomSend for one language.
#
#   appstore/tools/sim-setup.sh build            build the app into its own DerivedData
#   appstore/tools/sim-setup.sh create           create and boot the two simulators
#   appstore/tools/sim-setup.sh lang <code> [dark|light]
#                                                en | fr | de | es | it | pt: system locale and language
#                                                (the app follows them), appearance (dark by default),
#                                                PIN off, clean status bar, relaunch
#   appstore/tools/sim-setup.sh shot <name>      full-resolution capture of the main simulator into
#                                                appstore/screenshots/raw/<lang>/<name>.png
#
# The main simulator is an iPhone 17 Pro Max (1320 x 2868, the "Dynamic Island, large display" size
# of App Store Connect). The pair is an iPhone 17 on port 53320, so both can listen on the same Mac.
set -euo pipefail

readonly ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
readonly STATE_DIR="${ROOT}/appstore/tools/.state"
readonly DERIVED_DATA="${ROOMSEND_DERIVED_DATA:-${TMPDIR:-/tmp}/roomsend-appstore-dd}"
readonly APP_PATH="${DERIVED_DATA}/Build/Products/Release-iphonesimulator/RoomSend.app"
readonly BUNDLE_ID="app.roomsend.ios"
readonly RUNTIME="com.apple.CoreSimulator.SimRuntime.iOS-26-3"
readonly MAIN_NAME="RoomSend Store 6.9"
readonly PAIR_NAME="RoomSend Store Pair"
readonly PAIR_PORT=53320
readonly MEDIA_DIR="${ROOT}/appstore/tools/media"

main() {
  local command="${1:-}"
  case "${command}" in
    build) build_app ;;
    create) create_simulators ;;
    lang) set_language "${2:?language code required}" "${3:-dark}" ;;
    shot) capture "${2:?capture name required}" ;;
    *) echo "usage: $0 build | create | lang <code> | shot <name>" >&2; exit 64 ;;
  esac
}

build_app() {
  xcodebuild -project "${ROOT}/RoomSend.xcodeproj" -scheme RoomSend -configuration Release \
    -destination "generic/platform=iOS Simulator" -derivedDataPath "${DERIVED_DATA}" \
    CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM= build
}

create_simulators() {
  mkdir -p "${STATE_DIR}"
  local main_id pair_id
  main_id="$(xcrun simctl create "${MAIN_NAME}" com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max "${RUNTIME}")"
  pair_id="$(xcrun simctl create "${PAIR_NAME}" com.apple.CoreSimulator.SimDeviceType.iPhone-17 "${RUNTIME}")"
  printf 'MAIN=%s\nPAIR=%s\n' "${main_id}" "${pair_id}" > "${STATE_DIR}/simulators.env"
  for device in "${main_id}" "${pair_id}"; do
    xcrun simctl boot "${device}"
    xcrun simctl bootstatus "${device}" -b > /dev/null
    xcrun simctl install "${device}" "${APP_PATH}"
    xcrun simctl privacy "${device}" grant photos-add "${BUNDLE_ID}"
    xcrun simctl addmedia "${device}" "${MEDIA_DIR}"/*.jpg
  done
  xcrun simctl launch "${pair_id}" "${BUNDLE_ID}" > /dev/null
  xcrun simctl terminate "${pair_id}" "${BUNDLE_ID}"
  local domain
  domain="$(xcrun simctl get_app_container "${pair_id}" "${BUNDLE_ID}" data)/Library/Preferences/${BUNDLE_ID}"
  xcrun simctl spawn "${pair_id}" defaults write "${domain}" network.port -int "${PAIR_PORT}"
}

set_language() {
  local language="$1" appearance="$2" locale domain
  locale="$(locale_for "${language}")"
  load_simulators
  for device in "${MAIN}" "${PAIR}"; do
    xcrun simctl terminate "${device}" "${BUNDLE_ID}" 2> /dev/null || true
    # The app reads its own container, not the device-wide domain of the bundle id.
    domain="$(xcrun simctl get_app_container "${device}" "${BUNDLE_ID}" data)/Library/Preferences/${BUNDLE_ID}"
    xcrun simctl spawn "${device}" defaults write -g AppleLocale "${locale}"
    xcrun simctl spawn "${device}" defaults write -g AppleLanguages -array "${locale/_/-}"
    xcrun simctl spawn "${device}" defaults delete "${domain}" AppleLanguages 2> /dev/null || true
    xcrun simctl spawn "${device}" defaults write "${domain}" appearance -string "${appearance}"
    xcrun simctl spawn "${device}" defaults write "${domain}" receive.requiresPin -bool false
    xcrun simctl status_bar "${device}" override --time 9:41 --dataNetwork wifi --wifiMode active \
      --wifiBars 3 --cellularMode active --cellularBars 4 --operatorName '' \
      --batteryState discharging --batteryLevel 100
    xcrun simctl launch "${device}" "${BUNDLE_ID}" > /dev/null
  done
  echo "${language}" > "${STATE_DIR}/language"
}

capture() {
  local name="$1" language
  load_simulators
  language="$(cat "${STATE_DIR}/language")"
  mkdir -p "${ROOT}/appstore/screenshots/raw/${language}"
  xcrun simctl io "${MAIN}" screenshot "${ROOT}/appstore/screenshots/raw/${language}/${name}.png"
}

locale_for() {
  case "$1" in
    en) echo en_US ;;
    fr) echo fr_FR ;;
    de) echo de_DE ;;
    es) echo es_ES ;;
    it) echo it_IT ;;
    pt) echo pt_PT ;;
    *) echo "unknown language: $1" >&2; exit 65 ;;
  esac
}

load_simulators() {
  # shellcheck source=/dev/null
  source "${STATE_DIR}/simulators.env"
}

main "$@"
