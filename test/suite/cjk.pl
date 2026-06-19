/* vProlog CJK / Unicode unit tests (code-point semantics) */
:- include('harness.pl').
:- use_module(library(lists)).
tc(ja_len,    atom_length('日本語', 3),                        succ).
tc(ko_len,    atom_length('한국어', 3),                        succ).
tc(zh_chars,  (atom_chars('中文', Cs), length(Cs, 2)),          succ).
tc(sub_mid,   (sub_atom('日本語', 1, 1, _, S), atom_length(S, 1)), succ).
tc(concat,    atom_concat('日本', '語', '日本語'),               succ).
tc(emoji_cp,  atom_length('😀', 1),                            succ).
:- initialization(run_suite("cjk")).
