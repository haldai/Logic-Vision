% primitives.pl

% line(L, A, B, C): L is a line whose equation is a*x+b*y+c=0
% relaxed for discrete situation
point_on_line(X, Y, A, B, C):-
    integer(X),
    integer(Y),
    number(A),
    number(B),
    number(C),
    !,
    ((A =\= 0, B =\= 0) ->
	(Xn is -(B*Y + C)/A,
	 Yn is -(A*X + C)/B,
	 (abs(Xn - X) =< 1.0, abs(Yn - Y) =< 1.0)
	);
     ((A == 0, B =\= 0) ->
	 Yn is -C/B, abs(Yn - Y) =< 1.0;
      ((A =\= 0, B == 0) ->
	   Xn is -C/A, abs(Xn - X) =< 1.0;
       ((A == 0, B == 0) ->
	    fail
       )
      )
     )
    ).

point_on_line(X, Y, A, B, C):-
    var(X),
    integer(Y),
    number(A),
    number(B),
    number(C),
    !,
    (A =\= 0 -> 
	 X_ is -(B*Y + C)/A;
     ((B =\= 0, Y =:= -C/B) -> 
	  (img_size(W, _),
	   W_ is W - 1,
	   between(0, W_, X_)
	  );
      fail
     )
    ),
    X is truncate(X_ + 0.5).

point_on_line(X, Y, A, B, C):-
    integer(X),
    var(Y),
    number(A),
    number(B),
    number(C),
    !,
    (B =\= 0 -> 
	 Y_ is -(A*X + C)/B;
     ((A =\= 0, X =:= -C/A) -> 
	  (img_size(_, H), 
	   H_ is H - 1,
	   between(0, H_, Y_)
	  );
      fail
     )
    ),
    Y is truncate(Y_ + 0.5).

% only checks whether a point is in line segment
point_on_line_seg_x(X, Y, A, B, C, X1, X2):-
    number(X),
    number(Y),
    number(X1),
    number(X2),
    number(A),
    number(B),
    number(C),
    point_on_line(X, Y, A, B, C),
    (X1 =< X2 ->
	 (X >= X1, X =< X2);
     (X =< X1, X >= X2)
    ).

% only checks whether a point is in line segment
point_on_line_seg_y(X, Y, A, B, C, Y1, Y2):-
    number(X),
    number(Y),
    number(Y1),
    number(Y2),
    number(A),
    number(B),
    number(C),
    point_on_line(X, Y, A, B, C),
    (Y1 =< Y2 ->
	 (Y >= Y1, Y =< Y2);
     (Y =< Y1, Y >= Y2)
    ).

% use threshold
point_on_line_seg_thresh(Point, Seg, T):-
    Seg = [P1, P2],
    distance(Point, P1, D1),
    distance(Point, P2, D2),
    distance(P1, P2, D3),
    abs((D1 + D2 - D3)/D3) =< T.

point_on_line_seg(Point, Seg):-
    on_seg_thresh(T),
    point_on_line_seg_thresh(Point, Seg, T).

    
% get line parameters from two points
line_parameters(X1, Y1, X2, Y2, A, B, C):-
    integer(X1),
    integer(Y1),
    integer(X2),
    integer(Y2),
    X1 == X2,
    Y1 =\= Y2,
    A is 1,
    B is 0,
    C is -X1,
    !.
line_parameters(X1, Y1, X2, Y2, A, B, C):-
    integer(X1),
    integer(Y1),
    integer(X2),
    integer(Y2),
    Y1 == Y2,
    X1 =\= X2,
    A is 0,
    B is 1,
    C is -Y1,
    !.

line_parameters(X1, Y1, X2, Y2, A, B, C):-
    integer(X1),
    integer(Y1),
    integer(X2),
    integer(Y2),
    X1 =\= X2,
    Y1 =\= Y2,
    A is 1,
    B is -(X1 - X2)/(Y1 - Y2),
    C is (X1 - X2)*Y1/(Y1 - Y2) - X1.

line_parameters(P1, P2, A, B, C):-
    point(P1, X1, Y1),
    point(P2, X2, Y2),
    !,
    line_parameters(X1, Y1, X2, Y2, A, B, C).

line_parameters(P1, P2, A, B, C):-
    P1 = [X1, Y1],
    P2 = [X2, Y2],
    !,
    line_parameters(X1, Y1, X2, Y2, A, B, C).


line_parameters(S, A, B, C):-
    S = [[X1, Y1], [X2, Y2]],
    line_parameters(X1, Y1, X2, Y2, A, B, C).

% define midpoint/5
midpoint(X1, Y1, X2, Y2, X, Y):-
    X_d is (X1 + X2)/2,
    Y_d is (Y1 + Y2)/2,
    X is truncate(X_d + 0.5),
    Y is truncate(Y_d + 0.5).

% check whether [[X1, Y1],[X2, Y2]] is an edge line segment
edge_line_seg(X1, Y1, X2, Y2, 0):-
    edge_point(X1, Y1),
    edge_point(X2, Y2),
    midpoint(X1, Y1, X2, Y2, X3, Y3),
    edge_point(X3, Y3).

