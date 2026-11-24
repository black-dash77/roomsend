"""Fills the room for the App Store captures with LocalSend v2.2 peers running on this Mac.

These peers speak the real protocol (multicast announcement, HTTPS with a self-signed certificate
whose SHA-256 is the announced fingerprint, register, prepare-upload, upload), so RoomSend finds
them, checks their certificate and transfers to them for real. They are not physical devices: the
README of appstore/ says so next to every capture that shows them.

    python3 appstore/tools/room-peers.py serve               announce and answer until Ctrl-C
    python3 appstore/tools/room-peers.py send <peer> <host:port> --text "..."
    python3 appstore/tools/room-peers.py send <peer> <host:port> --file a.jpg b.jpg

The peer marked is_slow in ROSTER ("Quiet Lime") reads uploads slowly, so a capture can show a transfer in progress.
"""

from __future__ import annotations

import argparse
import hashlib
import http.server
import json
import logging
import mimetypes
import socket
import ssl
import subprocess
import threading
import time
import urllib.request
import uuid
from dataclasses import dataclass
from pathlib import Path

STATE_DIR = Path(__file__).resolve().parent / ".state" / "peers"
MULTICAST_GROUP = ("224.0.0.167", 53317)
API = "/api/localsend/v2"
PROTOCOL_VERSION = "2.2"
FIRST_PORT = 53340
ANNOUNCE_PERIOD_SECONDS = 4
MULTICAST_TTL = 1
SLOW_CHUNK_BYTES = 256 * 1024
SLOW_PAUSE_SECONDS = 0.02
FAST_CHUNK_BYTES = 4 * 1024 * 1024
CERT_DAYS = 365
HTTP_OK = 200
HTTP_NOT_FOUND = 404

log = logging.getLogger("room-peers")


@dataclass(frozen=True)
class Peer:
    key: str
    alias: str
    model: str
    kind: str
    port: int
    is_slow: bool = False


ROSTER = (
    Peer("cherry", "Bold Cherry", "Mac", "desktop", FIRST_PORT),
    Peer("zitrone", "Flinke Zitrone", "iPad", "mobile", FIRST_PORT + 1),
    Peer("fresa", "Fresa Tranquila", "iPhone", "mobile", FIRST_PORT + 2),
    Peer("litchi", "Litchi Doux", "Mac", "desktop", FIRST_PORT + 3),
    Peer("pesca", "Pesca Allegra", "iPhone", "mobile", FIRST_PORT + 4),
    Peer("manga", "Manga Esperta", "iPad", "mobile", FIRST_PORT + 5),
    Peer("lime", "Quiet Lime", "Linux", "desktop", FIRST_PORT + 6, is_slow=True),
    Peer("raisin", "Raisin Malin", "iPhone", "mobile", FIRST_PORT + 7),
    Peer("birne", "Glückliche Birne", "Mac", "desktop", FIRST_PORT + 8),
)


def main() -> None:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("serve")
    send = commands.add_parser("send")
    send.add_argument("peer", choices=[peer.key for peer in ROSTER])
    send.add_argument("target", help="host:port of the receiving RoomSend")
    content = send.add_mutually_exclusive_group(required=True)
    content.add_argument("--text")
    content.add_argument("--file", type=Path, nargs="+")
    arguments = parser.parse_args()
    if arguments.command == "serve":
        serve_all()
    else:
        peer = next(peer for peer in ROSTER if peer.key == arguments.peer)
        send_to(peer, arguments.target, arguments.text, arguments.file)


def serve_all() -> None:
    for peer in ROSTER:
        server = make_server(peer)
        threading.Thread(target=server.serve_forever, daemon=True).start()
    announcer = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    announcer.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, MULTICAST_TTL)
    log.info("%d peers announced on %s:%d", len(ROSTER), *MULTICAST_GROUP)
    while True:
        for peer in ROSTER:
            announcer.sendto(json.dumps(device_info(peer, announce=True)).encode(), MULTICAST_GROUP)
        time.sleep(ANNOUNCE_PERIOD_SECONDS)


def make_server(peer: Peer) -> http.server.ThreadingHTTPServer:
    handler = type(f"Handler_{peer.key}", (PeerHandler,), {"peer": peer})
    server = http.server.ThreadingHTTPServer(("0.0.0.0", peer.port), handler)
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    cert, key = certificate_files(peer)
    context.load_cert_chain(cert, key)
    server.socket = context.wrap_socket(server.socket, server_side=True)
    return server


