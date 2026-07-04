// R binding to the Trealla Prolog engine via its C embedding API.
#include <Rcpp.h>
extern "C" {
#include "trealla.h"
}

// Symbols that tpl.c's main() normally provides; required when embedding the
// library without the REPL driver (see test/embed_tests.c).
extern "C" char **environ;
extern "C" {
  char **g_envp = NULL;
  void sigfn(int s) { (void)s; }
}

using namespace Rcpp;

static void prolog_finalizer(prolog *pl) { if (pl) pl_destroy(pl); }
typedef XPtr<prolog, PreserveStorage, prolog_finalizer> PrologPtr;

// [[Rcpp::export]]
SEXP cpp_open() {
  prolog *pl = pl_create();
  if (!pl) stop("pl_create() failed");
  g_envp = environ;
  set_quiet(pl);  // suppress banner / interactive chatter
  PrologPtr p(pl);
  return p;
}

// [[Rcpp::export]]
bool cpp_consult(SEXP ptr, std::string filename) {
  PrologPtr p(ptr);
  return pl_consult(p.get(), filename.c_str());
}

// [[Rcpp::export]]
bool cpp_eval(SEXP ptr, std::string expr) {
  PrologPtr p(ptr);
  return pl_eval(p.get(), expr.c_str(), false);
}

// Run a single goal to completion and return success/failure.
// The caller wraps goals in double negation (\+ \+ Goal) so no free variables
// escape to the top-level variable dumper — that dumper also walks attributed
// (CLP) variables and is the source of the redo/alignment crash. One shot, no
// pl_redo iteration.
// [[Rcpp::export]]
bool cpp_query(SEXP ptr, std::string goal) {
  PrologPtr p(ptr);
  pl_sub_query *q = NULL;
  // pl_query()'s bool means "ran without a hard error", NOT "the goal
  // succeeded" (even `fail` returns true). The logical result is get_status().
  pl_query(p.get(), goal.c_str(), &q, 0);
  bool ok = get_status(p.get());
  if (ok && q) pl_done(q);  // choicepoint only exists on success
  return ok;
}
