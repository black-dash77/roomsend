#!/bin/zsh
# Writes site/tools/avatars/avatars.json from the fingerprints of the test peers and of the devices
# already in the room (src/shots/manifest.json), using the app's
# own avatar code compiled for the iOS simulator. Usage: run.sh <booted simulator udid>
set -euo pipefail
here=${0:A:h}
app=$here/../../../RoomSend
udid=${1:?simulator udid}
out=$(mktemp -d)
xcrun -sdk iphonesimulator swiftc -target arm64-apple-ios26.0-simulator -O \
  "$app/Core/Design/Palette.swift" "$app/Core/Identity/IdentityPattern.swift" "$here/main.swift" -o "$out/avatars"
fingerprints=($(python3 - "$here/../capture/peers.json" "$here/../../src/shots/manifest.json" <<'PY'
import json, os, sys
peers = json.load(open(sys.argv[1]))
base = json.load(open(sys.argv[2])).get("base", []) if os.path.exists(sys.argv[2]) else []
print(" ".join(entry["fingerprint"] for entry in base + peers))
PY
))
xcrun simctl spawn "$udid" "$out/avatars" $fingerprints > "$here/avatars.json"
rm -rf "$out"
echo "avatars: ${#fingerprints} written to $here/avatars.json"
