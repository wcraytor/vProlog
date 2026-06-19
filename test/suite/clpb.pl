/* vProlog CLP(B) unit tests (boolean constraints) */
:- include('harness.pl').
:- use_module(library(clpb)).
:- use_module(library(lists)).
tc(sat,        sat(X + Y),                                        succ).
tc(taut,       (taut(X + ~X, T), T == 1),                         succ).
tc(contradiction, (taut(X * ~X, T), T == 0),                      succ).
tc(contingent_no, (taut(X * Y, _)),                               fail).
tc(or_models,  (sat(X + Y), findall(X-Y, labeling([X,Y]), L), sort(L, S),
                S == [0-1, 1-0, 1-1]),                            succ).
tc(and,        (sat(X * Y), labeling([X,Y]), X==1, Y==1),         succ).
:- initialization(run_suite("clpb")).
