% polygon matcher

% polygon definition (with vertex list)
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

polygon_chk_xy(V):-
    length(V, Len),
    Len == 1,
    !.
    
polygon_chk_xy(V):-
    length(V, Len),
    Len > 1,
    V = [V1, V2 | Vs],
    V1 = [X1, Y1],
    V2 = [X2, Y2],
    recursion_limit(N),
    edge_line_seg(X1, Y1, X2, Y2, N),
    VV = [V2 | Vs],
    polygon_chk_xy(VV).

% edge quantity of polygon
edge_numbers(Polygon, N):-
    polygon(Polygon, Edge_list),
    !,
    length(Edge_list, N).

edge_numbers(Polygon, N):-
    length(Polygon, N).

% get all angles
angles_list(X, Y):-
    not(var(X)),
    X = [_ | _],
    edges_ends(X, Vs),
    all_vertex_angles_list(Vs, X, Y, []).

all_vertex_angles_list([], _, Return, Temp):-
    Return = Temp, !.
all_vertex_angles_list([V | Vs], Edges, Return, Temp):-
    findall(E, (member(E, Edges), member(V, E)), Conn),
    length(Conn, L),
    L >= 2,
    edges_ends(Conn, Ends),
    delete(Ends, V, Other_ends),
    Other_ends = [P1, P2 | _],
    edge_angle(P1, V, P2, A),
    Angle is A/pi,
    append(Temp, [Angle], Temp_1),
    all_vertex_angles_list(Vs, Edges, Return, Temp_1).
