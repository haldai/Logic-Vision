% post-process
post_process([], Return, Temp):-
    Return = Temp, !.
post_process([C_ | Cs], Return, Temp):-
    edges_ends(C_, Vs),
    connect_2_isolated_points(Vs, C_, C),
    combination(2, Vs, E_combs_),
    edges_not_in_list(E_combs_, C, E_combs, []),
    connect_and_exam_edges(E_combs, C_1, C),
    %edges_ends(C_1, Vs_1),
    %replace_large_obtuse_angles(Vs_1, C_1, Final_C),
    append(Temp, [C_1], Temp_1),
    post_process(Cs, Return, Temp_1).

connect_2_isolated_points(Vs, C_, C):-
    findall(V, (member(V, Vs), isolated_point(V, C_)), Iso),
    length(Iso, L),
    (L == 2 ->
	 (append(C_, [Iso], C), !);
     (C = C_, !)
    ).

replace_connected_edges([], C, _, Final_C):-
    Final_C = C, !.
replace_connected_edges(_, C, _, Final_C):-
    length(C, L),
    L == 1,
    Final_C = C, !.
replace_connected_edges([V | Vs], C_1, T, Final_C):-
    findall(E, (member(E, C_1), member(V, E)), Es),
    ((length(Es, LL), LL >= 2, Es = [E1, E2]) -> (true, !); 
     (replace_connected_edges(Vs, C_1, T, Final_C), !)
    ),
    ((E1 = [P1, V], E2 = [V, P2]);
    (E1 = [P1, V], E2 = [P2, V]);
    (E1 = [V, P1], E2 = [V, P2]);
    (E1 = [V, P1], E2 = [P2, V])),
    !,
    seg_length([P1, V], DV1),
    seg_length([V, P2], DV2),
    seg_length([P1, P2], D12),
    (abs(DV1 + DV2 - D12)/D12 < T ->
	 (New_edge = [P1, P2],
	  list_delete(C_1, Es, C_2),
	  add_edge_no_dup(C_2, New_edge, C_3),
	  edges_ends(C_3, Vs_1),
	  replace_connected_edges(Vs_1, C_3, T, Final_C),
	  !
	 );
     (replace_connected_edges(Vs, C_1, T, Final_C), !)
    ).

connect_and_exam_edges([], Return, Temp):-
    Return = Temp, !.
connect_and_exam_edges([Comb | Combs], Return, Temp):-
    Comb = [P1, P2],
    edge_point_thresh(GT),
    edge_points_proportion_threshold(PT),
    edge_point_relax(RG),
    edge_points_proportion_relax(RP),
    GT1 is (GT - RG),
    PT1 is (PT - RP),
    (edge_line_seg_proportion_grad(P1, P2, GT1, PT1) ->
	 (New_edge = Comb,
	  process_edge_edge_subsumption(New_edge, Temp, _, Unsubbed, [], []),
	  Temp_1 = Unsubbed,
	  connect_and_exam_edges(Combs, Return, Temp_1),
	  !
	 );
     % if near but not connected, find out new connecting point and modify edges
     (point_near(P1, P2) ->
	  (findall(E, 
		   (member(E, Temp), (member(P1, E);member(P2, E))), 
		   IsoEdges
		  ),
	   (IsoEdges = [IE1, IE2] ->
		(line_parameters(IE1, A1, B1, C1),
		 line_parameters(IE2, A2, B2, C2),
		 intersected_lines([A1, B1, C1], [A2, B2, C2], Points_1),
		 middle_element(Points_1, IP),
		 list_delete(IE1, Comb, IE1_),
		 list_delete(IE2, Comb, IE2_),
		 append(IE1_, [IP], IE1_R),
		 append(IE2_, [IP], IE2_R),
		 list_delete(Temp, [IE1, IE2], Temp_),
		 append(Temp_, [IE1_R, IE2_R], Temp_1),
		 connect_and_exam_edges(Combs, Return, Temp_1),
		 !
		);
	    (connect_and_exam_edges(Combs, Return, Temp), !)
	   ),
	   !
	  );
      % if not near but isolated points, connect them
      (((isolated_point(P1, Temp), 
	 isolated_point(P2, Temp), 
	 point_near_thresh(P1, P2, 0.05), 
	 edge_line_seg_proportion_grad(P1, P2, 1.0, 0.6))->
	    (New_edge = Comb,
	     process_edge_edge_subsumption(New_edge, Temp, _, Unsubbed, [], []),
	     Temp_1 = Unsubbed,
	     connect_and_exam_edges(Combs, Return, Temp_1),
	     !
	    );
	(connect_and_exam_edges(Combs, Return, Temp), !)
       ),
       !
      )
     )
    ),
    !.
    
edges_not_in_list([], _, Return, Temp):-
    Return = Temp, !.
edges_not_in_list([E | Es], List, Return, Temp):-
    edge_existed_in_list(E, List) ->
	(edges_not_in_list(Es, List, Return, Temp), !);
    (append(Temp, [E], Temp_1),
     edges_not_in_list(Es, List, Return, Temp_1),
     !
    ).

ignore_edges([], C, _, Final_C):-
    Final_C = C, !.
ignore_edges([E | Es], C, T, Final_C):-
    E = [P1, P2],
    findall(EE, (member(EE, C), (member(P1, EE); member(P2, EE))), Conn_),
    list_to_set(Conn_, Conn__),
    delete(Conn__, E, Conn),
    (Conn = [E1, E2] ->
	 (true, !);
     (ignore_edges(Es, C, T, Final_C), !)
    ),
    seg_length(E1, L1),
    seg_length(E2, L2),
    seg_length(E, L),
    Dev is (L/L1 + L/L2)/2,
    (Dev < T ->
	 (line_parameters(E1, A1, B1, C1),
	  line_parameters(E2, A2, B2, C2),
	  intersected_lines([A1, B1, C1], [A2, B2, C2], Points_1),
	  middle_element(Points_1, IP),
	  list_delete(E1, E, E1_),
	  list_delete(E2, E, E2_),
	  append(E1_, [IP], E1_R),
	  append(E2_, [IP], E2_R),
	  list_delete(C, [E1, E2, E], C_),
	  append(C_, [E1_R, E2_R], C_1),
	  ignore_edges(C_1, C_1, T, Final_C),
	  !
	 );
     (ignore_edges(Es, C, T, Final_C), !)
    ).

isolated_edge(E, C):-
    E = [P1, P2],
    findall(EE, (member(EE, C), member(P1, EE)), E1s),
    findall(EE, (member(EE, C), member(P2, EE)), E2s),
    length(E1s, L1),
    length(E2s, L2),
    (L1 =:= 1; L2 =:= 1),
    !.

isolated_point(P, C):-
    findall(EE, (member(EE, C), member(P, EE)), Es),
    length(Es, L),
    L == 1,
    !.
