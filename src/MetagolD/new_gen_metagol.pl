temp_vars(0, Return, Temp):-
    Return = Temp, !.
temp_vars(N, Return, Temp):-
    N1 is N - 1,
    append(Temp, [_], Temp_1),
    temp_vars(N1, Return, Temp_1).
temp_vars(N, List):-
    integer(N),
    N >= 0,
    temp_vars(N, List, []).

% TODO::breadth-first search for rules
search_prog(Pred/A, Prog1, COMPLETE_PROGs):-
    temp_vars(A, Vars),
    Atom_v = [Pred | Vars], % variable template for goal predicate
    %write('Target concept ='), writeln(Atom_v), 
    %write('Candidate programs = '), writeln(Prog1),
    % findall MetaSubs
    % metarule(RuleName, MetaSub, (Atom_v:-Body), PreTest, Prog1),
    findall([RuleName, MetaSub, (Atom_v:-Body), PreTest],
	    (metarule(RuleName, MetaSub, (Atom_v:-Body), PreTest, Prog1)),
	    ALL_MR
	   ),
    length(ALL_MR, L),
    %write('Found Metarule templates num: '), writeln(L),
    % findall rules (predicates bind)
    search_all_ms(ALL_MR, ALL_MS, []),
    % abduce all rules
    abduce_all_ms(ALL_MS, Prog1, ALL_PROGs, []),
    search_all_progs(ALL_PROGs, COMPLETE_PROGs, []),
    %print_list_ln(COMPLETE_PROGs),
    length(COMPLETE_PROGs, LL).
    %write('Found Program num: '), writeln(LL).
    % TODO::deduce all programs and test coverage
    % eval_all_programs(Poss, Negs, ALL_PROGs, ALL_MS, Prog2, []).

% TODO::consider all possible combinations
search_pred_for_progs(Pred, [Prog | Progs], Return, Temp):-
    prim(Pred),
    !,
    append(Temp, [Prog], Temp_1),
    search_pred_for_progs(Pred, Progs, Return, Temp_1), !.
search_pred_for_progs(Pred, [], Return, Temp):-
    Return = Temp, !.
search_pred_for_progs(Pred, [Prog | Progs], Return, Temp):-
    search_all_prog(Pred, Prog, ALL_PROGs),
    append(Temp, ALL_PROGs, Temp_1),
    search_pred_for_progs(Pred, Progs, Return, Temp_1).
    
search_all_preds([], Progs, Return):-
    Return = Progs, !.
search_all_preds([P | Ps], Progs, Return):-
    search_pred_for_progs(P, Progs, New_progs, []),
    search_all_preds(Ps, New_progs, Return).

% 
search_all_progs([], Return, Temp):-
    Temp = Return, !.
search_all_progs([Prog | Progs], Return, Temp):-
    Prog = ps([MetaSub | Mss], _, _, _),
    MetaSub = metasub(RuleName, MS),
    findall(P/A, (member(P/A, MS), ground(P/A)), Ps),
    Ps = [_/_ | Body],
    search_all_preds(Body, [Prog], New_progs),
    (New_progs == [Prog] ->
	 (append(Temp, New_progs, Temp_1),
	  search_all_progs(Progs, Return, Temp_1),
	  !
	 );
     (append(New_progs, Progs, Progs_1),
      %length(Progs, L), write("Prog Left "), writeln(L),
      search_all_progs(Progs_1, Return, Temp)
     )
    ).

search_all_prog(Pred/A, Prog1, ALL_PROGs):-
    Prog1 = ps(Mss, _, N, _),
    get_learned_preds(Mss, Learned_list, []),
    (member(Pred/A, Learned_list) ->
	 (ALL_PROGs = [Prog1], !);
     ((prim(Pred/A) ->
	   (ALL_PROGs = [], !);
       (temp_vars(A, Vars),
	Atom_v = [Pred | Vars], % variable template for goal predicate
	%write('Target concept ='), writeln(Atom_v), writeln(N),
	%write('Candidate programs = '), writeln(Prog1),
	% findall MetaSubs
	% metarule(RuleName, MetaSub, (Atom_v:-Body), PreTest, Prog1),
	findall([RuleName, MetaSub, (Atom_v:-Body), PreTest],
		(metarule(RuleName, MetaSub, (Atom_v:-Body), PreTest, Prog1)),
		ALL_MR
	       ),
	length(ALL_MR, L),
	%write('Found Metarule templates num: '), writeln(L),
	% findall rules (predicates bind)
	search_all_ms(ALL_MR, ALL_MS, []),
	% abduce all rules
	abduce_all_ms(ALL_MS, Prog1, ALL_PROGs_, []),
	list_to_set(ALL_PROGs_, ALL_PROGs)
       )
      )
     )
    ).

