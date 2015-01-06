% line(L, A, B, C): L is a line whose equation is a*x+b*y+c=0
point_on_line(X, Y, A, B, C):-
    number(X),
    number(Y),
    number(A),
    number(B),
    number(C),
    A*X + B*Y + C =:= 0,
    !.

point_on_line(X, Y, A, B, C):-
    var(X),
    number(Y),
    number(A),
    A =\= 0,
    number(B),
    number(C)
    -> X is -(B*Y + C)/A;

    var(Y),
    number(X),
    number(A),
    number(B),
    B =\= 0,
    number(C)
    -> Y is -(A*X + C)/B.

point_on_line_seg_x(X, Y, A, B, C, X1, X2):-
    number(X),
    number(Y),
    number(X1),
    number(X2),
    number(A),
    number(B),
    number(C),
    A*X + B*Y + C =:= 0,
    X > X1,
    X < X2.

point_on_line_seg_y(X, Y, A, B, C, Y1, Y2):-
    number(X),
    number(Y),
    number(Y1),
    number(Y2),
    number(A),
    number(B),
    number(C),
    A*X + B*Y + C =:= 0,
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
    X is truncate(X_d),
    Y is truncate(Y_d).

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
    edge_thresh(T),
    edge_point(X, Y, V, _),
    V >= T.

% define display_point/2
display_point(P, C):-
    point(P, X, Y),
    display_point(X, Y, C).