class PeerHandler(http.server.BaseHTTPRequestHandler):
    peer: Peer
    protocol_version = "HTTP/1.1"

    def do_GET(self) -> None:
        if self.path.startswith(f"{API}/info"):
            self.reply(device_info(self.peer, announce=None))
        else:
            self.reply({}, status=HTTP_NOT_FOUND)

    def do_POST(self) -> None:
        route = self.path.split("?")[0]
        if route == f"{API}/register":
            self.consume_body()
            self.reply(device_info(self.peer, announce=None))
        elif route == f"{API}/prepare-upload":
            offer = json.loads(self.consume_body())
            tokens = {file_id: uuid.uuid4().hex for file_id in offer.get("files", {})}
            log.info("%s accepts %d file(s) from %s", self.peer.alias, len(tokens), offer["info"]["alias"])
            self.reply({"sessionId": uuid.uuid4().hex, "files": tokens})
        elif route == f"{API}/upload":
            self.drain_body()
            self.reply({})
        else:
            self.consume_body()
            self.reply({})

    def consume_body(self) -> bytes:
        return self.rfile.read(int(self.headers.get("Content-Length", 0)))

    def drain_body(self) -> None:
        remaining = int(self.headers.get("Content-Length", 0))
        chunk = SLOW_CHUNK_BYTES if self.peer.is_slow else FAST_CHUNK_BYTES
        while remaining > 0:
            remaining -= len(self.rfile.read(min(chunk, remaining)))
            if self.peer.is_slow:
                time.sleep(SLOW_PAUSE_SECONDS)

    def reply(self, body: dict, status: int = HTTP_OK) -> None:
        payload = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, format: str, *args: object) -> None:
        log.debug("%s %s", self.peer.alias, format % args)


def send_to(peer: Peer, target: str, text: str | None, paths: list[Path] | None) -> None:
    payloads = [message_payload(text)] if text is not None else [file_payload(path) for path in paths]
    files = {payload["id"]: {key: value for key, value in payload.items() if key != "data"} for payload in payloads}
    offer = {"info": device_info(peer, announce=None), "files": files}
    context = ssl._create_unverified_context()
    answer = post_json(f"https://{target}{API}/prepare-upload", offer, context)
    tokens = answer.get("files", {})
    if not tokens:
        log.info("%s: nothing to upload (message shown, or offer refused)", peer.alias)
        return
    for payload in payloads:
        query = f"sessionId={answer['sessionId']}&fileId={payload['id']}&token={tokens[payload['id']]}"
        request = urllib.request.Request(f"https://{target}{API}/upload?{query}", data=payload["data"], method="POST")
        with urllib.request.urlopen(request, context=context) as response:
            log.info("%s sent %s (%d bytes): HTTP %d", peer.alias, payload["fileName"], payload["size"], response.status)


def message_payload(text: str) -> dict:
    data = text.encode()
    return {"id": uuid.uuid4().hex, "fileName": "message.txt", "size": len(data),
            "fileType": "text/plain", "preview": text, "data": data}


def file_payload(path: Path) -> dict:
    data = path.read_bytes()
    file_type = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
    return {"id": uuid.uuid4().hex, "fileName": path.name, "size": len(data),
            "fileType": file_type, "preview": None, "data": data}


def post_json(url: str, body: dict, context: ssl.SSLContext) -> dict:
    request = urllib.request.Request(
        url, data=json.dumps(body).encode(), headers={"Content-Type": "application/json"}, method="POST"
    )
    with urllib.request.urlopen(request, context=context) as response:
        raw = response.read()
    return json.loads(raw) if raw else {}


def device_info(peer: Peer, announce: bool | None) -> dict:
    info = {
        "alias": peer.alias, "version": PROTOCOL_VERSION, "deviceModel": peer.model,
        "deviceType": peer.kind, "fingerprint": fingerprint(peer), "port": peer.port,
        "protocol": "https", "download": False,
    }
    if announce is not None:
        info["announce"] = announce
    return info


def fingerprint(peer: Peer) -> str:
    cert, _ = certificate_files(peer)
    return hashlib.sha256(ssl.PEM_cert_to_DER_cert(cert.read_text())).hexdigest()


def certificate_files(peer: Peer) -> tuple[Path, Path]:
    folder = STATE_DIR / peer.key
    cert, key = folder / "cert.pem", folder / "key.pem"
    if not cert.exists():
        folder.mkdir(parents=True, exist_ok=True)
        subprocess.run(["openssl", "ecparam", "-genkey", "-name", "prime256v1", "-out", str(key)], check=True)
        subprocess.run(
            ["openssl", "req", "-new", "-x509", "-key", str(key), "-out", str(cert),
             "-days", str(CERT_DAYS), "-subj", f"/CN={peer.key}"],
            check=True,
        )
    return cert, key


if __name__ == "__main__":
    main()
