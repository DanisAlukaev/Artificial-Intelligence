%% Solution for the Home Assignment 1.

%% Student:			Danis Alukaev
%% Group:			BS19-02
%% Student ID: 		19BS551


%% Load files with the source code.

:- ensure_loaded('init.pl').
:- ensure_loaded('map.pl').
:- ensure_loaded('backtracking (shared).pl').
:- ensure_loaded('backtracking (variant 1).pl').
:- ensure_loaded('backtracking (variant 2).pl').
:- ensure_loaded('A-star (variant 1).pl').
:- ensure_loaded('A-star (variant 2).pl').
:- ensure_loaded('A-star (shared).pl').


set_map() :-
	%% Specify postions in a form of [X, Y] as it done below.
	assert(covid([1, 2])),
 	assert(covid([3, 0])),
 	assert(home([3, 7])),
	assert(mask([1, 0])),
	assert(doctor([8, 0])).


test() :-
	%% Test function.
	%% Here you can set up the environment and execute the algorithms.
	%% There are two of them:
	%% 		- Backtracking search
	%% 		- A-star search
	%% 
	%% For both of them there were implemented two variants of perception:
	%% 		- Perception of covid from the distance of 1 cell.
	%% 		- Perception of covid from the distance of 2 cells.


	%% ----------------------------------------------------------------------------------
	%% 								PREPARATIVE SECTION

	% Get rid of all out-of-date facts.
	prepare(),
	
	% [IMPORTANT] Set dimensions of the lattice.  
	assert(grid_size([9, 9])),
	
	% Initialize variables to store positions of agent, covids, home, mask doctor 
	% and starting minimal length of the path.
	initialize_variables(),

	%% ----------------------------------------------------------------------------------
	%% 								MAP GENERATION SECTION

	%% Either generate map randomly using rule generate_map()
	%%        or set map manually using rule set_map()
	%%        or use one of the prepared maps using rules 
	%% 							resolvable_map1_9x9(), ... ,resolvable_map3_9x9(), 
	%% 							impossible_map1_9x9(), ... , impossible_map2_9x9().

	%% Comment out the odd leaving only what you need:
	generate_map(),
	%% set_map(),
	%% resolvable_map1_9x9(), 
	%% resolvable_map2_9x9(), 
	%% resolvable_map3_9x9(), 
	%% resolvable_map4_9x9(), 
	%% impossible_map1_9x9(),
	%% impossible_map2_9x9(),

	% Display the original map.
	once(original_map()),

	%% ----------------------------------------------------------------------------------
	%% 								ALGORITHMS RUNNING SECTION

	%% Backtracking (variant 1).
	start_backtracking_v1(),
	
	%% Backtracking (variant 2).
	start_backtracking_v2(),

	% A-star algorithm (variant 1).
	start_a_star_v1(),

	% A-star algorithm (variant 2).
	start_a_star_v2().

