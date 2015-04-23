%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FlashFill domain-specific code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clausebound(5).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MetaRules - sequence of metarule sequences
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%metaruless([[precon,base,chain,inverse,property]]). %chain,
%metaruless([[chain,inverse,tailrec]]). %base--inverse
metaruless([[property_chain, chain]]). % ,inverse,tailrec
%note:instance and property are proved by d_proved



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial Program State
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init_prog([]).

init_consts([]).  % Initial constants
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Object ordering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Final Input and Output must be suffixes of initial Input and Output


obj_gt(atom_gt).
obj_gte(atom_gte).

atom_gt(X,Y,_) :-
    X\==Y.   %X @< Y. 

atom_gte(_,_,_):-
%***--atom_gte(In1/Out1/_,In2/Out2/_,_) :-
	true. 

suffix(X,Y) :- X==Y.			% Nonground suffix test
suffix(L,X) :-
	nonvar(L), L=[_|T],
	suffix(T,X).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% primitive dir

:- 
    P_dir = '../../prolog/',
    % geometry primitives
    concat(P_dir, 'primitive.pl', P_prim),
    concat(P_dir, 'polygon.pl', P_poly),
    concat(P_dir, 'sampler.pl', P_samp),
    concat(P_dir, 'conjecture.pl', P_conj),
    concat(P_dir, 'utils', P_util),
    [P_prim],
    [P_poly],
    [P_samp],
    [P_conj],
    [P_util].

% predicates for abduction
dyadics([polygon/2, list_length/2, connect_edges/3]).
monadics([]). % triangle/1

% other primitives

%num_edges(X, Y):-
%    polygon(X, L),
%    list_length(L, Y).

list_length(X, N):-
    X = [_|_],
    length(X, N),
    integer_(N).

connect_edges(X, Y, T):-
    thresh_1(T),
    edges_ends(X, Vs),
    replace_connected_edges(Vs, X, T, Y).

ignore_edge(X, Y, T):-
    thresh_2(T),
    ignore_edges(X, X, T, Y).

integer_(1). integer_(2).
integer_(3). integer_(4).
integer_(5). integer_(6).
integer_(7). integer_(8).
integer_(9). integer_(10).

thresh_1(0.002). thresh_1(0.004).
thresh_1(0.006). thresh_1(0.008).
thresh_1(0.010). thresh_1(0.012).
%thresh_1(0.014). thresh_1(0.016).
%thresh_1(0.018). thresh_1(0.020).
%thresh_1(0.022). thresh_1(0.024).
%thresh_1(0.026). thresh_1(0.028).
%thresh_1(0.030). thresh_1(0.032).
%thresh_1(0.034). thresh_1(0.036).
%thresh_1(0.038). thresh_1(0.040).

thresh_2(0.10). thresh_2(0.12).
thresh_2(0.14). thresh_2(0.16).
thresh_2(0.18). thresh_2(0.20).
thresh_2(0.22). thresh_2(0.24).
thresh_2(0.26). thresh_2(0.28).
thresh_2(0.30). thresh_2(0.32).
thresh_2(0.34). thresh_2(0.36).
thresh_2(0.38). thresh_2(0.40).
thresh_2(0.40). thresh_2(0.42).
thresh_2(0.44). thresh_2(0.46).
thresh_2(0.48). thresh_2(0.50).
