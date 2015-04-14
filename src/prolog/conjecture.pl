% conjecture.pl

% build a conjecture from one point.
sample_conjecture_edges_1(X, Y, Conn_comp_list):-
    sample_line_on_point(X, Y, Line_point_list),
    edge_points_in_point_list(Line_point_list, Edge_point_list),
    clearest_edge_points_mid(Edge_point_list, All_edge_points),
    get_coordinates(All_edge_points, All_edge_points_coor),
    combination(2, All_edge_points_coor, Init_combs),
    !,
    sample_edges_components(All_edge_points_coor, Init_combs, Conn_comp_list, [], [], 1),
    !.

% build an edge on given line segment
% split line (point list) into two parts
split_line_by_edge(X1, Y1, X2, Y2, Points, Left, Right):-
    number(X1),
    number(Y1),
    number(X2),
    number(Y2),
    var(Left),
    var(Right),
    (X1 == X2 ->
	 (Y1 =< Y2 ->
	      (findall([X, Y], (member([X, Y], Points), Y < Y2), Left),
	       findall([X, Y], (member([X, Y], Points), Y > Y1), Right),
	       !
	      );
	  (findall([X, Y], (member([X, Y], Points), Y < Y1), Left),
	   findall([X, Y], (member([X, Y], Points), Y > Y2), Right),
	   !
	  ),
	  !
	 );
     (X1 < X2 ->
	  (findall([X, Y], (member([X, Y], Points), X < X1), Left),
	   findall([X, Y], (member([X, Y], Points), X > X2), Right),
	   !
	  );
      (findall([X, Y], (member([X, Y], Points), X < X2), Left),
       findall([X, Y], (member([X, Y], Points), X > X1), Right),
       !
      ),
      !
     )
    ).

% extend line segment
extend_edge_line_seg_left(X1, Y1, X2, Y2, Left, Left_end):-
    Left = [] ->
	(Left_end = [X1, Y1], !);
    (Left = [First_point | Tail],
     First_point = [X, Y],
%     edge_points_proportion_threshold(T),
%     T1 is T + 1,
     edge_line_seg_proportion(X, Y, X2, Y2) ->
	 (extend_edge_line_seg_left(X, Y, X2, Y2, Tail, Left_end), !);
     (Left_end = [X1, Y1], !),
     !
    ).

extend_edge_line_seg_right(X1, Y1, X2, Y2, Right, Right_end):-
    Right = [] ->
	(Right_end = [X2, Y2], !);
    (Right = [First_point | Tail],
     First_point = [X, Y],
%     edge_points_proportion_threshold(T),
%     T1 is T + 1,
     (edge_line_seg_proportion(X1, Y1, X, Y) ->
	  (extend_edge_line_seg_right(X1, Y1, X, Y, Tail, Right_end), !);
      (Right_end = [X2, Y2], !)
     ),
     !
    ).

% shrink an edge such that each of its end is a local optima
shrink_edge_point_list([], R, _, R).
shrink_edge_point_list([P | Ps], Return, Max, _):-
    P = [X, Y],
    edge_point(X, Y, V, _),
    (V >= Max ->
	 (shrink_edge_point_list(Ps, Return, V, P), !);
     (Return = P, !)
    ).

shrink_edge(Edge, Return):-
    Edge = [L, R],
    sample_line_seg(Edge, Ps),
    reverse(Ps, [], Rev_Ps),
    shrink_edge_point_list(Ps, L1, 0, []),
    shrink_edge_point_list(Rev_Ps, R1, 0, []),
    sample_line_seg([L, L1], P1),
    sample_line_seg([R, R1], P2_),
    reverse(P2_, [], P2),
    length(P1, LP1),
    length(P2, LP2),
    edge_shrink_thresh(T),
    N1 is truncate(T*LP1),
    N2 is truncate(T*LP2),
    nth0(N1, P1, Left),
    nth0(N2, P2, Right),
    Return = [Left, Right].

% extend a short edge segment to long edge
extend_edge_line_seg(X1, Y1, X2, Y2, Left, Right, Edge):-
    reverse(Left, [], Rev_left),
    extend_edge_line_seg_left(X1, Y1, X2, Y2, Rev_left, Left_end),
    extend_edge_line_seg_right(X1, Y1, X2, Y2, Right, Right_end),
    Edge_ = [Left_end, Right_end],
    shrink_edge(Edge_, Edge).

% build_edge(org_x1, org_y1, org_x2, org_y2, [[start_x, start_y], [end_x, end_y]])
build_edge(X1, Y1, X2, Y2, Edge):-
    number(X1),
    number(Y1),
    number(X2),
    number(Y2),
    line_parameters(X1, Y1, X2, Y2, A, B, C),
    sample_line(A, B, C, Points),
    split_line_by_edge(X1, Y1, X2, Y2, Points, Left, Right),
    (X1 < X2 ->
	 (Edge_1 = [[X1, Y1], [X2, Y2]], !);
     (X1 > X2 ->
	  (Edge_1 = [[X2, Y2], [X1, Y1]], !);
      (Y1 < Y2 ->
	   (Edge_1 = [[X1, Y1], [X2, Y2]], !);
       (Edge_1 = [[X2, Y2], [X1, Y1]], !),
       !
      ),
      !
     ),
     !
    ),
    Edge_1 = [[X1_, Y1_], [X2_, Y2_]],
    extend_edge_line_seg(X1_, Y1_, X2_, Y2_, Left, Right, Edge).

% remove point combinations that contain particular point
remove_point_combs([], _, Return, Temp_list):-
    Return = Temp_list, !.

remove_point_combs([Head | Tail], Point, Return, Temp_list):-
    (member(Point, Head) -> 
	 (Temp_list_1 = Temp_list, !);
     (append(Temp_list, [Head], Temp_list_1), !)
    ),
    remove_point_combs(Tail, Point, Return, Temp_list_1),
    !.

remove_point_combs(Comb_list, Point, Return):-
    remove_point_combs(Comb_list, Point, Return, []), !.

remove_points_combs([], _, Return, Temp_list):-
    Return = Temp_list, !.
remove_points_combs([Head | Tail], Points, Return, Temp_list):-
    ((intersection(Head, Points, X), X == []) ->
	  (append(Temp_list, [Head], Temp_list_1), !);
      (Temp_list_1 = Temp_list, !)
    ),
    remove_points_combs(Tail, Points, Return, Temp_list_1),
    !.

remove_points_combs(Comb_list, Points, Return):-
    remove_points_combs(Comb_list, Points, Return, []), !.

% check whether sample line is existed in line list
line_existed(_, []):-
    fail, !.
line_existed(Line, Line_list):-
    Line_list = [Head | _],
    same_line(Line, Head) ->
	(true, !);
    (Line_list = [_ | Tail],
     line_existed(Line, Tail),
     !
    ).

% generate combination from existed edge points and a new point
gen_combs_point(_, [], _, _, _, Comb_list, Temp_list):-
    Comb_list = Temp_list, 
    !.
gen_combs_point(Point, Point_list, _, _, _, Comb_list, _):-
    member(Point, Point_list),
    Comb_list = [], 
    !.
gen_combs_point(Point, [Head | Tail], Sampled_lines, Tmax, Tmin, Comb_list, Temp_list):-
    (in_combo_dist(Point, Head, Tmax, Tmin), not(Point = Head)) ->
	(New_comb = [Point, Head],
	 line_parameters(New_comb, A, B, C),
	 (line_existed([A, B, C], Sampled_lines) ->
	      (gen_combs_point(Point, Tail, Sampled_lines, Tmax, Tmin, Comb_list, Temp_list), !);
	  (append(Temp_list, [New_comb], Temp_list_1),
	   gen_combs_point(Point, Tail, Sampled_lines, Tmax, Tmin, Comb_list, Temp_list_1),
	   !
	  )
	 ),
	 !
	);
    (gen_combs_point(Point, Tail, Sampled_lines, Tmax, Tmin, Comb_list, Temp_list), !).

