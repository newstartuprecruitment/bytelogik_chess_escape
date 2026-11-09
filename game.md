8x8 chessboard. 6 unique chess pieces. single colour.
rules of chess apply for pieces. a pawn is bidirectional. up and down only. pawn can capture diagonally a deleted square in any of the 4 diagonals to make it regular.
adjacent squares are all 8 squares next to a square.
contraints:
if a piece leaves a square then that square is deleted. in chess terms it is occupied by a friendly piece. knight can jump over the deleted squares. deleted squares not used in adjacent square checks. if a piece reaches a edge square it exits the board. king cannot exit but can reach the edge square. edge squares are not deleted.
A piece can go to a new square only if the from square has an adjacent square occupied by another piece.

goal : all pieces except king should exit the board.

initial setup:
board will have pieces in random squares in the inner 6x6 board. the game will have atleast 1 solution.


BFS algorithm:
Algorithm Setup
Initialize variable infeasible_count to zero
Initialize variable feasible_count to zero
Initialize dictionary steps_count mapping integer keys 5 through 15 to zero
Initialize variable steps_15_plus_count to zero
To avoid repetions and cycles use zobrist hashing.
Main Iteration Loop
Repeat n times
Select 6 unique coordinate pairs of row and column from the inner board where row is between 1 and 6 inclusive and column is between 1 and 6 inclusive.
atleast 2 of these should be adjacent. 
Assign the King, Queen, Rook, Bishop, Knight, and Pawn to these initial positions
Initialize is_deleted as an empty set to track deleted squares
Create an initial state containing the piece locations and the is_deleted set
Initialize a queue for breadth first search containing a tuple of the initial state and an integer steps set to zero
Initialize a visited set containing the initial state
Set boolean variable goal_reached to false

Breadth First Search
While queue is not empty
Remove current_state and steps from the front of the queue

If current_state contains exactly one piece and that piece is the King
Set goal_reached to true
Increment feasible_count
If steps is between 5 and 15 inclusive, increment the corresponding key in steps_count
If steps is strictly greater than 15, increment steps_15_plus_count
Break out of the breadth first search loop for this iteration

For each piece in current_state
Identify the starting row and starting column of the piece
Identify all reachable target_row and target_column coordinates based on specific rules
The target square must not contain another piece
The Queen, Rook, and Bishop move along straight or diagonal lines but are stopped immediately if they encounter any piece or any square present in is_deleted
The Knight moves in an L-shape and ignores all blocking squares or squares in is_deleted. cannot land on deleted squares
The King moves exactly one square in any of the 8 directions into squares not in is_deleted
The Pawn moves exactly one square vertically up or down into empty squares not in is_deleted
The Pawn moves exactly one square diagonally only if the target square is currently present in is_deleted

Evaluate the adjacency constraint by checking all 8 squares surrounding the from square
Squares in is_deleted are strictly ignored during this adjacency check

If the adjacency constraint is satisfied
Create next_state by duplicating current_state
Update the position of the moving piece to target_row and target_column in next_state

If the starting row of the piece is between 1 and 6 inclusive and the starting column is between 1 and 6 inclusive
Add the starting row and starting column to is_deleted in next_state

If the moving piece is a Pawn and target_row and target_column are in is_deleted
Remove target_row and target_column from is_deleted in next_state

If target_row is 0 or 7, or target_column is 0 or 7
If the moving piece is not the King
Remove the piece entirely from next_state

If next_state is not present in visited
Add next_state to visited
Add next_state and steps plus 1 to the back of the queue

End of Breadth First Search
If goal_reached is false
Increment infeasible_count

Output Generation
Output infeasible_count
Output feasible_count
For each step_value from 5 to 15, output step_value and the corresponding count from steps_count
Output 15+ and the value of steps_15_plus_count

Time Complexity Analysis
Let N represent the number of iterations which is fixed at 10000
Let V represent the maximum number of valid reachable states from any given initial configuration
Let E represent the maximum number of valid transitions from any state
The breadth first search evaluates each valid reachable state and its valid transitions exactly once per iteration
Generating moves, validating constraints, and confirming adjacency takes constant time bounded by the maximum 8 by 8 board dimensions
The time complexity for a single iteration is O(V + E)
The overall worst-case time complexity of the algorithm is O(N * (V + E))
The theoretical upper bound for V is extremely large, derived from the combinations of piece locations and subsets of the 36 deletable inner squares, but is practically heavily restricted by the strict piece adjacency constraints and edge exits.

greedy BFS algorithm:
similar to bfs but uses a heuristic function to get approximate count instead of exact count.