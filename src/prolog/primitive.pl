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
    X >= X_1,
    X <= X_2.

% use N to limit recursion times
edge_line_seg(P1, P2, 0):-
    edge_point(P1),
    edge_point(P2).
edge_line_seg(P1, P2, N):-
    midpoint(P1, P2, P),
    edge_line_seg(P1, P, N - 1),
    edge_line_seg(P, P2, N - 1).

% define edge_point/1
edge_point(P):-
    point(P, X, Y),
    edge_thresh(T),
    edge_point(X, Y, V, D),
    V >= T.
    

