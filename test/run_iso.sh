#!/bin/sh
# ISO-core conformance via the INRIA/Hodgson suite (Deransart, Ed-Dbali,
# Cervoni; driver by J.P.E. Hodgson). External standard -> informational score,
# NOT a pass/fail gate. Excludes the 'halt' BIP (would kill the process).
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TPL="$ROOT/trealla/tpl"
cd "$ROOT/test/iso/inriasuite" || exit 2
"$TPL" -g "findall(F,(file(F),F\==halt),Fs), test_all(Fs), (score(G,total(T),wrong(W)),format('SCORE ~w ~w ~w~n',[G,T,W]),fail;true), halt" \
     inriasuite.pl </dev/null 2>/dev/null \
| awk '/^SCORE/{t+=$3; w+=$4; n++; if($4>0){bad++; printf "  deviation: %-16s %d/%d ok\n",$2,$3-$4,$3}}
       END{printf "INRIA ISO-core: %d/%d pass (%.1f%%); %d/%d BIPs fully conformant\n", t-w,t,100*(t-w)/t, n-bad, n}'
