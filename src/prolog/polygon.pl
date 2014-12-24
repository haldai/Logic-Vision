% polygon matcher

% parameters
edge_thresh(5.0).
recursion_limit(2).

% polygon definition
% vertices
polygon_chk([V1, V2 | Vs]):-
    recursion_limit(N),
    edge_line_seg(V1, V2),
    
