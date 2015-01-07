% utils.pl

% write list
print_list(L):-
    forall(
	    member(X, L),
	    writeln(X)
	).

% define inner_product/3: Inner product of two lists (vectors)
inner_product([], [], 0).
inner_product([X|Xs], [Y|Ys], Result):-
    Prod is X*Y,
    inner_product(Xs, Ys, Remaining),
    Result is Prod + Remaining.

% define eu_dist/3: Euclidean distance
eu_dist_sum([], [], 0).
eu_dist_sum([X|Xs], [Y|Ys], Sum):-
    Dist is (X - Y)^2,
    eu_dist_sum(Xs, Ys, Remaining),
    Sum is Dist + Remaining.
eu_dist(X, Y, Result):-
    eu_dist_sum(X, Y, Sum),
    Result is sqrt(Sum).

