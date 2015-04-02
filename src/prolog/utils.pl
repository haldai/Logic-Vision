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
    list_delete(List_2, Tail, Out_list).

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

% define display_line_of_list/2
display_line_of_list(Points, C):-
    Points = [Start | _],
    Start = [X1, Y1],
    last(Points, End),
    End = [X2, Y2],
    display_line(X1, Y1, X2, Y2, C),
    !.

display_line(Line, C):-
    Line = [[X1, Y1], [X2, Y2]],
    display_line(X1, Y1, X2, Y2, C).

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
    (
	P1 = [];
	P2 = []
    ) 
    ->
	true;
    (
	P1 = [X1, Y1 | _],
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

% last element of list
last_ele(List, X):-
    List == []
    ->
	X = [];
    last(List, X).

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

% same line segment
same_seg([P1, P2], [P1, P2]).
same_seg([P1, P2], [P2, P1]).