gen_combs_point(Point, Point_list, Sampled_lines, Tmax, Tmin, Comb_list):-
    gen_combs_point(Point, Point_list, Sampled_lines, Tmax, Tmin, Comb_list, []),
    !.

gen_combs(Point_list_1, Point_list_2, Sampled_lines, Comb_list, Temp_list):-
    Point_list_1 == [] ->
	(Comb_list = Temp_list, !);
    (Point_list_1 = [Head | Tail],
     combo_max_dist_thresh(T_max),
     combo_min_dist_thresh(T_min),
     gen_combs_point(Head, Point_list_2, Sampled_lines, T_max, T_min, Comb_list_1),
     append(Temp_list, Comb_list_1, Temp_list_1),
     gen_combs(Tail, Point_list_2, Sampled_lines, T_max, T_min, Comb_list, Temp_list_1),
     !
    ).

gen_combs(Point_list_1, Point_list_2, Sampled_lines, Comb_list):-
    gen_combs(Point_list_1, Point_list_2, Sampled_lines, Comb_list, []), !.

gen_combs(Point_list_1, Point_list_2, Sampled_lines, T_max, T_min, Comb_list, Temp_list):-
    Point_list_1 == [] ->
	(Comb_list = Temp_list, !);
    (Point_list_1 = [Head | Tail],
     gen_combs_point(Head, Point_list_2, Sampled_lines, T_max, T_min, Comb_list_1),
     append(Temp_list, Comb_list_1, Temp_list_1),
     gen_combs(Tail, Point_list_2, Sampled_lines, T_max, T_min, Comb_list, Temp_list_1),
     !
    ).

% checks whether point is on existed edges
point_not_on_edges(_, []).
point_not_on_edges(Point, Edge_list):-
    Point = [X, Y| _],
    Edge_list = [Head | Tail],
    edge_near_thresh(T),
    (point_on_line_seg_thresh([X, Y], Head, T) ->
	 (fail, !);
     point_not_on_edges([X, Y], Tail),
     !
    ).

points_not_on_edges(Points, Edge_list, Return, Temp_list):-
    Points == [] ->
	(Return = Temp_list, !);
    (Points = [Head | Tail],
     (point_not_on_edges(Head, Edge_list) ->
	  (append(Temp_list, [Head], Temp_list_1),
	   points_not_on_edges(Tail, Edge_list, Return, Temp_list_1),
	   !
	  );
      (points_not_on_edges(Tail, Edge_list, Return, Temp_list), !)
     ),
     !
    ).

points_not_on_edges(Points, Edge_list, Return):-
    points_not_on_edges(Points, Edge_list, Return, []), 
    !.

% checks whether point near existed points
point_not_near_points(_, []).
point_not_near_points(Point, Point_list):-
    Point = [X, Y| _],
    Point_list = [Head | Tail],
    (point_near([X, Y], Head) ->
	 (fail, !);
     point_not_near_points([X, Y], Tail),
     !
    ).

points_not_near_points(Points, Point_list, Return, Temp_list):-
    Points == [] ->
	(Return = Temp_list, !);
    (Points = [Head | Tail],
     (point_not_near_points(Head, Point_list) ->
	  (append(Temp_list, [Head], Temp_list_1),
	   points_not_near_points(Tail, Point_list, Return, Temp_list_1),
	   !
	  );
      (points_not_near_points(Tail, Point_list, Return, Temp_list), !)
     ),
     !
    ).

points_not_near_points(Points, Point_list, Return):-
    points_not_near_points(Points, Point_list, Return, []), !.

% sample new points from perpendicular bisector of [[X1, Y1], [X2, Y2]], it should not appear on existed edges
sample_new_edge_points(X1, Y1, X2, Y2, Edge_list, Point_list, Points):-
    A is 2*(X1 - X2),
    B is 2*(Y1 - Y2),
    C is X2**2 + Y2**2 - X1**2 - Y1**2,
    sample_line(A, B, C, Line_point_list),
    edge_points_in_point_list(Line_point_list, Edge_point_list),
    clearest_edge_points_mid(Edge_point_list, All_edge_points),
    points_not_near_points(All_edge_points, Point_list, Temp_points),
    points_not_on_edges(Temp_points, Edge_list, Points),
    !.    

% sample a new point from random line that crosses [X, Y], it should not appear on existed edges
sample_new_edge_points_random(X, Y, Edge_list, Point_list, Points, N, Temp):-
    sample_new_point_time_limit(T1),
    N > T1 ->
	(Points = Temp, !);
    (sample_line_on_point(X, Y, Line_point_list),
     edge_points_in_point_list(Line_point_list, Edge_point_list),
     clearest_edge_points_mid(Edge_point_list, All_edge_points),
     points_not_near_points(All_edge_points, Point_list, Temp_points),
     points_not_on_edges(Temp_points, Edge_list, New_points),
     append(Temp, New_points, Temp_1),
     length(Temp_1, L),
     sample_new_point_size_limit(T2),
     (L < T2 ->
	  (sample_new_edge_points_random(X, Y, Edge_list, Points, N + 1, Temp_1), !);
      (Points = New_points, !)
     ), 
     !
    ).

sample_new_edge_points_random(X, Y, Edge_list, Point_list, Points, N):-
    sample_new_edge_points_random(X, Y, Edge_list, Point_list, Points, N, []).

% check if point is an end of any edge
point_is_end_of_edges(Point, Edge_list):-
    Edge_list = [Head | Tail],
    (member(Point, Head) ->
	 (true, !);
     (point_is_end_of_edges(Point, Tail), !)
    ).

% remove all points on edge and return the rest points
get_points_on_edge([], _, On_edge, Rest, On_edge, Rest).
get_points_on_edge([Head | Tail], Edge, On_edge, Rest, Temp_on_edge, Temp_rest):-
    point_on_line_seg(Head, Edge) ->
	(append(Temp_on_edge, [Head], Temp_on_edge_1),
	 get_points_on_edge(Tail, Edge, On_edge, Rest, Temp_on_edge_1, Temp_rest),
	 !
	);
    (append(Temp_rest, [Head], Temp_rest_1),
     get_points_on_edge(Tail, Edge, On_edge, Rest, Temp_on_edge, Temp_rest_1),
     !
    ).

get_points_on_edge(Point_list, Edge, On_edge, Rest):-
    get_points_on_edge(Point_list, Edge, On_edge, Rest, [], []).

get_points_on_edges(_, [], O, R, O, R).
get_points_on_edges(Point_list, [E | Es], On_edge, Rest, Temp_on, Temp_re):-
    get_points_on_edge(Point_list, E, O, R),
    append(Temp_on, O, Temp_on_1),
    append(Temp_re, R, Temp_re_1),
    get_points_on_edges(R, Es, On_edge, Rest, Temp_on_1, Temp_re_1), 
    !.

get_points_on_edges(Ps, Es, On_edge, Rest):-
    poly_rect(Es, P_min, P_max),
    point_near_thresh(T),
    image_diagonal(Dia),
    Soft is truncate(T*Dia),
    screening_points_of_rect(Ps, [P_min, P_max], Soft, Ps_),
    list_delete(Ps, Ps_, Rest_),
    get_points_on_edges(Ps_, Es, On_edge, Rest, [], Rest_).

% add new edge ends to point list
add_edge_ends_to_point_list(Edge, Point_list, Return):-
    Edge = [P1, P2],
    (\+member(P1, Point_list) -> 
	 (append(Point_list, [P1], R1), !);
     (R1 = Point_list, !)
    ),
    (\+member(P2, Point_list) -> 
	 (append(R1, [P2], R2), !);
     (R2 = R1, !)
    ),
    Return = R2.
    