% get all learned predicates in metasubs
get_learned_preds([], Return, Temp):-
    Return = Temp, !.
get_learned_preds([Ms | Mss], Return, Temp):-
    Ms = metasub(RuleName, MS),
    MS = [Pred | _],
    append(Temp, [Pred], Temp_1),
    get_learned_preds(Mss, Return, Temp_1).

% evaluate all programs
eval_all_programs(Poss, Negs, [], [], Prog2, []):-
    Prog2 = [], !.
eval_all_programs(Poss, Negs, [], [], Prog2, Temp):-
    Temp = [Prog2 | _],
    !.
eval_all_programs(Poss, Negs, [Ps | Pss], [Ms | Mss], Prog2, Temp):-
    eval_progs(Poss, Negs, Ps, Ms, Best_Ps, []),
    append(Temp, [Best_Ps], Temp_1),
    eval_all_programs(Poss, Negs, Pss, Mss, Prog2, Temp_1).

eval_progs(Poss, Negs, [], [], Prog2, Temp):-
    Prog2 = Temp, !.
eval_progs(Poss, Negs, [P | Ps], [M | Ms], Progs, Temp):-
    eval_prog(Poss, Negs, P, M, Best_P),
    append(Temp, [Best_P], Temp_1),
    eval_progs(Poss, Negs, Ps, Ms, Prog2, Temp_1).

% evaluate a program
eval_prog(Poss, Negss, Prog, MetaSub, Best_prog):-
    % TODO:: prove program and evaluate the foilgain
    (d_search_start(Prog, MetaSub, Prog2) ->
	 (Prog2 = Best_prog);
     Best_prog = []
    ).

% foil gain
foil_gain(_, _, 0, _, Gain):-
    Gain = -1000000, !.
foil_gain(P0, N0, P1, N1, Gain):-
    Gain is P1*(log(P1/(P1 + N1)) - log(P0/(P0 + N0))).

% search for all metasubs
search_all_ms([], ALL_MS, ALL_MS):-
    !.
search_all_ms([[RuleName, MetaSub, (Atom_v:-Body), PreTest] | MRs], ALL_MS, Temp):-
    findall([RuleName, MetaSub, (Atom_v:-Body), PreTest],
	    (call(PreTest), constraint_body(Body, [])),
	    PPS
	   ),
    length(PPS, LL),
    %write('Found MetaSub num: '), writeln(LL),
    %print_all_ms(PPS),
    append(Temp, [PPS], Temp_1),
    search_all_ms(MRs, ALL_MS, Temp_1).

constraint_body([], _).
constraint_body([B | Bs], Temp):-
    B = Atom-_,
    Atom = [Pred | _],
    arity(Atom, A),
    (member(Pred/A, Temp) ->
	 (fail, !);
     (prim(Pred/A) ->
	  (append(Temp, [Pred/A], Temp_1),
	   constraint_body(Bs, Temp_1), 
	   !
	  );
      (A =< 2 ->
	   (append(Temp, [Pred/A], Temp_1),
	    constraint_body(Bs, Temp_1), 
	    !
	   );
       fail
      )
     )
    ).

abduce_mss([], _, ALL_PROGs, ALL_PROGs):-
    !.
abduce_mss([[RuleName, MetaSub, _, _] | MRs], Prog, ALL_PROGs, Temp):-
    (abduce(metasub(RuleName, MetaSub), Prog, Prog2) -> 
	 (append(Temp, [Prog2], Temp_1), !);
     Temp_1 = Temp
    ),
    abduce_mss(MRs, Prog, ALL_PROGs, Temp_1).

abduce_all_ms([], _, ALL_PROGs, ALL_PROGs):-
    !.
abduce_all_ms([MSL | MSs], Prog, ALL_PROGs, Temp):-
    abduce_mss(MSL, Prog, Progs, []),
    append(Temp, Progs, Temp_1),
    abduce_all_ms(MSs, Prog, ALL_PROGs, Temp_1).
    
% print all metasubs
print_all_ms([]):-
    nl, !.
print_all_ms([[RuleName, MetaSub, _, _] | MRs]):-
    printprog([metasub(RuleName, MetaSub)]),
    print_all_ms(MRs).

test_new(Eps, W, BK):-
    format(atom(TrainExs), '../polygons/raw/~w_tr_episodes.pl', [W]),
    format(atom(TestExs), '../polygons/raw/~w_te_episodes.pl', [W]),
    [TrainExs],
    % load facts
    format(atom(Fact_file), '../polygons/facts/~w_bk.pl', [BK]),
    [Fact_file],
    asserta(clausebound(3)),
    test_learn_seq(Eps, Hyp),
    unload_file(TrainExs),
    test_hypothesis_rules(Eps, Hyp, TestExs, 4),
    unload_file(Fact_file).

