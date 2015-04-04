% conjecture.pl

% build a conjecture from one point.
sample_conjecture_edges(X, Y, Edge_list):-
    sample_line_on_point(X, Y, Line_point_list),
    edge_points_in_point_list(Line_point_list, Edge_point_list),
    clearest_edge_points_mid(Edge_point_list, All_edge_points),
    get_coordinates(All_edge_points, All_edge_points_coor),
    combination(2, All_edge_points_coor, Init_combs),
    sample_edges(All_edge_points_coor, Init_combs, Edge_list, [], [], 1).
    

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
	       findall([X, Y], (member([X, Y], Points), Y > Y1), Right)
	      );
	  (findall([X, Y], (member([X, Y], Points), Y < Y1), Left),
	   findall([X, Y], (member([X, Y], Points), Y > Y2), Right)
	  )
	 );
     (X1 < X2 ->
	  (findall([X, Y], (member([X, Y], Points), X < X1), Left),
	   findall([X, Y], (member([X, Y], Points), X > X2), Right)
	  );
      (findall([X, Y], (member([X, Y], Points), X < X2), Left),
       findall([X, Y], (member([X, Y], Points), X > X1), Right)
      )
     )
    ).

% extend line segment
extend_edge_line_seg_left(X1, Y1, X2, Y2, Left, Left_end):-
    Left = [] ->
	Left_end = [X1, Y1];
    (Left = [First_point | Tail],
     First_point = [X, Y],
     edge_line_seg_proportion(X, Y, X2, Y2) ->
	 extend_edge_line_seg_left(X, Y, X2, Y2, Tail, Left_end);
     Left_end = [X1, Y1]
    ).

extend_edge_line_seg_right(X1, Y1, X2, Y2, Right, Right_end):-
    Right = [] ->
	Right_end = [X2, Y2];
    (Right = [First_point | Tail],
     First_point = [X, Y],
     (edge_line_seg_proportion(X1, Y1, X, Y) ->
	  extend_edge_line_seg_right(X1, Y1, X, Y, Tail, Right_end);
      Right_end = [X2, Y2]
     )
    ).

% extend a short edge segment to long edge
extend_edge_line_seg(X1, Y1, X2, Y2, Left, Right, Edge):-
    reverse(Left, [], Rev_left),
    extend_edge_line_seg_left(X1, Y1, X2, Y2, Rev_left, Left_end),
    extend_edge_line_seg_right(X1, Y1, X2, Y2, Right, Right_end),
    Edge = [Left_end, Right_end].

% build_edge(org_x1, org_y1, org_x2, org_y2, [[start_x, start_y], [end_x, end_y]])
build_edge(X1, Y1, X2, Y2, Edge):-
    number(X1),
    number(Y1),
    number(X2),
    number(Y2),
    line_parameters(X1, Y1, X2, Y2, A, B, C),
    sample_line(A, B, C, Points),
    split_line_by_edge(X1, Y1, X2, Y2, Points, Left, Right),
    extend_edge_line_seg(X1, Y1, X2, Y2, Left, Right, Edge).

% remove point combinations that contain particular point
remove_point_combs(Comb_list, Point, Return, Temp_list):-
    Comb_list == [] ->
	Return = Temp_list;
    (Comb_list = [Head | Tail],
	(member(Point, Head) -> 
	      Temp_list_1 = Temp_list;
	append(Temp_list, [Head], Temp_list_1)),
	remove_point_combs(Tail, Point, Return, Temp_list_1)
    ).

remove_point_combs(Comb_list, Point, Return):-
    remove_point_combs(Comb_list, Point, Return, []).

remove_points_combs(Comb_list, Points, Return, Temp_list):-
    Comb_list == [] ->
	Return = Temp_list;
    (Comb_list = [Head | Tail],
     ((intersection(Head, Points, X), X == []) ->
	  append(Temp_list, [Head], Temp_list_1);
      Temp_list_1 = Temp_list
     ),
     remove_points_combs(Tail, Points, Return, Temp_list_1)
    ).

remove_points_combs(Comb_list, Points, Return):-
    remove_points_combs(Comb_list, Points, Return, []).

% check whether sample line is existed in line list
line_existed(Line, Line_list):-
    Line_list = [Head | _],
    same_line(Line, Head) ->
	true;
    (Line_list = [_ | Tail],
     line_existed(Line, Tail)
    ).

