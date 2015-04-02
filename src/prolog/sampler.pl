% sampler.pl

% sample a line with given parameters, return all points on it
sample_line(A, B, C, Point_list):-
    number(A),
    number(B),
    number(C),
    point_on_line(0, Y, A, B, C),
    img_size(W, H),
    (Y >= 0 ->
	 (Wn is W - 1,
	  findall([Xn, Yn],
		  (between(0, Wn, Xn),
		   point_on_line(Xn, Yn, A, B, C),
		   Yn < H,
		   Yn >= 0
		  ),
		  Point_list
		 )
	 );
     (Hn is H - 1,
      findall([Xn, Yn],
	      (between(0, Hn, Yn),
	       point_on_line(Xn, Yn, A, B, C),
	       Xn < W,
	       Xn >= 0
	      ),
	      Point_list
	     )
     )
    ),
    !.

sample_line(A, B, C, Point_list):-
    number(A),
    number(B),
    number(C),
    point_on_line(X, 0, A, B, C),
    img_size(W, H),
    (X >= 0 ->
	 (Hn is H - 1,
	  findall([Xn, Yn],
		  (between(0, Hn, Yn),
		   point_on_line(Xn, Yn, A, B, C),
		   Xn < W,
		   Xn >= 0
		  ),
		  Point_list
		 )
	 );
     (Wn is W - 1,
      findall([Xn, Yn],
	      (between(0, Wn, Xn),
	       point_on_line(Xn, Yn, A, B, C),
	       Yn < H,
	       Yn >= 0
	      ),
	      Point_list
	     )
     )
    ),
    !.

sample_line(Line, Point_list):-
    line(Line, A, B, C),
    number(A),
    number(B),
    number(C),
    sample_line(A, B, C, Point_list).

sample_line_seg_x(A, B, C, Point_list, X_1, X_2):-
    number(A),
    number(B),
    number(C),
    number(X_1),
    number(X_2),
    (X_1 =< X_2 ->
	 (X1 = X_1, X2 = X_2);
     (X1 = X_2, X2 = X1)
    ),
    point_on_line(0, Y, A, B, C),
    img_size(W, H),
    X2 =< W - 1,
    X1 >= 0,
    (Y >= 0 ->
	 (findall([Xn, Yn],
		  (between(X1, X2, Xn),
		   point_on_line(Xn, Yn, A, B, C),
		   Yn < H,
		   Yn >= 0
		  ),
		  Point_list
		 )
	 );
     (Hn is H - 1,
      findall([Xn, Yn],
	      (between(0, Hn, Yn),
	       point_on_line(Xn, Yn, A, B, C),
	       Xn =< X2,
	       Xn >= X1
	      ),
	      Point_list
	     )
     )
    ).

sample_line_seg_y(A, B, C, Point_list, Y_1, Y_2):-
    number(A),
    number(B),
    number(C),
    number(Y_1),
    number(Y_2),
    (Y_1 =< Y_2 ->
	 (Y1 = Y_1, Y2 = Y_2);
     (Y1 = Y_2, Y2 = Y_1)
    ),
    point_on_line(X, 0, A, B, C),
    img_size(W, H),
    Y2 =< H - 1,
    Y1 >= 0,
    (X >= 0 ->
	 (Wn is W - 1,
	  findall([Xn, Yn],
		  (between(0, Wn, Xn),
		   point_on_line(Xn, Yn, A, B, C),
		   Yn =< Y2,
		   Yn >= Y1
		  ),
		  Point_list
		 )
	 );
     (findall([Xn, Yn],
	      (between(Y1, Y2, Yn),
	       point_on_line(Xn, Yn, A, B, C),
	       Xn < W,
	       Xn >= 0
	      ),
	      Point_list
	     )
     )
    ).

sample_line_seg_x(Line, Point_list, X1, X2):-
    line(Line, A, B, C),
    sample_line_seg_x(A, B, C, Point_list, X1, X2).

sample_line_seg_y(Line, Point_list, Y1, Y2):-
    line(Line, A, B, C),
    sample_line_seg_y(A, B, C, Point_list, Y1, Y2).

