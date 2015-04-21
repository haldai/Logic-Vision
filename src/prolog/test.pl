% initialization & exit
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
    ['labeler.pl'].
    
    % debug test files

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
test_go:-
    display_refresh,
    sample_conjecture_edges_1(300, 200, Cs),
    !,
    display_polygon_list(Cs, r),
    print_list(Cs),
    post_process(Cs, Cs_1, []),
%    build_connected_components(E, P),
    display_refresh,
    display_polygon_list(Cs_1, g),
    open('../../triangles_4_R.pl', write, Out),
    write_polygons(Cs_1, Out, 1),
    close(Out).

test_label(I):-
    format(atom(Img_file), '../../triangles_~d.jpg', [I]),
    format(atom(Poly_file), '../../results/triangles_~d_R.pl', [I]),
    format(atom(Label_file), '../../labels/triangles_~d_label.pl', [I]),
    format(atom(Out_file), '../MetagolD/polygons/raw/poly_~d_label.pl', [I]),
    label_from_file(Img_file, Poly_file, Label_file, Out_file).