edge_line_seg(X1, Y1, X2, Y2, N):-
    integer(N),
    N > 0,
    midpoint(X1, Y1, X2, Y2, X, Y),
    N2 is N - 1,
    edge_line_seg(X1, Y1, X, Y, N2),
    edge_line_seg(X, Y, X2, Y2, N2),
    !.

edge_line_seg(X1, Y1, X2, Y2):-
    recursion_limit(N),
    edge_line_seg(X1, Y1, X2, Y2, N).

edge_line_seg(P1, P2, N):-
    integer(N),
    point(P1, X1, Y1),
    point(P2, X2, Y2),
    edge_line_seg(X1, Y1, X2, Y2, N).

edge_line_seg(S, N):-
    integer(N),
    S = [[X1, Y1], [X2, Y2]],
    !,
    edge_line_seg(X1, Y1, X2, Y2, N).

edge_line_seg(P1, P2):-
    recursion_limit(N),
    edge_line_seg(P1, P2, N).

edge_line_seg(S):-
    recursion_limit(N),
    S = [[X1, Y1], [X2, Y2]],
    edge_line_seg(X1, Y1, X2, Y2, N).

% uniform sampling between two points
inside_points_rec(X1, Y1, X2, Y2, N, Inside_points):-
    N =< 0 ->
	(connected(X1, Y1, X2, Y2) ->
	     Inside_points = [];
	    (midpoint(X1, Y1, X2, Y2, X, Y),
	     Inside_points = [[X, Y]]
	    )
	);
    (midpoint(X1, Y1, X2, Y2, X, Y),
     N2 is N - 1,
     inside_points_rec(X1, Y1, X, Y, N2, Inside_points1),
     append(Inside_points1, [[X, Y]], Temp_points),
     inside_points_rec(X, Y, X2, Y2, N2, Inside_points2),
     append(Temp_points, Inside_points2, Temp_points2),
     Inside_points = Temp_points2
    ).

avg_grad_val_seg(Seg, Value):-
    sample_line_seg(Seg, Point_list),
    avg_grad_val_point_list(Point_list, Value).

avg_grad_val_point_list([], Return, Len, Sum):-
    Return is Sum/Len.
avg_grad_val_point_list([P | Ps], Return, Len, Sum):-
    P = [X, Y],
    edge_point(X, Y, V, _),
    Sum_1 is Sum + V,
    avg_grad_val_point_list(Ps, Return, Len, Sum_1).

avg_grad_val_point_list(Point_list, Return):-
    length(Point_list, Len),
    avg_grad_val_point_list(Point_list, Return, Len, 0.0).
    
% proportion of edge points inside of a point list
edge_points_proportion(Point_list, Proportion):-
    length(Point_list, N),
    aggregate_all(
	    count,
	    (member(Point, Point_list),
	     Point = [X, Y],
	     edge_point(X, Y)
	    ),
	    Count
	),
    Proportion is Count/N.

% use proportion of edge points to judge the existance of edge
edge_line_seg_proportion(X1, Y1, X2, Y2, N, Thresh):-
    edge_point(X1, Y1),
    edge_point(X2, Y2),
    inside_points_rec(X1, Y1, X2, Y2, N, Inside_points),
    edge_points_proportion(Inside_points, Proportion),
    Proportion >= Thresh.

edge_line_seg_proportion(X1, Y1, X2, Y2, N):-
    edge_points_proportion_threshold(Proportion_thresh),
    edge_line_seg_proportion(X1, Y1, X2, Y2, N, Proportion_thresh).

edge_line_seg_proportion(X1, Y1, X2, Y2):-
    recursion_limit(N),
    edge_line_seg_proportion(X1, Y1, X2, Y2, N).

edge_line_seg_proportion(P1, P2):-
    P1 = [X1, Y1],
    P2 = [X2, Y2],
    recursion_limit(N),
    edge_line_seg_proportion(X1, Y1, X2, Y2, N).

edge_line_seg_proportion(P1, P2, Thresh):-
    P1 = [X1, Y1],
    P2 = [X2, Y2],
    recursion_limit(N),
    edge_line_seg_proportion(X1, Y1, X2, Y2, N, Thresh).

% define edge_point/2
edge_point(X, Y):-
    edge_point_thresh(T),
    edge_point(X, Y, V, _),
    V >= T.

% define edge_angle/7
edge_angle(X1, Y1, X2, Y2, X3, Y3, A):-
    inner_product([X2 - X1, Y2 - Y1], [X3 - X2, Y3 - Y2], P),
    eu_dist([X2 - X1, Y2 - Y1], [0, 0], D1),
    eu_dist([X3 - X2, Y3 - Y2], [0, 0], D2),
    Cos is P/(D1*D2),
    A is acos(Cos).

% define point_color/2
point_color(P, C):-
    P = [X, Y],
    !,
    point_color(X, Y, C).

point_color(P, C):-
    point(P, X, Y),
    !,
    point_color(X, Y, C).

% TODO:: define edge_direction/5
edge_direction(X1, Y1, X2, Y2, Dir):-
    fail.

% TODO:: colors on two sides of and edge
edge_colors(X1, Y1, X2, Y2, Colors):-
    fail.
