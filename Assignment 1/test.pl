:- ensure_loaded('backtracking (variant 2).pl').


test(Length, Path) :-
	% Test function.

	% Note the starting time.
	get_time(StartTime),

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

	% Backtracking approach.
	backtrack(Length, Path),

	% Display the map with found by backtracking shortest path.
	once(map_with_path()),

	% Note the finishing time.
	get_time(EndTime),
	% Output the runtime.
	ExecutionTime is EndTime - StartTime,
	write("Execution time: "), write(ExecutionTime), write(" s.").