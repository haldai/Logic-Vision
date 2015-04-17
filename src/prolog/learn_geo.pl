% Geometry shape learning domain-specific code

% MetaRules
metaruless([[monochain, chain]]).

% initial program state
init_prog([]).
init_consts([]).

% primitives
dyadics([shape/2, num_edges/2, num_equals/2]).
monadics([triangle/1, polygon/1]).

% define primitives
num_edges(X, Y):-
    polygon(X, Z),
    list(Z),
    length(Z, Y).

num_equals(X, Y):-
    number(X),
    number(Y),
    X =:= Y.

% Learning episodes