test_hypothesis_rules([], _, _, _).
test_hypothesis_rules([E | Es], Hyp, TestExs, N):-
    [TestExs],
    assert_all_rules(Hyp),
    episode(E, Pos, Neg), length(Pos, NumP), length(Neg, NumN),
    append(Pos, Neg, All_ex),
    query_for_all_ex(All_ex, N, Pos_, Neg_, [], []),
    intersection(Pos, Pos_, TP_),
    intersection(Neg, Neg_, TN_),
    intersection(Neg, Pos_, FP_),
    intersection(Pos, Neg_, FN_),
    length(TP_, TP),
    length(TN_, TN),
    length(FP_, FP),
    length(FN_, FN),
    Acc is (TP + TN)/(NumP + NumN),
    F1 is (2*TP)/(2*TP + FP + FN),
    retract_all_rules(Hyp),
    !,
    unload_file(TestExs),
    write("Accuracy: "), writeln(Acc),
    write("F1 score: "), writeln(F1),
    test_hypothesis_rules(Es, Hyp, TestExs, N).

query_for_all_ex([], _, Pos_, Neg_, Pos_, Neg_).
query_for_all_ex([E | Exs], N, Pos_, Neg_, Temp_p, Temp_n):-
    (query_for_ex(E, N, 0, N) ->
	 (append(Temp_p, [E], Temp_p_1), 
	  Temp_n_1 = Temp_n,
	  !);
     (append(Temp_n, [E], Temp_n_1),
      Temp_p_1 = Temp_p
     )
    ),
    query_for_all_ex(Exs, N, Pos_, Neg_, Temp_p_1, Temp_n_1).

query_for_ex(E, N, P_num, T):-
    N < 0,
    T > 0,
    P_num >= ceil((T + 1)/2),
    !.
query_for_ex(E, N, P_num, T):-
    N >= 0,
    T > 0,
    E = [Pred | Args],
    dup_args(Args, N, D_args, []),
    Goal =.. [Pred | D_args],
    (call(Goal) ->
	 (P_num_1 is P_num + 1, !);
     P_num_1 is P_num
    ),
    N1 is N - 1,
    query_for_ex(E, N1, P_num_1, T).

dup_args([], _, D_args, D_args).
dup_args([A | As], N, D_args, Temp):-
    concat(A, '_', A_),
    concat(A_, N, A_N),
    append(Temp, [A_N], Temp_1),
    dup_args(As, N, D_args, Temp_1).

test_new_multi(Eps, W, I):-
    format(atom(TrainExs), '../polygons/raw/~w_~d_episodes.pl', [W, I]),
    [TrainExs],
    % load facts
    format(atom(Fact_file), '../polygons/facts/~w_~d_R.pl', [W, I]),
    [Fact_file],
    asserta(clausebound(3)),
    test_learn_seq(Eps,Hyp).

test_learn_seq(Eps, Rules):-
    init_ps(P0),
    test_learn_seq(Eps, Eps, P0, Rules).

test_learn_seq(_, [], B, B):-
    !.
test_learn_seq(Eps, [E | T], BK, Rules):-
    episode(E, Pos, Neg), % length(Pos,P), length(Neg,N),
    clausebound(Bnd), %(clausebound(Bnd);(Bnd is floor(log(P+N)/log(2)))),
    interval(1, Bnd, I),
    test_learn_episode(Eps, E, I, BK, Hyp1),
    test_learn_seq(Eps, T, Hyp1, Rules), !.
test_learn_seq(_, [E | _], _, _):-
    episode(E, Pos, Neg), length(Pos, P), length(Neg, N),
    (clausebound(Bnd); (Bnd is floor(log(P+N)/log(2)))),
    write('EPISODE '), write(E),
    write(': NO COMPRESSION FOR CLAUSE BOUND UP TO '), write(Bnd), nl, nl,
    !, fail.

