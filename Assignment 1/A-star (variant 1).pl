%% Solution for the Home Assignment 1.

%% Student:			Danis Alukaev
%% Group:			BS19-02
%% Student ID: 		19BS551

%% The algorithm was adapted from the lecture slides of the week 5 (slides 33-35) on Artificial Intelligence course.
%% As priority there taken the sum of cost at the given cell and Manhattan distance from this point to home.


process_cell_v1(EvaluatedCurrentCell, NextCell) :-
	%% Get the locations of cells in open, closed lists.
	open(Open),
	unpack_cells(Open, [], OpenCells),
	closed(Closed),
	unpack_cells(Closed, [], ClosedCells),
	(
		%% Candidate is in the closed list.
		member(NextCell, ClosedCells) ->
			nth0(Index, ClosedCells, NextCell),
			nth0(Index, Closed, Cell),

			%% Get the priority of cell with same location.
			Cell = (_, _, PriorityCell, _),
			%% Unpack the current cell.
			EvaluatedCurrentCell = (_, CostCurrentCell, _, _),
			%% Increment the cost.
			CostNextCell is CostCurrentCell + 1,
			%% Get the distance to home.
			manhattan_distance_home(NextCell, DistanceHome),
			%% Compute the priority.
			PriorityNextCell is CostNextCell + DistanceHome,
			(
				%% Check that priority of cell with same location is less than the priority of next cell.
				PriorityCell < PriorityNextCell ->
					true
					; %% Update the open list.
					append(Open, [Cell], OpenUpdated),
					sort(2, @=<, OpenUpdated, SortedOpenUpdated),
					%% Update the open list globally.
					retractall(open(_)),
					assert(open(SortedOpenUpdated))
			)
		;(
			%% Candidate is not in the open list.
			\+ member(NextCell, OpenCells) ->
			(
				%% Unpack the current cell.
				EvaluatedCurrentCell = (CurrentCell, CostCurrentCell, _, _),
				%% Increment the cost.
				CostNextCell is CostCurrentCell + 1,
				%% Get the distance to home.
				manhattan_distance_home(NextCell, DistanceHome),
				PriorityNextCell is CostNextCell + DistanceHome,
				%% Create a new entry with candidate cell.
				EvaluatedNextCell = (NextCell, CostNextCell, PriorityNextCell, CurrentCell),
				
				%% Update the open list.
				append(Open, [EvaluatedNextCell], OpenUpdated),
				sort(2, @=<, OpenUpdated, SortedOpenUpdated),

				%% Update the open list globally.
				retractall(open(_)),
				assert(open(SortedOpenUpdated))
			);
				%% Get index of entry with the same location from open list.
				nth0(IndexEvaluatedNextCell, OpenCells, NextCell),
				%% Get an entry with next cell.
				nth0(IndexEvaluatedNextCell, Open, EvaluatedNextCell),

				%% Unpack the next cell entry.
				EvaluatedNextCell = (NextCell, CostNextCell, _, _),
				%% Unpack the current cell entry.
				EvaluatedCurrentCell = (CurrentCell, CostCurrentCell, _, _),
				
				%% Check whether cost can be minimized.
				ExpectedCost is CostCurrentCell + 1,
				(
					ExpectedCost < CostNextCell ->
						%% Get rid of outdated entry in the open list.
						delete(Open, EvaluatedNextCell, OpenPop),

						%% Compose new entry for candidate cell.

						manhattan_distance_home(NextCell, DistanceHome),
						PriorityNextCell is CostNextCell + DistanceHome, 
						NewEvaluatedNextCell = (NextCell, ExpectedCost, PriorityNextCell, CurrentCell),

						%% Update the open list.
						append(OpenPop, [NewEvaluatedNextCell], OpenUpdated),
						sort(2, @=<, OpenUpdated, SortedOpenUpdated),
						%% Update the open list globally.
						retractall(open(_)),
						assert(open(SortedOpenUpdated))
						; true
				)
		)
	).


process_candidate_v1(_, _, [], _).


process_candidate_v1(Mask, Doctor, [Candidate|Tail], EvaluatedCurrentCell) :-
	%% Process the candidate cells given in the list.
	closed(Closed),
	unpack_cells(Closed, [], ClosedCells),
	(
		%% Check the candidate cell is not closed.
		\+ member(Candidate, ClosedCells) -> 
			(
				Mask -> 
					%% Consider the case when mask was taken.
					mask_path(MaskPath),
					(
						%% Process all candidate cells that are not in the path to mask.
						\+ member(Candidate, MaskPath) -> 
							process_cell_v1(EvaluatedCurrentCell, Candidate)
							; true
					)				
					;(
						%% Consider the case when doctor was taken.
						Doctor ->
							doctor_path(DoctorPath),
							(
								%% Process all candidate cells that are not in the path to doctor.
								\+ member(Candidate, DoctorPath) -> 
									process_cell_v1(EvaluatedCurrentCell, Candidate)
									; true
							)					
							;( 
								%% In case there is no immunity, consider only not infected cells.
								not_infected(Candidate) -> 
									process_cell_v1(EvaluatedCurrentCell, Candidate)
									; true
							)
					)
			)
			; true
	),
	%% Run the rule again.
	process_candidate_v1(Mask, Doctor, Tail, EvaluatedCurrentCell).


