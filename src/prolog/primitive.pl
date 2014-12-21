% line(L, K, B): L is a line whose equation is y=K*x+B
point_on_line(P, L):-
    point(P, X, Y),
    line(L, K, B),
    K*X + B is Y.

point_on_line_seg(P, L, S):-
    point(P, X, Y),
    line(L, K, B),
    K*X + B is Y,
    seg(S, X_1, X_2),
    X > X_1,
    X < X_2.

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
