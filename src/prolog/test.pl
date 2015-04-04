% initialization & exit
:- dynamic point/3.
:-
    set_prolog_stack(global, limit(1*10**9)),
    set_prolog_stack(local, limit(1*10**9)),
    set_prolog_stack(trail, limit(1*10**9)),
    set_prolog_stack(global, spare(2048)),
    set_prolog_stack(local, spare(2048)),
    set_prolog_stack(trail, spare(1024)),
    set_prolog_stack(global, min_free(8192)),
    set_prolog_stack(local, min_free(2048)),
    set_prolog_stack(trail, min_free(2048)).

load_all_libs:-
    % load primitives
    ['parameters.pl'],
    ['primitive.pl'],
    ['polygon.pl'],
    ['sampler.pl'],
    ['utils.pl'],
    ['conjecture.pl'],
    ['io.pl'],
    
    % debug test files
    ['test_line.pl'].

init:-
    load_all_libs,
    % start image processor
    load_foreign_library(foreign('img_process.so')),
    load_img('../../triangles_0.jpg', _),
    img_quantize(3).

halt_prog:-
    img_release,
    writeln('Halt.'),
    halt.

% test program
test_go:-
    display_refresh,
    sample_conjecture_edges(300, 200, E),
    display_line_list(E, g),
    build_connected_components(E, P),
    display_refresh,
    display_polygon_list(P, r),
    open('../../triangles_2.pl', write, Out),
    write_polygons(P, Out, 1),
    close(Out).