% remove all other point info, only retains coordinates of points
get_coordinates(Point_list, Return, Temp_list):-
    Point_list == [] ->
	(Return = Temp_list, !);
    (Point_list = [Head | Tail],
     Head = [X, Y | _],
     append(Temp_list, [[X, Y]], Temp_list_1),
     get_coordinates(Tail, Return, Temp_list_1),
     !
    ).

get_coordinates(Point_list, Return):-
    get_coordinates(Point_list, Return, []).

% edge subsumption: E1 subsume E2
edge_subsume([X, Y1], [X, Y2]):-
    point_near(Y1, Y2), !.
edge_subsume([X1, Y], [X2, Y]):-
    point_near(X1, X2), !.
edge_subsume([X1, Y1], [X2, Y2]):-
    connected(X1, X2),
    point_near(Y1, Y2), !.
edge_subsume([X1, Y1], [X2, Y2]):-
    connected(Y1, Y2),
    point_near(X1, X2), !.
edge_subsume(E1, E2):-
    seg_length(E1, L1),
    seg_length(E2, L2),
    L1 >= L2,
    E2 = [P1, P2],
    edge_subsume_thresh(T),
    point_on_line_seg_thresh(P1, E1, T),
    point_on_line_seg_thresh(P2, E1, T), !.

edge_subsume_last(E1, E2):-
    E1 = [P1, P2],
    E2 = [P3, P4],
    point_on_line_seg(P3, E1),
    point_on_line_seg(P4, E1),
    edge_line_seg_proportion(P1, P3),
    edge_line_seg_proportion(P1, P4),
    edge_line_seg_proportion(P2, P3),
    edge_line_seg_proportion(P2, P4).

% remove corresponding points and combinations of subsumed edges
compute_points_to_delete(Subbed, Unsubbed, Del_p):-
    edges_ends(Subbed, S_p),
    edges_ends(Unsubbed, U_p),
    list_not_member(S_p, U_p, Del_p).

remove_subsumed_edges_point_combs(Subbed, Unsubbed, Point_list, 
				 Comb_list, New_point_list, New_comb_list):-
    compute_points_to_delete(Subbed, Unsubbed, Del_p),
    list_delete(Point_list, Del_p, New_point_list),
    remove_points_combs(Comb_list, Del_p, New_comb_list).

% build conjecture from two edge points
sample_edges_components(_, _, Conn_comp_list, Temp_comp_list, _, N):-
    sample_edge_limit(T),
    N >= T,
    write("turn "),
    writeln(N),
    Conn_comp_list = Temp_comp_list, 
    !.

sample_edges_components(_, [], Conn_comp_list, Temp_comp_list, _, N):-
    sample_edge_limit(T),
    N < T,
    Conn_comp_list = Temp_comp_list,
    write("turn "),
    writeln(N),
    writeln("finished!"),
%    writeln("====Points===="),
%    print_list(Point_list),
%    writeln("====Combs===="),
%    print_list([]),
%    writeln("====Comps===="),
%    print_list(Temp_comp_list),
%    writeln("====Sampled lines===="),
%    print_list(Sampled_lines),
%    writeln("========"),
    !.

sample_edges_components(Point_list, Ongoing_combs, Conn_comp_list, Temp_comp_list, Sampled_lines, N):-
    write("turn "),
    writeln(N),
    writeln("====Points===="),
    print_list(Point_list),
    writeln("====Combs===="),
    print_list(Ongoing_combs),
    writeln("====Comps===="),
    print_list(Temp_comp_list),
    writeln("====Sampled lines===="),
    print_list(Sampled_lines),
    writeln("========"),
    sample_edge_limit(T),
    N < T,
    N2 is N + 1,
    not(Ongoing_combs == []),
    Ongoing_combs = [Comb | Other_combs],
    Comb = [P1, P2],
%    line_parameters(Comb, A, B, C),
    (point_near(P1, P2) ->
	 (sample_edges_components(Point_list, Other_combs, Conn_comp_list, Temp_comp_list, Sampled_lines, N2), 
	  !);
     (line_parameters(Comb, A, B, C),
      (line_existed([A, B, C], Sampled_lines) -> 
	   (sample_edges_components(Point_list, Other_combs, Conn_comp_list, Temp_comp_list, Sampled_lines, N2), 
	    !);
       (append(Sampled_lines, [[A, B, C]], Sampled_lines_1),
	display_point_list(Comb, y),
	P1 = [X1, Y1],
	P2 = [X2, Y2],
	comps_to_edges(Temp_comp_list, Temp_edges, []),
	edges_ends(Temp_edges, All_ends),
	edge_point_thresh(GT),
	edge_points_proportion_threshold(PT),
	((member(P1, All_ends), member(P2, All_ends)) ->
	     (edge_point_relax(RG),
	      edge_points_proportion_relax(RP),
	      GT1 is (GT - RG),
	      PT1 is (PT - RP),
	      !);
	 (GT1 is GT,
	  PT1 is PT,
	  !)
	),
	(not(edge_line_seg_proportion_grad(P1, P2, GT1, PT1)) ->
	     (%comps_to_edges(Temp_comp_list, Temp_edges, []),
	      %edges_ends(Temp_edges, All_ends),
	      list_delete(Point_list, All_ends, Free_points),
	      sample_new_edge_points(X1, Y1, X2, Y2, Temp_edges, Point_list, New_points_),
	      get_coordinates(New_points_, New_points),
	      display_point_list(New_points, b),
	      %      writeln("New points:"),
	      %      print_list_ln(New_points),
	      gen_combs(New_points, Free_points, Sampled_lines, Comb_list),
	      append(Other_combs, Comb_list, Comb_list_1),
	      append(Point_list, New_points, Point_list_1),
	      display_point_list(Point_list_1, b),
	      %	  display_point_list(Comb, b),
	      sample_edges_components(Point_list_1, Comb_list_1, Conn_comp_list, Temp_comp_list, Sampled_lines_1, N2),
	      !
	     );
	 (build_edge(X1, Y1, X2, Y2, Edge_),
	  Edge_ = [P1_, P2_],
	  (not(P1_ = P2_; point_near(P1_, P2_)) ->
	       (reg_grow_edge(Edge_, Point_list, Edge, 0),
		display_line(Edge, r),
		add_edge(Edge, Temp_comp_list, Temp_comp_list_1, New_edge, [], []),
		(not(New_edge == []) ->
		     (display_polygon_list(Temp_comp_list, g),
		      display_polygon_list(Temp_comp_list_1, r),
		      display_point_list(Comb, b),
		      display_point_list(Point_list, r),
		      % find all single connected vertices of each Comp
		      % & make new combinations
		      make_new_combs(Temp_comp_list_1, Temp_comp_list, Point_list, Other_combs, Sampled_lines_1, New_point_list, New_ongoing_combs), % TODO::
		      display_point_list(New_point_list, b),
		      sample_edges_components(New_point_list, New_ongoing_combs, Conn_comp_list, Temp_comp_list_1, Sampled_lines_1, N2), 
		      !
		     );
		 (sample_edges_components(Point_list, Other_combs, Conn_comp_list, Temp_comp_list_1, Sampled_lines_1, N2), 
		  !
		 )
		)
	       );
	   (sample_edges_components(Point_list, Other_combs, Conn_comp_list, Temp_comp_list, Sampled_lines_1, N2), 
	    !
	   )
	  )
	 )
	)
       )
      )
     )
    ).

reg_grow_edge(E, _, E, 10).
reg_grow_edge(Edge, Point_list, New_edge, N):-
    N1 is N + 1,
    get_points_on_edge(Point_list, Edge, On_edge_point, _),
    !,
    append(Edge, On_edge_point, On_edge_point_1),
    list_to_set(On_edge_point_1, On_edge_point_2),
    reg_edge(Edge, On_edge_point_2, Reg_edge),
    Reg_edge = [[X1, Y1], [X2, Y2]],
    build_edge(X1, Y1, X2, Y2, Reg_edge_1),
    !,
    get_left_right_most_points_in_list(Edge, L, R),
    get_left_right_most_points_in_list(Reg_edge_1, L1, R1),
    !,
    ((connected(L, L1), connected(R, R1)) ->
	 (New_edge = Reg_edge_1, !);
     (append(Point_list, Reg_edge_1, Point_list_1),
      reg_grow_edge(Reg_edge_1, Point_list_1, New_edge, N1),
      !
     )
    ).

