%% Solution for the Home Assignment 1.

%% Student:			Danis Alukaev
%% Group:			BS19-02
%% Student ID: 		19BS551


manhattan_distance_home([X, Y], Distance) :-
	%% Yield the Manhattan distance for an agent position.
	%% The Manhattan distance is given by |current.X - home.X| + |current.Y - home.Y|
	home([HomeX, HomeY]),
	DistanceX is HomeX - X,
	DistanceY is HomeY - Y,
	absolute_value(DistanceX, AbsoluteDistanceX),
	absolute_value(DistanceY, AbsoluteDistanceY),
	Distance is AbsoluteDistanceX + AbsoluteDistanceY.


initialize_open_closed_lists(StartingPosition):-
	%% Create facts open and closed for correspondant lists.
	%% Each entry in these lists consists of location, cost, result of priority function and location of parent cell.
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
	%% Get the location of cell.
	Cell = (CurrentCell, _, _, _),
	%% Append the location to the resultant list.
	append(Cells, [CurrentCell], CellsUpdated),
	%% Run the rule again.
	unpack_cells(Tail, CellsUpdated, Result).


restore_path(Destination, CurrentCell, Result, Path) :-
	%% Restore the path starting from the home position and finishing original position.
	%% Restoring rule reached original position.
	is_same_position(Destination, CurrentCell),
	append(Result, [CurrentCell], ReversedPath),
	reverse(ReversedPath, Path), !.


restore_path(Destination, CurrentCell, Result, Path) :-
	%% Restore the path starting from the home position and finishing in original position.
	closed(Closed),
	unpack_cells(Closed, [], ClosedCells),
	%% Get the entry with the necessary location from the closed list.
	nth0(IndexCurrentCell, ClosedCells, CurrentCell),
	nth0(IndexCurrentCell, Closed, EvaluatedCurrentCell),
	%% Determine the parent of current cell.
	EvaluatedCurrentCell = (_, _, _, ParentCurrentCell),
	%% Append parent to the resultant list.
	append(Result, [CurrentCell], NewResult),
	%% Run the rule again.
	restore_path(Destination, ParentCurrentCell, NewResult, Path).


restore_path(_, _, _, Path) :-
	%% Restore the path starting from the home position and finishing in original position.
	%% Rule fails to find the parent for the next cell. Therefore, there is no path.
	Path = [].


get_non_zero_paths([], Result, Answer) :-
	%% Yield the list of non-zero pathes out of the given list.
	%% There is nothing else in the list.
	Answer = Result.


get_non_zero_paths([PathCompound|Tail], Result, Answer) :-
	%% Yield the list of non-zero pathes out of the given list.
	%% Iteratively check the length of the path in compound and append the entry in case it is non-zero.
	PathCompound = (LengthPath, _),
	(
		%% Check whether length is non-zero.
		LengthPath \= 0 -> 
			append(Result, [PathCompound], NewResult)
			; NewResult = Result
	),
	get_non_zero_paths(Tail, NewResult, Answer).