% generate combination from existed edge points and a new point
gen_combs_point(Point, Point_list, Sampled_lines, Comb_list, Temp_list):-
    member(Point, Point_list) ->
	Comb_list = [];
    (Point_list == [] ->
	 Comb_list = Temp_list;
     (Point_list = [Head | Tail],
      (in_combo_dist(Point, Head) ->
	   (New_comb = [Point, Head],
	    (line_existed(New_comb, Sampled_lines) ->
		 gen_combs_point(Point, Tail, Sampled_lines, Comb_list, Temp_list);
	     (append(Temp_list, [New_comb], Temp_list_1),
	      gen_combs_point(Point, Tail, Sampled_lines, Comb_list, Temp_list_1)
	     )
	    )
	   );
       gen_combs_point(Point, Tail, Sampled_lines, Comb_list, Temp_list)
      )
     )
    ).

gen_combs_point(Point, Point_list, Sampled_lines, Comb_list):-
    gen_combs_point(Point, Point_list, Sampled_lines, Comb_list, []).

gen_combs(Point_list_1, Point_list_2, Sampled_lines, Comb_list, Temp_list):-
    Point_list_1 == [] ->
	Comb_list = Temp_list;
    (Point_list_1 = [Head | Tail],
     gen_combs_point(Head, Point_list_2, Sampled_lines, Comb_list_1),
     append(Temp_list, Comb_list_1, Temp_list_1),
     gen_combs(Tail, Point_list_2, Sampled_lines, Comb_list, Temp_list_1)
    ).

gen_combs(Point_list_1, Point_list_2, Sampled_lines, Comb_list):-
    gen_combs(Point_list_1, Point_list_2, Sampled_lines, Comb_list, []).

% checks whether point is on existed edges
point_not_on_edges(_, []).
point_not_on_edges(Point, Edge_list):-
    Point = [X, Y| _],
    Edge_list = [Head | Tail],
    (point_on_line_seg([X, Y], Head) ->
	 fail;
     point_not_on_edges([X, Y], Tail)
    ).

points_not_on_edges(Points, Edge_list, Return, Temp_list):-
    Points == [] ->
	Return = Temp_list;
    (Points = [Head | Tail],
     (point_not_on_edges(Head, Edge_list) ->
	  (append(Temp_list, [Head], Temp_list_1),
	   points_not_on_edges(Tail, Edge_list, Return, Temp_list_1)
	  );
      points_not_on_edges(Tail, Edge_list, Return, Temp_list)
     )
    ).

points_not_on_edges(Points, Edge_list, Return):-
    points_not_on_edges(Points, Edge_list, Return, []).

% checks whether point near existed points
point_not_near_points(_, []).
point_not_near_points(Point, Point_list):-
    Point = [X, Y| _],
    Point_list = [Head | Tail],
    (point_near([X, Y], Head) ->
	 fail;
     point_not_near_points([X, Y], Tail)
    ).

points_not_near_points(Points, Point_list, Return, Temp_list):-
    Points == [] ->
	Return = Temp_list;
    (Points = [Head | Tail],
     (point_not_near_points(Head, Point_list) ->
	  (append(Temp_list, [Head], Temp_list_1),
	   points_not_near_points(Tail, Point_list, Return, Temp_list_1)
	  );
      points_not_near_points(Tail, Point_list, Return, Temp_list)
     )
    ).

points_not_near_points(Points, Point_list, Return):-
    points_not_near_points(Points, Point_list, Return, []).

% sample new points from perpendicular bisector of [[X1, Y1], [X2, Y2]], it should not appear on existed edges
sample_new_edge_points(X1, Y1, X2, Y2, Edge_list, Point_list, Points):-
    A is 2*(X1 - X2),
    B is 2*(Y1 - Y2),
    C is X2**2 + Y2**2 - X1**2 - Y1**2,
    sample_line(A, B, C, Line_point_list),
    edge_points_in_point_list(Line_point_list, Edge_point_list),
    clearest_edge_points_mid(Edge_point_list, All_edge_points),
    points_not_near_points(All_edge_points, Point_list, Temp_points),
    points_not_on_edges(Temp_points, Edge_list, Points).
    

