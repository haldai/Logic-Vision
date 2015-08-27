label_from_file(Img_file, Poly_file, Label_file, Out, N):-
    ((current_predicate(img_size/2), img_size(_, _)) ->
	 (img_release, !);
     true
    ),
    (img_load(Img_file, _) ->
	 ([Poly_file],
	  [Label_file],
	  findall(P, polygon(P, _), Polygons),
	  tell(Out),
	  writeln(':- discontiguous triangle/1.'),
	  writeln(':- discontiguous not_triangle/1.'),
	  label_all_triangle(Polygons, N),
	  writeln(''),
	  writeln(':- discontiguous quadrangle/1.'),
	  writeln(':- discontiguous not_quadrangle/1.'),
	  label_all_quadrangle(Polygons, N),
	  writeln(''),
	  writeln(':- discontiguous pentagon/1.'),
	  writeln(':- discontiguous not_pentagon/1.'),
	  label_all_pentagon(Polygons, N),
	  writeln(''),
	  writeln(':- discontiguous hexagon/1.'),
	  writeln(':- discontiguous not_hexagon/1.'),
	  label_all_hexagon(Polygons, N),
	  writeln(''),
	  %writeln(':- discontiguous regular/1.'),
	  %writeln(':- discontiguous not_regular/1.'),
	  %label_all_regular(Polygons, N),
	  %writeln(''),
	  %writeln(':- discontiguous right_triangle/1.'),
	  %writeln(':- discontiguous not_right_triangle/1.'),
	  %label_all_right_triangle(Polygons, N),
	  told,
	  write('Labels assigned to file '),
	  write(Out),
	  writeln('.'),
	  unload_file(Poly_file),
	  unload_file(Label_file),
	  img_release,
	  !
	 );
     fail
    ).

% procedure for labeling graphics on canvas
triangle(Poly):-
    label(X, Y),
    triangle(X, Y),
    P = [X, Y],
    polygon(Poly, Edges),
    point_in_polygon(P, Edges), !.

quadrangle(Poly):-
    label(X, Y),
    quadrangle(X, Y),
    P = [X, Y],
    polygon(Poly, Edges),
    point_in_polygon(P, Edges), !.

pentagon(Poly):-
    label(X, Y),
    pentagon(X, Y),
    P = [X, Y],
    polygon(Poly, Edges),
    point_in_polygon(P, Edges), !.

hexagon(Poly):-
    label(X, Y),
    hexagon(X, Y),
    P = [X, Y],
    polygon(Poly, Edges),
    point_in_polygon(P, Edges), !.

regular(Poly):-
    label(X, Y),
    regular(X, Y),
    P = [X, Y],
    polygon(Poly, Edges),
    point_in_polygon(P, Edges), !.

right_triangle(Poly):-
    label(X, Y),
    right_triangle(X, Y),
    P = [X, Y],
    polygon(Poly, Edges),
    point_in_polygon(P, Edges), !.


% label triangles
label_all_triangle([], _):-
    true, !.
label_all_triangle([Poly | Ps], N):-
    polygon(Poly, _),
    (triangle(Poly) ->
	 (write_triangles(Poly, N), !);
     write_n_triangles(Poly, N)
    ),
    label_all_triangle(Ps, N), !.

write_triangles(Poly, 0):-
    write('triangle('),
    concat(Poly, '_', Poly_),
    concat(Poly_, 0, PolyN),
    write(PolyN),
    writeln(').'),
    !.
write_triangles(Poly, N):-
    write('triangle('),
    concat(Poly, '_', Poly_),
    concat(Poly_, N, PolyN),
    write(PolyN),
    writeln(').'),
    N1 is N - 1,
    write_triangles(Poly, N1).

write_n_triangles(Poly, 0):-
    write('not_triangle('),
    concat(Poly, '_', Poly_),
    concat(Poly_, 0, PolyN),
    write(PolyN),
    writeln(').'),
    !.
write_n_triangles(Poly, N):-
    write('not_triangle('),
    concat(Poly, '_', Poly_),
    concat(Poly_, N, PolyN),
    write(PolyN),
    writeln(').'),
    N1 is N - 1,
    write_n_triangles(Poly, N1).

% label quadrangle
label_all_quadrangle([], _):-
    true, !.
label_all_quadrangle([Poly | Ps], N):-
    polygon(Poly, _),
    (quadrangle(Poly) ->
	 (write_quadrangles(Poly, N), !);
     write_n_quadrangles(Poly, N)
    ),
    label_all_quadrangle(Ps, N), !.

write_quadrangles(Poly, 0):-
    write('quadrangle('),
    concat(Poly, '_', Poly_),
    concat(Poly_, 0, PolyN),
    write(PolyN),
    writeln(').'),
    !.
write_quadrangles(Poly, N):-
    write('quadrangle('),
    concat(Poly, '_', Poly_),
    concat(Poly_, N, PolyN),
    write(PolyN),
    writeln(').'),
    N1 is N - 1,
    write_quadrangles(Poly, N1).

write_n_quadrangles(Poly, 0):-
    write('not_quadrangle('),
    concat(Poly, '_', Poly_),
    concat(Poly_, 0, PolyN),
    write(PolyN),
    writeln(').'),
    !.