reg_edge(Edge, Point_list, New_edge):-
    point_list_to_Xs_Ys(Point_list, Xs, Ys, [], []),
    lin_reg(Xs, Ys, A, B, C),
    Edge = [P1, P2],
    sample_line_seg(A, B, C, New_edge_Ps, P1, P2),
    get_left_right_most_points_in_list(New_edge_Ps, L, R),
    New_edge = [L, R].

point_list_to_Xs_Ys([], Xs, Ys, Xs, Ys).
point_list_to_Xs_Ys([P | Ps], Xs, Ys, TX, TY):-
    P = [X, Y],
    append(TX, [X], TX_1),
    append(TY, [Y], TY_1),
    point_list_to_Xs_Ys(Ps, Xs, Ys, TX_1, TY_1).

% TODO::generate new combinations
make_new_combs(Comp_list, Comp_list_old, PL_old, Combs_old, Sampled_lines, PL_new, Combs_new):-
    comps_to_edges(Comp_list, Edges_new, []),
    comps_to_edges(Comp_list_old, Edges_old, []),
    list_delete(Edges_new, Edges_old, Edges_added),
    print_list(Edges_added),
    edges_ends(Edges_new, PL_end_new),
    edges_ends(Edges_old, PL_end_old),
    list_delete(PL_end_new, PL_end_old, PL_end_added), % added ends
    list_delete(PL_old, PL_end_new, PL_free), % free points (not on edges)
    list_delete(PL_end_old, PL_end_new, PL_end_removed), % removed ends
    intersection(PL_end_old, PL_end_new, PL_end_remains), % remained ends
    get_points_on_edges(PL_old, Edges_added, PL_free_removed, PL_free_remains), % remove free points
    append(PL_end_removed, PL_free_removed, PL_removed),
    append(PL_free_remains, PL_end_new, PL_new),
    % generate new combinations
    combo_max_dist_thresh(T),
%    gen_combs(PL_end_added, PL_end_added, Sampled_lines, Comb_e_e_AA, []),
    gen_combs(PL_end_added, PL_end_remains, Sampled_lines, 0.5, 0, Comb_e_e_AR, []),
    gen_combs(PL_end_new, PL_free_remains, Sampled_lines, T, 0, Comb_e_f_AR, []),
%    append(Comb_e_e_AR, Comb_e_e_AA, Combs_1),
    append(Comb_e_e_AR, Comb_e_f_AR, Combs_2),
    append(Combs_2, Combs_old, Combs_new_),
    % remove old combinations
    remove_points_combs(Combs_new_, PL_removed, Combs_3),
    list_delete(Combs_3, Edges_old, Combs_4),
    list_delete(Combs_4, Edges_new, Combs_new),
    !.

%add_edge(Edge, [], Return, Temp, []):-
%    append(Temp, [Edge], Return), !.
add_edge(Edge, [], Return, New_edge, Temp, New_comps):-
    merge_conn_comps(Edge, New_comps, New_edge, Merged_comp, 0),
    append(Temp, Merged_comp, Return), !.
add_edge(Edge, [Comp | Comps], Return, New_edge, Temp, New_comps):-
    edge_connect_to_comp(Edge, Comp) ->
	(append(New_comps, [Comp], New_comps_2),
	 add_edge(Edge, Comps, Return, New_edge, Temp, New_comps_2)
	 ,!
	);
    (append(Temp, [Comp], Temp_2),
     add_edge(Edge, Comps, Return, New_edge, Temp_2, New_comps),
     !
    ).

merge_conn_comps(Edge, Comps, New_edge, Return, _):-
    length(Comps, L),
    L < 1,
    Return = [[Edge]],
    New_edge = Edge,
    !.
merge_conn_comps([], Comps, New_edge, Return, _):-
    comps_to_edges(Comps, All_edges, []),
    split_components(All_edges, Return),
    New_edge = [],
    !.
    
merge_conn_comps(Edge, Comps, New_edge, Return, T):-
    comps_to_edges(Comps, All_edges, []),
    % Process edge-subsumed edges
    process_edge_edge_subsumption(Edge, All_edges, Subbed, Unsubbed, [], []),
    % edge is subed by existing edge, no change
    (member(Edge, Subbed) ->
	 (split_components(All_edges, Return), New_edge = [], !);
     % edge cannot be subed, continue
     (merge_edge_with_all_edges(Edge, Unsubbed, Merged_edges),
      % merge_all_edges(All_edges, All_edges, Return),
      Merged_edges = [New_edge_ | New_other_edges],

      % Process point-subsumed edges (point_on_line_seg(_,_,T>TT), Xy<T<Xy)
%      process_point_edge_subsumption(New_edge, New_other_edges, New_other_edges_1),
      ((same_seg(New_edge_, Edge); T > 2) ->
	   (split_components(Merged_edges, Comp_list_),
	    Return = Comp_list_,
	    New_edge = New_edge_,
	    !);
       (T_1 is T + 1,
	merge_conn_comps(New_edge_, [New_other_edges], New_edge, Return, T_1),
	!
       )
      ),
      !
     )
    ).

% vertex subsume edge or edge subsume vertex
process_point_edge_subsumption(Edge, Other_edges, Return):-
    edges_ends(Other_edges, Vertices),
    process_point_edge_subsumption(Edge, Vertices, RM_p, RM_e, [], []),
    % edge not subsumed
    (RM_e == [] ->
	 % no point subsumed
	 (RM_p == [] ->
	      (append([Edge], Other_edges, Return), !);
	  % TODO:: remove points
	  (remove_edge_subsumed_points(Edge, Other_edges, RM_p, Return),
	   !
	  ),
	  !
	 );
     % edge subsumed
     (Return = Other_edges, !)
    ).

remove_edge_subsumed_points(Edge, Other_edges, [], Return):-
    append([Edge], Other_edges, Return), !.
remove_edge_subsumed_points(Edge, Other_edges, [P | Ps], Return):-
    all_edges_contains_point(Other_edges, P, All_edges, []),
    get_all_intersections(Edge, All_edges, All_intscts, []),
    intersection_all_edges(All_intscts, All_intsct_edges, []),
    list_delete(Other_edges, All_intsct_edges, Rest_edges),
    % cut the intersected edges by Edge at P
    cut_edges(All_intsct_edges, Edge, P, New_edges, []),
    append(New_edges, Rest_edges, New_edges_1),
    remove_edge_subsumed_points(Edge, New_edges_1, Ps, Return), !.

cut_edges([], _, _, Return, Return).
cut_edges([E | Es], Edge, P, Return, Temp):-
    E = [PP, P],
    Edge = [P1, P2],
    (point_on_line_seg_thresh(P1, E, 0.01) ->
	 (append([[PP, P1]], Temp, Temp_1),
	  cut_edges(Es, Edge, P, Return, Temp_1),
	  !
	 );
     (append([[PP, P2]], Temp, Temp_1),
      cut_edges(Es, Edge, P, Return, Temp_1),
      !
     )
    ).

cut_edges([E | Es], Edge, P, Return, Temp):-
    E = [P, PP],
    Edge = [P1, P2],
    (point_on_line_seg_thresh(P1, E, 0.01) ->
	 (append([[PP, P1]], Temp, Temp_1),
	  cut_edges(Es, Edge, P, Return, Temp_1),
	  !
	 );
     (append([[PP, P2]], Temp, Temp_1),
      cut_edges(Es, Edge, P, Return, Temp_1),
      !
     )
    ).

cut_edges([E | Es], Edge, P, Return, Temp):-
    not(E = [PP, P]),
    not(E = [P, PP]),
    append([E], Temp, Temp_1),
    cut_edges(Es, Edge, P, Return, Temp_1),
    !.

