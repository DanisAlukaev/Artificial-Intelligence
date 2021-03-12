% Solution for the Home Assignment 1.
%
% Student:			Danis Alukaev
% Group:			BS19-02
% Student ID:		19BS551


:- ensure_loaded('init.pl').
:- ensure_loaded('map.pl').
:- ensure_loaded('backtracking (shared).pl').
:- ensure_loaded('backtracking (variant 1).pl').
:- ensure_loaded('backtracking (variant 2).pl').


set_map() :-
	% Specify postions in a form of [X, Y] as it done below.
	assert(covid([4, 1])),
 	assert(covid([7, 6])),
 	assert(home([7, 1])),
	assert(mask([1, 7])),
	assert(doctor([4, 4])).


test() :-
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
	% set_map(),
	% resolvable_map1_9x9(), 
	% resolvable_map2_9x9(), 
	 resolvable_map3_9x9(), 
	% impossible_map1_9x9(),
	% impossible_map2_9x9(),

	% Display the map.
	once(original_map()),

	% Backtracking (variant 1).
	start_backtracking_v1(),
	% Backtracking (variant 2).
	start_backtracking_v2().