#!/bin/sh
# Run every vProlog unit-test suite. Exit 0 only if all pass.
#   Layer 1: feature suites via tpl (core, CLP(Z), CLP(B), CJK)
#   Layer 2: DCG conformance battery via tpl
#   Layer 3: the embedded C-API path (core+CLP+CJK+DCG through libtrealla.a)
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TPL="$ROOT/trealla/tpl"
rc=0

cd "$ROOT/test/suite" || exit 2
for s in core clpz clpb cjk; do
  out=$("$TPL" "$s.pl" </dev/null 2>&1)
  printf '%s\n' "$out" | grep -E '/[0-9]+ pass'
  printf '%s\n' "$out" | grep '^  FAIL' || true
  printf '%s\n' "$out" | grep -qE ' \(0 fail\)' || rc=1
done

# DCG conformance (its own runner / output format)
dout=$("$TPL" "$ROOT/test/dcg_conformance.pl" </dev/null 2>&1 | grep -E 'DCG conformance')
echo "$dout"; printf '%s' "$dout" | grep -q '/19 pass (0 fail)' || rc=1

# ISO phrase/2,3 conformance vs Neumerkel's WG17 oracle. EXTERNAL standard —
# reported as a conformance score, NOT a pass/fail gate (1 known divergence).
pout=$("$TPL" phrase_iso.pl </dev/null 2>&1 | grep -E '/[0-9]+ pass')
echo "$pout  [WG17 phrase conformance — informational]"

# ISO-core built-in conformance via the INRIA/Hodgson suite (external standard,
# informational — not a gate). ~10 known deviations: error-culprit granularity,
# intentional Unicode acceptance, and driver substitution-matching artifacts.
sh "$ROOT/test/run_iso.sh" 2>/dev/null | tail -1

# Embedded C-API test (build if libtrealla.a present, else skip with notice)
cd "$ROOT" || exit 2
if [ -f build/libtrealla.a ]; then
  if cc -I trealla/src test/embed_tests.c build/libtrealla.a -lm -ledit -lpthread \
        -o build/embed_tests 2>/dev/null; then
    eout=$(./build/embed_tests 2>&1); ec=$?
    echo "$eout"; [ "$ec" -eq 0 ] || rc=1
  else
    echo "embed C-API: SKIP (link failed)"; rc=1
  fi
else
  echo "embed C-API: SKIP (build/libtrealla.a missing — run: make -C trealla NOFFI=1 NOSSL=1 && archive)"
fi

exit $rc