all_edges_contains_point([], _, Return, Return).
all_edges_contains_point([E | Es], P, Return, Temp):-
    (member(P, E) ->
	 (append(Temp, [E], Temp_1), !);
     (Temp_1 = Temp, !)
    ),
    all_edges_contains_point(Es, P, Return, Temp_1), !.

process_point_edge_subsumption(_, [], RM_p, RM_e, Temp_p, Temp_e):-
    RM_p = Temp_p,
    RM_e = Temp_e,
    !.

% TODO::
process_point_edge_subsumption(Edge, [V | Vs], RM_p, RM_e, Temp_p, Temp_e):-
    Edge = [P1, P2],
    poly_rect([Edge], P_min, P_max),
    P_min = [X_min, Y_min],
    P_max = [X_max, Y_max],
    V = [X, Y],
    % vertex lies between edge
    ((((X =< X_max, X >= X_min); (Y =< Y_max, Y >= Y_min)),
      % vertex is not an end of edge
      not(member(V, Edge)),
      % vertex "on" edge
      point_on_line_seg_thresh(V, Edge, 0.3)) ->
	 (avg_grad_val_seg(Edge, Ve),
	  avg_grad_val_seg([P1, V], V1),
	  avg_grad_val_seg([P2, V], V2),
	  % if grad value of point is lower than edge
	  ((V1 + V2)/2 =< Ve ->
	       % remove point
	       (append([V], Temp_p, Temp_p_1),
		process_point_edge_subsumption(Edge, Vs, RM_p, RM_e, Temp_p_1, Temp_e),
		!
	       );
	   % remove edge
	   (RM_p = [],
	    RM_e = Edge,
	    !
	   )
	  ),
	  !
	 );
     (process_point_edge_subsumption(Edge, Vs, RM_p, RM_e, Temp_p, Temp_e),
      !
     )
    ).

% edge subsume edge
process_edge_edge_subsumption(_, [], Subbed, Unsubbed, Temp_s, Temp_u):-
    Unsubbed = Temp_u,
    Subbed = Temp_s,
    !.
process_edge_edge_subsumption(Edge, [E | Es], Subbed, Unsubbed, Temp_s, Temp_u):-
    edge_subsume(E, Edge), 
    not(edge_subsume(Edge, E)),
    append([E | Es], Temp_u, Unsubbed),
    append([Edge], Temp_s, Subbed),
    !.
process_edge_edge_subsumption(Edge, [E | Es], Subbed, Unsubbed, Temp_s, Temp_u):-
    not(edge_subsume(E, Edge)), 
    not(edge_subsume(Edge, E)),
    append([E], Temp_u, Temp_u_1),
    process_edge_edge_subsumption(Edge, Es, Subbed, Unsubbed, Temp_s, Temp_u_1), 
    !.
process_edge_edge_subsumption(Edge, [E | Es], Subbed, Unsubbed, Temp_s, Temp_u):-
    edge_subsume(Edge, E), 
    not(edge_subsume(E, Edge)),
    append([E], Temp_s, Temp_s_1),
    process_edge_edge_subsumption(Edge, Es, Subbed, Unsubbed, Temp_s_1, Temp_u),
    !.
process_edge_edge_subsumption(Edge, [E | Es], Subbed, Unsubbed, Temp_s, Temp_u):-
    edge_subsume(Edge, E), 
    edge_subsume(E, Edge),
    avg_grad_val_seg(Edge, V1),
    avg_grad_val_seg(E, V2),
    (V1 >= V2 ->
	 (append([E], Temp_s, Temp_s_1),
	  process_edge_edge_subsumption(Edge, Es, Subbed, Unsubbed, Temp_s_1, Temp_u),
	  !
	 );
     (append([E | Es], Temp_u, Unsubbed),
      append([Edge], Temp_s, Subbed),
      !
     )
    ).

get_connect_points(Edges, Points):-
    edges_ends(Edges, Ends),
    findall(P, 
	    (member(P, Ends), 
	     time_point_as_end_of_edges(P, Edges, N, 0),
	     N > 1
	    ), 
	    Points
	   ).

time_point_as_end_of_edges(_, [], N, N).
time_point_as_end_of_edges(P, [E | Es], N, T):-
    member(P, E) ->
	(T1 is T + 1, 
	 time_point_as_end_of_edges(P, Es, N, T1), !);
    time_point_as_end_of_edges(P, Es, N, T).

merge_edge_with_all_edges(Edge, [], [Edge]).
merge_edge_with_all_edges(Edge, Other_edges, Return):-
    get_all_intersections(Edge, Other_edges, All_intscts, []),
    intersection_all_edges(All_intscts, All_intsct_edges, []),
    list_delete(Other_edges, All_intsct_edges, Un_intsct_edges),
    %append([Edge], Other_edges, All_edges),
    get_connect_points(All_intsct_edges, Conn_points),
    readjust_intersected_edges(Edge, All_intscts, Other_edges, Conn_points, Adjd_edges, Unchanged, Changed_conn_pair, [], [], []),
%    intersection(All_intsct_edges, Adjd_edges, Adjd_unintsct_edges),
    change_end_to_end_pairs(Adjd_edges, Changed_conn_pair, Adjd_edges_x),
    change_end_to_end_pairs(Unchanged, Changed_conn_pair, Unchanged_x),
    change_end_to_end_pairs(Un_intsct_edges, Changed_conn_pair, Un_intsct_edges_x),
    readjust_new_edge(Edge, Adjd_edges_x, New_edge, New_IE, Old_IE),
    list_delete(Adjd_edges_x, Old_IE, Adjd_edges_1),
    append(Adjd_edges_1, New_IE, Adjd_edges_2),
    append(Adjd_edges_2, Un_intsct_edges_x, Adjusted_edges_),
    append(Adjusted_edges_, Unchanged_x, Adjusted_edges),

    append([New_edge], Adjusted_edges, Merged),
    filter_edges(Merged, Merged, Return, []),
    !.

filter_edges([], _, Return, Return).
filter_edges([E | Es], All, Return, Temp):-
    (E == []; E = [X, X];
     edge_existed_in_list(E, Es);
     edge_existed_in_list(E, Temp)) ->
	(filter_edges(Es, All, Return, Temp), !);
    (delete(All, E, All_),
     process_edge_edge_subsumption(E, All_, Subbed, _, [], []),
     (member(E, Subbed) ->
	  (filter_edges(Es, All, Return, Temp), !);
      (list_delete(Es, Subbed, Es_),
       append(Temp, [E], Temp_1),
       filter_edges(Es_, All, Return, Temp_1),
       !
      )
     )
    ).

% TODO::
readjust_new_edge(Edge, Intersected_edges, New_edge, New_IE, Old_IE):-
    get_all_intersections(Edge, Intersected_edges, All_intscts, []),
    readjust_new_edge_intsct(Edge, All_intscts, New_edge, Old_IE, New_IE, [], [], []), 
    !.

readjust_new_edge_intsct(_, [], New_edge_r, Old_IE, New_IE, New_edge_r, Old_IE, New_IE).
readjust_new_edge_intsct(Edge, [I | Intscts], New_edge_r, Old_IE, New_IE, Temp_edge, Temp_old_ie, Temp_new_ie):-
    I = [IE_, IPs],
    IPs = [IP | _],
    IE_ = [PE1, PE2],
    % an 'unchanged' edge between two adjusted edges
    not(point_near_ex(PE1, IP)),
    not(point_near_ex(PE2, IP)),
    append(Temp_old_ie, [IE_], Temp_old_ie_1),
    readjust_new_edge_intsct(Edge, Intscts, New_edge_r, Old_IE, New_IE, Temp_edge, Temp_old_ie_1, Temp_new_ie),
    !.
    
