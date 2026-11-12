#include "absl/container/flat_hash_set.h"
#include "board.h"
#include <algorithm>
#include <array>
#include <bit>
#include <fstream>
#include <iostream>
#include <queue>
#include <random>
#include <string>
#include <vector>

using namespace std;

constexpr Bitboard edges = Rank1 | Rank8 | FileA | FileH;
constexpr int MAX_STEPS = 25;
constexpr int MAX_ITERATIONS = 1ULL << 25;

struct BoardState {
  uint64_t deleted_squares;
  Square pieces[6];
  uint8_t step_value;
  uint8_t heuristic;
  uint8_t from[MAX_STEPS];
  uint8_t to[MAX_STEPS];

  bool operator>(const BoardState &other) const {
    return (step_value + heuristic) > (other.step_value + other.heuristic);
  }
};

struct IdentityHash {
  size_t operator()(uint64_t x) const { return x; }
};

uint64_t hashState(const BoardState &state) {
  uint64_t p = 0;
  for (int i = 0; i < 6; ++i) {
    p |= (static_cast<uint64_t>(state.pieces[i]) & 0x7F) << (i * 7);
  }

  p = (p ^ (p >> 30)) * 0xbf58476d1ce4e5b9ULL;

  uint64_t h = state.deleted_squares ^ p;
  h = (h ^ (h >> 27)) * 0x94d049bb133111ebULL;
  return h ^ (h >> 31);
}

Bitboard getValidTargets(const BoardState &state, int piece_idx, Bitboard occ) {
  int sq = static_cast<int>(state.pieces[piece_idx]);
  Bitboard unreachable = occ | state.deleted_squares;
  Bitboard valid_targets = 0;

  if (piece_idx == idx(Piece::Pawn)) {
    Bitboard p = squareIntToBitboard(sq);
    valid_targets |= (p << 8) & ~unreachable;
    valid_targets |= (p >> 8) & ~unreachable;

    Bitboard diag = 0;
    diag |= (p << 7) & ~FileH;
    diag |= (p << 9) & ~FileA;
    diag |= (p >> 7) & ~FileA;
    diag |= (p >> 9) & ~FileH;

    diag &= state.deleted_squares;
    diag &= ~occ;
    valid_targets |= diag;
  } else if (piece_idx == idx(Piece::Knight)) {
    valid_targets = knightToLocations[sq] & ~unreachable;
  } else if (piece_idx == idx(Piece::Bishop)) {
    valid_targets = getBishopQueenLocationsFast(unreachable, sq) & ~unreachable;
  } else if (piece_idx == idx(Piece::Rook)) {
    valid_targets = getRookQueenLocationsFast(unreachable, sq) & ~unreachable;
  } else if (piece_idx == idx(Piece::Queen)) {
    valid_targets = (getBishopQueenLocationsFast(unreachable, sq) |
                     getRookQueenLocationsFast(unreachable, sq)) &
                    ~unreachable;
  } else if (piece_idx == idx(Piece::King)) {
    valid_targets = kingToLocations[sq] & ~unreachable;
  }
  return valid_targets;
}

string posToString(int sq) {
  return string(1, (char)('a' + (sq % 8))) + string(1, (char)('1' + (sq / 8)));
}

string buildSolution(const BoardState &state) {
  string sol = "";
  for (int i = 0; i < state.step_value; ++i) {
    if (i > 0)
      sol += " ";
    sol += posToString(state.from[i]) + posToString(state.to[i]);
  }
  return sol;
}

uint8_t getHeuristic(const BoardState &state) {
  uint8_t exit_steps = 0;
  uint8_t extra_inner_steps = 0;
  Bitboard occ = 0;

  for (int i = 0; i < 6; ++i) {
    if (state.pieces[i] != Square::NoSquare) {
      occ |= squareIntToBitboard(static_cast<int>(state.pieces[i]));
    }
  }

  for (int i = 0; i < 5; ++i) {
    if (state.pieces[i] == Square::NoSquare) {
      continue;
    }
    exit_steps += 1;

    int sq = static_cast<int>(state.pieces[i]);
    int r = sq / 8;
    int f = sq % 8;

    if (i == idx(Piece::Pawn)) {
      extra_inner_steps += std::min(r, 7 - r) - 1;
    } else if (i == idx(Piece::Knight)) {
      if ((r == 3 || r == 4) && (f == 3 || f == 4)) {
        extra_inner_steps += 1;
      }
    }
  }

  if (exit_steps == 0) {
    return 0;
  }

  Bitboard piecesWithoutAdjacentPieces = 0;
  for (int i = 0; i < 5; ++i) {
    if (state.pieces[i] != Square::NoSquare) {
      int sq = static_cast<int>(state.pieces[i]);
      Bitboard self = squareIntToBitboard(sq);
      if ((kingToLocations[sq] & (occ & ~self)) == 0) {
        piecesWithoutAdjacentPieces |= self;
      }
    }
  }

  uint8_t adj_h = 0;
  Bitboard removed_squares = 0;

  while (piecesWithoutAdjacentPieces) {
    int sq = std::countr_zero(piecesWithoutAdjacentPieces);
    piecesWithoutAdjacentPieces &= piecesWithoutAdjacentPieces - 1;

    if ((kingToLocations[sq] & removed_squares) == 0) {
      adj_h += 1;
      removed_squares |= kingToLocations[sq];
    }
  }

  return exit_steps + std::max(extra_inner_steps, adj_h);
}

struct ReusablePq : public priority_queue<BoardState, vector<BoardState>,
                                          greater<BoardState>> {
  void clear() { c.clear(); }
  void reserve(size_t n) { c.reserve(n); }
};

