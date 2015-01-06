% initialization & exit
:- dynamic point/3.

init:-
    % load primitives
    ['primitive.pl'],
    ['polygon.pl'],
    ['sampler.pl'].
  
    % start image processor
    load_foreign_library(foreign('img_process.so')),
    load_img('../../triangle.jpg', _),
    img_quantize(2).

end_prog:-
    img_release,
    writeln('Halt.'),
    halt.

% points
point(a, 142, 97).
point(b, 320, 116).
point(c, 242, 221).
point(d, 288, 159).
point(o, 0, 0).
