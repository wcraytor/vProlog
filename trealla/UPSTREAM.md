# Vendored Trealla provenance

This `trealla/` directory is a vendored copy of upstream Trealla Prolog:

- Repo:   https://github.com/trealla-prolog/trealla
- Commit: e0b92d2
- Local patch: a Windows-only build fix (6 lines) — prepended
  `#if defined(_WIN32)\n#include <process.h>\n#endif` to
  `src/bif_posix.c` and `src/bif_functions.c` (GCC 16 implicit getpid decl).

To refresh from upstream: re-clone at a newer commit and re-apply the patch
(or upstream the patch so no local diff remains).
