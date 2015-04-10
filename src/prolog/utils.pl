% utils.pl

% write list
print_list_ln(L):-
    forall(member(X, L),
	   writeln(X)
	  ).

print_list(L):-
    L == [] ->
	writeln("");
    (write("["),
     L = [H | T],
     write(H),
     forall(member(X, T),
	    (write(", "),
	     write(X)
	    )
	   ),
     writeln("]")
    ).

% list delete
list_delete([], _, []).
list_delete(List, [], List).
list_delete(List, Del_list, Out_list):-
    Del_list = [Head | Tail],
    delete(List, Head, List_2),
    list_delete(List_2, Tail, Out_list),
    !.

% list add without duplication
list_add_nodup(L, [], L).
list_add_nodup(List, Add, Return):-
    Add = [Head | Tail],
    (member(Head, List) ->
	 list_add_nodup(List, Tail, Return);
     (append(List, [Head], List_2),
      list_add_nodup(List_2, Tail, Return)
     )
    ).

% list insertion
% from http://stackoverflow.com/questions/10063516/list-length-inserting-element
list_insert(Val, [H | List], Pos, [H | Res]):- 
    Pos > 1, !, 
    Pos1 is Pos - 1, list_insert(Val, List, Pos1, Res). 
list_insert(Val, List, 1, [Val | List]).

% elements in list 1 that are not member of list 2
list_not_member(List_1, List_2, Return, Temp):-
    List_1 == [] ->
	Return = Temp;
    (List_1 = [Head | Tail],
     (\+member(Head, List_2) ->
	  (append(Temp, [Head], Temp_1),
	   list_not_member(Tail, List_2, Return, Temp_1)
	  );
      list_not_member(Tail, List_2, Return, Temp)
     )
    ).

list_not_member(List_1, List_2, Return):-
    list_not_member(List_1, List_2, Return, []).

% odd number and even number
even(X):-
    integer(X),
    0 =:= X mod 2.
odd(X):-
    integer(X),
    1 =:= X mod 2.

% define same line, judged by parameters
same_line(L1, L2):-
    L1 = [A1, B1, C1],
    L2 = [A2, B2, C2],
    (A1 == 0 -> A2 == 0; (\+(A2 == 0), K1 is A2/A1)),
    (B1 == 0 -> B2 == 0; (\+(B2 == 0), K2 is B2/B1)),
    (C1 == 0 -> C2 == 0; (\+(C2 == 0), K3 is C2/C1)),
    same_line_para_thresh(T),
    ((number(K1), number(K2)) -> abs(K1 - K2) =< T; true),
    ((number(K2), number(K3)) -> abs(K2 - K3) =< T; true),
    ((number(K3), number(K1)) -> abs(K3 - K1) =< T; true).

% define inner_product/3: Inner product of two lists (vectors)
inner_product([], [], 0).
inner_product([X|Xs], [Y|Ys], Result):-
    Prod is X*Y,
    inner_product(Xs, Ys, Remaining),
    Result is Prod + Remaining.

% define eu_dist/3: Euclidean distance between two vectors
eu_dist_sum([], [], 0).
eu_dist_sum([X|Xs], [Y|Ys], Sum):-
    Dist is (X - Y)^2,
    eu_dist_sum(Xs, Ys, Remaining),
    Sum is Dist + Remaining.
eu_dist(X, Y, Result):-
    eu_dist_sum(X, Y, Sum),
    Result is sqrt(Sum).

% define point_dist/5, point_dist/3: Geometry distance between two points
point_dist(X1, Y1, X2, Y2, Dist):-
    D is (X1 - X2)^2 + (Y1 - Y2)^2,
    Dist is sqrt(D).

point_dist(P1, P2, Dist):-
    P1 is [X1, Y1],
    P2 is [X2, Y2],
    !,
    point_dist(X1, Y1, X2, Y2, D),
    Dist is sqrt(D).

point_dist(P1, P2, Dist):-
    point(P1, X1, Y1),
    point(P2, X2, Y2),
    !,
    point_dist(X1, Y1, X2, Y2, Dist).

% define display_point/2
display_point(P, C):-
    point(P, X, Y),
    display_point(X, Y, C),
    !.

display_point(P, C):-
    P = [X, Y],
    display_point(X, Y, C),
    !.

