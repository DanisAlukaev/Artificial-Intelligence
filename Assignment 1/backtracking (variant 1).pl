%% Solution for the Home Assignment 1.

%% Student:			Danis Alukaev
%% Group:			BS19-02
%% Student ID: 		19BS551


prioritize_v1([], PrioritizedCandidates, Result) :-
	%% Prioritize candidates given in list.
	%% There is nothing left in list of candidate cells.
	Result = PrioritizedCandidates.


prioritize_v1([Cell|Tail], PrioritizedCandidates, Result) :-
	%% Prioritize candidates given in list.
	grid_size([MaximalX, MaximalY]),
	MaximalLengthPath is MaximalX * MaximalY,
	%% Calculate the Chebyshev distance from candidate cell to home.
	distance_home(Cell, DistanceHome),
	%% Use this distance as priority of this cell: the lower the priority the better.
	%% Note that priority is normalized. 
	Priority is (DistanceHome - MaximalLengthPath) / MaximalLengthPath + 1,
	%% Create an entry and append it to resultant list.
	PrioritizedCandidate = (Priority, Cell),
	append(PrioritizedCandidates, [PrioritizedCandidate], ResultantPrioritizedCandidates),
	prioritize_v1(Tail, ResultantPrioritizedCandidates, Result).


search_v1(CurrentCell, PreviousPath, _, _, ResultantPath) :-
	%% Backtracking searching algorithm.
	%% The agent found the home.
	is_home(CurrentCell),
	append(PreviousPath, [CurrentCell], ResultantPath), !.


search_v1(CurrentCell, PreviousPath, _, Doctor, NextResultantPath) :-
	%% Backtracking searching algorithm.
	%% The agent found the mask, now it can go through infected cells.
	is_mask(CurrentCell),
	MaskNew = 1,
	append(PreviousPath, [CurrentCell], ResultantPath),
	%% Optimization: cut the solution branch if the length of current path is greater than of the minimal found.
	less_than_minimal_path(ResultantPath, CurrentCell),
	%% Get all candidates cells.
	setof(NextCell, perceive(CurrentCell, ResultantPath, MaskNew, Doctor, NextCell), Candidates),
	%% Prioritize the candidate cells.
	prioritize_v1(Candidates, [], PrioritizedCandidates),
	sort(0, @=<, PrioritizedCandidates, Sorted),
	%% Get the most valuable cell to try.
	get_candidate(Sorted, CandidateCell),
	%% Run the search again.
	search_v1(CandidateCell, ResultantPath, MaskNew, Doctor, NextResultantPath).


search_v1(CurrentCell, PreviousPath, Mask, _, NextResultantPath) :-
	%% Backtracking searching algorithm.
	%% The agent found the doctor, now it can go through infected cells.
	is_doctor(CurrentCell),
	DoctorNew = 1,
	append(PreviousPath, [CurrentCell], ResultantPath),
	%% Optimization: cut the solution branch if the length of current path is greater than of the minimal found.
	less_than_minimal_path(ResultantPath, CurrentCell),
	%% Get all candidates cells.
	setof(NextCell, perceive(CurrentCell, ResultantPath, Mask, DoctorNew, NextCell), Candidates),
	%% Prioritize the candidate cells.
	prioritize_v1(Candidates, [], PrioritizedCandidates),
	sort(0, @=<, PrioritizedCandidates, Sorted),
	%% Get the most valuable cell to try.
	get_candidate(Sorted, CandidateCell),
	%% Run the search again.
	search_v1(CandidateCell, ResultantPath, Mask, DoctorNew, NextResultantPath).


search_v1(CurrentCell, PreviousPath, Mask, Doctor, NextResultantPath) :-
	%% Backtracking searching algorithm.
	%% The agent did not found either the mask or doctor.
	\+ is_mask(CurrentCell), \+ is_doctor(CurrentCell),
	append(PreviousPath, [CurrentCell], ResultantPath),
	%% Optimization: cut the solution branch if the length of current path is greater than of the minimal found.
	less_than_minimal_path(ResultantPath, CurrentCell),
	%% Get all candidates cells.
	setof(NextCell, perceive(CurrentCell, ResultantPath, Mask, Doctor, NextCell), Candidates),
	%% Prioritize the candidate cells.
	prioritize_v1(Candidates, [], PrioritizedCandidates),
	sort(0, @=<, PrioritizedCandidates, Sorted),
	%% Get the most valuable cell to try.
	get_candidate(Sorted, CandidateCell), 
	%% Run the search again.
	search_v1(CandidateCell, ResultantPath, Mask, Doctor, NextResultantPath).


solve_v1(Length, Path) :-
	%% Auxiliary function to run searching algorithm.
	%% Start the backtracking.
	search_v1([0, 0], [], 0, 0, Path),
	%% Update the information about the minimal length of the path. 
	length(Path, Length),
	minimal_path(MinimalPath),
	(
	    Length < MinimalPath -> 
		    retractall(minimal_path(_)), assert(minimal_path(Length))
		    ; true
	).


backtrack_v1() :-
	%% Rule to display the result of the algorithm run.
	%% Find all solution to goal using setof function.
	setof((Length, Path), solve_v1(Length, Path), Paths),
	%% In case it managed to locate the optimal path the agent has won.
 	nth0(0, Paths, Optimal, _),
  	Optimal = (OptimalSteps, OptimalPath),
  	%% Number of steps is the number of cells minus one.
  	StepsWithoutFirstCell is OptimalSteps - 1,
  	retractall(optimal(_)),
  	assert(optimal(OptimalPath)),
	%% Output number of steps and optimal path.
  	write("Win."), nl, 
  	write("Number of steps: "), write(StepsWithoutFirstCell), nl, 
  	write("Path: "), write(OptimalPath), nl, 
  	%% Display the map with found by backtracking shortest path.
	once(map_with_path()), !.


backtrack_v1() :-
	%% Rule to display the result of the algorithm run.
	%% In case no path was found, the agent has lost.
	write("Lost."), nl.


start_backtracking_v1():-
	write("Backtracking (variant 1):"), nl,
	%% Note the starting time.
	get_time(StartTime),

	%% Backtracking approach.
	backtrack_v1(),

	%% Note the finishing time.
	get_time(EndTime),
	%% Output the runtime.
	ExecutionTime is EndTime - StartTime,
	write("Execution time of backtracking (variant 1): "), write(ExecutionTime), write(" s."), nl, nl.