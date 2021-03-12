% Solution for the Home Assignment 1.
%
% Student:			Danis Alukaev
% Group:			BS19-02
% Student ID:		19BS551


prepare() :-
	% remove all previously created facts.
	retractall(grid_size(_)),
	retractall(agent(_)),
	retractall(covid(_)),
	retractall(home(_)),
	retractall(mask(_)),
	retractall(doctor(_)),
	retractall(minimal_path(_)),
	retractall(optimal(_)).


%% ----------------- MAP GENERATION ----------------------------------------


is_same_position([X1, Y1], [X2, Y2]) :-
	% Check whether two positions are the same.
	X1 == X2, Y1 == Y2.


is_covid(Position) :-
	% Check whether the given position belongs to covid cell.
	covid(CovidPosition),
	is_same_position(Position, CovidPosition).


get_random_position_covid(RandomPosition) :-
	% Yield vacant random position for covid.
	% Repeatedly generate random position until it does not violate the conditions.
	% Proposed position cannot
	% 	- be the initial agent position
	% 	- already belong to covid
	grid_size([MaximalX, MaximalY]),
	repeat,
	random(0, MaximalX, RandomX),
	random(0, MaximalY, RandomY),
	agent(AgentPosition),
	RandomPosition = [RandomX, RandomY],
	(
	is_covid(RandomPosition) ->
		fail
	; is_same_position(RandomPosition, AgentPosition) ->
		fail
	;!
	).


coordinate_exists([X, Y]) :- 
	% Check whether position does exist in the lattice.
	grid_size([MaximalX, MaximalY]),
	X @>= 0, X @< MaximalX, 
 	Y @>= 0, Y @< MaximalY.


get_adjacent([X1, Y1], [X2, Y2]) :- 
	% Yield Moore neighborhood for a given position.
	(X2 is X1 + 1, Y2 is Y1, coordinate_exists([X2, Y1]));
	(X2 is X1 + 1, Y2 is Y1 + 1, coordinate_exists([X2, Y2]));
	(Y2 is Y1 - 1, X2 is X1, coordinate_exists([X1, Y2]));
	(X2 is X1 - 1, Y2 is Y1 + 1, coordinate_exists([X2, Y2]));
	(X2 is X1 - 1, Y2 is Y1, coordinate_exists([X2, Y1]));
	(X2 is X1 - 1, Y2 is Y1 - 1, coordinate_exists([X2, Y2]));
	(Y2 is Y1 + 1, X2 is X1, coordinate_exists([X1, Y2]));
	(X2 is X1 + 1, Y2 is Y1 - 1, coordinate_exists([X2, Y2])).


get_random_position_not_covid(RandomPosition) :-
	% Yield vacant not infected random position.
	% Repeatedly generate random position until it does not violate the conditions.
	% Proposed position cannot
	% 	- be the initial agent position
	% 	- be the home position
	% 	- be the mask position
	% 	- be the doctor position
	% 	- be infected
	grid_size([MaximalX, MaximalY]),
	repeat,
	random(0, MaximalX, RandomX),
	random(0, MaximalY, RandomY),
	agent(AgentPosition),
	home(HomePosition),
	mask(MaskPosition),
	doctor(DoctorPosition),
	RandomPosition = [RandomX, RandomY],
	(
	is_same_position(RandomPosition, AgentPosition) ->
	  	fail
	; is_same_position(RandomPosition, HomePosition) ->
	  	fail
	; is_same_position(RandomPosition, MaskPosition) ->
	  	fail
	; is_same_position(RandomPosition, DoctorPosition) ->
	  	fail
	; is_infected(RandomPosition) ->
		fail
	; !
	).


initialize_variables() :-
	% Set the original position of an agent, starting length of minimal path, and
	% create dummy positions for a home, mask, doctor to simplify code for the 
	% rule get_random_position_not_covid().
	assert(agent([0, 0])),
	assert(optimal([])),
	grid_size([MaximalX, MaximalY]),
	MinimalPathLength is  MaximalX * MaximalY + 1, 
 	assert(minimal_path(MinimalPathLength)).


create_covid() :-
	% Initialize covid in the lattice with the random position.
	get_random_position_covid(RandomPosition),
	assert(covid(RandomPosition)),
	write("Covid position: "), write(RandomPosition), nl.