% define display_line_of_list/2, it is a list of all points on this line
display_line_of_list(Points, C):-
    Points = [Start | _],
    Start = [X1, Y1],
    last(Points, End),
    End = [X2, Y2],
    display_line(X1, Y1, X2, Y2, C),
    !.

% display line with given start and end points
display_line(Line, C):-
    Line = [[X1, Y1], [X2, Y2]],
    display_line(X1, Y1, X2, Y2, C).

% display a list of lines
display_line_list(Line_list, C):-
    (Line_list == [] ->
	 true;
     (Line_list = [Head | Tail],
      display_line(Head, C),
      display_line_list(Tail, C)
     )
    ),
    !.

% display polygon list
display_polygon_list(Polygon_list, C):-
    (Polygon_list == [] ->
	 true;
     (Polygon_list = [H | T],
      display_line_list(H, C),
      display_polygon_list(T, C)
     )
    ),
    !.

% random point
random_point(X, Y):-
    img_size(W, H),
    random_between(0, W, R1),
    random_between(0, H, R2),
    X = R1,
    Y = R2.

% connectivity of 2 points
connected(X1, _, X2, _):-
    abs(X1 - X2) < 2,
    !.
connected(_, Y1, _, Y2):-
    abs(Y1 - Y2) < 2,
    !.

connected(P1, P2):-
    (P1 = []; P2 = []) ->
	true;
    (P1 = [X1, Y1 | _],
     P2 = [X2, Y2 | _],
     !,
     connected(X1, Y1, X2, Y2)
    ).

connected(P1, P2):-
    point(P1, X1, Y1),
    point(P2, X2, Y2),
    !,
    connected(X1, Y1, X2, Y2).

% connectivity of 2 line segments
connected_seg_ends(S1, S2):-
    S1 = [[X1, Y1], [X2, Y2]],
    S2 = [[X3, Y3], [X4, Y4]],
    (connected([X1, Y1], [X3, Y3]);
     connected([X1, Y1], [X4, Y4]);
     connected([X2, Y2], [X3, Y3]);
     connected([X2, Y2], [X4, Y4])
    ).

% direction of vector P1P2 and P1P3, it is a determination of P1P3 and P1P2
vector_direction(P1, P2, P3, D):-
    P1 = [X1, Y1],
    P2 = [X2, Y2],
    P3 = [X3, Y3],
    D is (X3 - X1)*(Y2 - Y1) - (Y3 - Y1)*(X2 - X1).

% when the det is 0, judge whether P3 is on P1P2
on_segment(P1, P2, P3):-
    P1 = [X1, Y1],
    P2 = [X2, Y2],
    P3 = [X3, Y3],
    (X1 < X2 -> (X_min = X1, X_max = X2); (X_min = X2, X_max = X1)),
    (Y1 < Y2 -> (Y_min = Y1, Y_max = Y2); (Y_min = Y2, Y_max = Y1)),
    \+(X3 < X_min; X3 > X_max; Y3 < Y_min; Y3 > Y_max).
    
% inersection of two line segments
intersected_seg(S1, S2):-
    S1 = [P1, P2],
    S2 = [P3, P4],
    vector_direction(P3, P4, P1, D1),
    vector_direction(P3, P4, P2, D2),
    vector_direction(P1, P2, P3, D3),
    vector_direction(P1, P2, P4, D4),
    ((D1*D2 < 0, D3*D4 < 0, !);
     (D1 =:= 0, on_segment(P3, P4, P1), !);
     (D2 =:= 0, on_segment(P3, P4, P2), !);
     (D3 =:= 0, on_segment(P1, P2, P3), !);
     (D4 =:= 0, on_segment(P1, P2, P4), !)
    ).

% return intersected point
intersected_seg(S1, S2, Points):-
    intersected_seg(S1, S2) ->
	(line_parameters(S1, A1, B1, C1),
	 line_parameters(S2, A2, B2, C2),
	 D is A1*B2 - A2*B1,
	 (D == 0 ->
	      (sample_line_seg(S1, PL1),
	       sample_line_seg(S2, PL2),
	       findall(P, (member(P, PL1), member(P, PL2)), Points)
	      );
	  (Dx is -(C1*B2 - C2*B1),
	   Dy is (C1*A2 - C2*A1),
	   X is truncate(Dx/D + 0.5),
	   Y is truncate(Dy/D + 0.5),
	   Points = [[X, Y]]
	  )
	 ),
	 !
	);
    Points = [].

