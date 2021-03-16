%% Solution for the Home Assignment 1.

%% Student:			Danis Alukaev
%% Group:			BS19-02
%% Student ID: 		19BS551


prepare() :-
	%% Remove all previously created facts.
	retractall(grid_size(_)),
	retractall(agent(_)),
	retractall(covid(_)),
	retractall(home(_)),
	retractall(mask(_)),
	retractall(doctor(_)),
	retractall(minimal_path(_)),
	retractall(optimal(_)).


reinitialize_variables() :-
	%% Remove supportive facts.
	retractall(covid([-1, -1])),
	retractall(home([-1, -1])),
	retractall(mask([-1, -1])),
	retractall(doctor([-1, -1])).


assert_dummy() :-
	%% Supprtive facts.
	assert(covid([-1, -1])),
	assert(home([-1, -1])),
	assert(mask([-1, -1])),
	assert(doctor([-1, -1])).


initialize_variables() :-
	%% Set the original position of an agent, starting length of minimal path, and
	%% create dummy positions for a home, mask, doctor to simplify code for the 
	%% rule get_random_position_not_covid().
	assert(agent([0, 0])),
	assert(optimal([])),
	grid_size([MaximalX, MaximalY]),
	MinimalPathLength is  MaximalX * MaximalY + 1, 
 	assert(minimal_path(MinimalPathLength)).