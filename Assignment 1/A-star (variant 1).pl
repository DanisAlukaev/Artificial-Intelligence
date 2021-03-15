%% Solution for the Home Assignment 1.

%% Student:			Danis Alukaev
%% Group:			BS19-02
%% Student ID: 		19BS551

%% The algorithm was adapted from the lecture slides of the week 5 (slides 33-35) on Artificial Intelligence course.


process_cell_v1(EvaluatedCurrentCell, NextCell) :-
	%% Candidate cell IS NOT in the open list.
	open(Open),
	unpack_cells(Open, [], OpenCells),

	closed(Closed),
	unpack_cells(Closed, [], ClosedCells),

	(
		member(NextCell, ClosedCells) ->
			nth0(Index, ClosedCells, NextCell),
			nth0(Index, Closed, Cell),

			Cell = (_, _, PriorityCell, _),
			%% Unpack the current cell.
			EvaluatedCurrentCell = (_, CostCurrentCell, _, _),
			%% Increment the cost.
			CostNextCell is CostCurrentCell + 1,
			%% Get the distance to home.
			manhattan_distance_home(NextCell, DistanceHome),
			PriorityNextCell is CostNextCell + DistanceHome,

			(
			PriorityCell < PriorityNextCell ->
				true;
				%% Update the open list.
				append(Open, [Cell], OpenUpdated),
				sort(2, @=<, OpenUpdated, SortedOpenUpdated),

				%% Update the open list globally.
				retractall(open(_)),
				assert(open(SortedOpenUpdated))
			)
		;
		(
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
			)
			;
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
						%% Get rid of outdated enry in the open list.
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
	%% Traverse the list with candidate cells and apply the rule to process each of them.
	closed(Closed),
	%% Check the candidate cell is not closed.
	unpack_cells(Closed, [], ClosedCells),
	(
		%% Check the candidate cell is not blocked or is in the closed list.
		\+ member(Candidate, ClosedCells) -> 
			(
				Mask -> 
					mask_path(MaskPath),
					(
						\+ member(Candidate, MaskPath) -> 
							process_cell_v1(EvaluatedCurrentCell, Candidate)
							; true
					)				
					;(
						Doctor ->
							doctor_path(DoctorPath),
							(
								\+ member(Candidate, DoctorPath) -> 
									process_cell_v1(EvaluatedCurrentCell, Candidate)
									; true
							)					
							;( 
								not_infected(Candidate) -> 
									process_cell_v1(EvaluatedCurrentCell, Candidate)
									; true
							)
					)
			)
			; true
	),
	process_candidate_v1(Mask, Doctor, Tail, EvaluatedCurrentCell).


search_a_star_v1(_, _) :-
	%% Implements while(Length =/= 0) loop.
	open(Open), 
	length(Open, LengthOpen), LengthOpen == 0, !.


search_a_star_v1(Mask, Doctor) :-
	%% Implements while(Length =/= 0) loop.
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
	%% Create open and closed lists.
	agent(AgentPosition),
	initialize_open_closed_lists(AgentPosition),

	search_a_star_v1(false, false),
	home(HomePosition),
	mask(MaskPosition),
	doctor(DoctorPosition),

	restore_path(AgentPosition, HomePosition, [], PathWOImmunity),
	restore_path(AgentPosition, MaskPosition, [], MaskPathWOImmunity),
	restore_path(AgentPosition, DoctorPosition, [], DoctorPathWOImmunity),

	retractall(mask_path(_)),
	retractall(doctor_path(_)),
	assert(mask_path(MaskPathWOImmunity)),
	assert(doctor_path(DoctorPathWOImmunity)),

	initialize_open_closed_lists(MaskPosition),
	search_a_star_v1(true, false),
	restore_path(MaskPosition, HomePosition, [], MaskPathImmunity),

	initialize_open_closed_lists(DoctorPosition),
	search_a_star_v1(false, true),
	restore_path(DoctorPosition, HomePosition, [], DoctorPathImmunity),

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

	length(PathWOImmunity, LengthPathWOImmunity),
	length(MaskFinal, LengthMaskFinal),
	length(DoctorFinal, LengthDoctorFinal),

	get_non_zero_paths([(LengthPathWOImmunity, PathWOImmunity), (LengthMaskFinal, MaskFinal), (LengthDoctorFinal, DoctorFinal)], [], NonZeroSolutions),

	sort(0, @=<, NonZeroSolutions, SortedSolutions),
	nth0(0, SortedSolutions, PathCompound),
	%% Output necessary information.
	PathCompound = (LengthPath, Path),
	StepsWithoutFirstCell is LengthPath - 1,
	retractall(optimal(_)),
  	assert(optimal(Path)),
	write("Win."), nl, write("Number of steps: "), write(StepsWithoutFirstCell), nl, write("Path: "), write(Path), nl,
	once(map_with_path()), !.


a_star_v1() :-
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