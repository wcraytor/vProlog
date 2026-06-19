/* Representative cross-feature checks driven from the embedded C API.
   No :- initialization / no halt: the host queries embed_all/0 directly.
   Operators (#=, sat, "...") are defined here at consult time, so the
   operator-free query string "embed_all" parses fine in the host. */
:- use_module(library(lists)).
:- use_module(library(clpz)).
:- use_module(library(clpb)).
:- use_module(library(dcgs)).
:- set_prolog_flag(double_quotes, chars).

greeting --> "hi".

embed_all :-
    /* core ISO */
    (X is 2+3*4, X =:= 14),
    append([1],[2],[1,2]),
    findall(Y, member(Y,[1,2,3]), [1,2,3]),
    catch(atom_length(123,_), error(type_error(_,_),_), true),
    /* CLP(Z) */
    (A #= 2+3, A == 5),
    (B in 1..3, findall(B, label([B]), Bs), sort(Bs,[1,2,3])),
    (C #= D+1, D in 1..3, findall(C-D, label([C,D]), L), sort(L,[2-1,3-2,4-3])),
    /* CLP(B) */
    sat(_P + _Q),
    (taut(R + ~R, T), T == 1),
    /* CJK / Unicode code-point semantics */
    atom_length('日本語', 3),
    atom_length('한국어', 3),
    (atom_chars('中文', Cs), length(Cs, 2)),
    sub_atom('日本語', 1, 1, _, '本'),
    /* DCG */
    phrase(greeting, [h,i]).
