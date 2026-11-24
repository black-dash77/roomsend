"""Test devices for the site's captures: real LocalSend v2.2 peers running on this Mac.

Each peer has its own self-signed certificate (fingerprint = SHA-256 of the certificate, as
the protocol asks), announces itself by multicast, answers `register` and `info` over HTTPS,
and receives uploads at a chosen speed, so RoomSend shows them as it would show any device.

    python3 peers.py serve --count 3 --rate 400000   # the first three peers, 400 kB/s
    python3 peers.py offer --to 127.0.0.1:53321 --files a.jpg b.jpg   # peer 1 sends to RoomSend

`peers.json` (alias, fingerprint, type) is written next to this file for `site/build.py`.
"""
import argparse
import hashlib
import http.client
import http.server
import json
import os
import socket
import ssl
import subprocess
import threading
import time
import urllib.request
import uuid

HERE = os.path.dirname(os.path.abspath(__file__))
STATE = os.path.join(HERE, ".state")
MULTICAST_GROUP, MULTICAST_PORT = "224.0.0.167", 53317
API = "/api/localsend/v2"
ANNOUNCE_EVERY = 2.0
CHUNK = 16384
RECEIVE_BUFFER = 65536
PEERS = [
    {"alias": "Witty Peach", "deviceModel": "MacBook", "deviceType": "desktop", "port": 53401},
    {"alias": "Lucky Lime", "deviceModel": "Samsung", "deviceType": "mobile", "port": 53402},
    {"alias": "Bright Plum", "deviceModel": "Windows", "deviceType": "desktop", "port": 53403},
    {"alias": "Sunny Fig", "deviceModel": "iPad", "deviceType": "mobile", "port": 53404},
]


def lan_address():
    probe = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        probe.connect(("192.0.2.1", 9))
        return probe.getsockname()[0]
    finally:
        probe.close()


def certificate(index):
    """The peer's certificate files and fingerprint, created once and kept in `.state`."""
    os.makedirs(STATE, exist_ok=True)
    cert, key = (os.path.join(STATE, f"peer{index}.{ext}") for ext in ("crt", "key"))
    if not os.path.exists(cert):
        # A named P-256 curve: `req -newkey ec` in LibreSSL writes explicit parameters, which no
        # TLS stack accepts.
        subprocess.run(["openssl", "ecparam", "-name", "prime256v1", "-genkey", "-noout", "-out", key],
                       check=True, capture_output=True)
        subprocess.run(["openssl", "req", "-x509", "-new", "-key", key, "-sha256", "-days", "3650",
                        "-subj", "/CN=LocalSend User", "-out", cert], check=True, capture_output=True)
    with open(cert, encoding="ascii") as handle:
        der = ssl.PEM_cert_to_DER_cert(handle.read())
    return cert, key, hashlib.sha256(der).hexdigest()


def info(peer, fingerprint, announce=None):
    body = {"alias": peer["alias"], "version": "2.2", "deviceModel": peer["deviceModel"],
            "deviceType": peer["deviceType"], "fingerprint": fingerprint, "port": peer["port"],
            "protocol": "https", "download": False}
    if announce is not None:
        body["announce"] = announce
    return body


def make_handler(peer, fingerprint, rate):
    class Handler(http.server.BaseHTTPRequestHandler):
        protocol_version = "HTTP/1.1"

        def log_message(self, *_):
            return

        def reply(self, payload=None):
            data = json.dumps(payload).encode() if payload is not None else b""
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

        def body(self):
            length = int(self.headers.get("Content-Length") or 0)
            return self.rfile.read(length) if length else b""

        def do_GET(self):
            self.reply(info(peer, fingerprint)) if self.path.startswith(f"{API}/info") else self.send_error(404)

        def do_POST(self):
            route = self.path.split("?")[0]
            if route in (f"{API}/register", f"{API}/info"):
                self.body()
                return self.reply(info(peer, fingerprint))
            if route == f"{API}/prepare-upload":
                files = json.loads(self.body() or b"{}").get("files", {})
                return self.reply({"sessionId": str(uuid.uuid4()), "files": {key: uuid.uuid4().hex for key in files}})
            if route == f"{API}/upload":
                self.receive_slowly(int(self.headers.get("Content-Length") or 0))
                return self.reply()
            if route == f"{API}/cancel":
                return self.reply()
            self.send_error(404)

        def receive_slowly(self, remaining):
            while remaining > 0:
                chunk = self.rfile.read(min(CHUNK, remaining))
                if not chunk:
                    return
                remaining -= len(chunk)
                time.sleep(len(chunk) / rate)

    return Handler


class SlowServer(http.server.ThreadingHTTPServer):
    """A small receive buffer, so the sender's progress follows what this peer has really read."""

    def server_bind(self):
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, RECEIVE_BUFFER)
        super().server_bind()


def serve_peer(index, rate):
    peer = PEERS[index]
    cert, key, fingerprint = certificate(index)
    server = SlowServer(("0.0.0.0", peer["port"]), make_handler(peer, fingerprint, rate))
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain(cert, key)
    server.socket = context.wrap_socket(server.socket, server_side=True)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return peer, fingerprint


