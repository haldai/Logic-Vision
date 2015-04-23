print_episodes(Names, W, I):-
    format(atom(Out_file), '../MetagolD/polygons/raw/~w_~d_episodes.pl', [W, I]),
    tell(Out_file),
    gen_episodes(Names, W, I),
    told.

gen_episodes([], _, _):-
    true.
gen_episodes([N | Ns], W, I):-
    gen_episode(N, W, I),
    writeln(''),
    gen_episodes(Ns, W, I).

gen_episode(Name, W, I):-
    format(atom(Poly_file), '../../results/~w_~d_R.pl', [W, I]),
    format(atom(Label_file), '../MetagolD/polygons/raw/~w_~d_label.pl', [W, I]),
    write('episode('),
    write(Name),
    writeln(','),
    evaluate_all_labels(Name, Poly_file, Label_file, Pos, Neg),
    writeln('\t['),
    print_episodes(Name, Pos),
    writeln('\t],'),
    writeln('\t['),
    print_episodes(Name, Neg),
    writeln('\t]'),
    writeln('       ).').

evaluate_all_labels(Name, Poly_file, Label_file, Pos, Neg):-
    unload_file('./labeler.pl'),
    [Poly_file],
    [Label_file],
    atomic_concat(not_, Name, Neg_name),
    findall(P, (polygon(P, _), call(Name, P)), Pos),
    findall(P, (polygon(P, _), call(Neg_name, P)), Neg),
    unload_file(Poly_file),
    unload_file(Label_file),
    ['./labeler.pl'].

print_episodes(Name, [Obj | []]):-
    write('\t ['),
    write(Name),
    write(', '),
    write(Obj),
    writeln(']'),
    !.
print_episodes(_, []):-
    writeln(''),
    !.
print_episodes(Name, [Obj | Objs]):-
    write('\t ['),
    write(Name),
    write(', '),
    write(Obj),
    writeln('],'),
    print_episodes(Name, Objs).