% my learn episode with coverage
test_learn_episode(Eps, Ep, Int, ps(Ms1, sig(Ps1, Cs1), _, _), Rules):-
    write('EXAMPLE EPISODE: '), write(Ep), nl, nl,
    name(Ep, EpChars),
    episode(Ep, Pos, Neg), Pos = [[Ep|Px]|_], arity([Ep|Px], Epa),
    length(Pos, Num_pos),
    length(Neg, Num_neg),
    learn_episode_bound(Int, Int, Pos, Neg, Ep, EpChars, Px, Epa, Ms1, Ps1, Cs1, Best_rules, []-(-1000000)),
    writeln("FOUND BEST PROGRAM:"),
    Best_rules = Rules-_,
    print_list_ln(Rules).
    %element(N, Int), peano(N, Lim1),
    %write('TRY CLAUSE BOUND: '), write(N), nl,
    %element(M, Int), M =< N, M1 is M - 1, % peano(M1,Lim2),
    %%---***M1 is N-1, peano(M1,Lim2),
    %write('TRY NEW PREDICATE BOUND: '), write(M1), nl,
    %addnewpreds(EpChars, 0, M1, Ps1, Ps3),append(NewPreds, Ps1, Ps3),
    %metaruless(Mss),
    %element(MetaRules, Mss),
    %write('TRY METARULE SET: '), write(MetaRules), nl,
    %add_prepost(Pos, Pos1), add_prepost(Neg, Neg1),
    %search_prog(Ep/Epa, ps(Ms1, sig([Ep/Epa|Ps3],Cs1), Lim1, MetaRules), Candidates),
    %learn_param_of_progs(Candidates, Pos, Neg, Learned, []-(-1000000)),
    %!.

learn_episode_bound([], _, _, _, _, _, _, _, _, _, _, Best_rules, Temp):-
    Best_rules = Temp, !.
learn_episode_bound([N | Ns], Int, Pos, Neg, Ep, EpChars, Px, Epa, Ms1, Ps1, Cs1, Best_rules, Temp):-
    peano(N, Lim1),
    write('TRY CLAUSE BOUND: '), write(N), nl,
    findall(M, (element(M, Int), M =< N), Ms),
    learn_episode_invent_pred_bound(Ms, Int, Pos, Neg, Ep, EpChars, Px, Epa, Ms1, Ps1, Cs1, Lim1, Learned, []-(-1000000)),
    Learned = _-Gain,
    (Gain == 'max' ->
	 (Best_rules = Learned, !);
     (Temp = _-G,
      (Gain > G ->
	   (Temp_1 = Learned, !);
       Temp_1 = Temp
      ),
      learn_episode_bound(Ns, Int, Pos, Neg, Ep, EpChars, Px, Epa, Ms1, Ps1, Cs1, Best_rules, Temp_1)
     )
    ).

learn_episode_invent_pred_bound([], _, _, _, _, _, _, _, _, _, _, _, Best_rules, Temp):-
    Best_rules = Temp, !.
learn_episode_invent_pred_bound([M | Ms], Int, Pos, Neg, Ep, EpChars, Px, Epa, Ms1, Ps1, Cs1, Lim1, Best_rules, Temp):-
    M1 is M - 1,
    write('TRY NEW PREDICATE BOUND: '), write(M1), nl,
    addnewpreds(EpChars, 0, M1, Ps1, Ps3),
    metaruless(Mss),
    element(MetaRules, Mss),
    write('TRY METARULE SET: '), write(MetaRules), nl,
    add_prepost(Pos, Pos1), add_prepost(Neg, Neg1),
    search_prog(Ep/Epa, ps(Ms1, sig([Ep/Epa|Ps3],Cs1), Lim1, MetaRules), Candidates),
    learn_param_of_progs(Candidates, Pos, Neg, Learned, []/[]-(-1000000), []-(-1000000), []),
    compute_program_gain(Learned, Pos, Neg, Gain),
    (Gain == 'max' ->
	 (Best_rules = Learned-Gain, !);
     (writeln('================='),
      print_list_ln(Learned),
      writeln('================='),
      Temp = _-G,
      (Gain > G ->
	   (Temp_1 = Learned-Gain, !);
       Temp_1 = Temp
      ),
      learn_episode_invent_pred_bound(Ms, Int, Pos, Neg, Ep, EpChars, Px, Epa, Ms1, Ps1, Cs1, Lim1, Best_rules, Temp_1)
     )
    ).

compute_program_gain(Rules, Pos, Neg, Gain):-
    Pos = [Ex | _],
    Ex = [Pred | Args],
    length(Args, A),
    assert_all_rules(Rules),
    % compute coverage,
    temp_vars(A, Target),
    append([Pred], Target, Call_str),
    %writeln('QUERY!'), writeln(Call_str),
    callatom_binds(Call_str, Target, All_results),
    %writeln('RESULT!'), print_list_ln(All_results),
    reconstruct_proved_atoms(Pred, All_results, Proved_atoms_, []),
    list_to_set(Proved_atoms_, Proved_atoms),
    intersection(Proved_atoms, Pos, Proved_Pos),
    intersection(Proved_atoms, Neg, Proved_Neg),
    length(Proved_Pos, P1),
    length(Proved_Neg, N1),
    length(Pos, P0),
    length(Neg, N0),
    ((P1 == P0, N1 == 0) ->
	 (Gain = 'max', !);
     foil_gain(P0, N0, P1, N1, Gain)
    ),
    retract_all_rules(Rules).

