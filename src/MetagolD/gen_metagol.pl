%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
% GEN_METAGOL VERSION 8.1
% 	AUTHOR: STEPHEN MUGGLETON
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
% Generalised form of meta-interpreter which supports tabulated
%	Metarules and background knowledge as MetaSubstitution.
%	The Program State is defined as the 4-tuple
%		Prog = ps(MetaSubs,Signature,SizeBound,MetaRules)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555

% Abductive/inductive proving

%xx prove(Atoms,_,_) :- write('PROVING '), write(Atoms), nl, fail. 
prove([],Prog,Prog).
prove([Atom-PostTest|Atoms],Prog1,Prog2) :-
    %xx 
    /*(Atom=[athleteplaysforteam,'coach:vincent_lecavalier',XX]->
trace;
true
),*/
    %write('dProve'-Atom),
    %--primatom(Atom), !,
    %***---Atom=[P|_],arity(Atom,Arity),defined(P/Arity),!, %***
    d_prove([Atom-PostTest],Prog1), %--callatom(Atom), 
    PostTest,!,
    %xx write('dProve_passed'-Atom-Atoms),nl,
    prove(Atoms,Prog1,Prog2).
% prove([Atom-Post|Atoms],Prog1,Prog2) :-
%	not(primatom(Atom)),
%	write('DPROVING: '), write(Atom-Post), nl,
%	(d_prove([Atom-Post],Prog1);(write('FAILED DPROVE'),nl,fail)),
%	prove(Atoms,Prog1,Prog2).
prove([Atom-PostTest|Atoms],Prog1,Prog2) :-
    %(Prog1 = ps([metasub(tailrec,[athletehomestadium/2,athleteplaysforteam/2])],sig([athletehomestadium/2,athletehomestadium_1/_131254,athleteplaysforteam/2,teamhomestadium/2],[]),s(0),[instance,chain,inverse,tailrec]) ->
%	 true;%(trace, spy d_prove/2, spy abduce);
%     true
    %),
    % Atom is a list of Constant/Variables
    %xx  	write('Prog1='), write(Atom-Prog1), nl, 
    metarule(RuleName,MetaSub,(Atom:-Body),PreTest,Prog1),
    %xx  	write('MetaRule='), write(metarule(RuleName,MetaSub,(Atom:-Body),PreTest)), nl, 
    call(PreTest),
    %--*** to filter hypothesis with examples 
    (PostTest==noExampleinH->   
	 RuleName\==instance;
     true
    ),
    %xx  	write('Passed PreTest'), nl, 
    %xx  	write('TRYING CLAUSE:'), nl, printprog([metasub(RuleName,MetaSub)]),
    /*(Prog1=ps([metasub(inverse,[athleteplayssport_2/2,athleteplaysforteam/2]),metasub(chain,[athleteplayssport_1/2,athleteplaysforteam/2,athleteplayssport_2/2]),metasub(tailrec,[athleteplayssport/2,athleteplayssport_1/2])],sig([athleteplayssport/2,athleteplayssport_1/2,athleteplayssport_2/2,athleteplaysforteam/2],[]),0,[chain,inverse,tailrec])->
trace;
true),*/
    %((RuleName=instance,Atom=[athleteplaysforteam,'athlete:john_salmons',A])->
    /*(RuleName=instance,Atom=[athleteplaysforteam,'athlete:john_salmons',A],Prog1=ps([metasub(chain,[athletehomestadium/2,athleteplaysforteam/2,teamhomestadium/2])],sig([athletehomestadium/2,athletehomestadium_1/_131254,athleteplaysforteam/2,teamhomestadium/2],[]),s(0),[instance,chain])->
trace; %,spy abduce/3
true
),*/
    abduce(metasub(RuleName,MetaSub),Prog1,Prog3), % Binds MetaSub
    Prog3=ps(_,_,Left,_),
    %xx  	write('CLAUSES LEFT='), write(Left), nl, 
    prove(Body,Prog3,Prog4),
    PostTest,
    %xx  	write('Passed PostTest'), nl, 
    prove(Atoms,Prog4,Prog2).

abduce(MetaSub,Prog,Prog) :-
    ground(MetaSub), MetaSub, !.	% Ground call
abduce(MetaSub,ps(Ms,S,s(N),MRs),ps([MetaSub|Ms],S,N,MRs)) :-
    MetaSub, !, ground(MetaSub).	% Capture constants
abduce(MetaSub,Prog,Prog) :- Prog=ps(Ms,_,_,_),
			     element(MetaSub,Ms), !.		% Already in Program
abduce(MetaSub,ps(Ms,S,s(N),Mss),ps([MetaSub|Ms],S,N,Mss)) :-
    %xx  	write('INSTANCE CHECK'), nl, 
    %xx  	write(MetaSub), nl, 
    MetaSub=metasub(RuleName,[P/A|_]).
%\+(RuleName==instance,P==athletehomestadium).
%xxx---RuleName\=instance, not(prim(P/A)). %***, functional(RuleName,P,Ms).




functest([],_,_).

functest([Ep1|Eps],Ep,Prog) :-
    functest1(Ep1,Ep,Prog),
    functest(Eps,Ep,Prog).

functest1(Ep,Ep,Prog):-!.
functest1(Ep1,Ep,Prog) :-
    episode(Ep1,Pos,Neg), 
    add_prepost(Pos,Pos1), %add_prepost(Neg,Neg1),
    member([_,X,Y]-Post,Pos1),d_prove([[Ep,X,Y]-Post],Prog),
    !,fail.
functest1(Ep1,Ep,Prog).


asserta_defined([]).
asserta_defined([P|Ps]):- 
    asserta(defined(P)),
    asserta_defined(Ps).

primatom(Atom) :-
    Atom=[P|_],
    arity(Atom,A),
    prim(P/A).

% Deductive proving

d_prove([],Prog).
d_prove([Atom-Post|Atoms],Prog) :-
    %***---primatom(Atom), !, otherwise, examples with recursive are not called
    callatom(Atom), Post, d_prove(Atoms,Prog).
d_prove([Atom-Post|Atoms],Prog) :-
    % Atom is a list of Constant/Variables
    %xx  	write('D: Prog='), write(Prog), nl, 
    Prog=ps(Ms,_,_,_), M=metasub(RuleName,MetaSub),
    element(M,Ms),
    metarule(RuleName,MetaSub,(Atom:-Body),PreTest,Prog),
    %xx  	write('D: TRYING CLAUSE:'), nl, printprog([metasub(RuleName,MetaSub)]), 
    call(PreTest),
    %xx  	write('D: Passed PreTest'), nl, 
    d_prove(Body,Prog),
    call(Post),
    %xx  	write('D: Passed PostTest'), nl, 
    d_prove(Atoms,Prog).

% Order-related predicates

pred_above(P,Q,Prog) :- Prog=ps(_,sig(Ps,_),_,_),
			append(_,[P|Rest],Ps), element(Q,Rest).

% obj_above(X,Y,Prog) :- Prog=ps(_,sig(_,Os),_,_),
%	once(append(_,[X|Rest],Os)), element(Y,Rest).

newpred(EpC,P,N) :-
    name(N,NC), append(EpC,[95|NC],PC), name(P,PC), !.

newconst(X,N1,N2) :-
    N is N1+48, name(X,[99,N]), N2 is N1+1, !.

element(H,[H|_]).
element(H,[_|T]) :- element(H,T).

append([],L,L).
append([H|T],L,[H|R]) :- append(T,L,R).

% Printing predicates

printprog(Ms) :-
    copy_term(Ms,Ms1),
    converts(Ms1,Cs), nl, sort(Cs,Cs1),
    printclauses(Cs1), !.

converts([],[]) :- !.
converts([metasub(RuleName,MetaSub)|MIs],[Clause|Cs]) :-
    metarule(RuleName,MetaSub,Clause,_,_),
    numbervars(Clause,0,_),
    converts(MIs,Cs), !.

printclauses([]) :- nl, !.
printclauses([C|Cs]) :-
    printclause(C), nl,
    printclauses(Cs).

printclause((Head :- [])) :-
    printatom(Head), write('.').
printclause((Head :- Body)) :-
    printatom(Head), write(' :- '),
    printatoms(Body).

printatom_cond(List-_) :- printatom(List).

printatom(List) :- Atom =.. List, write(Atom).

printatoms([A]) :- printatom_cond(A),  write('.'), !.
printatoms([A|As]) :- printatom_cond(A), write(', '), printatoms(As), !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
%
% Generate a Peano number

peano(0,0) :- !.
peano(N,s(M)) :- not(var(N)), !, N1 is N-1, peano(N1,M), !.
peano(N,s(M)) :- var(N), !, peano(N1,M), N is N1+1, !.

reverse(L1,L2) :- reverse1(L1,[],L2).

reverse1([],L,L) :- !.
reverse1([H|T],R,L) :- reverse1(T,[H|R],L).

% Construct an ordered list of naturals in the interval [Lo,Hi]

interval(Lo,Hi,[Lo|T]) :-
    Lo=<Hi, Lo1 is Lo+1,
    interval(Lo1,Hi,T), !.
interval(_,_,[]).

% Test that none of the negatives are provable

nproveall([],_) :- !.       % Check G fits all the negative episodes
nproveall([Atom|T],Prog) :-
    not(d_prove([Atom],Prog)),
    nproveall(T,Prog), !.

% Learn from a single episode and update the signature

learn_episode(Eps,Ep,Int,ps(Ms1,sig(Ps1,Cs1),_,_),Prog2) :-
    %write('EXAMPLE EPISODE: '), write(Ep), nl, nl,
    name(Ep,EpChars),
    episode(Ep,Pos,Neg), Pos = [[Ep|Px]|_], arity([Ep|Px],Epa),
    element(N,Int), peano(N,Lim1),
    %--write('TRY CLAUSE BOUND: '), write(N), nl,
    element(M,Int), M=<N, M1 is M-1, peano(M1,Lim2),
    %---***M1 is N-1, peano(M1,Lim2),
    %--write('TRY NEW PREDICATE BOUND: '), write(M1), nl,
    addnewpreds(EpChars,0,M1,Ps1,Ps3),append(NewPreds,Ps1,Ps3),
    % Ps3=Ps1
    metaruless(Mss),
    element(MetaRules,Mss),
    %--write('TRY METARULE SET: '), write(MetaRules), nl,
    add_prepost(Pos,Pos1), add_prepost(Neg,Neg1),
    prove(Pos1,ps(Ms1,sig([Ep/Epa|Ps3],Cs1),Lim1,MetaRules),Prog2),
    %**
    %spy d_prove/2,
    %trace,
    %write('testing'-Prog2),nl,
    (functest(Eps,Ep,Prog2)->
         true;
     fail 
    ),
    nproveall(Neg1,Prog2),
    %write('FINAL HYPOTHESIS FOR EPISODE: '),  write(Ep),
    %write(', BOUND: '), write(N), nl,
    Prog2=ps(Ms2,_,_,_),
    asserta_defined([Ep/Epa|NewPreds]),
    append(H,Ms1,Ms2), %printprog(H),
    !.


noExampleinH:- true. %---***
add_prepost([],[]).
add_prepost([Atom|Atoms1],[Atom-noExampleinH|Atoms2]) :- %---***
							  add_prepost(Atoms1,Atoms2).

% Learn from sequence of example episodes, where theory size is bounded
% 	by episode size/2.

learn_seq(Eps,Pn) :-
    init_ps(P0),
    learn_seq(Eps,Eps,P0,Pn). 
%---***test_seq(Eps,Pn), !.


learn_seq(Eps,[],B,B) :- !.
learn_seq(Eps,[E|T],BK,Hyp) :-
    episode(E,Pos,Neg), length(Pos,P), length(Neg,N),
    clausebound(Bnd),%(clausebound(Bnd);(Bnd is floor(log(P+N)/log(2)))),
    interval(1,Bnd,I),
    learn_episode(Eps,E,I,BK,Hyp1),
    learn_seq(Eps,T,Hyp1,Hyp), !.
learn_seq(Eps,[E|_],_,_) :-
    episode(E,Pos,Neg), length(Pos,P), length(Neg,N),
    (clausebound(Bnd);(Bnd is floor(log(P+N)/log(2)))),
    write('EPISODE '), write(E),
    write(': NO COMPRESSION FOR CLAUSE BOUND UP TO '), write(Bnd), nl, nl,
    !, fail.

% Test the learned episodes against unseen examples.

test_seq([],_) :- !.
test_seq([Ep|Eps],Prog) :-
    write('TEST ACCURACY '), write(Ep), write(': '),
    findall(Atom,test(Ep,[Atom|_],[]),Pos),
    length(Pos,N),
    findall(Atom1,(element(Atom1,Pos),d_prove([Atom1-true],Prog)),Covered),
    sort(Covered,Covered1),
    length(Covered1,M),
    write(M/N), nl,
    PA is 100*M/N,
    asserta(accuracy(Ep,PA)),
    test_seq(Eps,Prog), !.

% Non-deterministically add up to max(Lim)-1 new predicate symbols

addnewpreds(_,N,N,Ps1,Ps1) :- !.
addnewpreds(EpC,N,M,Ps1,[P/X|Ps2]) :-
    N1 is N+1,
    newpred(EpC,P,N1),
    N2 is N+1,
    addnewpreds(EpC,N2,M,Ps1,Ps2).

init_ps(ps(BK,sig(Ps,Os),_,_)) :-
    init_prog(BK),
    init_preds(Ps),asserta_defined(Ps),
    init_consts(Os).

prim(P) :- dyadic(P).
prim(P) :- monadic(P).

dyadic(P) :- dyadics(Ds), element(P,Ds).

monadic(P) :- monadics(Ds), element(P,Ds).

primitives(Ps) :-
    dyadics(Ds), monadics(Ms), append(Ds,Ms,Ps), !.

% General collection of metarules

metarule(RuleName,MetaSub,Rule,PreTest,Program) :-
    Program=ps(_,_,_,MetaRules),
    element(RuleName,MetaRules),
    metarule1(RuleName,MetaSub,Rule,PreTest,Program).

%***
metarule1(property,[P/1,X],([P,X] :- []),Pre,Prog) :-   
    Prog=ps(_,sig(Ps,_),_,_), Pre=element(P/1,Ps).
metarule1(instance,[P/A,X,Y],([P,X,Y] :- []),Pre,Prog) :-
    Prog=ps(_,sig(Ps,_),_,_), Pre=element(P/A,Ps).
metarule1(base1,[P/2,Q/1],([P,X,X] :- [[Q,X]]-true),Pre,Prog) :-
    Pre=pred_above(P/2,Q/1,Prog).
metarule1(base,[P/2,Q/Qa|U],([P,X,Y] :- [A-true]),Pre,Prog) :-
    A=[Q,X,Y|U], arity(A,Qa),
    Pre=pred_above(P/2,Q/Qa,Prog).
metarule1(inverse,[P/2,Q/Qa|U],([P,X,Y] :- [A-true]),Pre,Prog) :-
    A=[Q,Y,X|U], arity(A,Qa),
    Pre=pred_above(P/2,Q/Qa,Prog).
metarule1(precon,[P/2,Q/1,R/2],
	  ([P,X,Y] :- [[Q,X]-true,[R,X,Y]-true]),Pre,Prog) :-
    Pre=(pred_above(P/2,Q/1,Prog), pred_above(P/2,R/2,Prog)).
metarule1(postcon,[P/2,Q/2,R/1],
	  ([P,X,Y] :- [[Q,X,Y]-true,[R,Y]-true]),Pre,Prog) :-
    Pre=(pred_above(P/2,Q/2,Prog), pred_above(P/2,R/1,Prog)).
metarule1(tailrec,[P/2,Q/Qa|U],
	  ([P,X,Y] :- [A-Post1, [P,Z,Y]-Post2]),Pre,Prog) :-
    A=[Q,X,Z|U], arity(A,Qa),
    Pre=pred_above(P/2,Q/Qa,Prog),
    obj_gt(ObjGT), obj_gte(ObjGTE),
    Post1 =.. [ObjGT,X,Z,Prog],
    Post2 =.. [ObjGTE,Z,Y,Prog].
metarule1(chain,[P/2,Q/Qa,R/Ra|UV],([P,X,Y] :- [A-Post1,B-Post2]),Pre,Prog) :-
    A=[Q,X,Z|U], B=[R,Z,Y|V],
    arity(A,Qa), arity(B,Ra), append(U,V,UV),
    Pre=(pred_above(P/2,Q/Qa,Prog), pred_above(P/2,R/Ra,Prog)),
    obj_gt(ObjGT1),obj_gt(ObjGT2),
    Post1 =.. [ObjGT1,X,Z,Prog],
    Post2 =.. [ObjGT2,Z,Y,Prog].
metarule1(monochain,[P/1,Q/Qa,R/Ra|UV],([P,X] :- [A-Post1,B-Post2]),Pre,Prog) :-
    A=[Q,X,Z|U], B=[R,Z,Y|V],
    arity(A,Qa), arity(B,Ra), append(U,V,UV),
    Pre=(pred_above(P/1,Q/Qa,Prog), pred_above(P/1,R/Ra,Prog)),
    obj_gt(ObjGT1),obj_gt(ObjGT2),
    Post1 =.. [ObjGT1,X,Z,Prog],
    Post2 =.. [ObjGT2,Z,Y,Prog].

%arity([_,_,_,_],3). 
arity([_,_,_],2). arity([_,_],1).

init_preds(P) :- primitives(P).

metasub(instance,Args) :-
    Args = [P/_|Args1],
    callatom([P|Args1]).

callatom(Args) :-
    Goal =.. Args,
    %xx  	write('CALLATOM PROVING '), write(Goal), nl, 
    !, call(Goal).
%xx  	write('SUCCEEDED '), write(Goal), nl, 
%***!.
