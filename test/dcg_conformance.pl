/* Practical DCG (ISO/IEC TS 13211-3-style) conformance battery for Trealla.
   Not the formal TS suite — covers the spec's normative DCG features. */
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- set_prolog_flag(double_quotes, chars).

/* ---- grammars ---- */
empty      --> [].
one        --> [a].
two        --> [a], [b].
nt         --> one, [b].                 % nonterminal then terminal
disj       --> [a] ; [b].
optional   --> [a] ; [].
ifthen     --> ( [a] -> [b] ; [c] ).     % ->/; in a body
str        --> "hi".                     % terminal string (double_quotes=chars => [h,i])
push, [c]  --> [a].                      % pushback: consume a, push back c
brace(X)   --> [X], { integer(X) }.      % {}/1 Prolog escape
metant(Nt) --> Nt.                       % meta-call of a nonterminal (call//1-ish)
cutg       --> [a], !, [b].
star([])     --> [].
star([X|Xs]) --> [X], star(Xs).          % recursion / generation

/* ---- runner ---- */
:- dynamic(tally/2).
ev(G, R) :- catch( ( call(G) -> R = succ ; R = fail ), E, R = threw(E) ).
bump(p) :- retract(tally(P,F)), P1 is P+1, assertz(tally(P1,F)).
bump(f) :- retract(tally(P,F)), F1 is F+1, assertz(tally(P,F1)).

tc(terminal_match,    phrase(one,[a]),                 succ).
tc(terminal_nomatch,  phrase(one,[b]),                 fail).
tc(empty_body,        phrase(empty,[]),                succ).
tc(sequence,          phrase(two,[a,b]),               succ).
tc(nonterminal,       phrase(nt,[a,b]),                succ).
tc(disjunction_l,     phrase(disj,[a]),                succ).
tc(disjunction_r,     phrase(disj,[b]),                succ).
tc(disjunction_none,  phrase(disj,[c]),                fail).
tc(optional_empty,    phrase(optional,[]),             succ).
tc(phrase3_leftover,  (phrase(one,[a,b],R), R==[b]),   succ).
tc(brace_true,        phrase(brace(5),[5]),            succ).
tc(brace_false,       phrase(brace(a),[a]),            fail).
tc(if_then_else,      phrase(ifthen,[a,b]),            succ).
tc(string_terminal,   phrase(str,[h,i]),               succ).
tc(pushback,          (phrase(push,[a],R2), R2==[c]),  succ).
tc(meta_nonterminal,  phrase(metant(one),[a]),         succ).
tc(cut_in_body,       phrase(cutg,[a,b]),              succ).
tc(recursion_parse,   phrase(star([a,b,c]),[a,b,c]),   succ).
tc(recursion_gen,     (phrase(star(L),[a,b]), L==[a,b]), succ).

run :-
    ( retract(tally(_,_)) -> true ; true ), assertz(tally(0,0)),
    ( tc(N,G,E),
      ev(G,R),
      ( R == E -> Tag = 'PASS', bump(p) ; Tag = 'FAIL', bump(f) ),
      ( R == E -> true ; format("~w ~w  got=~w exp=~w~n",[Tag,N,R,E]) ),
      fail
    ; true ),
    tally(P,F), T is P+F,
    format("~nDCG conformance: ~w/~w pass (~w fail)~n",[P,T,F]),
    halt.
:- initialization(run).
