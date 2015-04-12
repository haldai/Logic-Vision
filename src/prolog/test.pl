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
    load_img('../../triangles_1.jpg', _),
    img_quantize(3).

halt_prog:-
    img_release,
    writeln('Halt.'),
    halt.

% test program
test_go:-
    display_refresh,
    sample_conjecture_edges_1(300, 200, E),
    display_polygon_list(E, g),
    print_list(E),
%    build_connected_components(E, P),
    display_refresh,
    display_polygon_list(E, g),
    open('../../triangles_1.pl', write, Out),
    write_polygons(E, Out, 1),
    close(Out).

debug_test(Conn_comp_list):-
    sample_edges_components([[21,153], [175,275], [183,69], [503,220], [174,274], [22,154]], [[[21,153],[183,69]], [[175,275],[183,69]], [[175,275],[503,220]], [[174,274],[183,69]]], Conn_comp_list, [[[[21,153],[175,275]],[[183,69],[503,220]],[[174,274],[503,220]],[[22,154],[183,69]]]], [[1,0.7350427350427351,-446.8461538461538], [1,-0.6453488372093024,-86.56395348837209], [1,-3.581818181818182,174.7818181818182], [1,5.823529411764706,-1774.9411764705883], [1,0.18705035971223022,-160.6474820143885], [1,-2.0384615384615383,-47.46153846153845], [1,1.9056603773584906,-313.60377358490564], [1,0.05365853658536585,-186.70243902439023], [1,6.12962962962963,-1851.5185185185185], [1,-1.2583333333333333,172.78333333333333]], 11).