bool solveAStar(const BoardState &initial_state, BoardState &goal_state,
                absl::flat_hash_set<uint64_t, IdentityHash> &visited,
                ReusablePq &pq) {
  BoardState start = initial_state;
  start.step_value = 0;
  start.heuristic = getHeuristic(start);

  pq.push(start);

  int iterations = 0;

  while (!pq.empty() && iterations < MAX_ITERATIONS) {
    BoardState current = pq.top();
    pq.pop();

    uint64_t current_hash = hashState(current);
    if (!visited.insert(current_hash).second) {
      continue;
    }

    iterations++;

    if (current.heuristic == 0) {
      goal_state = current;
      return true;
    }

    if (current.step_value >= MAX_STEPS) {
      continue;
    }

    Bitboard occ = 0;
    for (int i = 0; i < 6; ++i) {
      if (current.pieces[i] != Square::NoSquare) {
        occ |= squareIntToBitboard(static_cast<int>(current.pieces[i]));
      }
    }

    for (int i = 0; i < 6; ++i) {
      if (current.pieces[i] == Square::NoSquare) {
        continue;
      }

      int from_sq = static_cast<int>(current.pieces[i]);

      if ((kingToLocations[from_sq] & (occ & ~squareIntToBitboard(from_sq))) ==
          0)
        continue;

      Bitboard valid_targets = getValidTargets(current, i, occ);

      while (valid_targets) {
        int to_sq = std::countr_zero(valid_targets);
        valid_targets &= valid_targets - 1;

        BoardState next_state = current;

        if ((squareIntToBitboard(from_sq) & edges) == 0) {
          next_state.deleted_squares |= squareIntToBitboard(from_sq);
        }

        if (i == idx(Piece::Pawn) && (from_sq % 8) != (to_sq % 8)) {
          if ((squareIntToBitboard(to_sq) & edges) == 0) {
            next_state.deleted_squares &= ~squareIntToBitboard(to_sq);
          }
        }

        bool exited = ((squareIntToBitboard(to_sq) & edges) != 0) &&
                      (i != idx(Piece::King));
        if (exited) {
          next_state.pieces[i] = Square::NoSquare;
        } else {
          next_state.pieces[i] = static_cast<Square>(to_sq);
        }

        next_state.from[current.step_value] = from_sq;
        next_state.to[current.step_value] = to_sq;
        next_state.step_value++;

        next_state.heuristic = getHeuristic(next_state);

        if (next_state.step_value + next_state.heuristic <= MAX_STEPS) {
          uint64_t h = hashState(next_state);
          if (visited.find(h) == visited.end()) {
            pq.push(next_state);
          }
        }
      }
    }
  }
  return false;
}

static constexpr auto inner_squares = []() {
  std::array<int, 36> x;
  int i = 0;
  for (int r = 1; r <= 6; ++r) {
    for (int f = 1; f <= 6; ++f) {
      x[i++] = r * 8 + f;
    }
  }
  return x;
}();

void createBoard(mt19937 &rng, BoardState &initial_board_state,
                 string &initial_board) {
  auto squares = inner_squares;
  bool has_any_adjacent = false;

  while (!has_any_adjacent) {
    shuffle(squares.begin(), squares.end(), rng);
    initial_board_state.deleted_squares = 0;
    initial_board = "";

    Bitboard occ = 0;
    for (int i = 0; i < 6; ++i) {
      initial_board_state.pieces[i] = static_cast<Square>(squares[i]);
      initial_board += posToString(squares[i]);
      if (i < 5)
        initial_board += "-";
      occ |= squareIntToBitboard(squares[i]);
    }

    for (int i = 0; i < 6; ++i) {
      if ((kingToLocations[squares[i]] &
           (occ & ~squareIntToBitboard(squares[i]))) != 0) {
        has_any_adjacent = true;
        break;
      }
    }
  }
}

int main() {
  int num_simulations = 500;
  int infeasible_count = 0;
  int feasible_count = 0;
  vector<int> steps_count(16, 0);
  int steps_15_plus_count = 0;

  mt19937 rng(1);

  ofstream csv_file("solutions.csv");
  csv_file << "number_of_steps;initial_board;solution\n";

  absl::flat_hash_set<uint64_t, IdentityHash> visited;
  visited.reserve(MAX_ITERATIONS);

  ReusablePq pq;
  pq.reserve(MAX_ITERATIONS);

  for (int sim = 0; sim < num_simulations; ++sim) {
    BoardState initial_board_state;
    string initial_board;

    createBoard(rng, initial_board_state, initial_board);

    BoardState goal_state;
    visited.clear();
    pq.clear();

    if (solveAStar(initial_board_state, goal_state, visited, pq)) {
      feasible_count++;
      int number_of_steps = goal_state.step_value;
      if (number_of_steps >= 5 && number_of_steps <= 15) {
        steps_count[number_of_steps]++;
      } else if (number_of_steps > 15) {
        steps_15_plus_count++;
      }
      csv_file << number_of_steps << ";" << initial_board << ";"
               << buildSolution(goal_state) << "\n";
    } else {
      infeasible_count++;
    }
  }

  csv_file.close();

  std::cout << "infeasible_count " << infeasible_count << "\n";
  std::cout << "feasible_count " << feasible_count << "\n";
  for (int step_value = 5; step_value <= 15; ++step_value) {
    std::cout << step_value << " " << steps_count[step_value] << "\n";
  }
  std::cout << "15+ " << steps_15_plus_count << "\n";

  return 0;
}
