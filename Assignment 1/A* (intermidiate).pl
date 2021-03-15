initialize_variables_a_star():-
	assert(open([([0, 0], 0, [0, 0])])),
	assert(closed([])).


open_cells([], Cells, Result) :-
	Result = Cells.


open_cells([Cell|Tail], Cells, Result) :-
	Cell = (CurrentCell, _, _),
	append(Cells, [CurrentCell], CellsUpdated),
	open_cells(Tail, CellsUpdated, Result).


process_cell(EvaluatedCurrentCell, NextCell) :-
	%% NOT OPEN
	open(Open),
	open_cells(Open, [], OpenCells),
	\+ member(NextCell, OpenCells),

	%% Unpack the current cell.
	EvaluatedCurrentCell = (CurrentCell, CostCurrentCell, _),
	%% Increment the cost.
	CostNextCell is CostCurrentCell + 1,
	%% Create new entry.
	EvaluatedNextCell = (NextCell, CostNextCell, CurrentCell),
	
	%% Update open list.
	append(Open, [EvaluatedNextCell], OpenUpdated),
	sort(1, @<, OpenUpdated, SortedOpenUpdated),
	
	%% Update globally.
	retractall(open(_)),
	assert(open(SortedOpenUpdated)).


process_cell(EvaluatedCurrentCell, NextCell) :-
	%% OPEN
	open(Open),
	open_cells(Open, [], OpenCells),
	nth0(IndexEvaluatedNextCell, OpenCells, NextCell),
	%% Get an entry with next cell.
	nth0(IndexEvaluatedNextCell, Open, EvaluatedNextCell),

	%% Unpack the next cell entry.
	EvaluatedNextCell = (NextCell, CostNextCell, _),
	%% Unpack the current cell entry.
	EvaluatedCurrentCell = (CurrentCell, CostCurrentCell, _),
	
	%% Check whether cost is decreased.
	ExpectedCost is CostCurrentCell + 1,
	(
	ExpectedCost < CostNextCell ->
		%% Update open list.
		delete(Open, EvaluatedNextCell, OpenPop),
		NewEvaluatedNextCell = (NextCell, ExpectedCost, CurrentCell),
		append(OpenPop, [NewEvaluatedNextCell], OpenUpdated),
		sort(1, @<, OpenUpdated, SortedOpenUpdated),
		%% Update globally.
		retractall(open(_)),
		assert(open(SortedOpenUpdated)); true
	).


process_candidate([], _).

process_candidate([Candidate|Tail], EvaluatedCurrentCell) :-
	%% Get the closed list.
	closed(Closed),
	%% Check the candidate cell is not closed.
	open_cells(Closed, [], ClosedCells),
	(
		%% Check the candidate cell is not blocked.
		not_infected(Candidate), \+ member(Candidate, ClosedCells) -> %% if-else statement
		process_cell(EvaluatedCurrentCell, Candidate); true
	),
	process_candidate(Tail, EvaluatedCurrentCell).



search_a_star_v1() :-
	open(Open),
	length(Open, LengthOpen), LengthOpen == 0, !.


search_a_star_v1() :-
	%% Get the open and closed lists.
	open(Open),
	closed(Closed),
	%% write("Open: "), write(Open),nl,
	%% write("Closed: "), write(Closed),nl, 

	%% Check that open list is non-empty.
	length(Open, LengthOpen), LengthOpen @> 0,

	%% Pop the most valuable cell.
	nth0(0, Open, EvaluatedCurrentCell),
	delete(Open, EvaluatedCurrentCell, OpenPop),
	%% write(EvaluatedCurrentCell), nl, 
	%% Update globally.
	retractall(open(_)),
	assert(open(OpenPop)),

	%% Treat all neighbouring locations.
	EvaluatedCurrentCell = (CurrentCell, _, _),
	setof(NextCell, get_adjacent(CurrentCell, NextCell), Candidates),
	%% write(Candidates), nl,
	process_candidate(Candidates, EvaluatedCurrentCell),

	%% Push current to closed
	append(Closed, [EvaluatedCurrentCell], ClosedUpdated),
	retractall(closed(_)),
	assert(closed(ClosedUpdated)),

	%% Start again.
	search_a_star_v1().


restore_path(CurrentCell, Result, Path) :-
	agent(CurrentCell),
	append(Result, [CurrentCell], ReversedPath),
	reverse(ReversedPath, Path).

restore_path(CurrentCell, Result, Path) :-
	closed(Closed),
	open_cells(Closed, [], ClosedCells),
	nth0(IndexCurrentCell, ClosedCells, CurrentCell),
	nth0(IndexCurrentCell, Closed, EvaluatedCurrentCell),
	EvaluatedCurrentCell = (_, _, ParentCurrentCell),
	append(Result, [CurrentCell], NewResult),
	restore_path(ParentCurrentCell, NewResult, Path).


a_star() :-
	search_a_star_v1(),
	
	home(HomePosition),
	closed(Closed),
	open_cells(Closed, [], ClosedCells),
	member(HomePosition, ClosedCells),

	restore_path(HomePosition, [], Path),
	length(Path, LengthPath),
	StepsWithoutFirstCell is LengthPath - 1,
	retractall(optimal(_)),
  	assert(optimal(Path)),
	write("Win."), nl, write("Number of steps: "), write(StepsWithoutFirstCell), nl, write("Path: "), write(Path), nl,
	once(map_with_path()),  !.


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
	write("Execution time of A* algorithm: "), write(ExecutionTime), write(" s."), nl, nl.