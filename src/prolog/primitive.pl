% primitives.pl

% thresholds for edge_point gradient
edge_point_thresh(5.0).
% thresholds for "3 points on same line"
edge_angle_thresh(0.314).
% recursion limit for edge_line testing
recursion_limit(2).

% line(L, A, B, C): L is a line whose equation is a*x+b*y+c=0
% relaxed for discrete situation
point_on_line(X, Y, A, B, C):-
    number(X),
    number(Y),
    number(A),
    number(B),
    number(C),
    Xn is -(B*Y + C)/A,
    Yn is -(A*X + C)/B,
    (abs(Xn - X) =< 0.5; abs(Yn - Y) =< 0.5),
%    A*X + B*Y + C =:= 0,
    !.

point_on_line(X, Y, A, B, C):-
    var(X),
    number(Y),
    number(A),
    A =\= 0,
    number(B),
    number(C)
    -> Xn is -(B*Y + C)/A,
       X is truncate(Xn + 0.5);

    number(X),
    var(Y),
    number(A),
    number(B),
    B =\= 0,
    number(C)
    -> Yn is -(A*X + C)/B,
       Y is truncate(Yn + 0.5).

% check
point_on_line_seg_x(X, Y, A, B, C, X1, X2):-
    number(X),
    number(Y),
    number(X1),
    number(X2),
    number(A),
    number(B),
    number(C),
    Xn is -(B*Y + C)/A,
    Yn is -(A*X + C)/B,
    (abs(Xn - X) =< 0.5; abs(Yn - Y) =< 0.5),
    X > X1,
    X < X2.

% check
point_on_line_seg_y(X, Y, A, B, C, Y1, Y2):-
    number(X),
    number(Y),
    number(Y1),
    number(Y2),
    number(A),
    number(B),
    number(C),
    Xn is -(B*Y + C)/A,
    Yn is -(A*X + C)/B,
    (abs(Xn - X) =< 0.5; abs(Yn - Y) =< 0.5),
    Y > Y1,
    Y < Y2.

% get line parameters from two points
line_parameters(X1, Y1, X2, Y2, A, B, C):-
    X1 == X2,
    Y1 =\= Y2,
    A is 1,
    B is 0,
    C is X1,
    !.
line_parameters(X1, Y1, X2, Y2, A, B, C):-
    Y1 == Y2,
    X1 =\= X2,
    A is 0,
    B is 1,
    C is Y1,
    !.
line_parameters(X1, Y1, X2, Y2, A, B, C):-
    X1 =\= X2,
    Y1 =\= Y2,
    A is 1,
    B is -(X1 - X2)/(Y1 - Y2),
    C is (X1 - X2)*Y1/(Y1 - Y2) - X1.

% define midpoint/5
midpoint(X1, Y1, X2, Y2, X, Y):-
    X_d is (X1 + X2)/2,
    Y_d is (Y1 + Y2)/2,
    X is truncate(X_d + 0.5),
    Y is truncate(Y_d + 0.5).

% use N to limit recursion times
edge_line_seg(X1, Y1, X2, Y2, 0):-
    edge_point(X1, Y1),
    edge_point(X2, Y2),
    midpoint(X1, Y1, X2, Y2, X3, Y3),
    edge_point(X3, Y3).

edge_line_seg(X1, Y1, X2, Y2, N):-
    N > 0,
    midpoint(X1, Y1, X2, Y2, X, Y),
    N2 is N - 1,
    edge_line_seg(X1, Y1, X, Y, N2),
    edge_line_seg(X, Y, X2, Y2, N2),
    !.

edge_line_seg(P1, P2, N):-
    point(P1, X1, Y1),
    point(P2, X2, Y2),
    edge_line_seg(X1, Y1, X2, Y2, N).

% define edge_point/2
edge_point(X, Y):-
    edge_point_thresh(T),
    edge_point(X, Y, V, _),
    V >= T.

% define display_point/2
display_point(P, C):-
    point(P, X, Y),
    display_point(X, Y, C).

% define inner_product/3
inner_product([], [], 0).
inner_product([X|Xs], [Y|Ys], Result):-
    Prod is X*Y,
    inner_product(Xs, Ys, Remaining),
    Result is Prod + Remaining.

% define eu_dist/3
eu_dist_sum([], [], 0).
eu_dist_sum([X|Xs], [Y|Ys], Sum):-
    Dist is (X - Y)^2,
    eu_dist_sum(Xs, Ys, Remaining),
    Sum is Dist + Remaining.
eu_dist(X, Y, Result):-
    eu_dist_sum(X, Y, Sum),
    Result is sqrt(Sum).

% define edge_angle/7
edge_angle(X1, Y1, X2, Y2, X3, Y3, A):-
    inner_product([X2 - X1, Y2 - Y1], [X3 - X2, Y3 - Y2], P),
    eu_dist([X2 - X1, Y2 - Y1], [0, 0], D1),
    eu_dist([X3 - X2, Y3 - Y2], [0, 0], D2),
    Cos is P/(D1*D2),
    A is acos(Cos).
