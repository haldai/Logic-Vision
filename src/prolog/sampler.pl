% sampler.pl

% line sampler
random_point(X, Y):-
    img_size(W, H),
    random_between(0, W, R1),
    random_between(0, H, R2),
    X = R1,
    Y = R2.

% sample a line which defined by two points, return all points on it
sample_line(A, B, C, Point_list):-
    point_on_line(0, Y, A, B, C),
    Y >= 0,
    img_size(W, H)
    ->
	Wn is W - 1,
	findall(
		[Xn, Yn],
		(
		    between(0, Wn, Xn),
		    point_on_line(Xn, Yn, A, B, C),
		    Yn < H,
		    Yn >= 0
		),
		Point_list);

    point_on_line(0, Y, A, B, C),
    Y < 0,
    img_size(W, H) 
    ->
	Hn is H - 1,
	findall(
		[Xn, Yn],
		(
		    between(0, Hn, Yn),
		    point_on_line(Xn, Yn, A, B, C),
		    Xn < W,
		    Xn >= 0
		),
		Point_list).

%sample_line(A, B, C, W, H, Point_list):-
%    findall(Yn, 
%	  (
%	      between(0, W, Xn),
%	      point_on_line(Xn, Yn, A, B, C),
%	      Yn < H
%	  ),
%	  Point_list
%	 ).

% randomly sample a line
random_line(Point_list):-
    random_point(X1, Y1),
    random_point(X2, Y2),
    line_parameters(X1, Y1, X2, Y2, A, B, C),
    sample_line(A, B, C, Point_list).
