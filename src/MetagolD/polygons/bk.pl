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
dyadics([polygon/2, list_length/2, connect_edge/3]).
monadics([]). % triangle/1

% other primitives

%num_edges(X, Y):-
%    polygon(X, L),
%    list_length(L, Y).

list_length(X, N):-
    X = [_|_],
    length(X, N),
    integer_(N).

connect_edge(X, Y, T):-
    thresh_(T),
    edges_ends(X, Vs),
    replace_connected_edges(Vs, X, T, Y).

integer_(1). integer_(2).
integer_(3). integer_(4).
integer_(5). integer_(6).
integer_(7). integer_(8).
integer_(9). integer_(10).

thresh_(0.002). thresh_(0.004).
thresh_(0.006). thresh_(0.008).
thresh_(0.010). thresh_(0.012).
thresh_(0.014). thresh_(0.016).
thresh_(0.018). thresh_(0.020).
thresh_(0.022). thresh_(0.024).
thresh_(0.026). thresh_(0.028).
thresh_(0.030). thresh_(0.032).
thresh_(0.034). thresh_(0.036).
thresh_(0.038). thresh_(0.040).
