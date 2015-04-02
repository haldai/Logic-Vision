line(l1, 1, -2, 3).
line(l2, -1, 2, 10).

test_split(Left_end, Right_end):-
    line_parameters(a, b, A, B, C), 
    sample_line(A, B, C, P), 
    split_line_by_edge(168, 100, 251, 109, P, Left, Right),
    reverse(Left, [], Rev_left),
    extend_edge_line_seg_left(168, 100, 251, 109, Rev_left, Left_end),
    extend_edge_line_seg_right(168, 100, 251, 109, Right, Right_end).

test_extend(Ends):-
    line_parameters(a, b, A, B, C), 
    sample_line(A, B, C, P), 
    split_line_by_edge(168, 100, 251, 109, P, Left, Right),
    extend_edge_line_seg(168, 100, 251, 109, Left, Right, Ends).
