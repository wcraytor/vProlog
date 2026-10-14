"""Two local HTTP servers for test/http/redirect_auth.sh.

Origin A: /cross redirects to origin B (another port), /same redirects to
A's own /final. Every request's credential headers are logged, one line
each: "<origin> <path> auth=<0|1> cookie=<0|1> keep=<0|1>".
Prints "PORTS <a> <b>" once listening; serves until killed.
"""
import sys
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer

LOG = open(sys.argv[1], "w", buffering=1)
ports = {}


def handler(origin):
    class H(BaseHTTPRequestHandler):
        def do_GET(self):
            h = self.headers
            LOG.write(f"{origin} {self.path} auth={int('Authorization' in h)} "
                      f"cookie={int('Cookie' in h)} keep={int('X-Keep' in h)}\n")
            if origin == "A" and self.path in ("/cross", "/same"):
                target = (f"http://127.0.0.1:{ports['B']}/final" if self.path == "/cross"
                          else "/final")
                self.send_response(302)
                self.send_header("Location", target)
                self.send_header("Content-Length", "0")
                self.end_headers()
                return
            body = b"ok"
            self.send_response(200)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def log_message(self, *args):
            pass
    return H


servers = {}
for origin in ("A", "B"):
    servers[origin] = HTTPServer(("127.0.0.1", 0), handler(origin))
    ports[origin] = servers[origin].server_address[1]
    threading.Thread(target=servers[origin].serve_forever, daemon=True).start()
print(f"PORTS {ports['A']} {ports['B']}", flush=True)
threading.Event().wait()
