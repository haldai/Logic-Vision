label_from_file(Img_file, Poly_file, Label_file, Out):-
    ((current_predicate(img_size/2), img_size(_, _)) ->
	 (img_release, !);
     true
    ),
    (img_load(Img_file, _) ->
	 ([Poly_file],
	  [Label_file],
	  findall(P, polygon(P, _), Polygons),
	  tell(Out),
	  %writeln(':- discontiguous triangle/1.'),
	  %writeln(':- discontiguous not_triangle/1.'),
	  %label_all_triangle(Polygons),
	  %writeln(''),
	  %writeln(':- discontiguous quadrangle/1.'),
	  %writeln(':- discontiguous not_quadrangle/1.'),
	  %label_all_quadrangle(Polygons),
	  %writeln(''),
	  %writeln(':- discontiguous pentagon/1.'),
	  %writeln(':- discontiguous not_pentagon/1.'),
	  %label_all_pentagon(Polygons),
	  %writeln(''),
	  %writeln(':- discontiguous hexagon/1.'),
	  %writeln(':- discontiguous not_hexagon/1.'),
	  %label_all_hexagon(Polygons),
	  %writeln(''),
	  %writeln(':- discontiguous regular/1.'),
	  %writeln(':- discontiguous not_regular/1.'),
	  %label_all_regular(Polygons),
	  %writeln(''),
	  writeln(':- discontiguous right_triangle/1.'),
	  writeln(':- discontiguous not_right_triangle/1.'),
	  label_all_right_triangle(Polygons),
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
label_all_triangle([]):-
    true, !.
label_all_triangle([Poly | Ps]):-
    polygon(Poly, _),
    (triangle(Poly) ->
	 (write('triangle('),
	  write(Poly),
	  writeln(').')
	 );
     (write('not_triangle('),
      write(Poly),
      writeln(').')
     )
    ),
    label_all_triangle(Ps), !.

% label quadrangle
label_all_quadrangle([]):-
    true, !.
label_all_quadrangle([Poly | Ps]):-
    polygon(Poly, _),
    (quadrangle(Poly) ->
	 (write('quadrangle('),
	  write(Poly),
	  writeln(').')
	 );
     (write('not_quadrangle('),
      write(Poly),
      writeln(').')
     )
    ),
    label_all_quadrangle(Ps), !.

% label pentagons
label_all_pentagon([]):-
    true, !.
label_all_pentagon([Poly | Ps]):-
    polygon(Poly, _),
    (pentagon(Poly) ->
	 (write('pentagon('),
	  write(Poly),
	  writeln(').')
	 );
     (write('not_pentagon('),
      write(Poly),
      writeln(').')
     )
    ),
    label_all_pentagon(Ps), !.

% label hexagons
label_all_hexagon([]):-
    true, !.
label_all_hexagon([Poly | Ps]):-
    polygon(Poly, _),
    (hexagon(Poly) ->
	 (write('hexagon('),
	  write(Poly),
	  writeln(').')
	 );
     (write('not_hexagon('),
      write(Poly),
      writeln(').')
     )
    ),
    label_all_hexagon(Ps), !.

% label regulars
label_all_regular([]):-
    true, !.
label_all_regular([Poly | Ps]):-
    polygon(Poly, _),
    (regular(Poly) ->
	 (write('regular('),
	  write(Poly),
	  writeln(').')
	 );
     (write('not_regular('),
      write(Poly),
      writeln(').')
     )
    ),
    label_all_regular(Ps), !.

% label right_triangles
label_all_right_triangle([]):-
    true, !.
label_all_right_triangle([Poly | Ps]):-
    polygon(Poly, _),
    (right_triangle(Poly) ->
	 (write('right_triangle('),
	  write(Poly),
	  writeln(').')
	 );
     (write('not_right_triangle('),
      write(Poly),
      writeln(').')
     )
    ),
    label_all_right_triangle(Ps), !.