readjust_new_edge_intsct(Edge, [I | Intscts], New_edge_r, Old_IE, New_IE, _, Temp_old_ie, Temp_new_ie):-
    Edge = [P1, P2],
    I = [IE_, IPs],
    IPs = [IP | _],
    IE_ = [PE1, PE2],
    ((point_near_ex(PE1, IP), IE = [IP, PE2], !);
     (point_near_ex(PE2, IP), IE = [PE1, IP], !)), % descretization brings noise
    ((IE = [PE, IP], !); (IE = [IP, PE], !)),
    seg_length([P1, IP], L1),
    seg_length([P2, IP], L2),
%    seg_length([PE, IP], LE),
    % cut P2 or PE ?
    (L1 > L2 ->
	 % no edge between [P2, PE], just remove P2
	 (not(edge_line_seg_proportion(P2, PE)) ->
	      (New_edge = [P1, IP],
	       New_ie = IE,
	       !
	      );
	  % there is an edge, compare it with IE
	  (avg_grad_val_seg([P2, PE], V2E),
	   avg_grad_val_seg([P2, IP], V2I),
	   avg_grad_val_seg([IP, PE], VIE),
	   % if [P2, PE] is better than IE, replace it
	   ((V2E + V2I)/2 > VIE -> 
		(New_edge = [P1, P2],
		 New_ie = [PE, P2],
		 !
		);
	    (New_edge = [P1, IP],
	     New_ie = IE,
	     !
	    )
	   ),
	   !
	  ),
	  !
	 );
     (true, !)
    ),
    (L1 < L2 ->
	 % no edge between [P2, PE], just remove P2
	 (not(edge_line_seg_proportion(P1, PE)) ->
	      (New_edge = [P2, IP],
	       New_ie = IE,
	       !
	      );
	  % there is an edge, compare it with IE
	  (avg_grad_val_seg([P1, PE], V1E),
	   avg_grad_val_seg([P1, IP], V1I),
	   avg_grad_val_seg([IP, PE], VIE),
	   % if [P2, PE] is better than IE, replace it
	   ((V1E + V1I)/2 > VIE -> 
		(New_edge = [P2, P1],
		 New_ie = [PE, P1],
		 !
		);
	    (New_edge = [P2, IP],
	     New_ie = IE,
	     !
	    )
	   ),
	   !
	  ),
	  !
	 );
     (true, !)
    ),
    (L1 == L2 ->
	 (avg_grad_val_seg([P1, IP], V1I),
	  avg_grad_val_seg([P2, IP], V2I),
	  (V1I >= V2I -> 
	       % no edge between [P2, PE], just remove P2
	       (not(edge_line_seg_proportion(P2, PE)) ->
		    (New_edge = [P1, IP],
		     New_ie = IE,
		     !
		    );
		% there is an edge, compare it with IE
		(avg_grad_val_seg([P2, PE], V2E),
		 avg_grad_val_seg([P2, IP], V2I),
		 avg_grad_val_seg([IP, PE], VIE),
		 % if [P2, PE] is better than IE, replace it
		 ((V2E + V2I)/2 > VIE -> 
		      (New_edge = [P1, P2],
		       New_ie = [PE, P2],
		       !
		      );
		  (New_edge = [P1, IP],
		   New_ie = IE,
		   !
		  )
		 ),
		 !
		),
		!
	       );
	   (not(edge_line_seg_proportion(P1, PE)) ->
		(New_edge = [P2, IP],
		 New_ie = IE,
		 !
		);
	    % there is an edge, compare it with IE
	    (avg_grad_val_seg([P1, PE], V1E),
	     avg_grad_val_seg([P1, IP], V1I),
	     avg_grad_val_seg([IP, PE], VIE),
	     % if [P2, PE] is better than IE, replace it
	     ((V1E + V1I)/2 > VIE -> 
		  (New_edge = [P2, P1],
		   New_ie = [PE, P1],
		   !
		  );
	      (New_edge = [P2, IP],
	       New_ie = IE,
	       !
	      )
	     ),
	     !
	    ),
	    !
	   ),
	   !
	  ),
	  !
	 );
     (true, !)
    ),
%    intersection_line_seg(New_edge, Temp_edge, Temp_edge_1),
    Temp_edge_1 = New_edge,
    append(Temp_old_ie, [IE_], Temp_old_ie_1),
    append(Temp_new_ie, [New_ie], Temp_new_ie_1),
    readjust_new_edge_intsct(New_edge, Intscts, New_edge_r, Old_IE, New_IE, Temp_edge_1, Temp_old_ie_1, Temp_new_ie_1),
    !.

intersection_line_seg(E, [], Return):-
    Return = E, !.
intersection_line_seg(E, E, Return):-
    Return = E, !.
intersection_line_seg([X, Y], [Y, X], Return):-
    Return = [X, Y], !.
intersection_line_seg(E1, E2, Return):-
    get_left_right_most_points_in_list(E1, L1, R1),
    get_left_right_most_points_in_list(E2, L2, R2),
    L1 = [XL1, YL1],
    L2 = [XL2, YL2],
    R1 = [XR1, YR1],
    R2 = [XR2, YR2],
    ((XL1 =< XL2, XR1 > XR2, Return = [L2, R2], !);
     (XL1 < XL2, XR1 >= XR2, Return = [L2, R2], !);
     (XL1 =< XL2, XR1 < XR2, Return = [L2, R1], !);
     (XL1 < XL2, XR1 =< XR2, Return = [L2, R1], !);
     (XL1 >= XL2, XR1 < XR2, Return = [L1, R1], !);
     (XL1 > XL2, XR1 =< XR2, Return = [L1, R1], !);
     (XL1 >= XL2, XR1 > XR2, Return = [L1, R2], !);
     (XL1 > XL2, XR1 >= XR2, Return = [L1, R2], !);
     (XL1 == XL2, XR1 == XR2, 
      YL1 =< YL2, YR1 > YR2, Return = [L2, R2], !);
     (XL1 == XL2, XR1 == XR2, 
      YL1 < YL2, YR1 >= YR2, Return = [L2, R2], !);
     (XL1 == XL2, XR1 == XR2, 
      YL1 =< YL2, YR1 < YR2, Return = [L2, R1], !);
     (XL1 == XL2, XR1 == XR2, 
      YL1 < YL2, YR1 =< YR2, Return = [L2, R1], !);
     (XL1 == XL2, XR1 == XR2, 
      YL1 >= YL2, YR1 < YR2, Return = [L1, R1], !);
     (XL1 == XL2, XR1 == XR2, 
      YL1 > YL2, YR1 =< YR2, Return = [L1, R1], !);
     (XL1 == XL2, XR1 == XR2, 
      YL1 >= YL2, YR1 > YR2, Return = [L1, R2], !);
     (XL1 == XL2, XR1 == XR2, 
      YL1 > YL2, YR1 >= YR2, Return = [L1, R2], !)
    ).

