%% Solution for the Home Assignment 1.

%% Student:			Danis Alukaev
%% Group:			BS19-02
%% Student ID: 		19BS551


is_home(Position) :-
	%% Check whether specified position is home.
	home(HomePosition),
	is_same_position(Position, HomePosition).


is_mask(Position) :-
	%% Check whether specified position is mask.
	mask(MaskPosition),
	is_same_position(Position, MaskPosition).


is_doctor(Position) :-
	%% Check whether specified position is doctor.
	doctor(DoctorPosition),
	is_same_position(Position, DoctorPosition).


all_infected(InfectedPosition) :-
	%% Yield all infected positions, including covid cells and their Moore neighborhood.
	(
		covid(CovidPosition),
		get_adjacent(CovidPosition, InfectedPosition)
	);
	(
		covid(InfectedPosition)
	).


not_infected(Position) :-
	%% Check whether the given position is not infected.
	\+ all_infected(Position).  


is_infected(Position) :-
	%% Check whether the give position is infected.
	all_infected(Position).


perceive(CurrentCell, ResultantPath, Mask, Doctor, NextCell) :-
	%% Yield all the cells where agent could go.
	%% Firstly, it determines all adjacent cells to the given one.
	%% Then, check whether it was wisited.
	%% Finally, if agent does not have or did not visited the doctor,
	%% it check whether the cell is not infected.
	%% Determine all adjacent cells to the given one.
	get_adjacent(CurrentCell, NextCell),
	%% Check whether cell was visited.
	\+ member(NextCell, ResultantPath),
	(
		%% If agent does not have the mask or did not visited the doctor, check whether the cell is not infected.
		%% Otherwise, this cell is blocked.
		(Mask == 1; Doctor == 1) -> 
			true
			; not_infected(NextCell)
	).


absolute_value(Number, Number) :-
 	%% Yield absolute value of number.
	%% Cover the case when number is positive.
	Number >= 0.


absolute_value(Number, Absolute) :- 
	% Yield absolute value of number.
	% Cover the case when number is negative.
	Number < 0 , 
	Absolute is -Number.


maximal(X, Y, Maximal) :-
	%% Yield maximal number over two given.
	Maximal is max(X, Y).


distance_home([X, Y], Distance) :-
	%% Yield the Chebyshev distance for the given position.
	home([HomeX, HomeY]),
	DistanceX is HomeX - X,
	DistanceY is HomeY - Y,
	absolute_value(DistanceX, AbsoluteDistanceX),
	absolute_value(DistanceY, AbsoluteDistanceY),
	maximal(AbsoluteDistanceX, AbsoluteDistanceY, Distance).


%% The maximal number of candidate cells is 8 by the problem statement:
%% agent can move up, down, left, right, and diagonally. 
get_candidate(Candidates, CandidateCell) :-
	%% Yield cell candidate with index 0. 
	nth0(0, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	%% Yield cell candidate with index 1. 
	nth0(1, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	%% Yield cell candidate with index 2. 
	nth0(2, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	%% Yield cell candidate with index 3. 
	nth0(3, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	%% Yield cell candidate with index 4. 
	nth0(4, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	%% Yield cell candidate with index 5. 
	nth0(5, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	%% Yield cell candidate with index 6. 
	nth0(6, Candidates, Candidate),
	Candidate = (_, CandidateCell).


get_candidate(Candidates, CandidateCell) :-
	%% Yield cell candidate with index 7. 
	nth0(7, Candidates, Candidate),
	Candidate = (_, CandidateCell).


less_than_minimal_path(ResultantPath, CurrentCell) :-
	%% Rule used to determine wheter the path from current cell might be shorter than the minimal one.
	%% Compare the length from current cell to home with the length of current minimal path.
	length(ResultantPath, LengthResultantPath),
	minimal_path(MinimalPath),
	distance_home(CurrentCell, DistanceHome),
	SupposedLength is LengthResultantPath + DistanceHome,
	SupposedLength < MinimalPath.
