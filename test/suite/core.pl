/* vProlog core ISO Prolog unit tests */
:- include('harness.pl').
:- use_module(library(lists)).

tc(unify,          (X = a, X == a),                              succ).
tc(unify_fail,     (a = b),                                      fail).
tc(arith,          (X is 2+3*4, X =:= 14),                       succ).
tc(arith_cmp,      (3 > 2),                                      succ).
tc(functor_make,   (functor(T,foo,2), T = foo(_,_)),             succ).
tc(functor_insp,   (functor(foo(a,b),F,N), F==foo, N==2),        succ).
tc(arg,            (arg(2, foo(a,b,c), b)),                      succ).
tc(univ,           (foo(a,b) =.. [foo,a,b]),                     succ).
tc(atom_length,    (atom_length(hello,5)),                       succ).
tc(atom_concat,    (atom_concat(foo,bar,foobar)),                succ).
tc(atom_chars,     (atom_chars(abc,[a,b,c])),                    succ).
tc(member,         (member(b,[a,b,c])),                          succ).
tc(append,         (append([1],[2],[1,2])),                      succ).
tc(reverse,        (reverse([1,2,3],[3,2,1])),                   succ).
tc(findall,        (findall(X, member(X,[1,2,3]), [1,2,3])),     succ).
tc(setof,          (setof(X, member(X,[3,1,2,1]), [1,2,3])),     succ).
tc(between,        (between(1,3,2)),                             succ).
tc(sort,           (msort([3,1,2],[1,2,3])),                     succ).
tc(cut,            ((member(X,[1,2,3]), !, X==1)),               succ).
tc(neg,            (\+ member(x,[a,b])),                         succ).
tc(if_then_else,   (( 1 > 2 -> X=a ; X=b ), X==b),               succ).
tc(catch_throw,    (catch(throw(boom), E, E==boom)),             succ).
tc(assert_retract, (assertz(t_fact(1)), retract(t_fact(1)), \+ t_fact(_)), succ).
tc(type_error,     (catch(atom_length(123,_), error(type_error(_,_),_), true)), succ).

:- dynamic(t_fact/1).
:- initialization(run_suite("core")).