learn_param_of_progs([], Pos, Neg, Learned, Temp, Learned_temp-LGain, Usable_temp):-
    Temp = Rules/Cov-Gain,
    intersection(Cov, Pos, Proved_Pos),
    intersection(Cov, Neg, Proved_Neg),
    length(Proved_Pos, P1),
    length(Pos, P0),
    ((P1 == 1; Gain =< LGain) -> %, P0 > 1
	 (Learned = Learned_temp, !);
     (append(Rules, Learned_temp, Learned_temp_1),
      list_delete(Pos, Cov, Pos_1),
      (Pos_1 == [] ->
	   (Learned = Learned_temp_1, !);
       learn_param_of_progs(Usable_temp, Pos, Neg, Learned, []/[]-(-1000000), Learned_temp_1-Gain, [])
      )
     )
    ),
    !.
learn_param_of_progs([P | Progs], Pos, Neg, Learned, Temp, Learned_temp-LGain, Usable_temp):-
    P = ps(Mss, _, _, _),
    get_clause_and_para(Mss, Clause, Para, [], []),
    %writeln('=============='),
    %writeln(P),
    %print_list_ln(Clause),
    %print_list(Para),
    length(Mss, M),
    M1 is M*2,
    get_new_rules(Mss, New_rules, [], [], M1),
    %print_list_ln(New_rules),
    % assert new rule and evaluate them
    Pos = [Ex | _],
    Ex = [Pred | _],
    arity(Ex, A),
    learn_param_of_prog(New_rules, Learned_temp, Pred/A, Pos, Neg, Best_rules/Cov, Gain),
    %writeln(Best_rules/Cov),
    (not(Best_rules == []) ->
	 (append(Usable_temp, [P], Usable_temp_1), !);
     Usable_temp_1 = Usable_temp
    ),
    Temp = _-G,
    (Gain > G ->
	 (Temp_1 = Best_rules/Cov-Gain, !);
     Temp_1 = Temp
    ),
    learn_param_of_progs(Progs, Pos, Neg, Learned, Temp_1, Learned_temp-LGain, Usable_temp_1).

learn_param_of_prog(New_rules, Learned, Pred/A, Pos, Neg, Best_rules/Cov, Best_gain):-
    assert_and_get_head_para(New_rules, Pred/A, Target, Para),
    %print_list(Target),
    %print_list(Para),
    length(Para, PL),
    temp_vars(A, T_var),
    temp_vars(PL, P_var),
    append([Pred], T_var, Call_para_1),
    append(Call_para_1, P_var, Call_para),
    callatom_binds(Call_para, P_var, All_paras_),
    !,
    list_to_set(All_paras_, All_paras),
    (not(All_paras == []) ->
	 (writeln('Searching best parameters for'),
	  print_list_ln(New_rules),
	  assert_all_rules(Learned),
	  search_for_best_para(All_paras, Pred/A, Pos, Neg, Best_para/Cov_, Best_gain, _, -1000000, 0),
	  retract_all_rules(Learned),
	  %writeln('BEST PARA BEST GAIN!'),
	  %writeln(Best_para),
	  %writeln(Best_gain),
	  %writeln(embed_parameters(New_rules, Pred/A, Best_para, Best_rules, [])),
	  (not(ground(Best_para)) ->
	       (Best_rules = [],
		Cov = [],
		Best_gain = -1000000,
		!);
	   (embed_parameters(New_rules, Pred/A, Best_para, Best_rules, []),
	    Cov = Cov_,
	    print_list_ln(Best_rules)
	   )
	  ),
	  !
	 );
     (Best_rules = [],
      Cov = [],
      Best_gain = -1000000
     )
    ),
    retract_all_rules(New_rules).

embed_parameters([], _, _, Best_rules, Temp):-
    Best_rules = Temp, !.
embed_parameters([R | Rs], Pred/A, Best_para, Best_rules, Temp):-
    R = (Head :- Body),
    Head =.. Head_list,
    Head_list = [Pred_1 | Head_args],
    (Pred == Pred_1 ->
	 (temp_vars(A, New_arg),
	  append(New_arg, Best_para, New_body_1),
	  atomic_concat(Pred, '_0', New_body_pred),
	  append([New_body_pred], New_body_1, New_body_list),
	  append([Pred], New_arg, New_head_list),
	  New_head =.. [New_body_pred | Head_args],
	  New_rule_head =.. New_head_list,
	  New_rule_body =.. New_body_list,
	  %New_rule_body =.. [',', New_rule_body_1, !],
	  append(Temp, [(New_head :- Body)], Temp_1),
	  C = (New_rule_head :- New_rule_body),
	  numbervars(C, 0, _),
	  append(Temp_1, [C], Temp_2),
	  embed_parameters(Rs, Pred/A, Best_para, Best_rules, Temp_2),
	  !
	 );
     (append(Temp, [R], Temp_1),
      embed_parameters(Rs, Pred/A, Best_para, Best_rules, Temp_1)
     )
    ).
  