% intersected points of line L1 and L2
intersected_lines(L1, L2, Points):-
    L1 = [A1, B1, C1],
    L2 = [A2, B2, C2],
    D is A1*B2 - A2*B1,
    (D == 0 ->
	 (sample_line(A1, B1, C1, PL1),
	  sample_line(A2, B2, C2, PL2),
	  findall(P, (member(P, PL1), member(P, PL2)), Points)
	 );
     (Dx is -(C1*B2 - C2*B1),
      Dy is (C1*A2 - C2*A1),
      X is truncate(Dx/D + 0.5),
      Y is truncate(Dy/D + 0.5),
      Points = [[X, Y]]
     )
    ).

% last element of list
last_ele(List, X):-
    List == []
    ->
	X = [];
    last(List, X).

% most left and most right points; most upward and downward points
get_left_right_most_points_in_list([], Left, Right, Left, Right).
get_left_right_most_points_in_list([P | Ps], Left, Right, Temp_left, Temp_right):-
    Temp_left = [L | _],
    Temp_right = [R | _],
    L = [X_l, _],
    R = [X_r, _],
    P = [X_p, _],
    (X_p < X_l ->
	 (Temp_left_1 = [P], Temp_right_1 = Temp_right);
     (X_p > X_r ->
	  (Temp_right_1 = [P], Temp_left_1 = Temp_left);
      ((X_p == X_l, X_p == X_r) ->
	   (append(Temp_left, [P], Temp_left_1), 
	    append(Temp_right, [P], Temp_right_1)
	   );
       ((X_p == X_l, X_p < X_r) ->
	    (append(Temp_left, [P], Temp_left_1),
	     Temp_right_1 = Temp_right
	    );
	((X_p == X_r, X_p > X_l) ->
	     (append(Temp_right, [P], Temp_right_1),
	      Temp_left_1 = Temp_left
	     );
	 (Temp_left_1 = Temp_left, Temp_right_1 = Temp_right)
	)
       )
      )
     )
    ),
    get_left_right_most_points_in_list(Ps, Left, Right, Temp_left_1, Temp_right_1).

get_up_most_point([], Return, Return).
get_up_most_point([P | Ps], Return, Temp):-
    P = [_, Y_p],
    Temp = [_, Y_t],
    (Y_p < Y_t -> 
	 Temp_1 = P;
     Temp_1 = Temp
    ),
    get_up_most_point(Ps, Return, Temp_1).

get_down_most_point([], Return, Return).
get_down_most_point([P | Ps], Return, Temp):-
    P = [_, Y_p],
    Temp = [_, Y_t],
    (Y_p > Y_t -> 
	 Temp_1 = P;
     Temp_1 = Temp
    ),
    get_down_most_point(Ps, Return, Temp_1).

get_left_right_most_points_in_list(Point_list, Left, Right):-
    img_size(W, H),
    Point_list = [F, S | Tail],
    F = [X_1, Y_1],
    S = [X_2, Y_2],
    (X_1 < X_2 ->
	 (L_ = F, R_ = S);
     (X_1 > X_2 ->
	  (L_ = S, R_ = F);
      (Y_1 < Y_2 ->
	   (L_ = F, R_ = S);
       (L_ = S, R_ = F)
      )
     )
    ),
    get_left_right_most_points_in_list(Tail, L, R, [L_], [R_]),
    get_up_most_point(L, [L_u_x, L_u_y], [W, H]),
    get_up_most_point(R, [R_u_x, R_u_y], [-1, H]),
    get_down_most_point(L, [L_d_x, L_d_y], [W, -1]),
    get_down_most_point(R, [R_d_x, R_d_y], [-1, -1]),
    length(L, L_l),
    length(R, L_r),
    ((L_l == 1, L_r == 1) ->
	 (L = [Left | _],
	  R = [Right | _]
	 );
     (L_d_y > R_d_y -> % left down's position is lower than right down's
	   (Left = [L_d_x, L_d_y],
	    Right = [R_u_x, R_u_y]
	   );
       (L_u_y < R_u_y -> % left up's position is higher than right up's
	    (Left = [L_u_x, L_u_y],
	     Right = [R_d_x, R_d_y]
	    );
	(Left = [L_u_x, L_u_y],
	 Right = [R_d_x, R_d_y]
	)
       )
      )
     ).

