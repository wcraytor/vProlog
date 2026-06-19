# vProlog VS Code tooling

`.pl` editing for the Trealla-based engine, without needing an SWI install.

## Tasks (`Tasks: Run Task`, or Cmd/Ctrl+Shift+B for lint)

| Task | What it does |
|------|--------------|
| **lint current file** *(default build)* | `tpl -g "consult(FILE),halt"`; Trealla's singleton/syntax/error diagnostics are parsed into the **Problems** panel |
| **run current file** | `tpl FILE` — consults + runs any `:- initialization` |
| **trace current file (4-port)** | `tpl -t FILE` — the built-in CALL/EXIT/REDO/FAIL tracer in the terminal |
| **REPL (load file)** | `tpl -l FILE` — interactive toplevel with the file loaded |

## Caveat

The recommended Prolog extension's *own* linter/debugger assume **SWI-Prolog**
(they shell out to `swipl`). With Trealla you get syntax highlighting from the
extension and lint/trace from the tasks above. SWI's *graphical* breakpoint
debugger and deep static cross-referencer are not available for Trealla.
