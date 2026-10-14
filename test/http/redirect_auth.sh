#!/bin/sh
# vProlog patch check: http_open/3 must not send credentials across origins
# on a redirect, and must keep them on a same-origin redirect.
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TPL="${TPL:-$ROOT/trealla/tpl}"
TMP=$(mktemp -d)
trap 'kill $SRV 2>/dev/null; rm -rf "$TMP"' EXIT
python3 "$ROOT/test/http/redirect_servers.py" "$TMP/log" > "$TMP/ports" &
SRV=$!
i=0; while ! grep -q PORTS "$TMP/ports" 2>/dev/null; do
  i=$((i+1)); [ $i -gt 50 ] && { echo "http redirect auth: SKIP (no server)"; exit 1; }; sleep 0.1; done
set -- $(cat "$TMP/ports"); A=$2
fetch() {
  "$TPL" -q -g "use_module(library(http/http_open)), \
    http_open(\"http://user:pw@127.0.0.1:$A/$1\", S, \
      [request_header('Cookie'='c=1'), request_header('X-Keep'='k')]), \
    close(S), halt" </dev/null 2>&1
}
fetch cross; fetch same
expect() { grep -qx "$1" "$TMP/log" || { echo "  FAIL: expected \"$1\""; rc=1; }; }
rc=0
expect "A /cross auth=1 cookie=1 keep=1"
expect "B /final auth=0 cookie=0 keep=1"
expect "A /same auth=1 cookie=1 keep=1"
expect "A /final auth=1 cookie=1 keep=1"
if [ $rc -eq 0 ]; then echo "http redirect auth: PASS"; else echo "http redirect auth: FAIL"; cat "$TMP/log"; fi
exit $rc