% from point list get continuous intervals
continuous_intervals(Point_list, Temp_interval_list, Buff, Interval_list):-
    var(Interval_list),
    (
	Point_list = []
	->
	    append(Temp_interval_list, [Buff], Interval_list);
	(
	    Point_list = [P1 | OtherP],
	    last_ele(Buff, LastP),
	    (
		connected(P1, LastP)
		->
		    (
			append(Buff, [P1], Buff2),
			continuous_intervals(OtherP, Temp_interval_list, Buff2, Interval_list)
		    );
		(
		    append(Temp_interval_list, [Buff], Temp_interval_list2),
		    continuous_intervals(OtherP, Temp_interval_list2, [P1], Interval_list)
		)
	    )
	)
    ).

continuous_intervals(Point_list, Interval_list):-
    continuous_intervals(Point_list, [], [], Interval_list).

% get the middle point of a list
middle_element([],[]).
middle_element(List, Element):-
    length(List, Len),
    Idx is truncate(Len/2 + 0.5),
    nth1(Idx, List, Element).

% reverse a list
reverse([H|T], A, R):-
    reverse(T, [H|A], R). 
reverse([], A, A).

% combinations of elements in list: combination/3
comb_idx(0, _, []).
comb_idx(N, [X|T], [X|Comb]):-
    N > 0,
    N1 is N - 1,
    comb_idx(N1, T, Comb).
comb_idx(N, [_|T], Comb):-
    N > 0,
    comb_idx(N, T, Comb).

get_elements(Comb_idx_list, List, Comb_element, Temp_list):-
    Comb_idx_list == [] ->
	Comb_element = Temp_list;
    (Comb_idx_list = [Idx | Tail],
     nth1(Idx, List, Ele),
     append(Temp_list, [Ele], Temp_list_),
     get_elements(Tail, List, Comb_element, Temp_list_)
    ).

get_elements(Comb_idx_list, List, Comb_element):-
    get_elements(Comb_idx_list, List, Comb_element, []).

combination(N, List, Combs):-
    length(List, Len),
    findall(Num, between(1, Len, Num), Idx_list),
    findall(L, comb_idx(N, Idx_list, L), Comb_idx_list),
    findall(Comb_element, 
	    (member(Comb_idx, Comb_idx_list),
	     get_elements(Comb_idx, List, Comb_element)),
	    Combs).

% checks whether line seg E1 and E2 intersected or near
intersected_or_near(E1, E2):-
    (intersected_seg(E1, E2), !);
    ((E1 = [P1, P2],
      E2 = [P3, P4],
      ((point_near(P1, P3));%, edge_line_seg_proportion(P1, P3));
       (point_near(P1, P4));%, edge_line_seg_proportion(P1, P4));
       (point_near(P2, P3));%, edge_line_seg_proportion(P2, P3));
       (point_near(P2, P4))%, edge_line_seg_proportion(P2, P4))
      )
     ), !
    ).

% get end points of all edges in a list
edges_ends(Edges, Ends, Temp):-
    Edges == [] ->
	list_to_set(Temp, Ends);
    (Edges = [Head | Tail],
     Head = [P1, P2],
     append(Temp, [P1], Temp_1),
     append(Temp_1, [P2], Temp_2),
     edges_ends(Tail, Ends, Temp_2)
    ).

edges_ends(Edges, Ends):-
    edges_ends(Edges, Ends, []).

% define distance of two points
distance(X1, Y1, X2, Y2, D):-
    D is sqrt((X1 - X2)**2 + (Y1 - Y2)**2).

distance(P1, P2, D):-
    P1 = [X1, Y1],
    P2 = [X2, Y2],
    !,
    distance(X1, Y1, X2, Y2, D).

distance(P1, P2, D):-
    point(P1, X1, Y1),
    point(P2, X2, Y2),
    !,
    distance(X1, Y1, X2, Y2, D).

seg_length(S, L):-
    S = [P1, P2],
    distance(P1, P2, L).

% P1 nears P2
image_diagonal(Dia):-
    img_size(W, H),
    Dia is sqrt(W**2 + H**2).

