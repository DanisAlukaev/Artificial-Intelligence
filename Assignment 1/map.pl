%% Solution for the Home Assignment 1.

%% Student:			Danis Alukaev
%% Group:			BS19-02
%% Student ID: 		19BS551


is_same_position([X1, Y1], [X2, Y2]) :-
	%% Check whether two positions are the same by comparison of coordinates.
	X1 == X2, 
	Y1 == Y2.


is_covid(Position) :-
	%% Check whether the given position belongs to covid cell.
	covid(CovidPosition),
	is_same_position(Position, CovidPosition).


get_random_position_covid(RandomPosition) :-
	%% Yield vacant random position for covid.
	%% Repeatedly generate random position until it does not violate the conditions.
	%% Proposed position cannot
	%% 	- be the initial agent position
	%% 	- already belong to covid
	%% Get the grid size.
	grid_size([MaximalX, MaximalY]),
	repeat,
	%% Generate random position.
	random(0, MaximalX, RandomX),
	random(0, MaximalY, RandomY),
	%% Get the agent position.
	agent(AgentPosition),
	%% Pack the coordinates.
	RandomPosition = [RandomX, RandomY],
	(
		%% Check for constraints.
		is_covid(RandomPosition) -> 
			fail
		; is_same_position(RandomPosition, AgentPosition) ->
			fail
		;!
	).


coordinate_exists([X, Y]) :- 
	%% Check whether position does exist in the lattice.
	%% The coordinates of the cell should be in the range of 0..MaximalX for X 
	%% and 0..MaximalY for Y. 
	grid_size([MaximalX, MaximalY]),
	X @>= 0, X @< MaximalX, 
 	Y @>= 0, Y @< MaximalY.


get_adjacent([X1, Y1], [X2, Y2]) :- 
	%% Yield Moore neighborhood for a given position.
	%% For a give cell C it finds all the coordinates for cells denoted by X.
	%% 	
	%%  	* * * * *  			
	%% 		* X X X *  
	%% 		* X C X *
	%% 		* X X X *
	%%  	* * * * * 
	%% 
	(X2 is X1 + 1, Y2 is Y1, coordinate_exists([X2, Y1]));
	(X2 is X1 + 1, Y2 is Y1 + 1, coordinate_exists([X2, Y2]));
	(Y2 is Y1 - 1, X2 is X1, coordinate_exists([X1, Y2]));
	(X2 is X1 - 1, Y2 is Y1 + 1, coordinate_exists([X2, Y2]));
	(X2 is X1 - 1, Y2 is Y1, coordinate_exists([X2, Y1]));
	(X2 is X1 - 1, Y2 is Y1 - 1, coordinate_exists([X2, Y2]));
	(Y2 is Y1 + 1, X2 is X1, coordinate_exists([X1, Y2]));
	(X2 is X1 + 1, Y2 is Y1 - 1, coordinate_exists([X2, Y2])).