% sample a new point from random line that crosses [X, Y], it should not appear on existed edges
sample_new_edge_points_random(X, Y, Edge_list, Point_list, Points, N):-
    sample_new_point_limit(T),
    N > T ->
	Points = [];
    (sample_line_on_point(X, Y, Line_point_list),
     edge_points_in_point_list(Line_point_list, Edge_point_list),
     clearest_edge_points_mid(Edge_point_list, All_edge_points),
     points_not_near_points(All_edge_points, Point_list, Temp_points),
     points_not_on_edges(Temp_points, Edge_list, New_points),
     (New_points == [] ->
	  sample_new_edge_points_random(X, Y, Edge_list, Points, N + 1);
      Points = New_points 
     )
    ).

sample_new_edge_points_random(X, Y, Edge_list, Point):-
    sample_new_edge_points_random(X, Y, Edge_list, Point, 0).
    
% check if point is an end of any edge
point_is_end_of_edges(Point, Edge_list):-
    Edge_list = [Head | Tail],
    (member(Point, Head) ->
	 true;
     point_is_end_of_edges(Point, Tail)
    ).

% remove all points on edge and return the rest points
get_points_on_edge(Point_list, Exist_edge_list, Edge, On_edge, Rest, Temp_on_edge, Temp_rest):-
    Point_list == [] ->
	(Rest = Temp_rest,
	 On_edge = Temp_on_edge
	);
    (Point_list = [Head | Tail],
     (((member(Head, Edge); point_is_end_of_edges(Head, Exist_edge_list)) ->
	   (append(Temp_rest, [Head], Temp_rest_1),
	    get_points_on_edge(Tail, Exist_edge_list, Edge, On_edge, Rest, Temp_on_edge, Temp_rest_1)
	   );
       (point_on_line_seg(Head, Edge) ->
	    (append(Temp_on_edge, [Head], Temp_on_edge_1),
	     get_points_on_edge(Tail, Exist_edge_list, Edge, On_edge, Rest, Temp_on_edge_1, Temp_rest)
	    );
	(append(Temp_rest, [Head], Temp_rest_1),
	 get_points_on_edge(Tail, Exist_edge_list, Edge, On_edge, Rest, Temp_on_edge, Temp_rest_1))
       )
      )
     )
    ).

get_points_on_edge(Point_list, Exist_edge_list, Edge, On_edge, Rest):-
    get_points_on_edge(Point_list, Exist_edge_list, Edge, On_edge, Rest, [], []).

% add new edge ends to point list
add_edge_ends_to_point_list(Edge, Point_list, Return):-
    Edge = [P1, P2],
    (\+member(P1, Point_list) -> 
	 append(Point_list, [P1], R1);
     R1 = Point_list
    ),
    (\+member(P2, Point_list) -> 
	 append(R1, [P2], R2);
     R2 = R1
    ),
    Return = R2.
    
% remove all other point info, only retains coordinates of points
get_coordinates(Point_list, Return, Temp_list):-
    Point_list == [] ->
	Return = Temp_list;
    (Point_list = [Head | Tail],
     Head = [X, Y | _],
     append(Temp_list, [[X, Y]], Temp_list_1),
     get_coordinates(Tail, Return, Temp_list_1)
    ).

get_coordinates(Point_list, Return):-
    get_coordinates(Point_list, Return, []).
     

% edge subsumption: E1 subsume E2
edge_subsume(E1, E2):-
    E2 = [P1, P2],
    point_on_line_seg(P1, E1),
    point_on_line_seg(P2, E1).

edge_subsume_last(E1, E2):-
    E1 = [P1, P2],
    E2 = [P3, P4],
    point_on_line_seg(P3, E1),
    point_on_line_seg(P4, E1),
    edge_line_seg_proportion(P1, P3),
    edge_line_seg_proportion(P1, P4),
    edge_line_seg_proportion(P2, P3),
    edge_line_seg_proportion(P2, P4).

% remove subsumed edges
process_edge_subsumption(Edge, Edge_list, Subbed, Rest, Temp_sub, Temp_rest):-
    Edge_list == [] ->
	(Subbed = Temp_sub,
	 (member(Edge, Temp_sub) ->
	      Rest = Temp_rest;
	  append(Temp_rest, [Edge], Rest)
	 )
	);
    (Edge_list = [Head | Tail],
     (edge_subsume(Head, Edge) ->
	  (append(Temp_sub, [Edge], Temp_sub_1),
	   append(Temp_rest, Edge_list, Temp_rest_1),
	   process_edge_subsumption(Edge, [], Subbed, Rest, Temp_sub_1, Temp_rest_1)
	  );
      (edge_subsume(Edge, Head) ->
	   (append(Temp_sub, [Head], Temp_sub_1),
	    process_edge_subsumption(Edge, Tail, Subbed, Rest, Temp_sub_1, Temp_rest)
	   );
       (append(Temp_rest, [Head], Temp_rest_1),
	process_edge_subsumption(Edge, Tail, Subbed, Rest, Temp_sub, Temp_rest_1)
       )
      )
     )
    ).