create_home() :-
	% Initialize home in the lattice with the random position.
	get_random_position_not_covid(RandomPosition),
	assert(home(RandomPosition)),
	write("Home position: "), write(RandomPosition), nl.


create_mask() :-
	% Initialize mask in the lattice with the random position.
	get_random_position_not_covid(RandomPosition),
	assert(mask(RandomPosition)),
	write("Mask position: "), write(RandomPosition), nl.


create_doctor() :-
	% Initialize doctor in the lattice with the random position.
	get_random_position_not_covid(RandomPosition),
	assert(doctor(RandomPosition)),
	write("Doctor position: "), write(RandomPosition), nl, nl.


reinitialize_variables() :-
	% Remove unnecessary items.
	retractall(covid([-1, -1])),
	retractall(home([-1, -1])),
	retractall(mask([-1, -1])),
	retractall(doctor([-1, -1])).


assert_dummy() :-
	% Supprtive facts.
	assert(covid([-1, -1])),
	assert(home([-1, -1])),
	assert(mask([-1, -1])),
	assert(doctor([-1, -1])).


generate_map() :-
	% Randomly generate map, i.e. create 2 covids, 1 home, 1 mask and 1 doctor.
	assert_dummy(),
	create_covid(),
	create_covid(),
	create_home(),
	create_mask(),
	create_doctor(),
	reinitialize_variables().


set_map() :-
	% Specify postions in a form of [X, Y] as it done below.
	assert(covid([4, 1])),
 	assert(covid([7, 6])),
 	assert(home([7, 1])),
	assert(mask([1, 7])),
	assert(doctor([4, 4])).


print_map(X, _) :-
	% The rule iteratively decrease the index of the cell along X-axis,
	% so when this index becomes negative, the outputing of map is finished
	X == -1, nl, !.


print_map(X, Y) :-
	% When the index of cell along Y-axis becomes equal to maximal possible,
	% move the carriage to the next line.
	grid_size([_, MaximalY]),
	Y == MaximalY, 
	nl,
	NextX is X - 1, NextY is 0,
	print_map(NextX, NextY).


print_map(X, Y) :-
	% Output the corresponding symbol for object in the cell:
	% - actor position		A
	% - home position 		H
	% - cell in found path 	X
	% - covid cell 			C
	% - infected cell 		I
	% - doctor position 	D
	% - mask position 		M 
	grid_size([_, MaximalY]),
	Y \= MaximalY,
	optimal(Path),
	(
		agent([X, Y]) -> write("A ")
		; home([X, Y]) -> write("H ")
		; member([X, Y], Path) -> write("X ")
		; covid([X, Y]) -> write("C ")
		; all_infected([X, Y]) -> write("I ")
		; doctor([X, Y]) -> write("D ")
		; mask([X, Y]) -> write("M ")
		; write("* ")
	),
	NextX is X,
	NextY is Y + 1,
	print_map(NextX, NextY).


print_map() :-
	% Entry point for rule drawing the map.
	grid_size([MaximalX, _]),
	MaximalIndX is MaximalX - 1,
	print_map(MaximalIndX, 0).


original_map() :-
	nl, write("Original map: "), nl,
	print_map().


map_with_path() :-
	nl, write("Original map with shortest path shown: "), nl,
	print_map().


%% ----------------- PREPARED MAPS -----------------------------------------
%  The following section contatins ready-to-use maps of the size 9x9.
%  To try one of them, comment out the neccessary map in test() rule.


resolvable_map1_9x9() :-
	assert(covid([0, 2])),
 	assert(covid([6, 6])),
 	assert(home([3, 0])),
	assert(mask([5, 2])),
	assert(doctor([3, 3])).


resolvable_map2_9x9() :-
 	assert(covid([1, 2])),
 	assert(covid([3, 0])),
 	assert(home([3, 2])),
	assert(mask([1, 0])),
	assert(doctor([4, 3])).


resolvable_map3_9x9() :-
 	assert(covid([3, 0])),
 	assert(covid([4, 3])),
 	assert(home([8, 1])),
	assert(mask([2, 8])),
	assert(doctor([3, 8])).


impossible_map1_9x9() :-
 	assert(covid([1, 2])),
 	assert(covid([3, 0])),
 	assert(home([3, 2])),
	assert(mask([1, 4])),
	assert(doctor([4, 3])).