sample_line_seg(S, Point_list):-
    S = [[X1, Y1], [X2, Y2]],
    line_parameters(S, A, B, C),
    (X1 =\= X2 -> 
	 (sample_line_seg_x(A, B, C, Point_list, X1, X2), !);
     (sample_line_seg_y(A, B, C, Point_list, Y1, Y2), !)
    ).
    
% randomly sample a line
random_line(Point_list):-
    random_point(X1, Y1),
    random_point(X2, Y2),
    line_parameters(X1, Y1, X2, Y2, A, B, C),
    sample_line(A, B, C, Point_list).

% randomly sample a line that crosses point (X, Y)
sample_line_on_point(X, Y, Point_list):-
    random_point(X1, Y1),
    line_parameters(X, Y, X1, Y1, A, B, C),
    sample_line(A, B, C, Point_list).

% find all edge points
edge_points_in_point_list(Point_list, Edge_point_list):-
    findall(
	    [X, Y, V],
	    (
		member(A, Point_list),
		A = [X, Y],
		edge_point(X, Y, V, _),
		edge_point_thresh(VV),
		V >= VV
	    ),
	    Edge_point_list
	).

% sample a line with parameters and find all edge points
edge_points_on_line_with_para(A, B, C, Edge_point_list):-
    number(A),
    number(B),
    number(C),
    sample_line(A, B, C, Point_list),
    edge_points_in_point_list(Point_list, Edge_point_list).

edge_points_on_line(Line, Edge_point_list):-
    sample_line(Line, Point_list),
    edge_points_in_point_list(Point_list, Edge_point_list).

display_edge_points_on_line(A, B, C, Edge_point_list, Color):-
    number(A),
    number(B),
    number(C),
    edge_points_on_line_with_para(A, B, C, Edge_point_list),
    display_point_list(Edge_point_list, Color).

display_edge_points_on_line(Line, Edge_point_list, Color):-
    edge_points_on_line(Line, Edge_point_list),
    display_point_list(Edge_point_list, Color).

% get points with largest gradient inside of a large interval
largest_grad_points(Edge_point_list, Largest_value, Temp_points, Return):-
    var(Return),
    (
	Edge_point_list = []
	->
	    Return = Temp_points;
	(
	    Edge_point_list = [Point | Tail],
	    Point = [_, _, Value],
	    (
		Value > Largest_value
		->
		    largest_grad_points(Tail, Value, [Point], Return);
		(
		    Value =:= Largest_value
		    ->
			(
			    append(Temp_points, [Point], Temp_points_2),
			    largest_grad_points(Tail, Largest_value, Temp_points_2, Return)
			);
		    largest_grad_points(Tail, Largest_value, Temp_points, Return)
		)
	    )
	)
    ).

% get clearest edge points on a line
clearest_edge_points_mid(Interval_list, Temp_points, Return):-
    Interval_list = []
    ->
	Return = Temp_points;
    (
	Interval_list = [Interval | Tail],
	largest_grad_points(Interval, 0, [], Point_list),
	middle_element(Point_list, Point),
	append(Temp_points, [Point], Temp_points_2),
	clearest_edge_points_mid(Tail, Temp_points_2, Return)
    ).

clearest_edge_points_mid(Edge_point_list, Return):-
    Edge_point_list = []
    ->
	Return = [];
    (
    continuous_intervals(Edge_point_list, Interval_list),
    clearest_edge_points_mid(Interval_list, [], Return)
    ).

clearest_edge_points_all(Interval_list, Temp_points, Return):-
    Interval_list = []
    ->
	Return = Temp_points;
    (
	Interval_list = [Interval | Tail],
	largest_grad_points(Interval, 0, [], Point_list),
	append(Temp_points, Point_list, Temp_points_2),
	clearest_edge_points_all(Tail, Temp_points_2, Return)
    ).

clearest_edge_points_all(Edge_point_list, Return):-
    Edge_point_list = []
    ->
	Return = [];
    (
    continuous_intervals(Edge_point_list, Interval_list),
    clearest_edge_points_all(Interval_list, [], Return)
    ).
