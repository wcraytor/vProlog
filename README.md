# vProlog

Embeddable Prolog for valuation-engineer projects (R packages, tools), built on
[**Trealla Prolog**](https://github.com/trealla-prolog/trealla) — a compact, MIT-licensed,
C99 ISO Prolog **designed to be embedded** (C API + `-DEMBED=1`).

Unlike the earlier `valProlog` experiment (a port of Amzi! Prolog), Trealla **already
ships** the things we need:

- **Attributed variables** (`freeze/2`, `dif/2`, `when/2`)
- **Constraint libraries: CLP(Z) and CLP(B)** — no WAM surgery, no library porting
- **DCGs**, SWI-compatible predicates, delimited continuations
- A clean C embedding API (`pl_create` / `pl_consult` / `pl_query` / `pl_redo`)

**Scope.** This repository is the **Prolog layer only**: the vendored engine, a
clean-room **CLP(Q,R)** effort (`research/clp/`), and a conformance/test harness.
The **R binding** and any **application/domain grammars** (e.g. the MLS-remarks
DCG) live with the consuming app (currently `TrilogyWF`), not here.

## Relationship to Trealla

vProlog is **not a separate Prolog engine or a fork** — it is a *vendored copy*
of upstream Trealla plus this thin layer. `trealla/` is stock Trealla at the
commit recorded in `trealla/UPSTREAM.md`, with a single 6-line Windows-only
build patch (`getpid`/`<process.h>` in `src/bif_posix.c`, `src/bif_functions.c`).
All Prolog semantics, CLP(Z)/CLP(B), DCGs and ISO conformance are Trealla's.

## Status (arm64 macOS / Apple Silicon)

Builds and **embeds**: a C driver (`test/embed_probe.c`) links Trealla's objects and runs
- CLP(Z): `X #= Y+1, Y in 1..3, label([X,Y])` → `[2-1,3-2,4-3]`
- `dif/2` (attributed variable) → holds

### Conformance (`./test/run_suite.sh`)

| Suite | Result |
|---|---|
| Feature unit tests (core/CLP(Z)/CLP(B)/CJK) | all pass |
| DCG practical battery | 19/19 |
| ISO `phrase/2,3` (Neumerkel WG17) | 46/47 *(informational)* |
| ISO-core built-ins (INRIA suite) | 410/420 = 97.6% *(informational)* |
| Embedded C-API path | pass |

CLP(Q)/CLP(R) clean-room proofs-of-concept (linear-equality kernels over exact
rationals / floats) are in `research/clp/`.

## Build (engine)

Optional features (FFI, OpenSSL) off — not needed for CLP/DCG embedding:

```sh
cd trealla && make NOFFI=1 NOSSL=1        # builds tpl + objects (EMBED=1 is default)
```

## Embed into a C host

```sh
# archive engine objects (exclude tpl.c's main)
find trealla -name '*.o' ! -name 'tpl.o' -print0 | xargs -0 ar rcs build/libtrealla.a
# link a host driver
cc -O2 -I trealla/src host.c build/libtrealla.a -lm -ledit -lpthread -o host
```

The host must provide two symbols normally defined in `tpl.c`'s `main`:
`char **g_envp;` and `void sigfn(int);` (see `test/embed_probe.c`).

API (`trealla/src/trealla.h`): `pl_create` → `pl_consult(file)` / `pl_eval(goal)` /
`pl_query`+`pl_redo` (solution iteration) → `pl_destroy`. Load goals/operators via
`consult` of a `.pl` file (directives run in order, so `:- use_module(library(clpz))`
defines its operators before later goals are read).

## Layout

| Path | Contents |
|------|----------|
| `trealla/` | Vendored Trealla source (+ `UPSTREAM.md`; built in place) |
| `test/suite/` | Feature unit tests + `phrase_iso` conformance + shared `harness.pl` |
| `test/iso/inriasuite/` | Vendored INRIA ISO-core conformance suite |
| `test/` | Embed driver/tests, DCG battery, `run_suite.sh`, `run_iso.sh` |
| `research/clp/` | Clean-room CLP(Q)/CLP(R) proof-of-concept kernels |
| `build/` | Artifacts (gitignored) |

## License

MIT — see [LICENSE](LICENSE). Trealla is MIT, Copyright (c) 2020 Andrew George Davison.
