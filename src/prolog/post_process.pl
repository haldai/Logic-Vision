% TODO::post-process
post_process([], Return, Temp):-
    Return = Temp, !.
post_process([C | Cs], Return, Temp):-
    edges_ends(C, Vs),
    combination(2, Vs, E_combs_),
    edges_not_in_list(E_combs_, C, E_combs, []),
    connect_and_exam_edges(E_combs, C_1, C),
    edges_ends(C_1, Vs_1),
    replace_large_obtuse_angles(Vs_1, C_1, Final_C),
    append(Temp, [Final_C], Temp_1),
    post_process(Cs, Return, Temp_1).

replace_large_obtuse_angles([], C, Final_C):-
    Final_C = C, !.
replace_large_obtuse_angles([V | Vs], C_1, Final_C):-
    findall(E, (member(E, C_1), member(V, E)), Es),
    Es = [E1, E2],
    ((E1 = [P1, V], E2 = [V, P2]);
    (E1 = [P1, V], E2 = [P2, V]);
    (E1 = [V, P1], E2 = [V, P2]);
    (E1 = [V, P1], E2 = [P2, V])),
    !,
    seg_length([P1, V], DV1),
    seg_length([V, P2], DV2),
    seg_length([P1, P2], D12),
    %edge_subsume_thresh(),
    (abs(DV1 + DV2 - D12)/D12 < 0.01 ->
	 (New_edge = [P1, P2],
	  list_delete(C_1, Es, C_2),
	  append(C_2, [New_edge], C_3),
	  edges_ends(C_3, Vs_1),
	  replace_large_obtuse_angles(Vs_1, C_3, Final_C),
	  !
	 );
     (replace_large_obtuse_angles(Vs, C_1, Final_C), !)
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
     (((point_near_ex(P1, P2), edge_line_seg_proportion_grad(P1, P2, 1.0, 0.6))->
	   (New_edge = Comb,
	    append(Temp, [New_edge], Temp_1),
	    connect_and_exam_edges(Combs, Return, Temp_1),
	    !
	   );
	 (connect_and_exam_edges(Combs, Return, Temp), !)
      ),
      !
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
