#include <algorithm>
#include <cmath>
#include <fstream>
#include <iostream>
#include <queue>
#include <random>
#include <string>
#include <unordered_set>
#include <vector>

using namespace std;

enum PieceType {
  PAWN = 0,
  KNIGHT = 1,
  BISHOP = 2,
  ROOK = 3,
  QUEEN = 4,
  KING = 5
};

struct Position {
  int rank;
  int file;
  bool operator==(const Position &other) const {
    return rank == other.rank && file == other.file;
  }
};

struct BoardState {
  Position pieces[6];
  uint64_t deleted_squares;
  int step_value;
  int heuristic;
  string solution;

  bool operator>(const BoardState &other) const {
    return (step_value + heuristic) > (other.step_value + other.heuristic);
  }
};

string posToString(int rank, int file) {
  if (rank == -1 || file == -1)
    return "exited";
  string s = "";
  s += (char)('a' + file);
  s += (char)('1' + rank);
  return s;
}

bool isEdge(int rank, int file) {
  return rank == 0 || rank == 7 || file == 0 || file == 7;
}

bool isDeleted(uint64_t deleted_squares, int rank, int file) {
  if (isEdge(rank, file))
    return false;
  return (deleted_squares >> (rank * 8 + file)) & 1ULL;
}

void setDeleted(uint64_t &deleted_squares, int rank, int file, bool val) {
  if (isEdge(rank, file))
    return;
  if (val) {
    deleted_squares |= (1ULL << (rank * 8 + file));
  } else {
    deleted_squares &= ~(1ULL << (rank * 8 + file));
  }
}

bool isOccupiedByPiece(const BoardState &state, int rank, int file) {
  for (int i = 0; i < 6; ++i) {
    if (state.pieces[i].rank == rank && state.pieces[i].file == file) {
      return true;
    }
  }
  return false;
}

bool isNotReachable(const BoardState &state, int rank, int file) {
  return isOccupiedByPiece(state, rank, file) ||
         isDeleted(state.deleted_squares, rank, file);
}

bool hasAdjacentPiece(const BoardState &state, int piece_idx) {
  int r = state.pieces[piece_idx].rank;
  int f = state.pieces[piece_idx].file;
  for (int i = 0; i < 6; ++i) {
    if (i == piece_idx)
      continue;
    int pr = state.pieces[i].rank;
    int pf = state.pieces[i].file;
    if (pr == -1)
      continue;
    if (abs(r - pr) <= 1 && abs(f - pf) <= 1) {
      return true;
    }
  }
  return false;
}

int getHeuristic(const BoardState &state) {
  int h = 0;
  for (int i = 0; i < 5; ++i) {
    if (state.pieces[i].rank != -1) {
      h++;
    }
  }
  return h;
}

uint64_t hashState(const BoardState &state) {
  uint64_t h = state.deleted_squares;
  for (int i = 0; i < 6; ++i) {
    uint64_t p = (state.pieces[i].rank == -1)
                     ? 64
                     : (state.pieces[i].rank * 8 + state.pieces[i].file);
    h ^= (p << (i * 7));
    h = (h << 13) | (h >> 51);
  }
  return h;
}

vector<Position> getValidMoves(const BoardState &state, int piece_idx) {
  vector<Position> moves;
  int r = state.pieces[piece_idx].rank;
  int f = state.pieces[piece_idx].file;
  if (r == -1)
    return moves;
  if (!hasAdjacentPiece(state, piece_idx))
    return moves;

  if (piece_idx == PAWN) {
    int dr[] = {-1, 1};
    for (int d : dr) {
      int nr = r + d;
      int nf = f;
      if (nr >= 0 && nr < 8 && !isNotReachable(state, nr, nf)) {
        moves.push_back({nr, nf});
      }
    }
    int diag_r[] = {-1, -1, 1, 1};
    int diag_f[] = {-1, 1, -1, 1};
    for (int i = 0; i < 4; ++i) {
      int nr = r + diag_r[i];
      int nf = f + diag_f[i];
      if (nr >= 0 && nr < 8 && nf >= 0 && nf < 8) {
        if (isDeleted(state.deleted_squares, nr, nf) &&
            !isOccupiedByPiece(state, nr, nf)) {
          moves.push_back({nr, nf});
        }
      }
    }
  } else if (piece_idx == KNIGHT) {
    int dr[] = {-2, -2, -1, -1, 1, 1, 2, 2};
    int df[] = {-1, 1, -2, 2, -2, 2, -1, 1};
    for (int i = 0; i < 8; ++i) {
      int nr = r + dr[i];
      int nf = f + df[i];
      if (nr >= 0 && nr < 8 && nf >= 0 && nf < 8) {
        if (!isNotReachable(state, nr, nf)) {
          moves.push_back({nr, nf});
        }
      }
    }
  } else if (piece_idx == BISHOP || piece_idx == ROOK || piece_idx == QUEEN) {
    int dirs[8][2] = {{-1, -1}, {-1, 1}, {1, -1}, {1, 1},
                      {-1, 0},  {1, 0},  {0, -1}, {0, 1}};
    int start_d = (piece_idx == ROOK) ? 4 : 0;
    int end_d = (piece_idx == BISHOP) ? 4 : 8;
    for (int i = start_d; i < end_d; ++i) {
      int nr = r + dirs[i][0];
      int nf = f + dirs[i][1];
      while (nr >= 0 && nr < 8 && nf >= 0 && nf < 8) {
        if (!isNotReachable(state, nr, nf)) {
          moves.push_back({nr, nf});
        } else {
          break;
        }
        nr += dirs[i][0];
        nf += dirs[i][1];
      }
    }
  } else if (piece_idx == KING) {
    int dr[] = {-1, -1, -1, 0, 0, 1, 1, 1};
    int df[] = {-1, 0, 1, -1, 1, -1, 0, 1};
    for (int i = 0; i < 8; ++i) {
      int nr = r + dr[i];
      int nf = f + df[i];
      if (nr >= 0 && nr < 8 && nf >= 0 && nf < 8) {
        if (!isNotReachable(state, nr, nf)) {
          moves.push_back({nr, nf});
        }
      }
    }
  }
  return moves;
}

