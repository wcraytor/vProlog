/* Clean-room CLP(Q) PROOF-OF-CONCEPT — linear-equality kernel.
   Published algorithm (Gaussian elimination to solved form; Jaffar/Michaylov/
   Stuckey/Yap CLP(R) architecture). NO GPL source used.
   Self-contained EXACT rationals q(N,D) (gcd-normalised, D>0) — deliberately
   NOT Trealla's native rationals (incomplete: denominator/1 fails on ints). */
:- use_module(library(lists)).

/* exact rationals q(N,D) */
qgcd(A,0,A) :- !.
qgcd(A,B,G) :- R is A mod B, qgcd(B,R,G).
q_norm(N,D,Q) :-
    ( N =:= 0 -> Q = q(0,1)
    ; An is abs(N), Ad is abs(D), qgcd(An,Ad,G),
      ( N*D < 0 -> Nn is -(An//G) ; Nn is An//G ), Dn is Ad//G, Q = q(Nn,Dn) ).
int_q(I, q(I,1)).
q_add(q(N1,D1),q(N2,D2),R) :- N is N1*D2+N2*D1, D is D1*D2, q_norm(N,D,R).
q_mul(q(N1,D1),q(N2,D2),R) :- N is N1*N2, D is D1*D2, q_norm(N,D,R).
q_neg(q(N,D),q(M,D)) :- M is -N.
q_div(_,q(0,_),_) :- !, fail.
q_div(q(N1,D1),q(N2,D2),R) :- N is N1*D2, D is D1*N2, q_norm(N,D,R).
q_zero(q(0,_)).

/* linear forms lin(qConst,[Var-qCoeff,...]) */
lin_of(N, lin(Q,[]))              :- number(N), !, int_q(N,Q).
lin_of(V, lin(q(0,1),[V-q(1,1)])) :- var(V), !.
lin_of(A+B, L)                    :- !, lin_of(A,LA), lin_of(B,LB), lin_add(LA,LB,L).
lin_of(A-B, L)                    :- !, lin_of(A,LA), lin_of(B,LB), lin_neg(LB,NB), lin_add(LA,NB,L).
lin_of(-A, L)                     :- !, lin_of(A,LA), lin_neg(LA,L).
lin_of(N*A, L)                    :- number(N), !, int_q(N,Q), lin_of(A,LA), lin_sc(LA,Q,L).
lin_of(A*N, L)                    :- number(N), !, int_q(N,Q), lin_of(A,LA), lin_sc(LA,Q,L).
lin_sc(lin(C,Ps), Q, lin(C2,Ps2)) :- q_mul(C,Q,C2), sc_pairs(Ps,Q,Ps2).
sc_pairs([],_,[]).
sc_pairs([V-Co|T],Q,[V-Co2|T2]) :- q_mul(Co,Q,Co2), sc_pairs(T,Q,T2).
lin_neg(L, L2) :- lin_sc(L, q(-1,1), L2).
lin_add(lin(C1,P1), lin(C2,P2), lin(C,P)) :- q_add(C1,C2,C), foldl(ins_pair,P2,P1,P0), exclude(zero_q,P0,P).
ins_pair(V-Co, Pin, Pout) :- ( sel_eq(V,Cold,Pin,Prest) -> q_add(Cold,Co,Cn), Pout=[V-Cn|Prest] ; Pout=[V-Co|Pin] ).
zero_q(_-Q) :- q_zero(Q).
sel_eq(V, C0, [V0-C0|T], T)  :- V0==V, !.
sel_eq(V, C0, [P|T], [P|T2]) :- sel_eq(V, C0, T, T2).
find_def([V0-D|_], V, D) :- V0==V, !.
find_def([_|S], V, D)    :- find_def(S, V, D).
subst(lin(C,Ps), Store, Out) :- foldl(subst_pair(Store),Ps,lin(C,[]),Out).
subst_pair(Store, V-Co, Acc, Out) :- ( find_def(Store,V,Def) -> lin_sc(Def,Co,T) ; T=lin(q(0,1),[V-Co]) ), lin_add(Acc,T,Out).
elim(V, Def, V0-D0, V0-D1) :- D0=lin(C0,Pairs), ( sel_eq(V,Co,Pairs,Rest) -> lin_sc(Def,Co,T), lin_add(lin(C0,Rest),T,D1) ; D1=D0 ).

/* incremental solver */
add_constraint(Lin0, S0, S) :-
    subst(Lin0,S0,lin(C,Pairs)),
    ( Pairs == [] -> ( q_zero(C) -> S=S0 ; fail )
    ; Pairs=[V-Ck|Rest], q_neg(C,NegC), q_div(NegC,Ck,NC),
      mk_npairs(Rest,Ck,NPairs),
      Def=lin(NC,NPairs), maplist(elim(V,Def),S0,S1), S=[V-Def|S1] ).
mk_npairs([],_,[]).
mk_npairs([Vi-Coi|T],Ck,[Vi-NCi|T2]) :- q_neg(Coi,NCo), q_div(NCo,Ck,NCi), mk_npairs(T,Ck,T2).

solve([], S, S).
solve([L =:= R|Cs], S0, S) :- lin_of(L,LL), lin_of(R,LR), lin_neg(LR,NR), lin_add(LL,NR,Lin), add_constraint(Lin,S0,S1), solve(Cs,S1,S).
conj_list((A,B),[A|T]) :- !, conj_list(B,T).
conj_list(A,[A]).
cq(Conj) :- conj_list(Conj,Cs), solve(Cs,[],Store), bind_all(Store).
bind_all([]).
bind_all([V-lin(K,[])|T]) :- !, V=K, bind_all(T).
bind_all([_|T]) :- bind_all(T).

chk(Name, Goal) :- catch((call(Goal)->T=ok;T='FAIL'),E,T=err(E)), format("  ~w  ~w~n",[T,Name]).
:- initialization((
     chk(solve_2x2,    ( cq((X1+Y1 =:= 10, X1-Y1 =:= 2)), X1==q(6,1), Y1==q(4,1) )),
     chk(rational_1_3, ( cq((3*X2 =:= 1)), X2==q(1,3) )),
     chk(substitution, ( cq((2*X3 + 3*Y3 =:= 12, X3 =:= 3)), Y3==q(2,1) )),
     chk(inconsistent, ( \+ cq((X4 =:= 1, X4 =:= 2)) )),
     chk(three_var,    ( cq((A+B+C5 =:= 6, A-B =:= 0, C5 =:= 2)), A==q(2,1), B==q(2,1) )),
     chk(fractions,    ( cq((2*Y6 =:= 3)), Y6==q(3,2) )),
     halt )).
dbg :- solve([X+Y =:= 10, X-Y =:= 2], [], Store),
       write('STORE: '), write(Store), nl,
       ( member(V-lin(K,[]), Store) -> write('determined member ok'),nl ; write('NO determined member'),nl ),
       forall(member(V2-lin(K2,[]),Store), (write(V2=K2),nl)).