process_edge_subsumption(Edge, Edge_list, Subbed, Rest):-
    process_edge_subsumption(Edge, Edge_list, Subbed, Rest, [], []).

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
sample_edges(_, [], E, E, _, _).
sample_edges(Point_list, Ongoing_combs, Edge_list, Temp_list, Sampled_lines, N):-
    write("turn "),
    writeln(N),
%    writeln("====Points===="),
%    print_list(Point_list),
%    writeln("====Combs===="),
%    print_list(Ongoing_combs),
%    writeln("====Edges===="),
%    print_list(Temp_list),
%    writeln("====Sampled lines===="),
%    print_list(Sampled_lines),
%    writeln("========"),
%    get_char(_),
    sample_edge_limit(T),
    (N > T ->
	 (Edge_list = Temp_list);
     (Ongoing_combs = [Comb | Other_combs],
      Comb = [P1, P2],
      edges_ends(Temp_list, All_ends),
      ((member(P1, All_ends),
	member(P2, All_ends),
	point_near(P1, P2)
       ) ->
	   (N2 is N + 1,
	    sample_edges(Point_list, Other_combs, Edge_list, Temp_list, Sampled_lines, N2)
	   );
       (line_parameters(Comb, A, B, C),
	append(Sampled_lines, [[A, B, C]], Sampled_lines_1),
	display_point_list(Comb, y),
	P1 = [X1, Y1],
	P2 = [X2, Y2],
	(edge_line_seg_proportion(X1, Y1, X2, Y2) ->
	     (build_edge(X1, Y1, X2, Y2, Edge),
	      % TODO::if new edge is subsumed by existing edges, continue
	      process_edge_subsumption(Edge, Temp_list, Subbed, Unsubbed),
	      Temp_list_1 = Unsubbed,
	      (member(Edge, Subbed) ->
		   % this edge is subsumed by existing edge, ignore it
		   (N2 is N + 1,
		    sample_edges(Point_list, Other_combs, Edge_list, Temp_list_1, Sampled_lines, N2)
		   );
	       % if new edge is not subsumed by any existing edge, take it
	       (remove_subsumed_edges_point_combs(Subbed, Unsubbed, Point_list, 
						  Other_combs, Point_list_1, Other_combs_1),
		%	     write("Edge: "),
		%	     print_list([Edge]),
		% examinate edge duplication
		display_line(Edge, r),
		% TODO::do not remove edge ends?
		get_points_on_edge(Point_list_1, Temp_list, Edge, On_edge_points, Rest_points),
		%	     writeln("On edge points: "),
		%	     print_list(On_edge_points),
		%	     writeln("Rest points:"),
		%	     print_list(Rest_points),
		display_point_list(On_edge_points, r),
		display_point_list(Edge, g),
		gen_combs(Edge, Rest_points, Sampled_lines, Comb_list),
		add_edge_ends_to_point_list(Edge, Rest_points, Point_list_2),
		remove_points_combs(Other_combs_1, On_edge_points, Other_combs_2),
		append(Other_combs_2, Comb_list, Other_combs_3),
		N2 is N + 1,
		sample_edges(Point_list_2, Other_combs_3, Edge_list, Temp_list_1, Sampled_lines_1, N2)
	       )
	      )
	     );
	 (sample_new_edge_points(X1, Y1, X2, Y2, Temp_list, Point_list, New_points_),
	  get_coordinates(New_points_, New_points),
	  display_point_list(New_points, b),
	  %      writeln("New points:"),
	  %      print_list_ln(New_points),
	  gen_combs(New_points, Point_list, Sampled_lines, Comb_list),
	  append(Other_combs, Comb_list, Comb_list_1),
	  append(Point_list, New_points, Point_list_3),
	  N2 is N + 1,
	  sample_edges(Point_list_3, Comb_list_1, Edge_list, Temp_list, Sampled_lines_1, N2)
	 )
	)
       )
      )
     )
    ),
    !.

