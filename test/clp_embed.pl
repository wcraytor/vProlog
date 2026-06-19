:- use_module(library(clpz)).
:- use_module(library(dif)).
:- initialization((
     X #= Y+1, Y in 1..3, findall(X-Y, label([X,Y]), L),
     write(embedded_clpz=L), nl )).
:- initialization((
     ( dif(A,B), A=1, B=2 -> write(dif_ok) ; write(dif_bad) ), nl )).