bool solveAStar(const BoardState &initial_state, BoardState &goal_state) {
  priority_queue<BoardState, vector<BoardState>, greater<BoardState>> pq;
  unordered_set<uint64_t> visited;

  BoardState start = initial_state;
  start.step_value = 0;
  start.heuristic = getHeuristic(start);
  start.solution = "";

  pq.push(start);
  visited.insert(hashState(start));

  int iterations = 0;
  int max_iterations = 100000;

  while (!pq.empty() && iterations < max_iterations) {
    BoardState current = pq.top();
    pq.pop();
    iterations++;

    if (current.heuristic == 0) {
      goal_state = current;
      return true;
    }

    if (current.step_value >= 25) {
      continue;
    }

    for (int i = 0; i < 6; ++i) {
      if (current.pieces[i].rank == -1)
        continue;
      vector<Position> moves = getValidMoves(current, i);
      for (const auto &move : moves) {
        BoardState next_state = current;
        int old_r = current.pieces[i].rank;
        int old_f = current.pieces[i].file;

        setDeleted(next_state.deleted_squares, old_r, old_f, true);

        if (i == PAWN && old_f != move.file) {
          setDeleted(next_state.deleted_squares, move.rank, move.file, false);
        }

        if (isEdge(move.rank, move.file) && i != KING) {
          next_state.pieces[i] = {-1, -1};
        } else {
          next_state.pieces[i] = move;
        }

        next_state.step_value = current.step_value + 1;
        next_state.heuristic = getHeuristic(next_state);

        string move_str =
            posToString(old_r, old_f) + posToString(move.rank, move.file);
        if (next_state.solution.empty()) {
          next_state.solution = move_str;
        } else {
          next_state.solution += " " + move_str;
        }

        if (next_state.step_value + next_state.heuristic <= 25) {
          uint64_t h = hashState(next_state);
          if (visited.find(h) == visited.end()) {
            visited.insert(h);
            pq.push(next_state);
          }
        }
      }
    }
  }
  return false;
}

int main() {
  int num_simulations = 500;
  int infeasible_count = 0;
  int feasible_count = 0;
  vector<int> steps_count(16, 0);
  int steps_15_plus_count = 0;

  mt19937 rng(1);

  vector<Position> inner_squares;
  for (int r = 1; r <= 6; ++r) {
    for (int f = 1; f <= 6; ++f) {
      inner_squares.push_back({r, f});
    }
  }

  ofstream csv_file("solutions.csv");
  csv_file << "number_of_steps;initial_board;solution\n";

  for (int sim = 0; sim < num_simulations; ++sim) {
    BoardState initial_board_state;
    string initial_board;
    bool has_any_adjacent = false;

    while (!has_any_adjacent) {
      shuffle(inner_squares.begin(), inner_squares.end(), rng);
      initial_board_state.deleted_squares = 0;
      initial_board = "";

      for (int i = 0; i < 6; ++i) {
        initial_board_state.pieces[i] = inner_squares[i];
        initial_board +=
            posToString(inner_squares[i].rank, inner_squares[i].file);
        if (i < 5)
          initial_board += "-";
      }

      for (int i = 0; i < 6; ++i) {
        if (hasAdjacentPiece(initial_board_state, i)) {
          has_any_adjacent = true;
          break;
        }
      }
    }

    BoardState goal_state;
    if (solveAStar(initial_board_state, goal_state)) {
      feasible_count++;
      int number_of_steps = goal_state.step_value;
      if (number_of_steps >= 5 && number_of_steps <= 15) {
        steps_count[number_of_steps]++;
      } else if (number_of_steps > 15) {
        steps_15_plus_count++;
      }
      csv_file << number_of_steps << ";" << initial_board << ";"
               << goal_state.solution << "\n";
    } else {
      infeasible_count++;
    }
  }

  csv_file.close();

  cout << "infeasible_count " << infeasible_count << "\n";
  cout << "feasible_count " << feasible_count << "\n";
  for (int step_value = 5; step_value <= 15; ++step_value) {
    cout << step_value << " " << steps_count[step_value] << "\n";
  }
  cout << "15+ " << steps_15_plus_count << "\n";

  return 0;
}