search_for_best_para(_, _, _, _, Best_para, Best_gain, Temp_para, Temp_gain, 3):-
    Best_para = Temp_para,
    Best_gain = Temp_gain,
    !.
search_for_best_para([], _, _, _, Best_para, Best_gain, Temp_para, Temp_gain, _):-
    Best_para = Temp_para, 
    Best_gain = Temp_gain,
    !.
search_for_best_para([Para | Ps], Pred/A, Pos, Neg, Best_para, Best_gain, Temp_para, Temp_gain, Single_time):-
    temp_vars(A, Target),
    append([Pred], Target, Call_str_1),
    callatom_binds(Call_str_1, Target, All_results_1),
    append(Call_str_1, Para, Call_str),
    %writeln('QUERY!'), writeln(Call_str),
    callatom_binds(Call_str, Target, All_results_2),
    append(All_results_1, All_results_2, All_results),
    %writeln('RESULT!'), print_list_ln(All_results),
    reconstruct_proved_atoms(Pred, All_results, Proved_atoms_, []),
    list_to_set(Proved_atoms_, Proved_atoms),
    list_to_set(All_results_2, Proved_new),
    length(Proved_new, Proved_len),
    (Proved_len == 1 ->
	 (Single_time_1 is Single_time + 1, !);
     Single_time_1 = Single_time
    ),
    intersection(Proved_atoms, Pos, Proved_Pos),
    intersection(Proved_atoms, Neg, Proved_Neg),
    length(Proved_Pos, P1),
    length(Proved_Neg, N1),
    length(Pos, P0),
    length(Neg, N0),
    foil_gain(P0, N0, P1, N1, Gain),
    %writeln(Gain),
    (Gain > Temp_gain ->
	 (Temp_para_1 = Para/Proved_atoms,
	  Temp_gain_1 = Gain,
	  !
	 );
     (Temp_para_1 = Temp_para,
      Temp_gain_1 = Temp_gain
     )
    ),
    search_for_best_para(Ps, Pred/A, Pos, Neg, Best_para, Best_gain, Temp_para_1, Temp_gain_1, Single_time_1).

reconstruct_proved_atoms(_, [], Proved_atoms, Temp):-
    Proved_atoms = Temp, !.
reconstruct_proved_atoms(Pred, [Arg | Args], Proved_atoms, Temp):-
    append(Temp, [[Pred | Arg]], Temp_1),
    reconstruct_proved_atoms(Pred, Args, Proved_atoms, Temp_1).

assert_and_get_head_para([], _, _, _).
assert_and_get_head_para([R | Rs], Pred/A, Target, Para):-
    varnumbers(R, R_1),
    !,
    assertz((R_1)),
    R = (Head:-_),
    Head =.. Head_list,
    Head_list = [Head_pred | Head_args],
    ((Pred == Head_pred, Rs == []) ->
	 (listsplit(Head_args, Target, Para, A),
	  assert_and_get_head_para(Rs, Pred/A, Target, Para),
	  !
	 );
     assert_and_get_head_para(Rs, Pred/A, Target, Para)
    ).

assert_all_rules([]).
assert_all_rules([R | Rs]):-
    varnumbers(R, R_1),
    !,
    assertz(R_1),
    assert_all_rules(Rs).

retract_all_rules([]).
retract_all_rules([R | Rs]):-
    varnumbers(R, R_1),
    !,
    retract(R_1),
    retract_all_rules(Rs).

% split list with N headers
listsplit(List, Head, Tail, N):-
    integer(N),
    N >= 0,
    length(List, L),
    N =< L,
    listsplit(List, Head, Tail, N, []).
listsplit(List, Head, Tail, 0, TempH):-
	Tail = List,
	Head = TempH,
	!.
listsplit([H | T], Head, Tail, N, TempH):-
    append(TempH, [H], TempH_1),
    N1 is N - 1,
    listsplit(T, Head, Tail, N1, TempH_1).

get_clause_and_para([], Clauses, Parameters, Temp_C, Temp_P):-
    Clauses = Temp_C,
    Parameters = Temp_P,
    !.
