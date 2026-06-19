/* Clean-room CLP(R) PROOF-OF-CONCEPT — same linear-equality kernel as the
   CLP(Q) PoC, but the q(N,D) exact-rational layer is replaced by native
   FLOAT arithmetic (is/2 directly). The ONLY structural difference: a
   zero-test must use an epsilon tolerance instead of exact ==0 (the defining
   trade-off of reals-as-floats). NO GPL source used. */
:- use_module(library(lists)).
eps(1.0e-9).
is_zero(X) :- AX is abs(X), eps(E), AX < E.

lin_of(N, lin(N,[]))    :- number(N), !.
lin_of(V, lin(0,[V-1])) :- var(V), !.
lin_of(A+B, L) :- !, lin_of(A,LA), lin_of(B,LB), lin_add(LA,LB,L).
lin_of(A-B, L) :- !, lin_of(A,LA), lin_of(B,LB), lin_sc(LB,-1,NB), lin_add(LA,NB,L).
lin_of(-A, L)  :- !, lin_of(A,LA), lin_sc(LA,-1,L).
lin_of(N*A, L) :- number(N), !, lin_of(A,LA), lin_sc(LA,N,L).
lin_of(A*N, L) :- number(N), !, lin_of(A,LA), lin_sc(LA,N,L).
lin_sc(lin(C,Ps), K, lin(C2,Ps2)) :- C2 is C*K, sc_pairs(Ps,K,Ps2).
sc_pairs([],_,[]).
sc_pairs([V-Co|T],K,[V-Co2|T2]) :- Co2 is Co*K, sc_pairs(T,K,T2).
lin_neg(L,L2) :- lin_sc(L,-1,L2).
lin_add(lin(C1,P1),lin(C2,P2),lin(C,P)) :- C is C1+C2, foldl(ins_pair,P2,P1,P0), exclude(zero_coeff,P0,P).
ins_pair(V-Co,Pin,Pout) :- ( sel_eq(V,Cold,Pin,Prest) -> Cn is Cold+Co, Pout=[V-Cn|Prest] ; Pout=[V-Co|Pin] ).
zero_coeff(_-C) :- is_zero(C).
sel_eq(V,C0,[V0-C0|T],T) :- V0==V, !.
sel_eq(V,C0,[P|T],[P|T2]) :- sel_eq(V,C0,T,T2).
find_def([V0-D|_],V,D) :- V0==V, !.
find_def([_|S],V,D) :- find_def(S,V,D).
subst(lin(C,Ps),Store,Out) :- foldl(subst_pair(Store),Ps,lin(C,[]),Out).
subst_pair(Store,V-Co,Acc,Out) :- ( find_def(Store,V,Def) -> lin_sc(Def,Co,T) ; T=lin(0,[V-Co]) ), lin_add(Acc,T,Out).
elim(V,Def,V0-D0,V0-D1) :- D0=lin(C0,Pairs), ( sel_eq(V,Co,Pairs,Rest) -> lin_sc(Def,Co,T), lin_add(lin(C0,Rest),T,D1) ; D1=D0 ).
mk_npairs([],_,[]).
mk_npairs([Vi-Coi|T],Ck,[Vi-NCi|T2]) :- NCi is -Coi/Ck, mk_npairs(T,Ck,T2).
add_constraint(Lin0,S0,S) :-
    subst(Lin0,S0,lin(C,Pairs)),
    ( Pairs==[] -> ( is_zero(C) -> S=S0 ; fail )
    ; Pairs=[V-Ck|Rest], NC is -C/Ck, mk_npairs(Rest,Ck,NPairs),
      Def=lin(NC,NPairs), maplist(elim(V,Def),S0,S1), S=[V-Def|S1] ).
solve([],S,S).
solve([L=:=R|Cs],S0,S) :- lin_of(L,LL), lin_of(R,LR), lin_neg(LR,NR), lin_add(LL,NR,Lin), add_constraint(Lin,S0,S1), solve(Cs,S1,S).
conj_list((A,B),[A|T]) :- !, conj_list(B,T).
conj_list(A,[A]).
cr(Conj) :- conj_list(Conj,Cs), solve(Cs,[],Store), bind_all(Store).
bind_all([]).
bind_all([V-lin(K,[])|T]) :- !, V=K, bind_all(T).
bind_all([_|T]) :- bind_all(T).

near(X,V) :- D is abs(X-V), D < 1.0e-6.
chk(N,G) :- catch((call(G)->T=ok;T='FAIL'),E,T=err(E)), format("  ~w  ~w~n",[T,N]).
:- initialization((
     chk(solve_2x2,    ( cr((X1+Y1 =:= 10, X1-Y1 =:= 2)), near(X1,6), near(Y1,4) )),
     chk(real_third,   ( cr((3*X2 =:= 1)), near(X2,0.333333) )),
     chk(substitution, ( cr((2*X3 + 3*Y3 =:= 12, X3 =:= 3)), near(Y3,2) )),
     chk(inconsistent, ( \+ cr((X4 =:= 1, X4 =:= 2)) )),
     chk(decimals,     ( cr((X5 =:= 0.1 + 0.2)), near(X5,0.3) )),
     chk(show_value,   ( cr((3*Z =:= 1)), write('    3Z=1 -> Z='), write(Z), nl )),
     halt )).
