% Solution for the Home Assignment 1.
%
% Student:		Danis Alukaev
% Group:		BS19-02
% Student ID:	19BS551


%% ----------------- MAP GENERATION ----------------------------------------

prepare() :-
	retractall(grid_size(_)),
	retractall(agent(_)),
	retractall(covid(_)),
	retractall(home(_)),
	retractall(mask(_)),
	retractall(doctor(_)),
	retractall(minimal_path(_)).


% check whether two coordinates are the same
is_same_position([X1, Y1], [X2, Y2]) :-
	X1 == X2, Y1 == Y2.


% yield vacant random position for covid 
get_random_position_covid(RandomPosition) :-
	grid_size([MaximalX, MaximalY]),
	repeat,
	random(0, MaximalX, RandomX),
	random(0, MaximalY, RandomY),
	covid(CovidPosition),
	agent(AgentPosition),
	RandomPosition = [RandomX, RandomY],
	(
	is_same_position(RandomPosition, CovidPosition) ->
		fail
	; is_same_position(RandomPosition, AgentPosition) ->
		fail
	;!
	).


% check whether position does exist in lattice
coordinate_exists([X, Y]) :- 
	grid_size([MaximalX, MaximalY]),
	X @>= 0, X @< MaximalX, 
 	Y @>= 0, Y @< MaximalY.


% yield all adjacent to the given cell positions  
all_adjacent([X1, Y1], [X2, Y2]) :- 
	(X2 is X1 + 1, Y2 is Y1, coordinate_exists([X2, Y1]));
	(X2 is X1 - 1, Y2 is Y1, coordinate_exists([X2, Y1]));
	(Y2 is Y1 + 1, X2 is X1, coordinate_exists([X1, Y2]));
	(Y2 is Y1 - 1, X2 is X1, coordinate_exists([X1, Y2]));
	(X2 is X1 + 1, Y2 is Y1 + 1, coordinate_exists([X2, Y2]));
	(X2 is X1 + 1, Y2 is Y1 - 1, coordinate_exists([X2, Y2]));
	(X2 is X1 - 1, Y2 is Y1 + 1, coordinate_exists([X2, Y2]));
	(X2 is X1 - 1, Y2 is Y1 - 1, coordinate_exists([X2, Y2])).


% yield vacant not infected random position
get_random_position_not_covid(RandomPosition) :-
	grid_size([MaximalX, MaximalY]),
	repeat,
	random(0, MaximalX, RandomX),
	random(0, MaximalY, RandomY),
	agent(AgentPosition),
	covid(CovidPosition),
	home(HomePosition),
	mask(MaskPosition),
	doctor(DoctorPosition),
	RandomPosition = [RandomX, RandomY],
	(
	is_same_position(RandomPosition, AgentPosition) ->
	  	fail
	; is_same_position(RandomPosition, CovidPosition) ->
	  	fail
	; is_same_position(RandomPosition, HomePosition) ->
	  	fail
	; is_same_position(RandomPosition, MaskPosition) ->
	  	fail
	; is_same_position(RandomPosition, DoctorPosition) ->
	  	fail
	; all_adjacent(CovidPosition, RandomPosition) ->
		fail
	; all_adjacent(CovidPosition, RandomPosition) ->
		fail
	; !
	).


initialize_variables() :-
	% Set dimensions of the lattice.  
	assert(grid_size([9, 9])),
	assert(agent([0, 0])),
	assert(covid([-1, -1])),
	assert(home([-1, -1])),
	assert(mask([-1, -1])),
	assert(doctor([-1, -1])),
 	assert(minimal_path(100000)).


% create cell with covid
create_covid() :-
	get_random_position_covid(RandomPosition),
	assert(covid(RandomPosition)),
	write("Covid position: "), write(RandomPosition), nl.


% create cell with home
create_home() :-
	get_random_position_not_covid(RandomPosition),
	assert(home(RandomPosition)),
	write("Home position: "), write(RandomPosition), nl.


% create cell with home
create_mask() :-
	get_random_position_not_covid(RandomPosition),
	assert(mask(RandomPosition)),
	write("Mask position: "), write(RandomPosition), nl.


% create cell with doctor
create_doctor() :-
	get_random_position_not_covid(RandomPosition),
	assert(doctor(RandomPosition)),
	write("Doctor position: "), write(RandomPosition), nl, nl.


reinitialize_variables() :-
	retractall(covid([-1, -1])),
	retractall(home([-1, -1])),
	retractall(mask([-1, -1])),
	retractall(doctor([-1, -1])).

% create 2 covids, 1 home, 1 mask, 1 doctor
generate_map() :-
	create_covid(),
	create_covid(),
	create_home(),
	create_mask(),
	create_doctor(),
	reinitialize_variables().


