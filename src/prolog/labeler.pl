% procedure for labeling graphics on canvas
triangle(Poly):-
    label(X, Y),
    triangle(X, Y),
    P = [X, Y],
    polygon(Poly, Edges),
    point_in_polygon(P, Edges), !.

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
	  label_all_triangle(Polygons),
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

label_all_triangle([]):-
    true, !.
label_all_triangle([Poly | Ps]):-
    polygon(Poly, _),
    (triangle(Poly) ->
	 (write('triangle('),
	  write(Poly),
	  writeln(').')
	 );
     (write('not(triangle('),
      write(Poly),
      writeln(')).')
     )
    ),
    label_all_triangle(Ps), !.

