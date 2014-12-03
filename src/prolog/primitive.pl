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
