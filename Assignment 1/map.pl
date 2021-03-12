% Solution for the Home Assignment 1.
%
% Student:			Danis Alukaev
% Group:			BS19-02
% Student ID:		19BS551


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


generate_map() :-
	% Randomly generate map, i.e. create 2 covids, 1 home, 1 mask and 1 doctor.
	write("Generating..."), nl,
	assert_dummy(),
	create_covid(),
	create_covid(),
	create_home(),
	create_mask(),
	create_doctor(),
	reinitialize_variables().


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
