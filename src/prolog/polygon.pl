% polygon matcher

% polygon definition (with vertex list)
% line segment can be a degenerated polygon!
polygon_chk_v(V):-
    length(V, Len),
    Len == 1,
    !.
    
polygon_chk_v(V):-
    length(V, Len),
    Len > 1,
    V = [V1, V2 | Vs],
    V1 \= V2,
    recursion_limit(N),
    edge_line_seg(V1, V2, N),
    VV = [V2 | Vs],
    polygon_chk_v(VV).

% triangle (vertex)
triangle_chk_v(P1, P2, P3):-
    polygon_chk_v([P1, P2, P3, P1]).

triangle_chk_v_display(P1, P2, P3):-
    display_refresh,
    display_point(P1, r),
    display_point(P2, r),
    display_point(P3, r),
    polygon_chk_v([P1, P2, P3, P1]).
