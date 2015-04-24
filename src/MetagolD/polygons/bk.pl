%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FlashFill domain-specific code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clausebound(5).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MetaRules - sequence of metarule sequences
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%metaruless([[precon,base,chain,inverse,property]]). %chain,
%metaruless([[chain,inverse,tailrec]]). %base--inverse
metaruless([[chain, property_chain]]). % ,inverse,tailrec
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
    concat(P_dir, 'post_process.pl', P_post),
    [P_prim],
    [P_poly],
    [P_samp],
    [P_conj],
    [P_util],
    [P_post].

% predicates for abduction
dyadics([polygon/2, list_length/2, connect_edges/3, ignore_edge/3]).
monadics([]). % triangle/1

% other primitives

%num_edges(X, Y):-
%    polygon(X, L),
%    list_length(L, Y).

% predicate for list length
list_length(X, N):-
    X = [_|_],
    length(X, N),
    integer_(N).

% connect obtuse angles within threshold
connect_edges(X, Y, T):-
    thresh_1(T),
    edges_ends(X, Vs),
    replace_connected_edges(Vs, X, T, Y),
    (same_seg(X, Y) ->
	 (fail, !);
     (true, !)
    ).

% ignore short edges within threshold
ignore_edge(X, Y, T):-
    thresh_2(T),
    ignore_edges(X, X, T, Y),
    (same_seg(X, Y) ->
	 (fail, !);
     (true, !)
    ).

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

% list for edges length
edges_length_list([], Y, Temp):-
    Y = Temp, !.
edges_length_list([X | Xs], Y, Temp):-
    seg_length(X, L),
    append(Temp, [L], Temp_1),
    edges_length_list(Xs, Y, Temp).

edges_length_list(Edges, Edges_len_list):-
    edges_length_list(Edges, Edges_len_list, []).

% bound the standard deviation of a list
std_dev_bounded(List, T):-
    thresh_3(T),
    std_dev(List, D),
    D < T.

thresh_3(0.10). thresh_3(0.12).
thresh_3(0.14). thresh_3(0.16).
thresh_3(0.18). thresh_3(0.20).
thresh_3(0.22). thresh_3(0.24).
thresh_3(0.26). thresh_3(0.28).
thresh_3(0.30). thresh_3(0.32).
thresh_3(0.34). thresh_3(0.36).
thresh_3(0.38). thresh_3(0.40).
thresh_3(0.40). thresh_3(0.42).
thresh_3(0.44). thresh_3(0.46).
thresh_3(0.48). thresh_3(0.50).

% use edge_angle/7 to define right angle
% REMARK: RAD angle devided by pi/1.
has_angle(Angles, A_val, A_thresh):-
    angle_val(A_val),
    thresh_4(A_thresh),
    member(Angle, Angles),
    abs(Angle - A_val) < A_thresh,
    !.

angle_val(0.1). angle_val(0.2).
angle_val(0.3). angle_val(0.4).
angle_val(0.5). angle_val(0.6).
angle_val(0.7). angle_val(0.8).
angle_val(0.9). angle_val(1.0).

thresh_4(0.10). thresh_4(0.12).
thresh_4(0.14). thresh_4(0.16).
thresh_4(0.18). thresh_4(0.20).
thresh_4(0.22). thresh_4(0.24).
thresh_4(0.26). thresh_4(0.28).
thresh_4(0.30). thresh_4(0.32).
thresh_4(0.34). thresh_4(0.36).
thresh_4(0.38). thresh_4(0.40).
thresh_4(0.40). thresh_4(0.42).
thresh_4(0.44). thresh_4(0.46).
thresh_4(0.48). thresh_4(0.50).

