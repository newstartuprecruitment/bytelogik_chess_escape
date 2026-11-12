#include "board.h"
#include <algorithm>
#include <bit>
#include <fstream>
#include <iostream>
#include <queue>
#include <random>
#include <string>
#include <unordered_set>
#include <vector>

using namespace std;

constexpr Bitboard edges = Rank1 | Rank8 | FileA | FileH;
constexpr int MAX_STEPS = 25;
constexpr int MAX_ITERATIONS = 1ULL << 24;

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
    p |= (static_cast<uint64_t>(state.pieces[i]) << (i * 7));
  }
  uint64_t h = state.deleted_squares ^ (p * 0x9e3779b185e6ULL);
  h ^= h >> 33;
  h *= 0xff51afd7ed558ccdULL;
  h ^= h >> 33;
  h *= 0xc4ceb9fe1a85ec53ULL;
  h ^= h >> 33;
  return h;
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
  uint8_t h = 0;
  for (int i = 0; i < 5; ++i) {
    if (state.pieces[i] == Square::NoSquare) {
      continue;
    }
    int sq = static_cast<int>(state.pieces[i]);
    int r = sq / 8;
    int f = sq % 8;

    if (i == idx(Piece::Pawn)) {
      h += std::min({r, 7 - r, f, 7 - f});
    } else if (i == idx(Piece::Knight)) {
      if ((r == 3 || r == 4) && (f == 3 || f == 4)) {
        h += 2;
      } else {
        h += 1;
      }
    } else {
      h += 1;
    }
  }
  return h;
}

bool solveAStar(const BoardState &initial_state, BoardState &goal_state) {
  priority_queue<BoardState, vector<BoardState>, greater<BoardState>> pq;
  unordered_set<uint64_t, IdentityHash> visited;
  visited.reserve(131072);

  BoardState start = initial_state;
  start.step_value = 0;
  start.heuristic = getHeuristic(start);

  pq.push(start);
  visited.insert(hashState(start));

  int iterations = 0;

  while (!pq.empty() && iterations < MAX_ITERATIONS) {
    BoardState current = pq.top();
    pq.pop();
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
          if (visited.insert(h).second) {
            pq.push(next_state);
          }
        }
      }
    }
  }
  return false;
}

int main() {
  int num_simulations = 10;
  int infeasible_count = 0;
  int feasible_count = 0;
  vector<int> steps_count(16, 0);
  int steps_15_plus_count = 0;

  mt19937 rng(1);

  vector<int> inner_squares;
  inner_squares.reserve(36);
  for (int r = 1; r <= 6; ++r) {
    for (int f = 1; f <= 6; ++f) {
      inner_squares.push_back(r * 8 + f);
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

      Bitboard occ = 0;
      for (int i = 0; i < 6; ++i) {
        initial_board_state.pieces[i] = static_cast<Square>(inner_squares[i]);
        initial_board += posToString(inner_squares[i]);
        if (i < 5)
          initial_board += "-";
        occ |= squareIntToBitboard(inner_squares[i]);
      }

      for (int i = 0; i < 6; ++i) {
        if ((kingToLocations[inner_squares[i]] &
             (occ & ~squareIntToBitboard(inner_squares[i]))) != 0) {
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
               << buildSolution(goal_state) << "\n";
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
