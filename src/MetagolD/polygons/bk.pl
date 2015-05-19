%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Polygon domain-specific code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clausebound(5).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MetaRules - sequence of metarule sequences
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%metaruless([[precon,base,chain,inverse,property]]). %chain,
%metaruless([[chain,inverse,tailrec]]). %base--inverse
metaruless([[chain, property_chain, property_precon]]). % ,inverse,tailrec
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
% for regular polygons
% dyadics([polygon/2, connect_edges/3, angles_list/2, std_dev_bounded/2]). % has_angle/3

% for polygons
dyadics([polygon/2, list_length/2, connect_edges/3]). 

% for right-angle triangles
% dyadics([polygon/2, triangle_x/1, angles_list/2, has_angle/3]). % 

monadics([]). % triangle/1

% learned primitives
% triangles
triangle_1_x(A,C,H):-connect_edges(A,B,C),list_length(B,H).
triangle_0_x(A,A2,B2):-polygon(A,B),triangle_1_x(B,A2,B2).
triangle_x(A):-triangle_0_x(A,0.015,3).

% other primitives

% predicate for list length
list_length(X, N):-
    X = [_|_],
    integer_(N),
    length(X, N).

% connect obtuse angles within threshold
connect_edges(X, Y, T):-
    not(var(X)),
    X = [_ | _],
    thresh_1(T),
    edges_ends(X, Vs),
    replace_connected_edges(Vs, X, T, Y),
    length(X, L1),
    length(Y, L2),
    (L1 =< L2 ->
	 (fail, !);
     true
    ).

% ignore short edges within threshold
ignore_edge(X, Y, T):-
    not(var(X)),
    X = [_ | _],
    thresh_2(T),
    ignore_edges(X, X, T, Y),
    (same_seg(X, Y) ->
	 (fail, !);
     true
    ).

integer_(0).
integer_(1). integer_(2).
integer_(3). integer_(4).
integer_(5). integer_(6).
integer_(7). integer_(8).
integer_(9). integer_(10).

thresh_1(0.002). thresh_1(0.004).
thresh_1(0.006). thresh_1(0.008).
thresh_1(0.010). thresh_1(0.015).
thresh_1(0.02). thresh_1(0.03).
thresh_1(0.04). thresh_1(0.05).

% list for edges length
edges_length_list([], Y, Temp):-
    Y = Temp, !.
edges_length_list([X | Xs], Y, Temp):-
    seg_length(X, L),
    append(Temp, [L], Temp_1),
    edges_length_list(Xs, Y, Temp_1).

edges_length_list(Edges, Edges_len_list):-
    edges_length_list(Edges, Edges_len_list, []).

% bound the standard deviation of a list
std_dev_bounded(List, T):-
    List = [X | _],
    number(X),
    thresh_3(T),
    std_dev(List, D),
    D =< T.

thresh_3(0.01). thresh_3(0.02).
thresh_3(0.03). thresh_3(0.04).
thresh_3(0.05). thresh_3(0.06).
thresh_3(0.07). thresh_3(0.08).
thresh_3(0.09). thresh_3(0.10).

% use edge_angle/7 to define right angle
% REMARK: RAD angle devided by pi/1.
has_angle(Angles, A_val, A_thresh):-
    Angles = [X | _],
    number(X),
    angle_val(A_val),
    thresh_4(A_thresh),
    member(Angle, Angles),
    abs(Angle - A_val) < A_thresh.

angle_val(0.1). angle_val(0.2).
angle_val(0.3). angle_val(0.4).
angle_val(0.5). angle_val(0.6).
angle_val(0.7). angle_val(0.8).
angle_val(0.9). angle_val(1.0).

thresh_4(0.005). thresh_4(0.010).
thresh_4(0.015). thresh_4(0.020).
thresh_4(0.025). thresh_4(0.030).
