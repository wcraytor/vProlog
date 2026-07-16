#' Open a Prolog engine
#'
#' Creates an in-process Trealla Prolog engine. The returned external pointer
#' carries a finalizer, so the engine is destroyed automatically when garbage
#' collected.
#' @return An external pointer of class \code{prolog_engine}.
#' @export
prolog_open <- function() {
  p <- cpp_open()
  class(p) <- "prolog_engine"
  p
}

#' Close a Prolog engine
#'
#' Destroys the engine immediately instead of waiting for garbage collection.
#' Safe to call more than once; using the engine afterwards is an error. Useful
#' in long-running processes (Shiny sessions, batch drivers) that open many
#' engines.
#' @param pl A \code{prolog_engine}.
#' @return \code{NULL}, invisibly.
#' @export
prolog_close <- function(pl) {
  stopifnot(inherits(pl, "prolog_engine"))
  cpp_close(pl)
  invisible(NULL)
}

#' Consult a Prolog source file
#' @param pl A \code{prolog_engine}.
#' @param file Path to a \code{.pl} file.
#' @return \code{TRUE} if the file loaded without error.
#' @export
pl_consult <- function(pl, file) {
  stopifnot(inherits(pl, "prolog_engine"))
  cpp_consult(pl, normalizePath(file, mustWork = TRUE))
}

#' Consult Prolog source held in a character string
#' @param pl A \code{prolog_engine}.
#' @param text Prolog source text.
#' @return \code{TRUE} if it loaded without error.
#' @export
pl_consult_text <- function(pl, text) {
  tf <- tempfile(fileext = ".pl")
  on.exit(unlink(tf), add = TRUE)
  writeLines(text, tf, useBytes = TRUE)
  pl_consult(pl, tf)
}

#' Load a Trealla library module (e.g. "clpz", "clpb", "dcgs", "lists")
#'
#' Makes the module's operators (such as \code{#=} or \code{sat}) available to
#' subsequent \code{\link{pl_query}} goal strings.
#' @param pl A \code{prolog_engine}.
#' @param lib Module name without the \code{library()} wrapper.
#' @return \code{TRUE} on success.
#' @export
pl_use <- function(pl, lib) {
  stopifnot(inherits(pl, "prolog_engine"))
  cpp_query(pl, sprintf("use_module(library(%s))", lib))
}

#' Run a directive/goal via pl_eval
#' @param pl A \code{prolog_engine}.
#' @param expr A bare goal (no leading \code{:-} or trailing \code{.}).
#' @return \code{TRUE} on success.
#' @export
pl_eval <- function(pl, expr) {
  stopifnot(inherits(pl, "prolog_engine"))
  cpp_eval(pl, expr)
}

#' Is a goal provable?
#'
#' The goal is run under double negation (\code{\\+ \\+ (Goal)}), so it reports
#' provability without leaving bindings for the top-level dumper to print.
#' @param pl A \code{prolog_engine}.
#' @param goal A goal string.
#' @return \code{TRUE} if the goal has at least one solution.
#' @export
pl_query <- function(pl, goal) {
  stopifnot(inherits(pl, "prolog_engine"))
  cpp_query(pl, sprintf("\\+ \\+ (%s)", goal))
}

#' Count the solutions of a goal
#'
#' Counted inside Prolog via \code{findall/3} (no \code{pl_redo} iteration). The
#' goal must be finite; \code{max > 0} caps the reported count.
#' @param pl A \code{prolog_engine}.
#' @param goal A goal string.
#' @param max Maximum solutions to count (0 = no cap).
#' @return Integer solution count.
#' @export
pl_count <- function(pl, goal, max = 0L) {
  stopifnot(inherits(pl, "prolog_engine"))
  n <- length(pl_findall(pl, "x", goal))
  max <- as.integer(max)
  if (max > 0L) min(n, max) else n
}

#' Collect solution bindings (findall)
#'
#' Runs \code{goal}, writing one \code{template} instance per solution to a temp
#' file via \code{writeq/2}, then reads the lines back. Each returned string is a
#' canonical (\code{writeq}) term. Operators used in \code{template}/\code{goal}
#' must already be loaded (see \code{\link{pl_use}}).
#' @param pl A \code{prolog_engine}.
#' @param template A term whose bindings to capture per solution (e.g. "X-Y").
#' @param goal The goal to satisfy (e.g. "member(X,[1,2,3])").
#' @return Character vector of \code{writeq}'d solution terms (possibly empty).
#' @export
pl_findall <- function(pl, template, goal) {
  stopifnot(inherits(pl, "prolog_engine"))
  tf <- tempfile(fileext = ".terms")
  on.exit(unlink(tf), add = TRUE)
  pf <- gsub("\\\\", "/", tf)  # Prolog wants forward slashes in path atoms
  # \+ \+ keeps the file side effects but discards the stream binding so it
  # never reaches the top-level variable dumper.
  g <- sprintf(
    "\\+ \\+ (open('%s',write,S),forall((%s),(writeq(S,(%s)),nl(S))),close(S))",
    pf, goal, template)
  ok <- cpp_query(pl, g)
  if (!ok || !file.exists(tf)) return(character(0))
  readLines(tf, encoding = "UTF-8", warn = FALSE)
}
