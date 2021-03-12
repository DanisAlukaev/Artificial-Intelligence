% Solution for the Home Assignment 1.
%
% Student:			Danis Alukaev
% Group:			BS19-02
% Student ID:		19BS551


prioritize_v2([], PrioritizedCandidates, Result) :-
	% There is nothing left in list of candidate cells.
	Result = PrioritizedCandidates.


prioritize_v2([Cell|Tail], PrioritizedCandidates, Result) :-
	% Calculate the Chebyshev distance from candidate cell to home.
	% Use this distance as priority of this cell: the lower the priority the better.
	% Priority and position of cell are stored as structures.
	grid_size([MaximalX, MaximalY]),
	MaximalLengthPath is MaximalX * MaximalY,
	distance_home(Cell, DistanceHome),
	(
		get_adjacent(Cell, AdjacentCell), all_infected(AdjacentCell) -> ExpectedDistanceHome is DistanceHome * 2;
		ExpectedDistanceHome is DistanceHome
	),
	Priority is (ExpectedDistanceHome - MaximalLengthPath) / MaximalLengthPath + 1,
	PrioritizedCandidate = (Priority, Cell),
	append(PrioritizedCandidates, [PrioritizedCandidate], ResultantPrioritizedCandidates),
	prioritize_v2(Tail, ResultantPrioritizedCandidates, Result).


search_v2(CurrentCell, PreviousPath, _, _, ResultantPath) :-
	% Searching algorith.
	% The agent found the home, so it is done.
	is_home(CurrentCell),
	append(PreviousPath, [CurrentCell], ResultantPath), !.


search_v2(CurrentCell, PreviousPath, _, Doctor, NextResultantPath) :-
	% Searching algorith.
	% The agent found the mask, now it can go through infected cells.
	% Optimization: cut the solution branch if the length of current path is greater than of the minimal found.
	is_mask(CurrentCell),
	MaskNew = 1,
	append(PreviousPath, [CurrentCell], ResultantPath),
	less_than_minimal_path(ResultantPath, CurrentCell),
	setof(NextCell, perceive(CurrentCell, ResultantPath, MaskNew, Doctor, NextCell), Candidates),
	prioritize_v2(Candidates, [], PrioritizedCandidates),
	sort(0, @<, PrioritizedCandidates, Sorted),
	get_candidate(Sorted, CandidateCell),
	search_v2(CandidateCell, ResultantPath, MaskNew, Doctor, NextResultantPath).


search_v2(CurrentCell, PreviousPath, Mask, _, NextResultantPath) :-
	% Searching algorith.
	% The agent found the doctor, now it can go through infected cells.
	% Optimization: cut the solution branch if the length of current path is greater than of the minimal found.
	is_doctor(CurrentCell),
	DoctorNew = 1,
	append(PreviousPath, [CurrentCell], ResultantPath),
	less_than_minimal_path(ResultantPath, CurrentCell),
	setof(NextCell, perceive(CurrentCell, ResultantPath, Mask, DoctorNew, NextCell), Candidates),
	prioritize_v2(Candidates, [], PrioritizedCandidates),
	sort(0, @<, PrioritizedCandidates, Sorted),
	get_candidate(Sorted, CandidateCell),
	search_v2(CandidateCell, ResultantPath, Mask, DoctorNew, NextResultantPath).


search_v2(CurrentCell, PreviousPath, Mask, Doctor, NextResultantPath) :-
	% Searching algorith.
	% The agent did not found either the mask or doctor.
	% Optimization: cut the solution branch if the length of current path is greater than of the minimal found.
	\+ is_mask(CurrentCell), \+ is_doctor(CurrentCell),
	append(PreviousPath, [CurrentCell], ResultantPath),
	less_than_minimal_path(ResultantPath, CurrentCell),
	setof(NextCell, perceive(CurrentCell, ResultantPath, Mask, Doctor, NextCell), Candidates),
	prioritize_v2(Candidates, [], PrioritizedCandidates),
	sort(0, @<, PrioritizedCandidates, Sorted),
	get_candidate(Sorted, CandidateCell), 
	search_v2(CandidateCell, ResultantPath, Mask, Doctor, NextResultantPath).


solve_v2(Length, Path) :-
	% Auxiliary function to run searching algorith.
	% Update the information about the minimal length of found path for oprimization. 
	search_v2([0, 0], [], 0, 0, Path),
	length(Path, Length),
	minimal_path(MinimalPath),
	(
	   Length < MinimalPath -> retractall(minimal_path(_)), assert(minimal_path(Length))
	   ; true
	).


backtrack_v2() :-
	% Find all solution to goal using setof function.
	% In case it managed to locate the optimal path the agent has won.
	% Output number of steps and optimal path.
	setof((Length, Path), solve_v2(Length, Path), Paths),
 	nth0(0, Paths, Optimal, _),
  	Optimal = (OptimalSteps, OptimalPath),
  	StepsWithoutFirstCell is OptimalSteps - 1,
  	retractall(optimal(_)),
  	assert(optimal(OptimalPath)),
  	write("Win."), nl, write("Number of steps: "), write(StepsWithoutFirstCell), nl, write("Path: "), write(OptimalPath), nl, 
  	% Display the map with found by backtracking shortest path.
	once(map_with_path()), !.


backtrack_v2() :-
	% In case no path was found, the agent has lost.
	% Set number of steps to zero and path to empty list.
	write("Lost."), nl.


start_backtracking_v2():-
	write("Backtracking (variant 2):"), nl,

	% Note the starting time.
	get_time(StartTime),

	% Initialize variables to store positions of agent, covids, home, mask doctor 
	% and starting minimal length of the path.
	initialize_variables(),

	% Backtracking approach.
	backtrack_v2(),

	% Note the finishing time.
	get_time(EndTime),
	% Output the runtime.
	ExecutionTime is EndTime - StartTime,
	write("Execution time of backtracking (variant 2): "), write(ExecutionTime), write(" s."), nl, nl.