get_random_position_not_covid(RandomPosition) :-
	%% Yield vacant not infected random position.
	%% Repeatedly generate random position until it does not violate the conditions.
	%% Proposed position cannot
	%% 	- be the initial agent position
	%% 	- be the home position
	%% 	- be the mask position
	%% 	- be the doctor position
	%% 	- be infected
	%% Get the grid size.
	grid_size([MaximalX, MaximalY]),
	repeat,
	%% Generate random coordinates.
	random(0, MaximalX, RandomX),
	random(0, MaximalY, RandomY),
	%% Get positions of agent, home, mask, doctor.
	agent(AgentPosition),
	home(HomePosition),
	mask(MaskPosition),
	doctor(DoctorPosition),
	%% Pack the coordinats.
	RandomPosition = [RandomX, RandomY],
	(
		%% Check for constraints.
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
	%% Initialize covid in the lattice with the random position.
	get_random_position_covid(RandomPosition),
	assert(covid(RandomPosition)),
	write("Covid position: "), write(RandomPosition), nl.


create_home() :-
	%% Initialize home in the lattice with the random position.
	get_random_position_not_covid(RandomPosition),
	assert(home(RandomPosition)),
	write("Home position: "), write(RandomPosition), nl.


create_mask() :-
	%% Initialize mask in the lattice with the random position.
	get_random_position_not_covid(RandomPosition),
	assert(mask(RandomPosition)),
	write("Mask position: "), write(RandomPosition), nl.


create_doctor() :-
	%% Initialize doctor in the lattice with the random position.
	get_random_position_not_covid(RandomPosition),
	assert(doctor(RandomPosition)),
	write("Doctor position: "), write(RandomPosition), nl, nl.


generate_map() :-
	%% Randomly generate map, i.e. create 2 covids, 1 home, 1 mask and 1 doctor.
	write("Generating..."), nl,
	assert_dummy(),
	create_covid(),
	create_covid(),
	create_home(),
	create_mask(),
	create_doctor(),
	reinitialize_variables().


print_map() :-	
	%% Rule outputing the map.
	%% Entry point for the rule.
	%% Starts ouputing from the last row.
	grid_size([MaximalX, _]),
	MaximalIndX is MaximalX - 1,
	nl, write(" "),
	print_map(MaximalIndX, 0).


print_map(X, _) :-
	%% Rule outputing the map.
	%% The rule iteratively decrease the index of the cell along X-axis,
	%% so when this index becomes negative, the outputing of map is finished.
	X == -1, nl, !.


print_map(X, Y) :-
	%% Rule outputing the map.
	%% When the index of cell along Y-axis becomes equal to maximal possible,
	%% move the carriage to the next line.
	grid_size([_, MaximalY]),
	Y == MaximalY, 
	nl, write(" "),
	NextX is X - 1, NextY is 0,
	print_map(NextX, NextY).


print_map(X, Y) :-
	%% Rule outputing the map.
	%% Output the corresponding symbol for object in the cell:
	%% - actor position 		A
	%% - home position 			H
	%% - cell in found path 	X
	%% - covid cell 			C
	%% - infected cell 			I
	%% - doctor position 		D
	%% - mask position 			M 
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


original_map() :-
	%% Rule outputing the original map.
	nl, write("Original map: "), nl,
	print_map().


map_with_path() :-
	%% Rule outputing the map with found path.
	nl, write("Original map with shortest path shown: "), nl,
	print_map().


%% ----------------- PREPARED MAPS -----------------------------------------
%  The following section contatins ready-to-use maps of the size 9x9.
%  To try one of them, comment out the neccessary map in test() rule.


resolvable_map1_9x9() :-
	assert(covid([0, 2])),
 	assert(covid([6, 6])),
 	assert(home([8, 6])),
	assert(mask([5, 2])),
	assert(doctor([3, 3])).


resolvable_map2_9x9() :-
 	assert(covid([1, 2])),
 	assert(covid([3, 0])),
 	assert(home([3, 7])),
	assert(mask([1, 0])),
	assert(doctor([8, 0])).


resolvable_map3_9x9() :-
 	assert(covid([3, 0])),
 	assert(covid([4, 3])),
 	assert(home([8, 1])),
	assert(mask([2, 8])),
	assert(doctor([3, 8])).


resolvable_map4_9x9() :-
 	assert(covid([3, 6])),
 	assert(covid([8, 3])),
 	assert(home([4, 8])),
	assert(mask([3, 0])),
	assert(doctor([2, 1])).


impossible_map1_9x9() :-
 	assert(covid([2, 0])),
 	assert(covid([0, 2])),
 	assert(home([1, 6])),
	assert(mask([5, 2])),
	assert(doctor([6, 6])).


impossible_map2_9x9() :-
 	assert(covid([1, 5])),
 	assert(covid([3, 7])),
 	assert(home([1, 8])),
	assert(mask([1, 7])),
	assert(doctor([0, 7])).