get_clause_and_para([metasub(RuleName, MetaSub) | MIs], Clauses, Parameters, Temp_C, Temp_P):-
    metarule(RuleName, MetaSub, C, _, _),
    numbervars(C, 0, _),
    all_free(MetaSub, Para, []),
    clause_to_term(C, Clause),
    append(Temp_C, [Clause], Temp_C_1),
    append(Temp_P, [Para], Temp_P_1),
    get_clause_and_para(MIs, Clauses, Parameters, Temp_C_1, Temp_P_1),
    !.

get_new_rules(_, [], _, _, 0).
get_new_rules([], Rules, _, Temp, _):-
    Rules = Temp, !.
get_new_rules([Ms | MIs], Rules, Processed, Temp, M):-
    Ms = metasub(RuleName, MetaSub),
    % get head and body
    findall(P/A, (member(P/A, MetaSub), ground(P/A)), Ps),
    Ps = [Head | Body],
    % if body only contains primitives and processed preds, continue
    (not_all_prim_and_processed(Body, Processed) ->
		     (M1 is M - 1,
		      append(MIs, [Ms], MIs_1),
		      get_new_rules(MIs_1, Rules, Processed, Temp, M1),
		      !
		     );
     (metarule(RuleName, MetaSub, C, _, _),    
      numbervars(C, 0, _),
      all_free(MetaSub, Para, []),
      % TODO:: embed all paras
      embed_free_vars(C, Processed, Para, R, NFree),
      append(Processed, [Head-NFree], Processed_1),
      append(Temp, [R], Temp_1),
      M1 is M - 1,
      get_new_rules(MIs, Rules, Processed_1, Temp_1, M1)
     )
    ),
    !.

embed_free_vars((Head :- Body), Processed_preds, Before_free, Return, After_free):-
    getatoms_with_free_vars(Body, Processed_preds, Body_term_list, Free_vars, [], []),
    numbervars(Body_term_list, 52, _),
    append(Before_free, Free_vars, After_free),
    getatom_with_free_vars(Head, After_free, Head_term),
    list_to_term(Body_term_list, Body_term),
    Return = (Head_term:-Body_term), 
    !.

getatoms_with_free_vars([], _, Body_term_list, Free_vars, Temp, Temp_free_vars):-
    Body_term_list = Temp, 
    Free_vars = Temp_free_vars,
    !.
getatoms_with_free_vars([A | As], Processed_preds, Body_term_list, Free_vars, Temp, Temp_free_vars):-
    getatom_cond_with_free_vars(A, Processed_preds, New_term, F_vars),
    append(Temp, [New_term], Temp_1),
    append(Temp_free_vars, F_vars, Temp_free_vars_1),
    getatoms_with_free_vars(As, Processed_preds, Body_term_list, Free_vars, Temp_1, Temp_free_vars_1).

getatom_with_free_vars(List, Free_vars, Return):-
    append(List, Free_vars, New_list),
    Return =.. New_list.

getatom_cond_with_free_vars(List-_, Processed_preds, Return, New_vars):-
    arity(List, A),
    List = [Pred | _],
    find_pred_with_free_vars(Pred/A, Processed_preds, Free_vars),
    length(Free_vars, N),
    temp_vars(N, New_vars),
    append(List, New_vars, New_list),
    Return =.. New_list.

find_pred_with_free_vars(_, [], []).
find_pred_with_free_vars(P, _, Return):-
    prim(P),
    Return = [], 
    !.
find_pred_with_free_vars(P, [Pred | Pros], Return):-
    Pred = P-Return ->
	(true, !);
    find_pred_with_free_vars(P, Pros, Return).

not_all_prim_and_processed([], _):-
    fail, !.
not_all_prim_and_processed([P | Ps], Pro):-
    not(prim(P)),
    not_processed(P, Pro), !.
not_all_prim_and_processed([P | Ps], Pro):-
    not_all_prim_and_processed(Ps, Pro).

not_processed(_, []).
not_processed(P, [P1-_| T]):-
    P == P1 ->
	(fail, !);
    not_processed(P, T).

all_free([], Vars, Vars).
all_free([H | T], Vars, Temp):-
    not(H = _/_) ->
	(append(Temp, [H], Temp_1),
	 all_free(T, Vars, Temp_1),
	 !
	);
    all_free(T, Vars, Temp).

clause_to_term((Head :- Body), Clause):-
    getatoms(Body, Body_term_list, []),
    getatom(Head, Head_term),
    list_to_term(Body_term_list, Body_term),
    Clause = (Head_term:-Body_term), 
    !.

term_list_str([T], Str, Temp):-
    term_string(T, S),
    atom_concat(Temp, S, Str), 
    !.
