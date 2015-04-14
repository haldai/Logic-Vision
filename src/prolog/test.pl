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
    sample_edges_components([[219,158], [304,202], [394,249], [438,272], [497,303], [577,345], [65,304], [76,283], [104,229], [132,175], [202,40], [341,366], [349,351], [395,263], [422,211], [491,80], [521,22], [96,94], [107,87], [90,103], [264,80], [70,329], [89,284], [109,237], [128,193], [195,36], [107,165], [224,152], [263,148], [365,136], [401,132], [512,120], [239,64], [142,64], [204,175], [235,230], [263,279], [276,303], [271,217], [287,295], [342,354], [352,364], [406,214], [469,250], [505,271], [590,320], [90,205], [212,165], [352,119], [422,96], [483,76], [551,53]], [[[264,80],[202,40]]], Conn_comp_list, [[[[90,103],[264,80]]]], [[1,-2,92], [1,-1.921875,84.65625], [1,-1.9108910891089108,82], [1,-0.5714285714285714,-42.285714285714285], [1,8,-908], [1,-2.3454545454545452,151.5818181818182], [1,-0.1111111111111111,-78.55555555555556], [1,-0.5833333333333334,-29.916666666666664], [1,1.7777777777777777,-273.1111111111111], [1,0.6666666666666666,-158.66666666666669], [1,1.0625,-199.4375], [1,0.5769230769230769,-310.15384615384613], [1,-0.32786885245901637,-237.77049180327867]], 39).
