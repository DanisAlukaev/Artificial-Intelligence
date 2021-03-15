get_cells([], Cells, Result) :-
	Result = Cells.


get_cells([Cell|Tail], Cells, Result) :-
	Cell = (CurrentCell, _, _, _),
	append(Cells, [CurrentCell], CellsUpdated),
	get_cells(Tail, CellsUpdated, Result).


initialize_variables_a_star():-
	distance_home([0, 0], DistanceHome),
	assert(open([([0, 0], 0, DistanceHome, [0, 0])])),
	assert(closed([])).


process_cell(EvaluatedCurrentCell, NextCell) :-
	%% Get the closed list.
	closed(Closed),
	%% Check the candidate cell is not closed.
	get_cells(Closed, [], ClosedCells),
	write("ClosedCells: "), write(ClosedCells), nl,
	write("NextCell: "), write(NextCell), nl,

	member(NextCell, ClosedCells),
	write(1),
	nth0(IndexEvaluatedNextCell, ClosedCells, NextCell),
	%% Get an entry with next cell.
	nth0(IndexEvaluatedNextCell, Closed, EvaluatedNextCell),
	EvaluatedNextCell = (NextCell, CostNextCell, _, _),

	EvaluatedCurrentCell = (_, CostCurrentCell, _, _),
	ExpectedCost is CostCurrentCell + 1,
	ExpectedCost >= CostNextCell.


process_cell(EvaluatedCurrentCell, NextCell) :-
	write("here"), nl,
	EvaluatedCurrentCell = (CurrentCell, CostCurrentCell, _, _),
	ExpectedCost is CostCurrentCell + 1,
	distance_home(NextCell, DistanceHome),
	PriorityNextCell is ExpectedCost + DistanceHome,
	EvaluatedNextCell = (NextCell, ExpectedCost, PriorityNextCell, CurrentCell),
	open(Open),
	get_cells(Open, [], OpenCells),
	(
		\+ member(NextCell, OpenCells) -> 
			append(Open, [EvaluatedNextCell], OpenUpdated),
			sort(2, @=<, OpenUpdated, SortedOpenUpdated),
			retractall(open(_)),
			assert(open(SortedOpenUpdated))
			; true
	).


process_candidate([], _).


process_candidate([Candidate|Tail], EvaluatedCurrentCell) :-
	(
		%% Check the candidate cell is not blocked.
		not_infected(Candidate) -> process_cell(EvaluatedCurrentCell, Candidate)
		; true
	),
	process_candidate(Tail, EvaluatedCurrentCell).


search_a_star_v1() :-
	open(Open),
	length(Open, LengthOpen), LengthOpen == 0, !.

%% search_a_star_v1() :-
%% %% Get the open and closed lists.
%% 	open(Open),
%% 	nth0(0, Open, EvaluatedCurrentCell),
%% 	EvaluatedCurrentCell = (CurrentCell, _, _, _),
%% 	is_home(CurrentCell), 
%% 	write("Home "), write(CurrentCell), nl, !.


search_a_star_v1() :-
	%% Get the open and closed lists.
	open(Open),
	closed(Closed),
	write("Open: "), write(Open),nl,
	write("Closed: "), write(Closed), nl,
	EvaluatedCurrentCell = (CurrentCell, _, _, _),

	%% Pop the most valuable cell.
	nth0(0, Open, EvaluatedCurrentCell),
	delete(Open, EvaluatedCurrentCell, OpenPop),
	retractall(open(_)),
	assert(open(OpenPop)),
	
	%% Push current to closed
	append(Closed, [EvaluatedCurrentCell], ClosedUpdated),
	retractall(closed(_)),
	assert(closed(ClosedUpdated)),

	%% Treat all neighbouring locations.
	setof(NextCell, get_adjacent(CurrentCell, NextCell), Candidates),
	write("Cand "), write(Candidates), nl,
	process_candidate(Candidates, EvaluatedCurrentCell),


	%% Start again.
	search_a_star_v1().


restore_path(CurrentCell, Result, Path) :-
	agent(CurrentCell),
	append(Result, [CurrentCell], ReversedPath),
	reverse(ReversedPath, Path).

restore_path(CurrentCell, Result, Path) :-
	closed(Closed),
	get_cells(Closed, [], ClosedCells),
	nth0(IndexCurrentCell, ClosedCells, CurrentCell),
	nth0(IndexCurrentCell, Closed, EvaluatedCurrentCell),
	EvaluatedCurrentCell = (_, _, _, ParentCurrentCell),
	append(Result, [CurrentCell], NewResult),
	restore_path(ParentCurrentCell, NewResult, Path).


a_star() :-
	search_a_star_v1(),
	home(HomePosition),
	closed(Closed),
	get_cells(Closed, [], ClosedCells),
	member(HomePosition, ClosedCells),

	restore_path(HomePosition, [], Path),
	length(Path, LengthPath),
	StepsWithoutFirstCell is LengthPath - 1,
	retractall(optimal(_)),
  	assert(optimal(Path)),
	write("Win."), nl, write("Number of steps: "), write(StepsWithoutFirstCell), nl, write("Path: "), write(Path), nl,
	once(map_with_path()), !.


a_star() :-
	% In case no path was found, the agent has lost.
	% Set number of steps to zero and path to empty list.
	write("Lost."), nl.


start_a_star():-
	write("A* algorithm:"), nl,

	% Note the starting time.
	get_time(StartTime),

	% Initialize variables to store positions of agent, covids, home, mask doctor 
	% and starting minimal length of the path.
	initialize_variables(),
	initialize_variables_a_star(),

	% Backtracking approach.
	a_star(),

	% Note the finishing time.
	get_time(EndTime),
	% Output the runtime.
	ExecutionTime is EndTime - StartTime,
	write("Execution time of A* algorithm: "), write(ExecutionTime), write(" s."), nl, nl, !.