term_list_str([T | Ts], Str, Temp):-
    term_string(T, S),
    atom_concat(Temp, S, Temp_1),
    atom_concat(Temp_1, ',', Temp_2),
    term_list_str(Ts, Str, Temp_2).

list_to_term(Term_list, Body_term):-
    term_list_str(Term_list, Str_1, ''),
    atom_concat('(', Str_1, Str_2),
    atom_concat(Str_2, ')', Str),
    term_string(Body_term, Str).

getatom_cond(List-_, Return):-
    getatom(List, Return).

getatom(List, Atom):-
    Atom =.. List.

getatoms([], Return, Temp):-
    Return = Temp, !.
getatoms([A | As], Return, Temp):-
    getatom_cond(A, Atom), 
    append(Temp, [Atom], Temp_1),
    getatoms(As, Return, Temp_1), !.

% my call atom all, find all possible bindings
callatom_binds(Args, Vars, New_binds):-
    not(ground(Args)),
    !,
    Goal =.. Args,
    %write('CALLATOM PROVING '), write(Goal), nl, 
    !, 
    findall(Vars, call(Goal), New_binds), !.

% my meta rules
metarule1(property_precon,[P/1,Q/1,R/Ra|V],
	  ([P,X] :- [[Q,X]-true,B-true]),Pre,Prog) :-
    B = [R, X|V],
    arity(B, Ra),
    Pre=(pred_above(P/1,Q/1,Prog), pred_above(P/1,R/Ra,Prog)).
metarule1(property_chain,[P/1,Q/Qa,R/Ra|UV],([P,X] :- [A-Post, B-true]),Pre,Prog) :-   
    A=[Q,X,Y|U], B=[R,Y|V],
    arity(A,Qa), arity(B,Ra), append(U,V,UV),
    Pre=(pred_above(P/1,Q/Qa,Prog), pred_above(P/1,R/Ra,Prog)),
    obj_gt(ObjGT),
    Post =.. [ObjGT,X,Y,Prog].
    
% =============================
% Modefied from Richard A. O'Keefe's code by daiwz
% http://swi-prolog.996271.n3.nabble.com/SWIPL-Undo-numbervars-3-td210.html
% =============================
varnumbers(T0, T) :- 
    varnumbers(T0, T, '$VAR', 0). 

varnumbers(T0, T, N0) :- 
    varnumbers(T0, T, '$VAR', N0). 

varnumbers(T0, T, F, N0) :- 
    integer(N0), 
    N1 is N0 - 1, 
    max_var_number_(T0, F, N1, N), 
    Number_Of_Variables is N - N1, 
    functor(Vars, '$VAR', Number_Of_Variables), 
    varnumbers_(T0, T, F, N1, Vars). 

max_var_number_(T0, F, N1, N) :- 
    (   var(T0) -> N = N1 
	;   functor(T0, Symbol, Arity), 
            (   Arity < 1 -> N = N1 
		;   Arity = 1 -> 
			arg(1, T0, A0), 
			(   Symbol == F, integer(A0) -> 
				(   A0 > N1 -> N = A0	    
				    ;/* A0=< N1 */ N = N1 
				) 
			    ;/* not a $VAR(N) term */ 
			    max_var_number_(A0, F, N1, N) 
			) 
		;   max_var_number_(T0, F, N1, N, Arity) 
            ) 
    ). 

max_var_number_(T0, F, N1, N, I) :- 
    arg(I, T0, A0), 
    (   I > 1 -> 
            max_var_number_(A0, F, N1, N2), 
            J is I - 1, 
            max_var_number_(T0, F, N2, N, J) 
	;   max_var_number_(A0, F, N1, N) 
    ). 

varnumbers_(T0, T, F, N1, Vars) :- 
    (   var(T0) -> T = T0 
	;   functor(T0, Symbol, Arity), 
            (   Arity < 1 -> T = T0 
		;   (Arity = 1, Symbol = F) -> 
			arg(1, T0, A0), 
			(  integer(A0), A0 > N1 -> 
				I is A0 - N1, 
				arg(I, Vars, T) 
			    ;   arg(1, T0, AAAA), 
				varnumbers_(A0, AAAA, F, N1, Vars) 
			) 
		;   functor(T, Symbol, Arity), 
		    varnumbers_(T0, T, F, N1, Vars, Arity) 
            ) 
    ). 

varnumbers_(T0, T, F, N1, Vars, I) :- 
    arg(I, T0, A0), 
    arg(I, T,  AAAA), 
    (   I > 1 -> 
            varnumbers_(A0, AAAA, F, N1, Vars), 
            J is I - 1, 
            varnumbers_(T0, T, F, N1, Vars, J) 
	;   varnumbers_(A0, AAAA, F, N1, Vars) 
    ).