impossible_map2_9x9() :-
 	assert(covid([0, 1])),
 	assert(covid([8, 2])),
 	assert(home([6, 7])),
	assert(mask([2, 6])),
	assert(doctor([0, 5])).


%% ----------------- BACKTRACKING ------------------------------------------


is_home(Position) :-
	% Check whether specified position is home.
	home(HomePosition),
	is_same_position(Position, HomePosition).


is_mask(Position) :-
	% Check whether specified position is mask.
	mask(MaskPosition),
	is_same_position(Position, MaskPosition).


is_doctor(Position) :-
	% Check whether specified position is doctor.
	doctor(DoctorPosition),
	is_same_position(Position, DoctorPosition).


all_infected(InfectedPosition) :-
	% Yield all infected positions, including covid cells and their Moore neighborhood.
	(
		covid(CovidPosition),
		get_adjacent(CovidPosition, InfectedPosition)
	);
	(
		covid(InfectedPosition)
	).


not_infected(Position) :-
	% Check whether the given position is not infected.
	\+ all_infected(Position).  


is_infected(Position) :-
	% Check whether the give position is infected.
	all_infected(Position).


perceive(CurrentCell, ResultantPath, Mask, Doctor, NextCell) :-
	% Yield all the cells where agent could go.
	% Firstly, it determines all adjacent cells to the given one.
	% Then, check whether it was wisited.
	% Finally, if agent does not have or did not visited the doctor,
	% it check whether the cell is not infected.
	get_adjacent(CurrentCell, NextCell),
	\+ member(NextCell, ResultantPath),
	(
		(Mask == 1; Doctor == 1) -> true;
			not_infected(NextCell)
	).	


absolute_value(Number, Number) :-
 	% Yield absolute value of number.
	% Cover the case when number is positive.
	Number >= 0.


absolute_value(Number, Absolute) :- 
	% Yield absolute value of number.
	% Cover the case when number is negative.
	Number < 0 , 
	Absolute is -Number.


maximal(X, Y, Maximal) :-
	% Yield maximalnumber over two given.
	Maximal is max(X, Y).


distance_home([AgentX, AgentY], Distance) :-
	% Yield the Chebyshev distance for an agent position.
	home([HomeX, HomeY]),
	DistanceX is HomeX - AgentX,
	DistanceY is HomeY - AgentY,
	absolute_value(DistanceX, AbsoluteDistanceX),
	absolute_value(DistanceY, AbsoluteDistanceY),
	maximal(AbsoluteDistanceX, AbsoluteDistanceY, Distance).


