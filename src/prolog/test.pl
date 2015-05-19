% initialization & exit
:- dynamic(point/3, triangle/2, quadrangle/2, pentagon/2, hexagon/2, right_angle/2, regular/2, triangle/1, quadrangle/1, pentagon/1, hexagon/1, right_angle/1, regular/1).

debug_(0).

:-
    set_prolog_stack(global, limit(2*10**9)),
    set_prolog_stack(local, limit(2*10**9)),
    set_prolog_stack(trail, limit(2*10**9)),
    set_prolog_stack(global, spare(4096)),
    set_prolog_stack(local, spare(4096)),
    set_prolog_stack(trail, spare(2048)),
    set_prolog_stack(global, min_free(16384)),
    set_prolog_stack(local, min_free(4096)),
    set_prolog_stack(trail, min_free(4096)),

    % load cv lib
    load_foreign_library(foreign('img_process.so')),

    % load primitives
    ['parameters.pl'],
    ['primitive.pl'],
    ['polygon.pl'],
    ['sampler.pl'],
    ['utils.pl'],
    ['conjecture.pl'],
    ['io.pl'],
    ['post_process.pl'],
    ['labeler.pl'],
    ['gen_episodes'].

halt_prog:-
    img_release,
    writeln('Halt.'),
    halt.

% test program
run_sampling(W, I):-
    format(atom(Img_file), '../../data/~w_~d.jpg', [W, I]),
    format(atom(Out_file), '../../results/~w_~d_R.pl', [W, I]),
    img_load(Img_file, _),
    img_quantize(2),
    display_refresh,
    sample_conjecture_edges_1(300, 200, Cs),
    !,
    display_polygon_list(Cs, r),
    print_list(Cs),
    post_process(Cs, Cs_1, []),
%    build_connected_components(E, P),
    display_refresh,
    display_polygon_list(Cs_1, g),
    open(Out_file, write, Out),
    write_polygons(Cs_1, Out, I, 1),
    close(Out),
    (debug_(1) -> (get_char(_), !); true),
    img_release.

run_labeling(W, I, N):-
    format(atom(Img_file), '../../data/~w_~d.jpg', [W, I]),
    format(atom(Poly_file), '../../results/~w_~d_R.pl', [W, I]),
    format(atom(Label_file), '../../labels/~w_~d_label.pl', [W, I]),
    format(atom(Out_file), '../MetagolD/polygons/raw/~w_~d_label.pl', [W, I]),
    label_from_file(Img_file, Poly_file, Label_file, Out_file, N).

run_sampling_image(Img_file, Out_file, I):-
    img_load(Img_file, _),
    img_quantize(2),
    display_refresh,
    sample_conjecture_edges_1(300, 200, Cs),
    !,
    display_polygon_list(Cs, r),
    print_list(Cs),
    post_process(Cs, Cs_1, []),
    display_refresh,
    display_polygon_list(Cs_1, g),
    open(Out_file, write, Out),
    write_polygons(Cs_1, Out, I, 1),
    close(Out),
    (debug_(1) -> (get_char(_), !); true),
    img_release.

run_sampling_image_repeat(Img_file, Out_file, I, N):-
    img_load(Img_file, _),
    img_quantize(2),
    open(Out_file, write, Out),
    sample_image_repeat(Out, I, 0, N),
    close(Out),
    (debug_(1) -> (get_char(_), !); true),
    img_release.

sample_image_repeat(_, _, Max, Max).
sample_image_repeat(Out, I, N, Max):-
    display_refresh,
    sample_conjecture_edges_1(300, 200, Cs),
    !,
    length(Cs, LC),
    ((LC == 0; LC > 1) -> % special for task1
	 (writeln("REDO!"), sample_image_repeat(Out, I, N, Max), !);
     (display_polygon_list(Cs, r),
      print_list(Cs),
      (post_process(Cs, Cs_1, []) ->
	   (display_refresh,
	    display_polygon_list(Cs_1, g),
	    write_polygons(Cs_1, Out, I, N),
	    N1 is N + 1,
	    sample_image_repeat(Out, I, N1, Max),
	    !
	   );
       (writeln("REDO!"), sample_image_repeat(Out, I, N, Max))
      )
     )
    ).

run_sampling_list(_, []).
run_sampling_list(D, [I | Is]):-
    format(atom(Img_file), '../../data/~w/~d.jpg', [D, I]),
    format(atom(Out_file), '../../results/~w/~d.pl', [D, I]),
    run_sampling_image(Img_file, Out_file, I),
    run_sampling_list(D, Is).

run_sampling_list_repeat(_, [], _).
run_sampling_list_repeat(D, [I | Is], N):-
    format(atom(Img_file), '../../data/~w/~d.jpg', [D, I]),
    format(atom(Out_file), '../../results/~w/~d.pl', [D, I]),
    run_sampling_image_repeat(Img_file, Out_file, I, N),
    run_sampling_list_repeat(D, Is, N).

% D is dir name, N is number of images
run_sampling_dir(D, N):-
    findall(I, between(1, N, I), List),
    run_sampling_list(D, List).
    
run_checker_list(D, [I | Is]):-
    writeln(I),
    format(atom(Img_file), '../../data/~w/~d.jpg', [D, I]),
    format(atom(Out_file), '../../results/~w/~d.pl', [D, I]),
    [Out_file],
    img_load(Img_file, _),
    display_all_polygons(r),
    unload_file(Out_file),
    get_char(_),
    img_release,
    run_checker_list(D, Is).

run_checker_dir(D, S, E):-
    findall(I, between(S, E, I), List),
    run_checker_list(D, List).
