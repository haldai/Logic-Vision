% triangle matcher

% parameters
edge_thresh(5.0).
recursion_limit(5).

% definition
triangle_point(P1, P2, P3):-
    recursion_limit(N),
    edge_line_seg(P1, P2, N),
    edge_line_seg(P2, P3, N),
    edge_line_seg(P3, P1, N).