def multicast_socket(address):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    sock.bind(("", MULTICAST_PORT))
    membership = socket.inet_aton(MULTICAST_GROUP) + socket.inet_aton(address)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, membership)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(address))
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    return sock


def unverified():
    """RoomSend's certificate is self-signed; a test peer does not check it."""
    context = ssl.create_default_context()
    context.check_hostname, context.verify_mode = False, ssl.CERT_NONE
    return context


def answer_announcements(sock, peers):
    """Registers every peer with a device that announces itself, as the protocol prefers."""
    own = {fingerprint for _, fingerprint in peers}
    insecure = unverified()
    while True:
        data, (host, _) = sock.recvfrom(65535)
        try:
            other = json.loads(data)
        except ValueError:
            continue
        if other.get("fingerprint") in own or not other.get("announce"):
            continue
        scheme = other.get("protocol", "https")
        for peer, fingerprint in peers:
            request = urllib.request.Request(f"{scheme}://{host}:{other.get('port', MULTICAST_PORT)}{API}/register",
                                             data=json.dumps(info(peer, fingerprint)).encode(),
                                             headers={"Content-Type": "application/json"}, method="POST")
            try:
                urllib.request.urlopen(request, timeout=2, context=insecure).read()
            except OSError:
                continue


def serve(count, rate):
    address = lan_address()
    peers = [serve_peer(index, rate) for index in range(count)]
    sock = multicast_socket(address)
    threading.Thread(target=answer_announcements, args=(sock, peers), daemon=True).start()
    print(f"{count} peers on {address}: " + ", ".join(peer["alias"] for peer, _ in peers), flush=True)
    while True:
        for peer, fingerprint in peers:
            sock.sendto(json.dumps(info(peer, fingerprint, announce=True)).encode(), (MULTICAST_GROUP, MULTICAST_PORT))
        time.sleep(ANNOUNCE_EVERY)


def offer(target, paths, index, rate):
    """Peer `index` proposes files to RoomSend over HTTPS; once accepted, uploads them at `rate`."""
    peer = PEERS[index]
    _, _, fingerprint = certificate(index)
    files, by_id = {}, {}
    for path in paths:
        key = uuid.uuid4().hex
        by_id[key] = path
        files[key] = {"id": key, "fileName": os.path.basename(path), "size": os.path.getsize(path),
                      "fileType": "image/jpeg" if path.lower().endswith((".jpg", ".jpeg")) else "application/octet-stream"}
    request = urllib.request.Request(f"https://{target}{API}/prepare-upload",
                                     data=json.dumps({"info": info(peer, fingerprint), "files": files}).encode(),
                                     headers={"Content-Type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(request, timeout=300, context=unverified()) as response:
            answer = json.loads(response.read() or b"{}")
    except OSError as error:
        print("no answer:", error, flush=True)
        return
    for key, token in answer.get("files", {}).items():
        upload(target, answer["sessionId"], key, token, by_id[key], rate)
    print("sent", len(answer.get("files", {})), flush=True)


def upload(target, session, key, token, path, rate):
    host, port = target.split(":")
    connection = http.client.HTTPSConnection(host, int(port), timeout=120, context=unverified())
    size = os.path.getsize(path)
    connection.putrequest("POST", f"{API}/upload?sessionId={session}&fileId={key}&token={token}")
    connection.putheader("Content-Length", str(size))
    connection.putheader("Content-Type", "application/octet-stream")
    connection.endheaders()
    with open(path, "rb") as handle:
        while True:
            chunk = handle.read(CHUNK)
            if not chunk:
                break
            connection.send(chunk)
            time.sleep(len(chunk) / rate)
    connection.getresponse().read()
    connection.close()


def write_manifest():
    entries = [{"alias": peer["alias"], "type": peer["deviceType"], "fingerprint": certificate(index)[2]}
               for index, peer in enumerate(PEERS)]
    with open(os.path.join(HERE, "peers.json"), "w", encoding="utf-8") as handle:
        json.dump(entries, handle, indent=2)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    serve_args = sub.add_parser("serve")
    serve_args.add_argument("--count", type=int, default=len(PEERS), choices=range(1, len(PEERS) + 1))
    serve_args.add_argument("--rate", type=float, default=2_000_000, help="upload speed, bytes per second")
    offer_args = sub.add_parser("offer")
    offer_args.add_argument("--to", required=True, help="host:port of RoomSend")
    offer_args.add_argument("--peer", type=int, default=0)
    offer_args.add_argument("--files", nargs="+", required=True)
    offer_args.add_argument("--rate", type=float, default=350_000, help="upload speed, bytes per second")
    args = parser.parse_args()
    write_manifest()
    if args.command == "serve":
        serve(args.count, args.rate)
    else:
        offer(args.to, args.files, args.peer, args.rate)


if __name__ == "__main__":
    main()
