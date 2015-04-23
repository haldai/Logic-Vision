:-['../gen_metagol.pl'].
:-['../polygons/bk.pl'].  %prim2_ep,

:- expects_dialect(sicstus).
:-use_module(library(timeout)).
:-use_module(library(apply_macros)).
:-use_module(library(lists)).
:-set_prolog_flag(unknown, fail).

%timelimit(120000).

it_claBound([],SolvedTasks,KBound,KBound):-!. 
it_claBound(UnsolvedTasks,SolvedTasks,KBoundSofar,KBoundSofar):-
    KBoundSofar > 4,!,write('------------ Unsolved tasks: '),write(UnsolvedTasks),nl. 
it_claBound(Tasks_toBeSolved,SolvedTasks-BK,KBoundSofar,KBound):-
    %learn_seq(SolvedTasks,BK), %***
    %write('_*_*_*_*new bound'-KBoundSofar-BK),nl,
    NewKBoundSofar is KBoundSofar+1,
    retractall(clausebound(PreKBound)),
    asserta(clausebound(NewKBoundSofar)),
    BK=ps(Ms1,sig(Ps1,Cs1),_,Pn1,_),
    retractall(defined(Q)),%***
    asserta_defined(Ps1), %***
    statistics(cputime,[Total1,Previous]),%write('----------start'),write(I),nl,
    maplist(solveOneTask_basedonPresolvedTasks(BK),Tasks_toBeSolved,Hyps),
    statistics(cputime,[Total2,TimeTaken0]),TimeTaken is TimeTaken0/1000,asserta(time(NewKBoundSofar,TimeTaken)),
    remove_redundant(BK,Hyps,NewBK),
    write('************************Problems solved at ClaBound'),write(NewKBoundSofar),write(':'),
    sep_solvedtasks(Tasks_toBeSolved,Hyps,NewSolvedTasks0,Remaining_Tasks_toBeSolved),write(SolvedTasks-NewSolvedTasks0-Remaining_Tasks_toBeSolved),nl,
    nl,nl,
    append(SolvedTasks,NewSolvedTasks0,NewSolvedTasks),
    it_claBound(Remaining_Tasks_toBeSolved,NewSolvedTasks-NewBK,NewKBoundSofar,KBound).

remove_redundant0(Ms0-Ms2,Ps0-Ps2):-
    %write('inital----'),write(Ms0-Ps0),nl,
    %spy remove_redundant_oneRound,trace,
    remove_redundant_oneRound(Ms0,Ms0-Ms1,Ps0-Ps1),%write('after one round'),write(Ms1-Ps1),nl,
    ((Ms0==Ms1,Ps0==Ps1)->
         Ms0=Ms2,Ps0=Ps2;
     %write('***another round'),write(remove_redundant0(Ms1-Ms2,Ps1-Ps2)),nl,
     remove_redundant0(Ms1-Ms2,Ps1-Ps2)
    ).


% if equilant -- remove the lower ones --since it is high frequency, should be higher in the order
/*remove_redundant_oneRound([],Ms-Ms,Ps-Ps).
remove_redundant_oneRound([metasub(RuleName,[Head|Rest])|RestMetaSubs],Ms0-Ms2,Ps0-Ps2):-
    findall(MetaSub,(member(MetaSub,RestMetaSubs),MetaSub=metasub(RuleName,[Head1|Rest])),Equivelents),write(Equivelents),nl,
    remove_equivelents(Head,Equivelents,Ms0-Ms1,Ps0-Ps1),write(Ms1-Ps1),nl,
    remove_redundant_oneRound(RestMetaSubs,Ms1-Ms2,Ps1-Ps2).
*/

remove_redundant_oneRound([],Ms-Ms,Ps-Ps).
remove_redundant_oneRound([metasub(RuleName,[Head|Rest])|RestMetaSubs],Ms0-Ms2,Ps0-Ps2):-
    remove_redundant_oneRound(RestMetaSubs,Ms0-Ms1,Ps0-Ps1),%write('find eqv'),
    (deleted(metasub(RuleName,[Head|Rest]))->
	 Ms1=Ms2,Ps1=Ps2;
     findall(MetaSub,(member(MetaSub,Ms1),MetaSub=metasub(RuleName,[Head1|Rest]),Head1\==Head),Equivelents),%write(Equivelents),nl,
     remove_equivelents(Head,Equivelents,Ms1-Ms2,Ps1-Ps2)).