% specify positions of objects manually
set_map() :-
	assert(covid([0, 2])),
 	assert(covid([6, 6])),
 	assert(home([3, 0])),
	assert(mask([5, 2])),
	assert(doctor([3, 3])).


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


impossible_map1_9x9() :-
 	assert(covid([1, 2])),
 	assert(covid([3, 0])),
 	assert(home([3, 2])),
	assert(mask([1, 4])),
	assert(doctor([4, 3])).


%% ----------------- SEARCHING ----------------------------------------

% check whether specified position is home
is_home(Position) :-
	home(HomePosition),
	is_same_position(Position, HomePosition).


is_mask(Position) :-
	mask(MaskPosition),
	is_same_position(Position, MaskPosition).


is_doctor(Position) :-
	doctor(DoctorPosition),
	is_same_position(Position, DoctorPosition).


all_infected(InfectedPosition) :-
	(
		covid(CovidPosition),
		all_adjacent(CovidPosition, InfectedPosition)
	);
	(
		covid(InfectedPosition)
	).

not_infected(Position) :-
	\+ all_infected(Position).  


% TODO: minimal length
% TODO: use knowledge where home is
perceive(CurrentCell, ResultantPath, Mask, Doctor, NextCell) :-
	all_adjacent(CurrentCell, NextCell),
	\+ member(NextCell, ResultantPath),
	(
	(Mask == 1; Doctor == 1) -> true;
	not_infected(NextCell)
	).


%% Found the home.
search(CurrentCell, PreviousPath, Mask, Doctor, ResultantPath) :-
	is_home(CurrentCell),
	append(PreviousPath, [CurrentCell], ResultantPath), !,
	length(ResultantPath, LengthResultantPath).


%% Found the mask.
search(CurrentCell, PreviousPath, Mask, Doctor, NextResultantPath) :-
	is_mask(CurrentCell),
	MaskNew = 1,
	append(PreviousPath, [CurrentCell], ResultantPath),

	length(ResultantPath, LengthResultantPath),
	minimal_path(MinimalPath),
	LengthResultantPath < MinimalPath,

	perceive(CurrentCell, ResultantPath, MaskNew, Doctor, NextCell),
	search(NextCell, ResultantPath, MaskNew, Doctor, NextResultantPath).


%% Found the doctor.
search(CurrentCell, PreviousPath, Mask, Doctor, NextResultantPath) :-
	is_doctor(CurrentCell),
	DoctorNew = 1,
	append(PreviousPath, [CurrentCell], ResultantPath),

	length(ResultantPath, LengthResultantPath),
	minimal_path(MinimalPath),
	LengthResultantPath < MinimalPath,

	perceive(CurrentCell, ResultantPath, Mask, DoctorNew, NextCell),
	search(NextCell, ResultantPath, Mask, DoctorNew, NextResultantPath).


search(CurrentCell, PreviousPath, Mask, Doctor, NextResultantPath) :-
	\+ is_mask(CurrentCell), \+ is_doctor(CurrentCell),
	append(PreviousPath, [CurrentCell], ResultantPath),
	
	length(ResultantPath, LengthResultantPath),
	minimal_path(MinimalPath),
	LengthResultantPath < MinimalPath,

	perceive(CurrentCell, ResultantPath, Mask, Doctor, NextCell),
	search(NextCell, ResultantPath, Mask, Doctor, NextResultantPath).

%% Add Lost.

solve(Length, Path) :-
	search([0, 0], [], 0, 0, Path),
	length(Path, Length),
	minimal_path(MinimalPath),
	(
	   Length < MinimalPath -> retractall(minimal_path(_)), assert(minimal_path(Length))
	   ; true
	).


backtrack(Length, Path) :-
	setof((Length, Path), solve(Length, Path), Solutions),
 	nth0(0, Solutions, Optimal, _),
  	Optimal = (OptimalSteps, OptimalPath),
  	write("Win."), nl, write("Number of steps: "), write(OptimalSteps), nl, write("Path: "), write(OptimalPath), !.


backtrack(Length,Path):-
	write("Lost.").


test(Length, Path) :-
	% Get rid of all out-of-date facts.
	prepare(),

	% Initialize variables to store positions of agent, covids, home, mask doctor 
	% and starting minimal length of the path.
	initialize_variables(),

	% Either generate map randomly using rule generate_map()
	%        or set map manually using rule set_map()
	%        or use one of the prepared maps using rules resolvable_map1_9x9(), 
	%        resolvable_map2_9x9(), impossible_map1_9x9().

	% Comment out the odd:
	generate_map(),
	% set_map(),
	% resolvable_map1_9x9(), 
	% resolvable_map2_9x9(), 
	% impossible_map1_9x9(),

	% Backtracking approach.
	backtrack(Length, Path).