% connect ends and examinate new edges whether it exists or subsumed
edge_existed_in_list(Edge, Edge_list):-
    member(Edge, Edge_list);
    (Edge = [P1, P2], member([P2, P1], Edge_list)).

edge_subsumed_by_edge_in_list(Edge, Edge_list):-
    Edge_list = [Head | Tail],
    (edge_subsume(Head, Edge) ->
	 true;
     edge_subsumed_by_edge_in_list(Edge, Tail)
    ).

examine_new_edges(Combs, Edge_list, New_edges, Temp_list):-
    Combs == [] ->
	New_edges = Temp_list;
    (Combs = [Comb | Other_combs],
     Comb = [[X1, Y1], [X2, Y2]],
     (edge_line_seg_proportion(X1, Y1, X2, Y2) ->
	  ((edge_existed_in_list(Comb, Edge_list);
	    edge_subsumed_by_edge_in_list(Comb, Edge_list)
	   ) ->
	       examine_new_edges(Other_combs, Edge_list, New_edges, Temp_list);
	   (append(Temp_list, [Comb], Temp_list_1),
	    examine_new_edges(Other_combs, Edge_list, New_edges, Temp_list_1)
	   )
	  );
      examine_new_edges(Other_combs, Edge_list, New_edges, Temp_list)
     )
    ).

connect_ends(Edge_list, New_edges):-
    edges_ends(Edge_list, All_ends),
    combination(2, All_ends, Combs),
    examine_new_edges(Combs, Edge_list, New_edges, []).

% build a connection list of all edges
intersected_or_near(E1, E2):-
    (intersected_seg(E1, E2), !);
    ((E1 = [P1, P2],
      E2 = [P3, P4],
      ((point_near(P1, P3), edge_line_seg_proportion(P1, P3));
       (point_near(P1, P4), edge_line_seg_proportion(P1, P4));
       (point_near(P2, P3), edge_line_seg_proportion(P2, P3));
       (point_near(P2, P4), edge_line_seg_proportion(P2, P4))
      )
     ), !
    ).

find_all_intersected_or_near_edges(Edge, Idx_list, Edge_list, Return, Temp):-
    Edge_list == [] ->
	Return = Temp;
    (Edge_list = [Head | Tail],
     Idx_list = [Head_idx | Tail_idx],
     ((\+same_seg(Edge, Head), intersected_or_near(Edge, Head)) ->
	  (append(Temp, [Head_idx], Temp_1),
	   find_all_intersected_or_near_edges(Edge, Tail_idx, Tail, Return, Temp_1)
	  );
      find_all_intersected_or_near_edges(Edge, Tail_idx, Tail, Return, Temp)
     )
    ).

generate_connected_edge_idx(To_process, Idx_list, Edge_list, Return, Temp):-
    To_process == [] ->
	Return = Temp;
    (To_process = [Head | Tail],
     find_all_intersected_or_near_edges(Head, Idx_list, Edge_list, C, []),
     append(Temp, [C], Temp_1),
     generate_connected_edge_idx(Tail, Idx_list, Edge_list, Return, Temp_1)
    ).

% build connective component indices
build_component_idx(Indices, Connections, Return, Temp):-
    Indices == [] ->
	Return = Temp;
    (Indices = [Idx | Others],
     nth1(Idx, Connections, Con),
     list_not_member(Con, Temp, Con_2),
     list_add_nodup(Others, Con_2, Others_2),
     list_add_nodup(Temp, Con, Temp_2),
     build_component_idx(Others_2, Connections, Return, Temp_2)
    ).
    
% split edges to connective components
split_components(Edge_list, Idx_list, Connections, Components, Temp):-
    (Idx_list == [] ->
	 Components = Temp;
     (Idx_list = [Head | Tail],
      build_component_idx([Head], Connections, Comp_idx, [Head]),
      get_elements(Comp_idx, Edge_list, C),
      list_delete(Tail, Comp_idx, Tail_2),
      append(Temp, [C], Temp_2),
      split_components(Edge_list, Tail_2, Connections, Components, Temp_2)
     )
    ),
    !.

% process a single connective component
replace_nearest_end(Edge, Point, Return):-
    Edge = [P1, P2],
    distance(P1, Point, D1),
    distance(P2, Point, D2),
    (D1 =< D2 ->
	 Return = [Point, P2];
     Return = [P1, Point]
    ).