/*
remove_redundant_oneRound([],Ms-Ms,Ps-Ps).
remove_redundant_oneRound([metasub(RuleName,[Head|Rest])|RestMetaSubs],Ms0-Ms2,Ps0-Ps2):-
    findall(MetaSub,(member(MetaSub,RestMetaSubs),MetaSub=metasub(RuleName,[Head1|Rest]),Head1\==Head),Equivelents),write(Equivelents),nl,
    remove_equivelents(Head,Equivelents,Ms1-Ms2,Ps1-Ps2),write('oneRound'),write(Ms2-Ps2),nl,
    remove_redundant_oneRound(RestMetaSubs,Ms0-Ms1,Ps0-Ps1),write('find eqv').
*/

remove_equivelents(Head,[],Ms-Ms,Ps-Ps).
remove_equivelents(Head,[E|Equivelents],Ms0-Ms2,Ps0-Ps2):-
    remove_oneEquivelent(Head,E,Ms0-Ms1,Ps0-Ps1),%write('one_eqv'),write(Ms1-Ps1),nl,
    remove_equivelents(Head,Equivelents,Ms1-Ms2,Ps1-Ps2).

remove_oneEquivelent(Head,metasub(RuleName,[Head1|Rest]),Ms0-Ms1,Ps0-Ps1):-
    delete(Ps0,Head1,Ps1), delete(Ms0,metasub(RuleName,[Head1|Rest]),Ms10),asserta(deleted(metasub(RuleName,[Head1|Rest]))),
    replace_with(Head1,Head,Ms10,Ms1).


replace_with(BeingReplaced,Sub,Ms1,Ms2):-
    maplist(replace_with_eachCla(BeingReplaced-Sub),Ms1,Ms2).

replace_with_eachCla(BeingReplaced-Sub,metasub(RuleName,Sub0),metasub(RuleName,Sub1)):-
    maplist(replace_with_eachP(BeingReplaced-Sub),Sub0,Sub1).

replace_with_eachP(BeingReplaced-Sub,BeingReplaced,Sub):-!.
replace_with_eachP(BeingReplaced-Sub,Sub0,Sub0). % keep the original.

gathering(BK,Hyps,Ms,Ps):-
    maplist(gathering0(BK),Hyps,Ms0,Ps0),
    append(Ms0,Ms1),append(Ps0,Ps1), 
    remove_duplicates(Ms1,Ms),remove_duplicates(Ps1,Ps).

gathering0(BK,fail,[],[]):-!. 
gathering0(ps(Ms0,sig(Ps0,_),_,_,_),ps(Ms1,sig(Ps1,_),_,_,_),MsNew,PsNew):-
    append(MsNew,Ms0,Ms1),
    append(PsNew,Ps0,Ps1).


remove_redundant(BK,Hyps,ps(Ms2,sig(Ps2,_),_,0,_)):-
    gathering(BK,Hyps,Ms0,Ps0),%write('Gathered '),write(Ms0-Ps0),nl,   % initiate frequency as 0 
    remove_redundant0(Ms0-Ms1,Ps0-Ps1),retractall(deleted(X)),
    BK=ps(Ms00,sig(Ps00,_),_,_,_),
    append(Ps1,Ps00,Ps2),append(Ms1,Ms00,Ms2).


learn_episode0(CurrentTask,BK,Hyp):-
    episode(CurrentTask,Pos,Neg), length(Pos,P), length(Neg,N),
    clausebound(Bnd),
    interval(1,Bnd,I),
    %timelimit(TimeLimit),
    %statistics(cputime,[Total1,Previous]),%write('----------start'),write(I),nl,
    %time_out(learn_episode(CurrentTask,I,BK,Hyp),TimeLimit,Result),Result=success,
    learn_episode(CurrentTask,I,BK,Hyp),
    %statistics(cputime,[Total2,TimeTaken0]),TimeTaken is TimeTaken0/1000,
    test_seq([CurrentTask],Hyp,Accuracy),
    portray_clause(result(Bnd,CurrentTask,Accuracy,TimeTaken)),
    asserta(result(Bnd,CurrentTask,Accuracy,TimeTaken,Hyp)).


solveOneTask_basedonPresolvedTasks(BK,CurrentTask,Hyp):-
    %write('solving'),write(CurrentTask),nl,
    learn_episode0(CurrentTask,BK,Hyp),!,
    (dependent_check(CurrentTask,BK,Hyp)->
         portray_clause(depended(SolvedTask,CurrentTask));
     %write(dependent_check(CurrentTask,BK,Hyp)),write('failed depend check'),
     true
    ).  
solveOneTask_basedonPresolvedTasks(BK,CurrentTask,fail):-write(CurrentTask),write('Fail'),nl. 


