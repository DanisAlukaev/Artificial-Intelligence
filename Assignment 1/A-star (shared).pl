%% Solution for the Home Assignment 1.

%% Student:			Danis Alukaev
%% Group:			BS19-02
%% Student ID: 		19BS551


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