process_intersection(E1, E2, N1, N2):-
    intersected_seg(E1, E2, Points),
    (Points == [] ->
	 (N1 = E1,
	  N2 = E2
	 );
     (middle_element(Points, Intsct),
      replace_nearest_end(E1, Intsct, N1),
      replace_nearest_end(E2, Intsct, N2)
     )
    ).

process_intersection(Comb_idx, Edge_list, New_edges):-
    Comb_idx == [] ->
	New_edges = Edge_list;
    (Comb_idx = [Head | Tail],
     Head = [Id_1, Id_2],
     nth1(Id_1, Edge_list, E1),
     nth1(Id_2, Edge_list, E2),
     process_intersection(E1, E2, N1, N2),
     list_delete(Edge_list, [E1, E2], Edge_list_2),
     (Id_1 < Id_2 ->
	  (list_insert(N1, Edge_list_2, Id_1, Edge_list_3),
	   list_insert(N2, Edge_list_3, Id_2, Edge_list_4),
	   process_intersection(Tail, Edge_list_4, New_edges)
	  );
      (list_insert(N2, Edge_list_2, Id_2, Edge_list_3),
       list_insert(N1, Edge_list_3, Id_1, Edge_list_4),
       process_intersection(Tail, Edge_list_4, New_edges)
      )
     )
    ).
	
process_intersection(Edge_list, New_edges):-
    length(Edge_list, Len),
    findall(Num, between(1, Len, Num), Idx_list),
    combination(2, Idx_list, Comb_idx),
    process_intersection(Comb_idx, Edge_list, New_edges),
    !.
    
% find duplicate end points
end_duplicate(End, Test_edge_list, Edge_list, Edge):-
    Test_edge_list = [Head | Tail],
    Head = [P1, P2],
    ((\+member(End, Head),
      point_on_line_seg(End, Head),
      (member([End, P1], Edge_list); member([P1, End], Edge_list)),
      (member([End, P2], Edge_list); member([P2, End], Edge_list))
     ) ->
	 Edge = Head;
     end_duplicate(End, Tail, Edge_list, Edge)
    ).

remove_duplicate_end_edges(Ends, Edge_list, New_edges, Dup_ends):-
    Ends == [] ->
	remove_points_combs(Edge_list, Dup_ends, New_edges);
    (Ends = [Head | Tail],
     (end_duplicate(Head, Edge_list, Edge_list, _) ->
	  append(Dup_ends, [Head], Dup_ends_2);
      Dup_ends_2 = Dup_ends
     ),
     remove_duplicate_end_edges(Tail, Edge_list, New_edges, Dup_ends_2)
    ).

process_duplicate_edges(Edge_list, New_edges):-
    edges_ends(Edge_list, All_ends),
    remove_duplicate_end_edges(All_ends, Edge_list, New_edges, []).

process_connective_component(Comp, New_comp):-
    process_intersection(Comp, New_edges_1),
    connect_ends(New_edges_1, New_edges_2),
    append(New_edges_1, New_edges_2, New_edges_3),
%    remove_subsumed_edges(New_edges_3, New_edges_4),
    process_duplicate_edges(New_edges_3, New_comp).

process_connective_components(Comps, Polygons, Temp):-
    Comps == [] ->
	Polygons = Temp;
    (Comps = [Head | Tail],
     process_connective_component(Head, New_comp),
     append(Temp, [New_comp], Temp_2),
     process_connective_components(Tail, Polygons, Temp_2)
    ).

process_connective_components(Comps, Polygons):-
    process_connective_components(Comps, Polygons, []).

% build conjecture polygon with sampled edges
build_polygons(Edge_list, Polygons):-
    length(Edge_list, Len),
    findall(Num, between(1, Len, Num), Idx_list),
    generate_connected_edge_idx(Edge_list, Idx_list, Edge_list, Conn, []),
    split_components(Edge_list, Idx_list, Conn, Comps, []),
    process_connective_components(Comps, Polygons).

build_connected_components(Edge_list, Comps):-
    length(Edge_list, Len),
    findall(Num, between(1, Len, Num), Idx_list),
    generate_connected_edge_idx(Edge_list, Idx_list, Edge_list, Conn, []),
    split_components(Edge_list, Idx_list, Conn, Comps, []).
    
% TODO: remove duplicated edges