readjust_intersected_edges(_, [], _, _, E, U, C, E, U, C).
readjust_intersected_edges(Edge, [I | Intscts], Other_edges, Conn_points, Return, Unchanged, Changed_conn_pair, Temp, Temp_U, Temp_chged_conn_pair):-
    I = [E, Points],
    append(Other_edges, [Edge], All_edges),
    delete(All_edges, E, Rest_edges),
    get_all_intersections(E, Rest_edges, All_intscts, []),
    intersection_all_points(All_intscts, All_intsct_pts_, []),
    list_to_set(All_intsct_pts_, All_intsct_pts),
    length(All_intsct_pts, L_int_pts),
    % if only one intersected point
    (L_int_pts == 1 ->
	 (All_intsct_pts = [IP | _],
	  E = [P1, P2],
	  % if the intersected point (IP) is an end of Edge, no change
	  (member(IP, E) ->
	       (append([E], Temp, Temp_1), Temp_U_1 = Temp_U, 
		Temp_chged_conn_pair_1 = Temp_chged_conn_pair, !);
	   (seg_length([P1, IP], L1),
	    seg_length([P2, IP], L2),
	    % if lengths have large difference
	    (L1 > L2 -> (New_edge = [P1, IP], !); (true, !)),
	    (L1 < L2 -> (New_edge = [IP, P2], !); (true, !)),
	    (L1 == L2 ->
		 (avg_grad_val_seg([P1, IP], V1),
		  avg_grad_val_seg([P2, IP], V2),
		  (V1 >= V2 ->
		       (New_edge = [P1, IP], !);
		   (New_edge = [IP, P2], !)
		  ),
		  !
		 );
	     (true, !)
	    ),
	    list_delete(E, New_edge, Removed),
	    (Removed == [] ->
		 (append([New_edge], Temp, Temp_1), Temp_U_1 = Temp_U, !);
	     (seg_length(New_edge, LN),
	      seg_length(E, LE),
	      % if the is edge extended, the extended part should also be an edge
	      (LE < LN ->
		   (edge_points_proportion_threshold(PT),
		    edge_point_thresh(GT),
		    edge_point_relax(RG),
		    edge_points_proportion_relax(RP),
		    PT1 is (PT - RP),
		    GT1 is (GT - RG),
		    Removed = [Removed_P | _],
		    ((edge_line_seg_proportion_grad(Removed_P, IP, GT1, PT1)
		     ) ->
			 (append([New_edge], Temp, Temp_1), Temp_U_1 = Temp_U, !);
		     (Temp_1 = Temp, append([E], Temp_U, Temp_U_1), !)
		    ),
		    !
		   );
	       (append([New_edge], Temp, Temp_1), Temp_U_1 = Temp_U, !)
	      )
	     )
	    ),
%    	    New_edge = [NP1, NP2],
%	    intersection(E, Conn_points, Conn_it),
%	    list_delete(Conn_it, New_edge, Changed_conn),
%	    (not(Changed_conn == []) ->
%		 (Changed_conn = [Ch_conn | _],
%		  list_delete(New_edge, E, Changed_IP),
%		  Changed_IP = [Ch_IP | _],
%		  append(Temp_chged_conn_pair, [[Ch_conn, Ch_IP]], Temp_chged_conn_pair_1),
%		  !
%		 );
%	     (Temp_chged_conn_pair_1 = Temp_chged_conn_pair, !)
%	    ),
%	    Edge = [I1, I2],
%	    edge_points_proportion_threshold(PT),
%	    edge_point_thresh(GT),
%	    edge_point_relax(RG),
%	    edge_points_proportion_relax(RP),
%	    PT1 is (PT - RP),
%	    GT1 is (GT - RG),
%	    ((edge_line_seg_proportion_grad(NP1, NP2, GT1, PT1),
%	      edge_line_seg_proportion_grad(I1, I2, GT1, PT1)
%	     ) ->
%		 (append([New_edge], Temp, Temp_1), Temp_U_1 = Temp_U, !);
%	     (Temp_1 = Temp, append([E], Temp_U, Temp_U_1), !)
%	    )
	    !
	   ),
	   !
	  ),
	  !
	 );
     % if more than one intersected point
     (append(Points, All_intsct_pts, All_intsct_pts_1),
      append(E, All_intsct_pts_1, All_intsct_pts_2),
      list_to_set(All_intsct_pts_2, All_intsct_pts_3),
      search_for_longest_edge_line_seg(All_intsct_pts_3, New_edge_),
      (New_edge_ == [] ->
	   (get_left_right_most_points_in_list(All_intsct_pts, LL, RR),
	    New_edge = [LL, RR], 
	    !
	   );
       (New_edge = New_edge_, !)
      ),
      intersection(E, Conn_points, Conn_it),
      list_delete(Conn_it, New_edge, Changed_conn),
      (not(Changed_conn == []) ->
	   (Changed_conn = [Ch_conn | _],
	    list_delete(New_edge, E, Changed_IP),
	    Changed_IP = [Ch_IP | _],
	    append(Temp_chged_conn_pair, [[Ch_conn, Ch_IP]], Temp_chged_conn_pair_1),
	    !
	   );
       (Temp_chged_conn_pair_1 = Temp_chged_conn_pair, !)
      ),
      list_delete(E, New_edge, Removed),
      (Removed == [] ->
	   (append([New_edge], Temp, Temp_1), Temp_U_1 = Temp_U, !);
       (seg_length(New_edge, LN),
	seg_length(E, LE),
	% if the is edge extended, the extended part should also be an edge
	(LE < LN ->
	     (edge_points_proportion_threshold(PT),
	      edge_point_thresh(GT),
	      edge_point_relax(RG),
	      edge_points_proportion_relax(RP),
	      PT1 is (PT - RP),
	      GT1 is (GT - RG),
	      list_delete(New_edge, E, Added),
	      Added = [IP | _],
	      Removed = [Removed_P | _],
	      ((edge_line_seg_proportion_grad(Removed_P, IP, GT1, PT1)
	       ) ->
		   (append([New_edge], Temp, Temp_1), Temp_U_1 = Temp_U, !);
	       (Temp_1 = Temp, append([E], Temp_U, Temp_U_1), !)
	      ),
	      !
	     );
	 (append([New_edge], Temp, Temp_1), Temp_U_1 = Temp_U, !)
	)
       )
      ),
      !
     ),
     !
    ),
    readjust_intersected_edges(Edge, Intscts, All_edges, Conn_points, Return, Unchanged, Changed_conn_pair, Temp_1, Temp_U_1, Temp_chged_conn_pair_1),
    !.

search_for_longest_edge_line_seg([], []).
search_for_longest_edge_line_seg([X, Y], [X, Y]).
search_for_longest_edge_line_seg(Point_list, New_edge):-
    combination(2, Point_list, Combs),
    get_longest_edge_line_seg(Combs, New_edge, []).

get_longest_edge_line_seg([], New_edge, New_edge).
get_longest_edge_line_seg([C | Cs], New_edge, Temp):-
    edge_points_proportion_threshold(PT),
    edge_point_thresh(GT),
    edge_point_relax(RG),
    edge_points_proportion_relax(RP),
    PT1 is (PT - RP),
    GT1 is (GT - RG),
    C = [P1, P2],
    (edge_line_seg_proportion_grad(P1, P2, GT1, PT1) ->
	 (seg_length(Temp, LT),
	  seg_length(C, LC),
	  (LC > LT ->
	       (get_longest_edge_line_seg(Cs, New_edge, C), !);
	   (get_longest_edge_line_seg(Cs, New_edge, Temp), !)
	  ),
	  !
	 );
     get_longest_edge_line_seg(Cs, New_edge, Temp)
    ).


change_end_to_end_pairs(Edges, [], Return):-
    Return = Edges,
    !.
change_end_to_end_pairs(Edges, [EP | EPs], Return):-
    EP = [End1, End2],
    change_end_to_end(Edges, End1, End2, Edges_new),
    change_end_to_end_pairs(Edges_new, EPs, Return).

change_end_to_end(Edges, End1, End2, Return):-
    findall(EE, (member(EE, Edges), member(End1, EE)), Has_end1),
    change_end(Has_end1, End1, End2, Return, []).

change_end([], _, _, Return, Temp):-
    Return = Temp,
    !.
change_end([E | Es], End1, End2, Return, Temp):-
    delete(E, End1, E_),
    append(E_, [End2], E_1),
    (not(E_1 = [X, X]) ->
	 (append(Temp, [E_1], Temp_1),
	  change_end(Es, End1, End2, Return, Temp_1),
	  !
	 );
     (change_end(Es, End1, End2, Return, Temp), !)
    ).

merge_all_edges([], _, Return, Return).
merge_all_edges([Edge | Edges], All_edges, Return, Temp):-
    delete(All_edges, Edge, Other_edges),
    get_all_intersections(Edge, Other_edges, All_intersections, []),
    intersection_all_points(All_intersections, All_intsct_pts, []),
    get_left_right_most_points_in_list(All_intsct_pts, Left, Right),
    New_edge = [Left, Right],
    append(Temp, [New_edge], Temp_1),
    delete(All_edges, Edge, All_edges_1),
    append([New_edge], All_edges_1, All_edges_2),
    merge_all_edges(Edges, All_edges_2, Return, Temp_1).
    
