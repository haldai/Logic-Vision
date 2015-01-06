% line sampler
random_point(X, Y):-
    img_size(W, H),
    random_between(0, W, R1),
    random_between(0, H, R2),
    X = R1,
    Y = R2.

% randomly sample a line, return all point on it
random_line(Point_List):-
    random_point(X1, Y1),
    random_point(X2, Y2),
    forall().