point_near(P1, P2):-
    distance(P1, P2, D),
    image_diagonal(Dia),
    point_near_thresh(T),
    D/Dia =< T.

% combo distance limit
in_combo_dist(P1, P2):-
    distance(P1, P2, D),
    image_diagonal(Dia),
    combo_dist_thresh(T),
    D/Dia =< T.

in_combo_dist(P1, P2, T):-
    distance(P1, P2, D),
    image_diagonal(Dia),
    D/Dia =< T.


% same line segment
same_seg([P1, P2], [P1, P2]).
same_seg([P1, P2], [P2, P1]).

% randomly sampling a point on canvas edge
random_point_on_canvas_edge([X, Y]):-
    img_size(W, H),
    random_between(0, 3, L), % on which edge
    (L == 0 -> 
	 (X is 0, H1 is H - 1, random_between(0, H1, Y), !);
     (L == 1 -> 
	  (X is W - 1, H1 is H - 1, random_between(0, H1, Y), !);
      (L == 2 -> 
	   (Y is 0, W1 is W - 1, random_between(0, W1, X), !);
       (L == 3 -> 
	    (Y is H - 1, W1 is W - 1, random_between(0, W1, X), !);
	fail
       )
      )
     )
    ).

% minimum rectangle contains given points
points_rect([], P_min, P_max, P_min, P_max).
points_rect([Point | Points], P_min, P_max, Temp_min, Temp_max):-
    Point = [X, Y],
    Temp_min = [X_min, Y_min],
    Temp_max = [X_max, Y_max],
    (X < X_min -> New_X_min is X; New_X_min is X_min),
    (Y < Y_min -> New_Y_min is Y; New_Y_min is Y_min),
    (X > X_max -> New_X_max is X; New_X_max is X_max),
    (Y > Y_max -> New_Y_max is Y; New_Y_max is Y_max),
    points_rect(Points, P_min, P_max, [New_X_min, New_Y_min], [New_X_max, New_Y_max]).

poly_rect(Poly, P_min, P_max):-
    edges_ends(Poly, Points),
    img_size(W, H),
    W1 is W - 1,
    H1 is H - 1,
    points_rect(Points, P_min, P_max, [W1, H1], [0, 0]).

point_in_rect(P, P_min, P_max):-
    P = [X, Y],
    P_min = [X_min, Y_min],
    P_max = [X_max, Y_max],
    X =< X_max,
    X >= X_min,
    Y =< Y_max,
    Y >= Y_min.

point_on_polygon_edges(_, []):-
    fail.
point_on_polygon_edges(P, [Edge | Edges]):-
    point_on_line_seg_thresh(P, Edge, 0.001) ->
	true;
    point_on_polygon_edges(P, Edges).    

% whether a line segment crosses one of point in list
line_seg_cross_points(_, []):-
    fail.
line_seg_cross_points(Seg, [Point | Points]):-
    point_on_line_seg_thresh(Point, Seg, 0.001) ->
	true;
    line_seg_cross_points(Seg, Points).

% whether a line segment crosses vertices of given polygon
line_seg_cross_vertices_of_polygon(Seg, Poly):-
    edges_ends(Poly, Vertices),
    line_seg_cross_points(Seg, Vertices).

% counting number of intersected points between a ray and polygon
ray_casting(_, [], N, N).
ray_casting(Seg, [Edge | Edges], N, Temp):-
    intersected_seg(Seg, Edge) ->
	(T2 is Temp + 1,
	 ray_casting(Seg, Edges, N, T2)
	);
    ray_casting(Seg, Edges, N, Temp).

% checks whether a point is inside of a polygon by ray casting
point_in_polygon(P, Poly):-
    % display_line_list(Poly, g),
    % display_point(P, r),
    ((point_on_polygon_edges(P, Poly), !);
     (poly_rect(Poly, P_min, P_max), % min rect. box contains polygon
      point_in_rect(P, P_min, P_max), % point inside of box
      random_point_on_canvas_edge(R), % random point and random ray
      % display_line([P, R], b),
      % writeln(R),
      (line_seg_cross_vertices_of_polygon([P, R], Poly) -> % if ray cross vertex
							    point_in_polygon(P, Poly); %  resample a ray
       true
      ),
      ray_casting([P, R], Poly, N, 0),
      odd(N),
      !
     )
    ).