dependent_check(CurrentTask,ps([],sig(Ps1,Cs1),_,Pn1,_),Hyp):-!.
dependent_check(CurrentTask,BK,Hyp):-
    BK=ps(Ms1,sig(Ps1,Cs1),_,Pn1,_),
    Hyp=ps(Ms2,_,_,_,_),
    append(H,Ms1,Ms2),
    element(metasub(RuleName,Sub),H),element(P/Arity,Sub),
    atom_chars(CurrentTask,CurrentTaskP),
    atom_chars(P,PList),
    not(append(CurrentTask,_,PList)),
    not(prim(P/Arity)).


sep_solvedtasks([],[],[],[]).
sep_solvedtasks([Task|Tasks_toBeSolved],[Hyp|Hyps],NewSolvedTasks,Remaining):-
    sep_solvedtasks(Tasks_toBeSolved,Hyps,NewSolvedTasks0,Remaining0),
    (Hyp==fail ->
         NewSolvedTasks=NewSolvedTasks0,Remaining=[Task|Remaining0];
     NewSolvedTasks=[Task|NewSolvedTasks0],Remaining=Remaining0,write(Task)
    ).

%solveTasks_basedOnPresolvedTasks(Tasks_toBeSolved,Tasks_stillRemain,PreSolvedTasks,),

summarise_results(Tasks_toBeSolved):-
    %length(Tasks_toBeSolved,NumTasks),
    %TotalNumPredictingExs is NumTasks*4,
    incremental_accuracy(10,FinalAccuracy,FinalNumTasks,FinalTime).


sumList([],0).
sumList([X|List],Result):-
    sumList(List,PreResult),
    Result is X+PreResult.

incremental_accuracy(0,0,0,0):-!.
incremental_accuracy(Bnd,TotalNumPredicted,TotalNumTasks,TotalTime):-
    PreBnd is Bnd-1,
    incremental_accuracy(PreBnd,PreTotalNumPredicted,PreTotalNumTasks,PreTotalTime),
    findall(NumPredicted,result(Bnd,CurrentTask,[NumPredicted/NumPredicting],TimeTaken,Hyp),NumsPredicted),
    sumList([PreTotalNumPredicted|NumsPredicted],TotalNumPredicted),
    length(NumsPredicted,NumSolvedTask),TotalNumTasks is PreTotalNumTasks+NumSolvedTask,
    findall(TimeTaken,time(Bnd,TimeTaken),Times),sumList(Times,TimeTaken0),  TotalTime is PreTotalTime+TimeTaken0,
    portray_clause(predicted(Bnd,TotalNumPredicted,TotalNumTasks,TotalTime)).

%:-['../tasks_toBeSolved.pl'].
scripts:-
    tasks_toBeSolved(Tasks_toBeSolved),
    %Tasks_toBeSolved=[ep28,ep29],
    %Tasks_toBeSolved=[ep01,ep02,ep03,ep04,ep06,ep08,ep10,ep13,ep15,ep16,ep18,ep19,ep21,ep28,ep29,ep30,ep31], % %ep08                
    %tell('result.txt'),
    init_ps(InitBK),
    it_claBound(Tasks_toBeSolved,[]-InitBK,0,KBound),
    summarise_results(Tasks_toBeSolved),
    nl. %told. 

timelimit(600000). % 1min 

gogogo(Eps, W, I):-
    % load training examples
    format(atom(TrainExs), '../polygons/raw/~w_~d_episodes.pl', [W, I]),
    [TrainExs],
    % load facts
    format(atom(Fact_file), '../polygons/facts/~w_~d_R.pl', [W, I]),
    [Fact_file],
    asserta(clausebound(10)),
    %timelimit(TimeLimit),
    %statistics(cputime,[Total1,Previous]),%write('----------start'),write(I),nl,
    %time_out(learn_seq(Eps,Hyp),TimeLimit,Result),
    learn_seq(Eps,Hyp),
    Hyp=ps(Hyp0,_,_,_),printprog(Hyp0).
    %statistics(cputime,[Total2,TimeTaken0]),TimeTaken is TimeTaken0/1000,

    %tell('oneTime.pl'),
    %write(TimeTaken),write(' '),
    %told,

%    (Result==success->
%	 test_seq(Eps,Hyp),accuracy(Ep,PA);
%     write('%----Time out'),nl,PA=0
%    ).
    %tell('onePA.pl'),
    %write(PA),write(' '),
    %told. 


/*
iterative increasing the clause bound
start with while set of problems to be learned and [] pre-sovled problem 
    set of solve problems

    substract the solved problem and multiply with 


%?? indentifying the equivelence -> reduce the set of functions. 

%advantage of using scripts --> each learning is independently 
*/
