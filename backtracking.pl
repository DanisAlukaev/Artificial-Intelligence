%% ----------------- MAP GENERATION ----------------------------------------

% check whether two coordinates are the same
is_same_position([X1, Y1], [X2, Y2]) :-
  X1 == X2,
  Y1 == Y2.


% yield vacant random position for covid 
get_random_position_covid([X_random, Y_random]) :-
  b_getval(grid_size, [X_max, Y_max]),
  repeat,
  random(0, X_max, X_random),
  random(0, Y_max, Y_random),
  b_getval(covid1, [X_covid1, Y_covid1]),
  b_getval(covid2, [X_covid2, Y_covid2]),
  (
    is_same_position([X_random, Y_random], [X_covid1, Y_covid1]) ->
      fail
    ; is_same_position([X_random, Y_random], [X_covid2, Y_covid2]) ->
      fail
    ; X_random == 0, Y_random == 0 ->
      fail
    ;!
  ).


% check whether position does exist in lattice
coordinate_exists([X, Y]) :- 
  nb_getval(grid_size, [X_max, Y_max]), 
  X < X_max, 
  X >= 0, 
  Y < Y_max, 
  Y >= 0.


% yield all adjacent to the given cell positions  
all_adjacent([X, Y], [X1, Y1]) :- 
  (X1 is X + 1, Y1 is Y, coordinate_exists([X1, Y]));
  (X1 is X - 1, Y1 is Y, coordinate_exists([X1, Y]));
  (Y1 is Y + 1, X1 is X, coordinate_exists([X, Y1]));
  (Y1 is Y - 1, X1 is X, coordinate_exists([X, Y1]));
  (X1 is X + 1, Y1 is Y + 1, coordinate_exists([X1, Y1]));
  (X1 is X + 1, Y1 is Y - 1, coordinate_exists([X1, Y1]));
  (X1 is X - 1, Y1 is Y + 1, coordinate_exists([X1, Y1]));
  (X1 is X - 1, Y1 is Y - 1, coordinate_exists([X1, Y1])).


% yield vacant not infected random position
get_random_position_not_covid([X_random, Y_random]) :-
  nb_getval(grid_size, [X_max, Y_max]),
  repeat,
  random(0, X_max, X_random),
  random(0, Y_max, Y_random),
  b_getval(covid1, [X_covid1, Y_covid1]),
  b_getval(covid2, [X_covid2, Y_covid2]),
  b_getval(home, [X_home, Y_home]),
  b_getval(mask, [X_mask, Y_mask]),
  b_getval(doctor, [X_doctor, Y_doctor]),
  (
    X_random == 0, Y_random == 0 ->
      fail
    ; is_same_position([X_random, Y_random], [X_covid1, Y_covid1]) ->
      fail
    ; is_same_position([X_random, Y_random], [X_covid2, Y_covid2]) ->
      fail
    ; is_same_position([X_random, Y_random], [X_home, Y_home]) ->
      fail
    ; is_same_position([X_random, Y_random], [X_mask, Y_mask]) ->
      fail
    ; is_same_position([X_random, Y_random], [X_doctor, Y_doctor]) ->
      fail
    ; all_adjacent([X_covid1, Y_covid1], [X_random, Y_random]) ->
      fail
    ; all_adjacent([X_covid2, Y_covid2], [X_random, Y_random]) ->
      fail
    ; !
  ).


% create first cell with covid
create_covid1() :-
  get_random_position_covid([X_random, Y_random]),
  b_setval(covid1, [X_random, Y_random]).


% create second cell with covid
create_covid2() :-
  get_random_position_covid([X_random, Y_random]),
  b_setval(covid2, [X_random, Y_random]).


% create cell with home
create_home() :-
  get_random_position_not_covid([X_random, Y_random]),
  b_setval(home, [X_random, Y_random]).


% create cell with home
create_mask() :-
  get_random_position_not_covid([X_random, Y_random]),
  b_setval(mask, [X_random, Y_random]).


% create cell with doctor
create_doctor() :-
  get_random_position_not_covid([X_random, Y_random]),
  b_setval(doctor, [X_random, Y_random]).


% set values of variables to non-existent postitons to simplify code.%
initialize_variables() :-
  b_setval(agent, [0, 0]),
  b_setval(mask_taken, 0),
  b_setval(doctor_visited, 0),
  b_setval(covid1, [-1, -1]),
  b_setval(covid2, [1, -1]),
  b_setval(home, [-1, -1]),
  b_setval(mask, [-1, -1]),
  assert(minimal_path(100000)),
  b_setval(doctor, [-1, -1]).


% create 2 covids, 1 home, 1 mask, 1 doctor
generate_map() :-
  create_covid1(),
  create_covid2(),
  create_home(),
  create_mask(),
  create_doctor().

% specify positions of objects manually
set_map() :-
  %% b_setval(covid1, [0, 2]),
  %% b_setval(covid2, [6, 6]),
  %% b_setval(home, [3, 0]),
  %% b_setval(mask, [5, 2]),
  %% b_setval(doctor, [3, 3]).
  b_setval(covid1, [1, 2]),
  b_setval(covid2, [3, 0]),
  b_setval(home, [3, 2]),
  b_setval(mask, [1, 4]),
  b_setval(doctor, [4, 3]).

% print postions of agent, covids, home, mask and doctor
print_objects() :-
  b_getval(agent, Agent),
  b_getval(covid1, Covid1),
  b_getval(covid2, Covid2),
  b_getval(home, Home),
  b_getval(mask, Mask),
  b_getval(doctor, Doctor),
  % output the positions
  write("Agent: "), write(Agent), nl,
  write("Covid-1: "), write(Covid1), nl,
  write("Covid-2: "), write(Covid2), nl,
  write("Home: "), write(Home), nl,
  write("Mask: "), write(Mask), nl,
  write("Doctor: "), write(Doctor), nl, nl.

%% ----------------- SEARCHING ----------------------------------------

% check whether specified position is home
is_home(Position) :-
  b_getval(home, Position_home),
  is_same_position(Position, Position_home).


all_infected([X, Y]) :-
  b_getval(covid1, [X_covid1, Y_covid1]),
  all_adjacent([X_covid1, Y_covid1], [X, Y]).


all_infected([X, Y]) :-
  b_getval(covid2, [X_covid2, Y_covid2]),
  all_adjacent([X_covid2, Y_covid2], [X, Y]).


all_infected([X, Y]) :-
  b_getval(covid1, [X, Y]).


all_infected([X, Y]) :-
  b_getval(covid2, [X, Y]).


not_infected([X, Y]) :-
  \+ all_infected([X, Y]).  


not_visited(Position) :-
  b_getval(visited, Visited),
  \+ member(Position, Visited).


is_mask(Position) :-
  b_getval(mask, Position_mask),
  is_same_position(Position, Position_mask).


is_doctor(Position) :-
  b_getval(doctor, Position_doctor),
  is_same_position(Position, Position_doctor).


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
  % set dimensions of the lattice % 
  nb_setval(grid_size, [5, 5]),
  initialize_variables(),
  
  % either generate map randomly using generate_map()
  % or set map manually using set_map()
  % comment out the odd
  % generate_map(),
  set_map(),

  print_objects(),
  backtrack(Length, Path).
