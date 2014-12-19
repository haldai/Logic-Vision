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

% define midpoint/3
midpoint(P1, P2, P):-
    point(P1, X1, Y1),
    point(P2, X2, Y2),
    X3_d is (X1 + X2)/2,
    Y3_d is (Y1 + Y2)/2,
    X3 is truncate(X3_d),
    Y3 is truncate(Y3_d),
    assertz(point(P, X3, Y3)). % TODO

% use N to limit recursion times
edge_line_seg(P1, P2, 0):-
    edge_point(P1),
    edge_point(P2),
    midpoint(P1, P2, P),
    edge_point(P).
edge_line_seg(P1, P2, N):-
    midpoint(P1, P2, P),
    N2 is N - 1,
    edge_line_seg(P1, P, N2),
    edge_line_seg(P, P2, N2).

% define edge_point/1
edge_point(P):-
    point(P, X, Y),
    edge_thresh(T),
    edge_point(X, Y, V, _),
    V >= T.
