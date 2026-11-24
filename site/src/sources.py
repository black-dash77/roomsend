"""What the site reads from the rest of the project: the legal texts and the avatars."""
import json
import os
import sys

SITE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT = os.path.dirname(SITE)
sys.path.insert(0, os.path.join(PROJECT, "tools"))

import legal  # noqa: E402  (tools/legal, shared with the app's catalog)
from legal.publisher import PUBLISHER  # noqa: E402

AVATARS_FILE = os.path.join(SITE, "tools", "avatars", "avatars.json")
PEERS_FILE = os.path.join(SITE, "tools", "capture", "peers.json")


def devices(shots):
    """The devices of the captures with their avatars: those already in the room (`shots["base"]`,
    real RoomSend devices of the Wi-Fi), then the test peers in the order they join."""
    with open(PEERS_FILE, encoding="utf-8") as handle:
        peers = json.load(handle)
    with open(AVATARS_FILE, encoding="utf-8") as handle:
        patterns = {pattern["fingerprint"]: pattern for pattern in json.load(handle)}
    base = [dict(entry, pattern=patterns[entry["fingerprint"]], isBase=True) for entry in shots.get("base", [])]
    return base + [dict(entry, pattern=patterns[entry["fingerprint"]], isBase=False) for entry in peers]
