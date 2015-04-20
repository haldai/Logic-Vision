%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FlashFill domain-specific code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clausebound(5).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MetaRules - sequence of metarule sequences
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%metaruless([[precon,base,chain,inverse,property]]). %chain,
%metaruless([[chain,inverse,tailrec]]). %base--inverse
metaruless([[property_chain]]). % ,inverse,tailrec
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

% dyadics([write_dot,write_slash,make_uppercase,make_lowercase,copy1,skip1]).
% monadics([uppercase,lowercase,input_space,digit]).



% dyadics([athleteplaysforteam/2,teamhomestadium/2]). %athleteplayssport/2 -- from episode
% monadics([]). %female/1,male/1

dyadics([polygon/2, list_length/2]).
monadics([]). % triangle/1

:-['./facts/poly_1.pl'].

%num_edges(X, Y):-
%    polygon(X, L),
%    list_length(L, Y).

list_length(X, N):-
    X = [_|_],
    length(X, N),
    num_edges(N).


%num_equals(X, Y):-
%    num(X),
%    num(Y),
%    X =:= Y.

num_edges(1). num_edges(2).
num_edges(3). num_edges(4).
num_edges(5). num_edges(6).
num_edges(7). num_edges(8).
num_edges(9). num_edges(10).