% The maximal number of candidate cells is 8 by the problem statement:
% agent can move up, down, left, right, and diagonally. 
get_candidate(Candidates, CandidateCell) :-
	% Yield cell candidate with index 0. 
	nth0(0, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	% Yield cell candidate with index 1. 
	nth0(1, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	% Yield cell candidate with index 2. 
	nth0(2, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	% Yield cell candidate with index 3. 
	nth0(3, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	% Yield cell candidate with index 4. 
	nth0(4, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	% Yield cell candidate with index 5. 
	nth0(5, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	% Yield cell candidate with index 6. 
	nth0(6, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	% Yield cell candidate with index 7. 
	nth0(7, Candidates, Candidate),
	Candidate = (_, CandidateCell).


prioritize([], PrioritizedCandidates, Result) :-
	% There is nothing left in list of candidate cells.
	Result = PrioritizedCandidates.


prioritize([Cell|Tail], PrioritizedCandidates, Result) :-
	% Calculate the Chebyshev distance from candidate cell to home.
	% Use this distance as priority of this cell: the lower the priority the better.
	% Priority and position of cell are stored as structures.
	grid_size([MaximalX, MaximalY]),
	MaximalLengthPath is MaximalX * MaximalY,
	distance_home(Cell, DistanceHome),
	Priority is (DistanceHome - MaximalLengthPath) / MaximalLengthPath + 1,
	PrioritizedCandidate = (Priority, Cell),
	append(PrioritizedCandidates, [PrioritizedCandidate], ResultantPrioritizedCandidates),
	prioritize(Tail, ResultantPrioritizedCandidates, Result).


less_than_minimal_path(ResultantPath, CurrentCell) :-
	% Compare the length from current cell to home with the length of current minimal path.
	length(ResultantPath, LengthResultantPath),
	minimal_path(MinimalPath),
	distance_home(CurrentCell, DistanceHome),
	SupposedLength is LengthResultantPath + DistanceHome,
	SupposedLength < MinimalPath.



search(CurrentCell, PreviousPath, _, _, ResultantPath) :-
	% Searching algorith.
	% The agent found the home, so it is done.
	is_home(CurrentCell),
	append(PreviousPath, [CurrentCell], ResultantPath), !.


search(CurrentCell, PreviousPath, _, Doctor, NextResultantPath) :-
	% Searching algorith.
	% The agent found the mask, now it can go through infected cells.
	% Optimization: cut the solution branch if the length of current path is greater than of the minimal found.
	is_mask(CurrentCell),
	MaskNew = 1,
	append(PreviousPath, [CurrentCell], ResultantPath),
	less_than_minimal_path(ResultantPath, CurrentCell),
	setof(NextCell, perceive(CurrentCell, ResultantPath, MaskNew, Doctor, NextCell), Candidates),
	prioritize(Candidates, [], PrioritizedCandidates),
	sort(0, @<, PrioritizedCandidates, Sorted),
	get_candidate(Sorted, CandidateCell),
	search(CandidateCell, ResultantPath, MaskNew, Doctor, NextResultantPath).


search(CurrentCell, PreviousPath, Mask, _, NextResultantPath) :-
	% Searching algorith.
	% The agent found the doctor, now it can go through infected cells.
	% Optimization: cut the solution branch if the length of current path is greater than of the minimal found.
	is_doctor(CurrentCell),
	DoctorNew = 1,
	append(PreviousPath, [CurrentCell], ResultantPath),
	less_than_minimal_path(ResultantPath, CurrentCell),
	setof(NextCell, perceive(CurrentCell, ResultantPath, Mask, DoctorNew, NextCell), Candidates),
	prioritize(Candidates, [], PrioritizedCandidates),
	sort(0, @<, PrioritizedCandidates, Sorted),
	get_candidate(Sorted, CandidateCell),
	search(CandidateCell, ResultantPath, Mask, DoctorNew, NextResultantPath).


search(CurrentCell, PreviousPath, Mask, Doctor, NextResultantPath) :-
	% Searching algorith.
	% The agent did not found either the mask or doctor.
	% Optimization: cut the solution branch if the length of current path is greater than of the minimal found.
	\+ is_mask(CurrentCell), \+ is_doctor(CurrentCell),
	append(PreviousPath, [CurrentCell], ResultantPath),
	less_than_minimal_path(ResultantPath, CurrentCell),
	setof(NextCell, perceive(CurrentCell, ResultantPath, Mask, Doctor, NextCell), Candidates),
	prioritize(Candidates, [], PrioritizedCandidates),
	sort(0, @<, PrioritizedCandidates, Sorted),
	get_candidate(Sorted, CandidateCell), 
	
	search(CandidateCell, ResultantPath, Mask, Doctor, NextResultantPath).


solve(Length, Path) :-
	% Auxiliary function to run searching algorith.
	% Update the information about the minimal length of found path for oprimization. 
	search([0, 0], [], 0, 0, Path),
	length(Path, Length),
	minimal_path(MinimalPath),
	(
	   Length < MinimalPath -> retractall(minimal_path(_)), assert(minimal_path(Length))
	   ; true
	).


backtrack(Length, Path) :-
	% Find all solution to goal using setof function.
	% In case it managed to locate the optimal path the agent has won.
	% Output number of steps and optimal path.
	setof((Length, Path), solve(Length, Path), Paths),
 	nth0(0, Paths, Optimal, _),
  	Optimal = (OptimalSteps, OptimalPath),
  	StepsWithoutFirstCell is OptimalSteps - 1,
  	retractall(optimal(_)),
  	assert(optimal(OptimalPath)),
  	write("Win."), nl, write("Number of steps: "), write(StepsWithoutFirstCell), nl, write("Path: "), write(OptimalPath), nl, !.


backtrack(Length, Path) :-
	% In case no path was found, the agent has lost.
	% Set number of steps to zero and path to empty list.
	Length is 0, 
	Path = [],
	write("Lost.").