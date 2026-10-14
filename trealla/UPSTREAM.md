# Vendored Trealla provenance

This `trealla/` directory is a vendored copy of upstream Trealla Prolog:

- Repo:    https://github.com/trealla-prolog/trealla
- Release: v3.13.9 (commit 7fd0ea9), exported with `git archive`
  (previously commit e0b92d2, v2.102.30)

Local patches (in `trealla/src`, and therefore in the R package's `src/`):

- `bif_posix.c`, `query.c`: Windows-only — prepended
  `#if defined(_WIN32)\n#include <process.h>\n#endif` (GCC 16 implicit
  `getpid` declaration).
- `skiplist.c`: `sl_find_key` returned `false` from a pointer function
  (C23 error under `gcc -std=gnu2x`); now `NULL`.
- `history.c`: `USE_PLAIN_HISTORY` selects a plain `getline()` reader for
  embed builds (no libedit). Upstream's `history_none.c` is not used because
  it returns EOF for every read from stdin.

## Building `tpl`

    cd trealla && GIT_DIR=/nonexistent make

`GIT_DIR=/nonexistent` stops `git describe` from finding vProlog's own
repository, so the version comes from upstream's `.tarball-version`
(`tpl --version` prints v3.13.9).

The embed test (`test/run_suite.sh`) links `build/libtrealla.a`, built
without FFI/SSL from a scratch copy of this tree:
`GIT_DIR=/nonexistent make NOFFI=1 NOSSL=1 libtrealla.a`.

## The R package's `src/`

`src/` is a flat copy of `trealla/src/*.[ch]`, `src/imath`, `src/sre`, plus
the embedded libraries (`library/**/*.pl` converted with `util/bin2c`, as the
GNUmakefile's `library/%.c` rule does; make deletes them as intermediates).
Upstream alternates are left out, since `Makevars` compiles `*.c`:
`bif_ffi.c` (`bif_ffi_none.c` is used), `bif_gpio_linux.c`,
`bif_net_none.c`, `network_none.c`, `bif_os_none.c`, `bif_posix_none.c`,
`history_none.c`, `janus_py.c`.

Since v3, the engine itself defines `g_envp` and the signal handler, so an
embedder only declares `extern char **g_envp;` (see `src/vprolog.cpp`).

To refresh from upstream: re-export at a newer tag, re-apply the patches
above (or upstream them), rebuild, and regenerate `src/` the same way.
