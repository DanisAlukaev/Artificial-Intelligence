%% Solution for the Home Assignment 1.

%% Student:			Danis Alukaev
%% Group:			BS19-02
%% Student ID: 		19BS551

%% The algorithm was adapted from the lecture slides of the week 5 (slides 33-35) on Artificial Intelligence course.


manhattan_distance_home([AgentX, AgentY], Distance) :-
	% Yield the Manhattan distance for an agent position.
	home([HomeX, HomeY]),
	DistanceX is HomeX - AgentX,
	DistanceY is HomeY - AgentY,
	absolute_value(DistanceX, AbsoluteDistanceX),
	absolute_value(DistanceY, AbsoluteDistanceY),
	Distance is AbsoluteDistanceX + AbsoluteDistanceY.


initialize_open_closed_lists(StartingPosition):-
	%% Create facts open and closed for corresponding lists.
	%% Each entry in these lists consists of location, cost and location of parent cell.
	retractall(open(_)),
	retractall(closed(_)),
	manhattan_distance_home(StartingPosition, DistanceHome),
	assert(open([(StartingPosition, 0, DistanceHome, StartingPosition)])),
	assert(closed([])).


unpack_cells([], Cells, Result) :-
	%% Yields the list of location of cells out of correspondent entries of a given list.
	%% There is nothing to procede with. 
	%% Define the result of rule to list of cells.
	Result = Cells.


unpack_cells([Cell|Tail], Cells, Result) :-
	%% Yields the list of location of cells out of correspondent entries of a given list.
	%% Get the location of cell and place it in aggregate list.
	Cell = (CurrentCell, _, _, _),
	append(Cells, [CurrentCell], CellsUpdated),
	unpack_cells(Tail, CellsUpdated, Result).


process_cell(EvaluatedCurrentCell, NextCell) :-
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


process_candidate(_, _, [], _).


%% TODO: add not in member
process_candidate(Mask, Doctor, [Candidate|Tail], EvaluatedCurrentCell) :-
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
							process_cell(EvaluatedCurrentCell, Candidate)
							; true
					)				
					;(
						Doctor ->
							doctor_path(DoctorPath),
							(
								\+ member(Candidate, DoctorPath) -> 
									process_cell(EvaluatedCurrentCell, Candidate)
									; true
							)					
							;( 
								not_infected(Candidate) -> 
									process_cell(EvaluatedCurrentCell, Candidate)
									; true
							)
					)
			)
			; true
	),
	process_candidate(Mask, Doctor, Tail, EvaluatedCurrentCell).


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
	process_candidate(Mask, Doctor, Candidates, EvaluatedCurrentCell),

	%% Push current cell to closed list.
	append(Closed, [EvaluatedCurrentCell], ClosedUpdated),
	retractall(closed(_)),
	assert(closed(ClosedUpdated)),

	%% Start again.
	search_a_star_v1(Mask, Doctor).




restore_path(Destination, CurrentCell, Result, Path) :-
	%% Restore the path starting from the home position and finishing original position.
	%% Restoring rule reached original position.
	is_same_position(Destination, CurrentCell),
	append(Result, [CurrentCell], ReversedPath),
	reverse(ReversedPath, Path), !.


restore_path(Destination, CurrentCell, Result, Path) :-
	%% Restore the path starting from the home position and finishing original position.
	%% Append the parent of current cell.
	closed(Closed),
	unpack_cells(Closed, [], ClosedCells),
	nth0(IndexCurrentCell, ClosedCells, CurrentCell),
	nth0(IndexCurrentCell, Closed, EvaluatedCurrentCell),
	EvaluatedCurrentCell = (_, _, _, ParentCurrentCell),
	append(Result, [CurrentCell], NewResult),
	restore_path(Destination, ParentCurrentCell, NewResult, Path).

restore_path(_, _, _, Path) :-
	Path = [].

get_non_zero_paths([], Result, Answer) :-
	Answer = Result.


get_non_zero_paths([PathCompound|Tail], Result, Answer) :-
	PathCompound = (LengthPath, _),
	(
		LengthPath \= 0 -> append(Result, [PathCompound], NewResult);
		NewResult = Result
	),
	get_non_zero_paths(Tail, NewResult, Answer).




%% TODO: don't repeat path
a_star() :-
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


a_star() :-
	%% In case no path was found, the agent has lost.
	%% Set number of steps to zero and path to empty list.
	write("Lost."), nl.


start_a_star():-
	write("A-star algorithm:"), nl,

	%% Note the starting time.
	get_time(StartTime),

	%% Initialize variables to store positions of agent, covids, home, mask doctor 
	%% and starting minimal length of the path.
	initialize_variables(),

	%% Run A* algorithm.
	once(a_star()),

	%% Note the finishing time.
	get_time(EndTime),
	%% Output the runtime.
	ExecutionTime is EndTime - StartTime,
	write("Execution time of A* algorithm: "), write(ExecutionTime), write(" s."), nl, nl, !.