% obtain all intersected points in [[E1, P1], [E2, P2], ...]
intersection_all_points([], Return, Temp):-
    list_to_set(Temp, Return), !.
intersection_all_points([EP | EPs], Return, Temp):-
    EP = [_, Points],
    append(Temp, Points, Temp_1),
    intersection_all_points(EPs, Return, Temp_1),
    !.

intersection_all_edges([], Return, Return).
intersection_all_edges([EP | EPs], Return, Temp):-
    EP = [Edge, _],
    append(Temp, [Edge], Temp_1),
    intersection_all_edges(EPs, Return, Temp_1).

% get all intersections between a line seg (edge) and all other line segs
% Return = [[E1, P1], [E2, P2], ...]
get_all_intersections(_, [], Return, Return).
get_all_intersections(Edge, [E | Es], Return, Temp):-
    intersected_or_near(Edge, E) ->
	(intersected_seg(Edge, E, Points),
	 (not(Points == []) ->
	      % intersected
	      (append(Temp, [[E, Points]], Temp_1),
	       get_all_intersections(Edge, Es, Return, Temp_1),
	       !
	      );
	  % not intersected, so near
	  (line_parameters(Edge, A1, B1, C1),
	   line_parameters(E, A2, B2, C2),
	   intersected_lines([A1, B1, C1], [A2, B2, C2], Points_1),
	   append(Temp, [[E, Points_1]], Temp_1),
	   get_all_intersections(Edge, Es, Return, Temp_1),
	   !
	  )
	 ),
	 !
	);
    % not intersected nor near
    (get_all_intersections(Edge, Es, Return, Temp), !).

% use extended lines to get intersections
get_all_intersections_ex(_, [], Return, Return).
get_all_intersections_ex(Edge, [E | Es], Return, Temp):-
    intersected_seg(Edge, E, Points),
    (not(Points == []) ->
	 % intersected
	 (append(Temp, [[E, Points]], Temp_1),
	  get_all_intersections(Edge, Es, Return, Temp_1),
	  !
	 );
     % not intersected, use extended line
     (line_parameters(Edge, A1, B1, C1),
      line_parameters(E, A2, B2, C2),
      intersected_lines([A1, B1, C1], [A2, B2, C2], Points_1),
      append(Temp, [[E, Points_1]], Temp_1),
      get_all_intersections(Edge, Es, Return, Temp_1),
      !
     )
    ),
    !.
    
comps_to_edges([], Return, Return).
comps_to_edges([Comp | Comps], Return, Temp):-
	append(Temp, Comp, Temp_1),
	comps_to_edges(Comps, Return, Temp_1), !.

edge_connect_to_comp(_, []):-
    fail, !.
edge_connect_to_comp(Edge, [E | Edges]):-
    intersected_or_near(Edge, E) ->
	(true, !);
    (edge_connect_to_comp(Edge, Edges), !).

edge_connect_to_comp_edges(_, [], Return, Temp):-
    Return = Temp.
edge_connect_to_comp_edges(Edge, [E | Edges], Return, Temp):-
    intersected_or_near(Edge, E) ->
	(append(Temp, [E], Temp_2),
	 edge_connect_to_comp_edges(Edge, [E | Edges], Return, Temp_2),
	 !
	);
    (edge_connect_to_comp_edges(Edge, Edges, Return, Temp), !).

% connect ends and examinate new edges whether it exists or subsumed
edge_existed_in_list(_, []):-
    fail, !.
edge_existed_in_list(Edge, Edge_list):-
    (member(Edge, Edge_list), !);
    ((Edge = [P1, P2], member([P2, P1], Edge_list)), !).

edge_subsumed_by_edge_in_list(Edge, Edge_list):-
    Edge_list = [Head | Tail],
    (edge_subsume(Head, Edge) ->
	 (true, !);
     (edge_subsumed_by_edge_in_list(Edge, Tail), !)
    ), 
    !.

examine_new_edges(Combs, Edge_list, New_edges, Temp_list):-
    Combs == [] ->
	(New_edges = Temp_list, !);
    (Combs = [Comb | Other_combs],
     Comb = [[X1, Y1], [X2, Y2]],
     edge_points_proportion_threshold(T),
     T1 is (T - 0.1),
     (edge_line_seg_proportion([X1, Y1], [X2, Y2], T1) ->
	  (((edge_existed_in_list(Comb, Edge_list), !);
	    (edge_subsumed_by_edge_in_list(Comb, Edge_list), !)
	   ) ->
	       (examine_new_edges(Other_combs, Edge_list, New_edges, Temp_list), !);
	   (append(Temp_list, [Comb], Temp_list_1),
	    examine_new_edges(Other_combs, Edge_list, New_edges, Temp_list_1),
	    !
	   ),
	   !
	  );
      (examine_new_edges(Other_combs, Edge_list, New_edges, Temp_list), !)
     ),
     !
    ).

connect_ends(Edge_list, New_edges):-
    edges_ends(Edge_list, All_ends),
    combination(2, All_ends, Combs),
    examine_new_edges(Combs, Edge_list, New_edges, []).

% build a connection list of all edges
find_all_intersected_or_near_edges(Edge, Idx_list, Edge_list, Return, Temp):-
    Edge_list == [] ->
	(Return = Temp, !);
    (Edge_list = [Head | Tail],
     Idx_list = [Head_idx | Tail_idx],
     ((\+same_seg(Edge, Head), intersected_or_near(Edge, Head)) ->
	  (append(Temp, [Head_idx], Temp_1),
	   find_all_intersected_or_near_edges(Edge, Tail_idx, Tail, Return, Temp_1),
	   !
	  );
      find_all_intersected_or_near_edges(Edge, Tail_idx, Tail, Return, Temp),
      !
     ),
     !
    ),
    !.

generate_connected_edge_idx(To_process, Idx_list, Edge_list, Return, Temp):-
    To_process == [] ->
	(Return = Temp, !);
    (To_process = [Head | Tail],
     find_all_intersected_or_near_edges(Head, Idx_list, Edge_list, C, []),
     append(Temp, [C], Temp_1),
     generate_connected_edge_idx(Tail, Idx_list, Edge_list, Return, Temp_1),
     !
    ).

% build connective component indices
build_component_idx(Indices, Connections, Return, Temp):-
    Indices == [] ->
	(Return = Temp, !);
    (Indices = [Idx | Others],
     nth1(Idx, Connections, Con),
     list_not_member(Con, Temp, Con_2),
     list_add_nodup(Others, Con_2, Others_2),
     list_add_nodup(Temp, Con, Temp_2),
     build_component_idx(Others_2, Connections, Return, Temp_2),
     !
    ).
    
% split edges to connective components
split_components(Edge_list, Idx_list, Connections, Components, Temp):-
    (Idx_list == [] ->
	 (Components = Temp, !);
     (Idx_list = [Head | Tail],
      build_component_idx([Head], Connections, Comp_idx, [Head]),
      get_elements(Comp_idx, Edge_list, C),
      list_delete(Tail, Comp_idx, Tail_2),
      append(Temp, [C], Temp_2),
      split_components(Edge_list, Tail_2, Connections, Components, Temp_2),
      !
     )
    ).


split_components(Edge_list, Comp_list):-
    length(Edge_list, Len),
    findall(Num, between(1, Len, Num), Idx_list),
    generate_connected_edge_idx(Edge_list, Idx_list, Edge_list, Conn, []),
    split_components(Edge_list, Idx_list, Conn, Comp_list, []).

% TODO::post-process
post_process([], Return, Temp):-
    Return = Temp, !.
post_process([C | Cs], Return, Temp):-
    fail.

