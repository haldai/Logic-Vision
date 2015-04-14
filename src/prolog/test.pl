% initialization & exit
:- dynamic point/3.
:-
    set_prolog_stack(global, limit(2*10**9)),
    set_prolog_stack(local, limit(2*10**9)),
    set_prolog_stack(trail, limit(2*10**9)),
    set_prolog_stack(global, spare(4096)),
    set_prolog_stack(local, spare(4096)),
    set_prolog_stack(trail, spare(2048)),
    set_prolog_stack(global, min_free(16384)),
    set_prolog_stack(local, min_free(4096)),
    set_prolog_stack(trail, min_free(4096)).

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
    !,
    display_polygon_list(E, g),
    print_list(E),
%    build_connected_components(E, P),
    display_refresh,
    display_polygon_list(E, g),
    open('../../triangles_1.pl', write, Out),
    write_polygons(E, Out, 1),
    close(Out).

test_debug(Conn_comp_list):-
    sample_edges_components([[280,115], [312,130], [486,222], [328,138], [174,275], [486,222], [187,66], [23,152], [174,275], [486,222]], [[[187,66],[174,275]], [[187,66],[486,222]], [[187,66],[280,115]], [[187,66],[312,130]], [[187,66],[486,222]], [[187,66],[328,138]], [[187,66],[174,275]], [[187,66],[486,222]], [[486,222],[280,115]], [[486,222],[312,130]], [[312,130],[280,115]], [[328,138],[280,115]], [[328,138],[312,130]]], Conn_comp_list, [[[[187,66],[23,152]],[[23,152],[174,275]],[[174,275],[486,222]]]], [[1,-1.7062937062937062,41.21678321678323], [1,-0.3563218390804598,-91.08045977011494], [1,5.870967741935484,-1784.9032258064517], [1,-0.2711864406779661,-99.42372881355932], [1,0.6625,-356.1875], [1,-1.2238805970149254,162.56716417910445], [1,1.9074074074074074,-312.9259259259259]], 8).
