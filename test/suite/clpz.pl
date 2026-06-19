/* vProlog CLP(Z) unit tests (constraints over integers) */
:- include('harness.pl').
:- use_module(library(clpz)).
:- use_module(library(lists)).

tc(equate,        (X #= 2+3, X == 5),                                          succ).
tc(equate_fail,   (2 #= 3),                                                    fail).
tc(disequal,      (3 #\= 4),                                                   succ).
tc(less,          (2 #< 3),                                                    succ).
tc(domain_label,  (X in 1..3, findall(X, label([X]), L), sort(L,[1,2,3])),     succ).
tc(plus_relation, (X #= Y+1, Y in 1..3, findall(X-Y, label([X,Y]), L),
                   sort(L, [2-1,3-2,4-3])),                                    succ).
tc(exclude_val,   (X in 1..3, X #\= 2, findall(X, label([X]), L), sort(L,[1,3])), succ).
tc(min_constraint,(X in 1..5, X #>= 3, once(label([X])), X == 3),              succ).
tc(all_different, (Vs=[A,B], Vs ins 1..2, all_different(Vs),
                   findall(A-B, label(Vs), L), sort(L,[1-2,2-1])),             succ).
tc(sum_constraint,(Vs=[A,B], Vs ins 0..3, sum(Vs,#=,3),
                   findall(A-B, label(Vs), L), sort(L,[0-3,1-2,2-1,3-0])),     succ).
tc(inconsistent,  (X in 1..2, X #> 5),                                        fail).
tc(reif,          (X in 0..1, B in 0..1, X #= 1 #<==> B #= 1,
                   X = 1, once(label([B])), B == 1),                          succ).

:- initialization(run_suite("clpz")).
