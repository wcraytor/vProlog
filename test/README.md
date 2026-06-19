# vProlog test suite

One command runs everything:

    ./test/run_suite.sh        # exit 0 iff all pass

## Layers

1. **Feature unit tests** (`test/suite/*.pl`, run via `trealla/tpl`)
   - `core.pl` — 24 core ISO tests (unify, arith, functor/arg/univ, atom ops,
     lists, findall/setof/between/sort, cut, neg, if-then-else, catch/throw,
     assert/retract, type_error)
   - `clpz.pl` — 12 CLP(Z) tests (`#=`,`#\=`,`#<`, `in`/`ins`, `label`,
     `all_different`, `sum`, reification, inconsistency)
   - `clpb.pl` — 6 CLP(B) tests (`sat`, `taut`, `labeling`, contradiction)
   - `cjk.pl` — 6 Unicode/CJK tests (code-point `atom_length`/`atom_chars`/
     `sub_atom`/`atom_concat` over JA/KO/ZH + emoji)
   - shared harness: `test/suite/harness.pl` (`tc(Name,Goal,Expect)` facts +
     `run_suite/1`); each suite `:- include('harness.pl').`
2. **DCG conformance** — `test/dcg_conformance.pl` (19/19, ISO TS 13211-3-style)
   - `test/suite/phrase_iso.pl` — the 47 `phrase/2,3` cases from Ulrich
     Neumerkel's WG17 conformance table
     (complang.tuwien.ac.at/ulrich/iso-prolog/phrase), each encoded as an oracle
     checking this engine against the standard-intended result. **46/47**
     (informational — external standard, not a pass/fail gate). The one
     divergence: `phrase(phrase(phrase,[]),L)` succeeds here vs WG17's
     `existence_error` (a nested-`phrase//2` edge the source flags as in-flux).
3. **ISO-core conformance** — `test/iso/inriasuite/` is the vendored INRIA suite
   (Deransart/Ed-Dbali/Cervoni tests, Hodgson driver; from
   deransart.fr/prolog/suites.html), 420 standard examples across 58 built-ins.
   `test/run_iso.sh` runs it on our Trealla and reports a conformance score:
   **410/420 (97.6%), 52/58 BIPs fully conformant** (informational — external
   standard, not a gate). The ~10 deviations are minor/explainable: error-culprit
   *granularity* (`call`/`catch` report `type_error(callable,1)` vs the standard's
   whole-goal culprit), intentional **Unicode** acceptance (`atom_codes`/
   `number_codes` accept code point 1000 where the 1995 text wanted
   `representation_error`), and driver substitution-matching artifacts
   (`sub_atom` — Trealla's answers are actually correct).
4. **Embedded C-API** — `test/embed_tests.c` consults
   `test/suite/embed_checks.pl` and queries `embed_all/0` through
   `pl_create`/`pl_consult`/`pl_query` against `build/libtrealla.a`. This is the
   path the R package uses, so it covers core+CLP(Z)+CLP(B)+CJK+DCG end to end.

## Adding a test

Append a `tc(name, Goal, succ|fail).` fact to the relevant suite. For a new
feature needing operators, `:- use_module(library(...)).` BEFORE the `tc/3`
facts so operators are defined at parse time.
