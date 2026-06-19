/* ISO phrase/2,3 + DCG conformance suite.

   Test cases and intended (WG17) results transcribed from Ulrich Neumerkel's
   public conformance table:
     https://www.complang.tuwien.ac.at/ulrich/iso-prolog/phrase
   (the de-facto reference behind ISO/IEC TS 13211-3 DCG semantics).

   Each tc/3 goal is an ORACLE that succeeds iff this engine's behaviour on the
   query matches one of the WG17-acceptable outcomes (several queries permit
   alternatives, e.g. representation_error(dcg_body) OR a success). Error checks
   match by class + type (the culprit term is allowed to vary, matching the
   table's "good"/"error class & type ok" criterion). */

:- include('harness.pl').
:- use_module(library(dcgs)).
:- use_module(library(lists)).

/* ---- oracle helpers ---- */

% throws(G, Class): running G raises an error whose class/type is Class.
throws(Goal, Class) :-
    catch( ( ( call(Goal) -> true ; true ), R = ok ), error(E,_), R = err(E) ),
    R = err(E),
    err_class(E, Class).

err_class(type_error(T,_),            type(T)).
err_class(instantiation_error,       inst).
err_class(existence_error(_,_),       exist).
err_class(permission_error(_,_,_),    perm).
err_class(representation_error(_),    repr).

first(Goal) :- call(Goal), !.    % commit to first solution (for binding checks)

/* ---- 47 cases (numbers match the source table) ---- */

tc(t01, ( first((phrase((=),L), L==[])) ; throws(phrase((=),_), exist) ), succ).
tc(t02, throws(phrase(1,_), type(callable)),                              succ).
tc(t03, throws(phrase(_K,_L), inst),                                      succ).
tc(t04, (K=[], phrase(K,L), K==[], L==[]),                                succ).
tc(t05, throws(asserta((a-->b)), perm),                                   succ).
tc(t06, throws(clause((a-->b),_), perm),                                  succ).
tc(t07, throws((_X-->_Y), exist),                                         succ).
tc(t08, (phrase(!,L), L==[]),                                             succ).
tc(t09, (phrase([a],L), L==[a]),                                          succ).
tc(t10, throws(phrase([a|b],_), type(list)),                              succ).
tc(t11, throws(phrase([a|_L],_K), inst),                                  succ).
tc(t12, throws(phrase([a|_L],_L2), inst),                                 succ).
tc(t13, throws(phrase([a|_L],[a,b]), inst),                               succ).
tc(t14, throws(phrase([a|_L],[]), inst),                                  succ).
tc(t15, phrase(([a],[]),[a]),                                             succ).
tc(t16, throws(phrase(([a],{1}),[]), type(callable)),                     succ).
tc(t17, throws(phrase((!,[a],{1}),[]), type(callable)),                   succ).
tc(t18, \+ phrase(({!,fail};[]),_),                                       succ).
tc(t19, phrase('|'([],[a]),[a]),                                          succ).
tc(t20, throws(phrase(({fail},1),_), type(callable)),                     succ).
tc(t21, first((phrase(([a];[]),L), L==[a])),                              succ).
tc(t22, throws(phrase({fail,1},_), type(callable)),                       succ).
tc(t23, catch((phrase({throw(h)},[a]),fail), h, true),                    succ).
tc(t24, throws(phrase(({L=[]},[a|L]),[a]), inst),                         succ).
tc(t25, throws((phrase([a|L],_K), L=[b]), inst),                          succ).
tc(t26, ( throws(phrase(([a|_L],1),[]), type(callable))
        ; throws(phrase(([a|_L],1),[]), inst) ),                          succ).
tc(t27, ( throws(phrase((1,[a|_L]),[]), type(callable))
        ; throws(phrase((1,[a|_L]),[]), inst) ),                          succ).
tc(t28, ( throws(phrase((1,[a|b]),[]), type(callable))
        ; throws(phrase((1,[a|b]),[]), type(list)) ),                     succ).
tc(t29, throws(phrase((1,{2}),[]), type(callable)),                       succ).
tc(t30, throws(phrase(({2},1),[]), type(callable)),                       succ).
tc(t31, ( throws(phrase('|'(([x]->[y]),[z]),_), repr)
        ; first((phrase('|'(([x]->[y]),[z]),L), L==[x,y])) ),             succ).
tc(t32, first((phrase(;(([x]->[y]),[z]),L), L==[x,y])),                    succ).
tc(t33, \+ phrase(([a],phrase(2)),[]),                                    succ).
tc(t34, ( throws(phrase(\+[a],[]), repr) ; phrase(\+[a],[]) ),            succ).
tc(t35, ( throws(phrase(\+1,_), repr)
        ; throws(phrase(\+1,_), type(callable)) ),                        succ).
tc(t36, ( throws(phrase(([a],\+1),[]), repr) ; \+ phrase(([a],\+1),[]) ), succ).
tc(t37, ( throws(phrase(([a],\+1;[]),[]), repr)
        ; phrase(([a],\+1;[]),[]) ),                                      succ).
% KNOWN DIVERGENCE: WG17 prescribes existence_error(procedure,phrase/4) (or a
% non_terminal existence_error); our Trealla v2.102.30 instead SUCCEEDS with
% L=[] on this nested-phrase goal. The source table flags phrase//2 as an area
% of ongoing spec clarification, so this reflects a post-table build change.
tc(t38, throws(phrase(phrase(phrase,[]),_), exist),                       succ).
tc(t39, ( throws(phrase(call([]),[]), exist) ; phrase(call([]),[]) ),     succ).
tc(t40, (L=[], \+ phrase([a|L],[b])),                                     succ).
tc(t41, (L=[], phrase([a|L],[a]), L==[]),                                 succ).
tc(t42, \+ phrase([a],[b]),                                               succ).
tc(t43, ( (phrase(!,[_]) ; L=1), L==1 ),                                  succ).
tc(t44, ( \+ phrase([],non_list) ; throws(phrase([],non_list), type(list)) ), succ).
tc(t45, ( \+ phrase([],[a|non_list]) ; throws(phrase([],[a|non_list]), type(list)) ), succ).
tc(t46, ( first((phrase([],L,non_list), L==non_list))
        ; throws(phrase([],_,non_list), type(list)) ),                    succ).
tc(t47, ( first((phrase([],L,[a|non_list]), L==[a|non_list]))
        ; throws(phrase([],_,[a|non_list]), type(list)) ),                succ).

:- initialization(run_suite("phrase_iso")).