write_n_quadrangles(Poly, N):-
    write('not_quadrangle('),
    concat(Poly, '_', Poly_),
    concat(Poly_, N, PolyN),
    write(PolyN),
    writeln(').'),
    N1 is N - 1,
    write_n_quadrangles(Poly, N1).

% label pentagons
label_all_pentagon([], _):-
    true, !.
label_all_pentagon([Poly | Ps], N):-
    polygon(Poly, _),
    (pentagon(Poly) ->
	 (write_pentagons(Poly, N), !);
     write_n_pentagons(Poly, N)
    ),
    label_all_pentagon(Ps, N), !.

write_pentagons(Poly, 0):-
    write('pentagon('),
    concat(Poly, '_', Poly_),
    concat(Poly_, 0, PolyN),
    write(PolyN),
    writeln(').'),
    !.
write_pentagons(Poly, N):-
    write('pentagon('),
    concat(Poly, '_', Poly_),
    concat(Poly_, N, PolyN),
    write(PolyN),
    writeln(').'),
    N1 is N - 1,
    write_pentagons(Poly, N1).

write_n_pentagons(Poly, 0):-
    write('not_pentagon('),
    concat(Poly, '_', Poly_),
    concat(Poly_, 0, PolyN),
    write(PolyN),
    writeln(').'),
    !.
write_n_pentagons(Poly, N):-
    write('not_pentagon('),
    concat(Poly, '_', Poly_),
    concat(Poly_, N, PolyN),
    write(PolyN),
    writeln(').'),
    N1 is N - 1,
    write_n_pentagons(Poly, N1).

% label hexagons
label_all_hexagon([], _):-
    true, !.
label_all_hexagon([Poly | Ps], N):-
    polygon(Poly, _),
    (hexagon(Poly) ->
	 (write_hexagons(Poly, N), !);
     write_n_hexagons(Poly, N)
    ),
    label_all_hexagon(Ps, N), !.

write_hexagons(Poly, 0):-
    write('hexagon('),
    concat(Poly, '_', Poly_),
    concat(Poly_, 0, PolyN),
    write(PolyN),
    writeln(').'),
    !.
write_hexagons(Poly, N):-
    write('hexagon('),
    concat(Poly, '_', Poly_),
    concat(Poly_, N, PolyN),
    write(PolyN),
    writeln(').'),
    N1 is N - 1,
    write_hexagons(Poly, N1).

write_n_hexagons(Poly, 0):-
    write('not_hexagon('),
    concat(Poly, '_', Poly_),
    concat(Poly_, 0, PolyN),
    write(PolyN),
    writeln(').'),
    !.

write_n_hexagons(Poly, N):-
    write('not_hexagon('),
    concat(Poly, '_', Poly_),
    concat(Poly_, N, PolyN),
    write(PolyN),
    writeln(').'),
    N1 is N - 1,
    write_n_hexagons(Poly, N1).

% label regulars
label_all_regular([], _):-
    true, !.
label_all_regular([Poly | Ps], N):-
    polygon(Poly, _),
    (regular(Poly) ->
	 (write_regulars(Poly, N), !);
     write_n_regulars(Poly, N)
    ),
    label_all_regular(Ps, N), !.

write_regulars(Poly, 0):-
    write('regular('),
    concat(Poly, '_', Poly_),
    concat(Poly_, 0, PolyN),
    write(PolyN),
    writeln(').'),
    !.
write_regulars(Poly, N):-
    write('regular('),
    concat(Poly, '_', Poly_),
    concat(Poly_, N, PolyN),
    write(PolyN),
    writeln(').'),
    N1 is N - 1,
    write_regulars(Poly, N1).

write_n_regulars(Poly, 0):-
    write('not_regular('),
    concat(Poly, '_', Poly_),
    concat(Poly_, 0, PolyN),
    write(PolyN),
    writeln(').'),
    !.

write_n_regulars(Poly, N):-
    write('not_regular('),
    concat(Poly, '_', Poly_),
    concat(Poly_, N, PolyN),
    write(PolyN),
    writeln(').'),
    N1 is N - 1,
    write_n_regulars(Poly, N1).

% label right_triangles
label_all_right_triangle([], _):-
    true, !.
label_all_right_triangle([Poly | Ps], N):-
    polygon(Poly, _),
    (right_triangle(Poly) ->
	 (write_right_triangles(Poly, N), !);
     write_n_right_triangles(Poly, N)
    ),
    label_all_right_triangle(Ps, N), !.

write_right_triangles(Poly, 0):-
    write('right_triangle('),
    concat(Poly, '_', Poly_),
    concat(Poly_, 0, PolyN),
    write(PolyN),
    writeln(').'),
    !.
write_right_triangles(Poly, N):-
    write('right_triangle('),
    concat(Poly, '_', Poly_),
    concat(Poly_, N, PolyN),
    write(PolyN),
    writeln(').'),
    N1 is N - 1,
    write_right_triangles(Poly, N1).

write_n_right_triangles(Poly, 0):-
    write('not_right_triangle('),
    concat(Poly, '_', Poly_),
    concat(Poly_, 0, PolyN),
    write(PolyN),
    writeln(').'),
    !.

write_n_right_triangles(Poly, N):-
    write('not_right_triangle('),
    concat(Poly, '_', Poly_),
    concat(Poly_, N, PolyN),
    write(PolyN),
    writeln(').'),
    N1 is N - 1,
    write_n_right_triangles(Poly, N1).
