% Solution for the Home Assignment 1.
%
% Student:		Danis Alukaev
% Group:		BS19-02
% Student ID:	19BS551


prepare() :-
	retractall(grid_size(_)),
	retractall(agent(_)),
	retractall(covid(_)),
	retractall(home(_)),
	retractall(mask(_)),
	retractall(doctor(_)),
	retractall(minimal_path(_)).

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


all_adjacent([X1, Y1], [X2, Y2]) :- 
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
 	assert(minimal_path(100000)).


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


%% ----------------- PREPARED MAPS -----------------------------------------
%  The following section contatins ready-to-use maps of the size 9x9.
%  In order to try one of them, comment out the neccessary map in test() rule.


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
		all_adjacent(CovidPosition, InfectedPosition)
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
	all_adjacent(CurrentCell, NextCell),
	\+ member(NextCell, ResultantPath),
	(
		(Mask == 1; Doctor == 1) -> true;
			not_infected(NextCell)
	).	


absolute_value(Number, Absolute) :- 
	% Yield absolute value of number.
	Number < 0 , 
	Absolute is -Number.

absolute_value(Number, Number) :- 
	Number >= 0.


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


get_candidate(Candidates, CandidateCell) :-
	nth0(0, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	nth0(1, Candidates, Candidate),
	Candidate = (_, CandidateCell).

get_candidate(Candidates, CandidateCell) :-
	nth0(2, Candidates, Candidate),
	Candidate = (_, CandidateCell).

get_candidate(Candidates, CandidateCell) :-
	nth0(3, Candidates, Candidate),
	Candidate = (_, CandidateCell).

get_candidate(Candidates, CandidateCell) :-
	nth0(4, Candidates, Candidate),
	Candidate = (_, CandidateCell).

get_candidate(Candidates, CandidateCell) :-
	nth0(5, Candidates, Candidate),
	Candidate = (_, CandidateCell).

get_candidate(Candidates, CandidateCell) :-
	nth0(6, Candidates, Candidate),
	Candidate = (_, CandidateCell).

get_candidate(Candidates, CandidateCell) :-
	nth0(7, Candidates, Candidate),
	Candidate = (_, CandidateCell).

get_candidate(Candidates, CandidateCell) :-
	nth0(8, Candidates, Candidate),
	Candidate = (_, CandidateCell).

prioritize([], PrioritizedCandidates, Result) :-
	Result = PrioritizedCandidates.


prioritize([Cell|Tail], PrioritizedCandidates, Result) :-
	distance_home(Cell, DistanceHome),
	PrioritizedCandidate = (DistanceHome, Cell),
	append(PrioritizedCandidates, [PrioritizedCandidate], ResultantPrioritizedCandidates),
	prioritize(Tail, ResultantPrioritizedCandidates, Result).


search(CurrentCell, PreviousPath, Mask, Doctor, ResultantPath) :-
	% Searching algorith.
	% The agent found the home, so it is done.
	is_home(CurrentCell),
	append(PreviousPath, [CurrentCell], ResultantPath),
	length(ResultantPath, LengthResultantPath), !.


search(CurrentCell, PreviousPath, Mask, Doctor, NextResultantPath) :-
	% Searching algorith.
	% The agent found the mask, now it can go through infected cells.
	% Optimization: cut the solution branch if the length of current path is greater than of the minimal found.
	is_mask(CurrentCell),
	MaskNew = 1,
	append(PreviousPath, [CurrentCell], ResultantPath),

	length(ResultantPath, LengthResultantPath),
	minimal_path(MinimalPath),
	distance_home(CurrentCell, DistanceHome),
	SupposedLength is LengthResultantPath + DistanceHome,
	SupposedLength < MinimalPath,

	setof(NextCell, perceive(CurrentCell, ResultantPath, MaskNew, Doctor, NextCell), Candidates),
	prioritize(Candidates, [], PrioritizedCandidates),
	sort(0, @<, PrioritizedCandidates, Sorted),
	get_candidate(Sorted, CandidateCell),
	search(CandidateCell, ResultantPath, MaskNew, Doctor, NextResultantPath).


search(CurrentCell, PreviousPath, Mask, Doctor, NextResultantPath) :-
	% Searching algorith.
	% The agent found the doctor, now it can go through infected cells.
	% Optimization: cut the solution branch if the length of current path is greater than of the minimal found.
	is_doctor(CurrentCell),
	DoctorNew = 1,
	append(PreviousPath, [CurrentCell], ResultantPath),

	length(ResultantPath, LengthResultantPath),
	minimal_path(MinimalPath),
	distance_home(CurrentCell, DistanceHome),
	SupposedLength is LengthResultantPath + DistanceHome,
	SupposedLength < MinimalPath,

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
	
	length(ResultantPath, LengthResultantPath),
	minimal_path(MinimalPath),
	distance_home(CurrentCell, DistanceHome),
	SupposedLength is LengthResultantPath + DistanceHome,
	SupposedLength < MinimalPath,

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
	% Otherwise, the agent has lost.
	setof((Length, Path), solve(Length, Path), Solutions),
 	nth0(0, Solutions, Optimal, _),
  	Optimal = (OptimalSteps, OptimalPath),
  	StepsWithoutFirstCell is OptimalSteps - 1,
  	write("Win."), nl, write("Number of steps: "), write(StepsWithoutFirstCell), nl, write("Path: "), write(OptimalPath), !.

backtrack(Length, Path) :-
	Length is 0, 
	Path = [],
	write("Lost.").


test(Length, Path) :-
	% Test function.

	% Get rid of all out-of-date facts.
	prepare(),

	% Set dimensions of the lattice.  
	assert(grid_size([9, 9])),

	% Initialize variables to store positions of agent, covids, home, mask doctor 
	% and starting minimal length of the path.
	initialize_variables(),

	% Either generate map randomly using rule generate_map()
	%        or set map manually using rule set_map()
	%        or use one of the prepared maps using rules resolvable_map1_9x9(), ... ,
	%        resolvable_map3_9x9(), impossible_map1_9x9(), ... , impossible_map2_9x9().

	% Comment out the odd:
	% generate_map(),
	set_map(),
	% resolvable_map1_9x9(), 
	% resolvable_map2_9x9(), 
	% resolvable_map3_9x9(), 
	% impossible_map1_9x9(),
	% impossible_map2_9x9(),

	% Backtracking approach.
	backtrack(Length, Path).