search_a_star_v1(_, _) :-
	%% A-star searching algorithm.
	%% There are no cells in the open list.
	open(Open), 
	length(Open, LengthOpen), LengthOpen == 0, !.


search_a_star_v1(Mask, Doctor) :-
	%% A-star searching algorithm.
	%% Get the open and closed lists.
	open(Open),
	closed(Closed),

	%% Check that open list is non-empty.
	length(Open, LengthOpen), LengthOpen @> 0,

	%% Pop the most valuable cell.
	nth0(0, Open, EvaluatedCurrentCell),
	delete(Open, EvaluatedCurrentCell, OpenPop),
	%% Update open list globally.
	retractall(open(_)),
	assert(open(OpenPop)),

	%% Treat all neighbouring locations.
	EvaluatedCurrentCell = (CurrentCell, _, _, _),
	setof(NextCell, get_adjacent(CurrentCell, NextCell), Candidates),
	process_candidate_v1(Mask, Doctor, Candidates, EvaluatedCurrentCell),

	%% Push current cell to closed list.
	append(Closed, [EvaluatedCurrentCell], ClosedUpdated),
	retractall(closed(_)),
	assert(closed(ClosedUpdated)),

	%% Start again.
	search_a_star_v1(Mask, Doctor).


a_star_v1() :-
	%% Rule to display the result of the algorithm run.
	
	%% Run the A-star algorithm from the agent position without immunity.
	agent(AgentPosition),
	initialize_open_closed_lists(AgentPosition),
	search_a_star_v1(false, false),
	%% Get the position of Home, Mask, Doctor.
	home(HomePosition),
	mask(MaskPosition),
	doctor(DoctorPosition),
	%% Restore the path to Home, Mask, Doctor.
	restore_path(AgentPosition, HomePosition, [], PathWOImmunity),
	restore_path(AgentPosition, MaskPosition, [], MaskPathWOImmunity),
	restore_path(AgentPosition, DoctorPosition, [], DoctorPathWOImmunity),
	%% Save the paths to mask and doctor globally.
	retractall(mask_path(_)),
	retractall(doctor_path(_)),
	assert(mask_path(MaskPathWOImmunity)),
	assert(doctor_path(DoctorPathWOImmunity)),

	%% Run the A-star algorithm from the mask position with immunity.
	initialize_open_closed_lists(MaskPosition),
	search_a_star_v1(true, false),
	%% Restore the path to Home from Mask.
	restore_path(MaskPosition, HomePosition, [], MaskPathImmunity),

	%% Run the A-star algorithm from the doctor position with immunity.
	initialize_open_closed_lists(DoctorPosition),
	search_a_star_v1(false, true),
	%% Restore the path to Home from Doctor.
	restore_path(DoctorPosition, HomePosition, [], DoctorPathImmunity),

	%% Merge paths from Agent to Mask with path from Mask to Home and 
	%% path from Agent to Mask with path from Mask to Home.
	(
			MaskPathWOImmunity == [] -> MaskFinal = [];
			delete(MaskPathWOImmunity, MaskPosition, NewMaskFinal), 
			append(NewMaskFinal, MaskPathImmunity, MaskFinal)		
	),
	(
			DoctorPathWOImmunity == [] -> DoctorFinal = [];
			delete(DoctorPathWOImmunity, DoctorPosition, NewDoctorFinal), 
			append(NewDoctorFinal, DoctorPathImmunity, DoctorFinal)		
	),

	%% Determine the lenghts of obtained paths.
	length(PathWOImmunity, LengthPathWOImmunity),
	length(MaskFinal, LengthMaskFinal),
	length(DoctorFinal, LengthDoctorFinal),

	%% Get list of non-empty paths.
	get_non_zero_paths([(LengthPathWOImmunity, PathWOImmunity), (LengthMaskFinal, MaskFinal), (LengthDoctorFinal, DoctorFinal)], [], NonZeroSolutions),
	%% Get the shortest paths.
	sort(0, @=<, NonZeroSolutions, SortedSolutions),
	nth0(0, SortedSolutions, PathCompound),
	%% Output necessary information.
	PathCompound = (LengthPath, Path),
	StepsWithoutFirstCell is LengthPath - 1,
	retractall(optimal(_)),
  	assert(optimal(Path)),
	write("Win."), nl,
	write("Number of steps: "), write(StepsWithoutFirstCell), nl, 
	write("Path: "), write(Path), nl,
  	%% Display the map with found by backtracking shortest path.
	once(map_with_path()), !.


a_star_v1() :-
	%% Rule to display the result of the algorithm run.
	%% In case no path was found, the agent has lost.
	%% Set number of steps to zero and path to empty list.
	write("Lost."), nl.


start_a_star_v1():-
	write("A-star algorithm (variant 1):"), nl,

	%% Note the starting time.
	get_time(StartTime),

	%% Initialize variables to store positions of agent, covids, home, mask doctor 
	%% and starting minimal length of the path.
	initialize_variables(),

	%% Run A* algorithm.
	once(a_star_v1()),

	%% Note the finishing time.
	get_time(EndTime),
	%% Output the runtime.
	ExecutionTime is EndTime - StartTime,
	write("Execution time of A* algorithm (variant 1): "), write(ExecutionTime), write(" s."), nl, nl, !.