% initialization & exit
debug_(1).

:- dynamic(point/3, triangle/2, quadrangle/2, pentagon/2, hexagon/2, right_angle/2, regular/2, triangle/1, quadrangle/1, pentagon/1, hexagon/1, right_angle/1, regular/1).

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

%load_all_libs:-
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
    


init:-
%    load_all_libs,
    % start image processor

    img_load('../../triangles_4.jpg', _),
    img_quantize(2).

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
    write_polygons(Cs_1, Out, 1),
    close(Out),
    (debug_(1) -> (get_char(_), !); true),
    img_release.

run_labeling(W, I):-
    format(atom(Img_file), '../../data/~w_~d.jpg', [W, I]),
    format(atom(Poly_file), '../../results/~w_~d_R.pl', [W, I]),
    format(atom(Label_file), '../../labels/~w_~d_label.pl', [W, I]),
    format(atom(Out_file), '../MetagolD/polygons/raw/~w_~d_label.pl', [W, I]),
    label_from_file(Img_file, Poly_file, Label_file, Out_file).
