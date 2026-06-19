/* vProlog test harness. Each suite file: consult this, define tc(Name,Goal,Expect)
   facts (Expect in {succ, fail, or a custom checker goal}), then
   :- initialization(run_suite("name")).  Exits 0 if all pass, 1 otherwise. */
:- dynamic(t_tally/2).

t_ev(G, R) :- catch( ( call(G) -> R = succ ; R = fail ), E, R = threw(E) ).

t_bump(p) :- retract(t_tally(P,F)), P1 is P+1, assertz(t_tally(P1,F)).
t_bump(f) :- retract(t_tally(P,F)), F1 is F+1, assertz(t_tally(P,F1)).

run_suite(Name) :-
    ( retract(t_tally(_,_)) -> true ; true ), assertz(t_tally(0,0)),
    ( tc(N, G, E),
      t_ev(G, R),
      ( R == E -> t_bump(p)
      ; t_bump(f), format("  FAIL ~w  got=~w exp=~w~n", [N, R, E]) ),
      fail
    ; true ),
    t_tally(P, F), T is P + F,
    format("~w: ~w/~w pass (~w fail)~n", [Name, P, T, F]),
    ( F =:= 0 -> halt(0) ; halt(1) ).
