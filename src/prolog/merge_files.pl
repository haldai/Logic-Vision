% merge training examples and facts
merge_facts_episodes(W, [I | Is], Temp_facts):-
    format(atom(Poly_file), '../MetagolD/polygons/facts/~w_~d_R.pl', [W, I]),
    [Poly_file],
    length(Temp_facts, L),
    
