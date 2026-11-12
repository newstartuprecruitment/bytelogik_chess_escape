#pragma once

#include <array>
#include <bit>
#include <cstddef>
#include <cstdint>
#include <immintrin.h>

#define ALWAYS_INLINE inline

using Bitboard = uint64_t;

constexpr Bitboard All_Squares = 0xFFFFFFFFFFFFFFFFULL;

constexpr Bitboard FileA = 0x0101010101010101ULL;
constexpr Bitboard FileB = 0x0202020202020202ULL;
constexpr Bitboard FileC = 0x0404040404040404ULL;
constexpr Bitboard FileD = 0x0808080808080808ULL;
constexpr Bitboard FileE = 0x1010101010101010ULL;
constexpr Bitboard FileF = 0x2020202020202020ULL;
constexpr Bitboard FileG = 0x4040404040404040ULL;
constexpr Bitboard FileH = 0x8080808080808080ULL;

constexpr Bitboard Rank1 = 0x00000000000000FFULL;
constexpr Bitboard Rank2 = 0x000000000000FF00ULL;
constexpr Bitboard Rank3 = 0x0000000000FF0000ULL;
constexpr Bitboard Rank4 = 0x00000000FF000000ULL;
constexpr Bitboard Rank5 = 0x000000FF00000000ULL;
constexpr Bitboard Rank6 = 0x0000FF0000000000ULL;
constexpr Bitboard Rank7 = 0x00FF000000000000ULL;
constexpr Bitboard Rank8 = 0xFF00000000000000ULL;

constexpr Bitboard promotionRanks = Rank8 | Rank1;
constexpr Bitboard nonPromotionRanks = ~promotionRanks;

constexpr Bitboard Square_A1 = (1ULL << 0);
constexpr Bitboard Square_B1 = (1ULL << 1);
constexpr Bitboard Square_C1 = (1ULL << 2);
constexpr Bitboard Square_D1 = (1ULL << 3);
constexpr Bitboard Square_E1 = (1ULL << 4);
constexpr Bitboard Square_F1 = (1ULL << 5);
constexpr Bitboard Square_G1 = (1ULL << 6);
constexpr Bitboard Square_H1 = (1ULL << 7);

constexpr Bitboard Square_A8 = (1ULL << 56);
constexpr Bitboard Square_B8 = (1ULL << 57);
constexpr Bitboard Square_C8 = (1ULL << 58);
constexpr Bitboard Square_D8 = (1ULL << 59);
constexpr Bitboard Square_E8 = (1ULL << 60);
constexpr Bitboard Square_F8 = (1ULL << 61);
constexpr Bitboard Square_G8 = (1ULL << 62);
constexpr Bitboard Square_H8 = (1ULL << 63);

// clang-format off
enum class Colour : uint8_t { White = 0, Black, Both };

enum class Piece : uint8_t { Pawn = 0, Knight, Bishop, Rook, Queen, King, None };

enum class Square : uint8_t {
  A1 = 0, B1, C1, D1, E1, F1, G1, H1,
  A2, B2, C2, D2, E2, F2, G2, H2,
  A3, B3, C3, D3, E3, F3, G3, H3,
  A4, B4, C4, D4, E4, F4, G4, H4,
  A5, B5, C5, D5, E5, F5, G5, H5,
  A6, B6, C6, D6, E6, F6, G6, H6,
  A7, B7, C7, D7, E7, F7, G7, H7,
  A8, B8, C8, D8, E8, F8, G8, H8,
  NoSquare
};

// clang-format on

static constexpr ALWAYS_INLINE Bitboard squareIntToBitboard(int sq) {
  return (1ULL << static_cast<size_t>(sq));
}

static constexpr ALWAYS_INLINE size_t idx(Piece p) {
  return static_cast<size_t>(p);
}

static constexpr auto knightToLocations = []() {
  std::array<Bitboard, 64> knightLocations{};

  for (auto sq = 0; sq < 64; sq++) {
    Bitboard locations{};
    Bitboard knightLocation = squareIntToBitboard(sq);

    locations |= (knightLocation & ~FileH) << 17;
    locations |= (knightLocation & ~FileA) << 15;
    locations |= (knightLocation & ~(FileG | FileH)) << 10;
    locations |= (knightLocation & ~(FileA | FileB)) << 6;

    locations |= (knightLocation & ~FileH) >> 15;
    locations |= (knightLocation & ~FileA) >> 17;
    locations |= (knightLocation & ~(FileG | FileH)) >> 6;
    locations |= (knightLocation & ~(FileA | FileB)) >> 10;

    knightLocations[sq] = locations;
  }

  return knightLocations;
}();

static constexpr auto kingToLocations = []() {
  std::array<Bitboard, 64> kingLocations{};

  for (auto sq = 0; sq < 64; sq++) {
    Bitboard locations{};
    Bitboard kingLocation = squareIntToBitboard(sq);

    locations |= (kingLocation & ~FileH) << 9;
    locations |= (kingLocation & ~FileA) << 7;
    locations |= (kingLocation & ~FileA) >> 9;
    locations |= (kingLocation & ~FileH) >> 7;

    locations |= (kingLocation) >> 8;
    locations |= (kingLocation) << 8;

    locations |= (kingLocation & ~FileH) << 1;
    locations |= (kingLocation & ~FileA) >> 1;

    kingLocations[sq] = locations;
  }

  return kingLocations;
}();

static constexpr std::array<Bitboard, 64> rookPathsFast = []() {
  std::array<Bitboard, 64> paths{};

  for (int sq = 0; sq < 64; sq++) {
    int rank = sq / 8;
    int file = sq % 8;

    for (int r = rank + 1; r < 7; r++) {
      paths[sq] |= squareIntToBitboard(r * 8 + file);
    }

    for (int r = rank - 1; r > 0; r--) {
      paths[sq] |= squareIntToBitboard(r * 8 + file);
    }

    for (int f = file - 1; f > 0; f--) {
      paths[sq] |= squareIntToBitboard(rank * 8 + f);
    }

    for (int f = file + 1; f < 7; f++) {
      paths[sq] |= squareIntToBitboard(rank * 8 + f);
    }
  }

  return paths;
}();

static constexpr std::array<Bitboard, 64> bishopPathsFast = []() {
  std::array<Bitboard, 64> paths{};

  for (int sq = 0; sq < 64; sq++) {
    int rank = sq / 8;
    int file = sq % 8;

    for (int r = rank + 1, f = file - 1; r < 7 && f > 0; r++, f--) {
      paths[sq] |= squareIntToBitboard(r * 8 + f);
    }

    for (int r = rank + 1, f = file + 1; r < 7 && f < 7; r++, f++) {
      paths[sq] |= squareIntToBitboard(r * 8 + f);
    }

    for (int r = rank - 1, f = file - 1; r > 0 && f > 0; r--, f--) {
      paths[sq] |= squareIntToBitboard(r * 8 + f);
    }

    for (int r = rank - 1, f = file + 1; r > 0 && f < 7; r--, f++) {
      paths[sq] |= squareIntToBitboard(r * 8 + f);
    }
  }

  return paths;
}();

struct RookData {
  Bitboard rookPathsFast;
  Bitboard squareOffsetsForRooks;
};

struct BishopData {
  Bitboard bishopPathsFast;
  Bitboard squareOffsetsForBishops;
};

static constexpr std::array<struct RookData, 64> rookData = []() {
  std::array<struct RookData, 64> data{};
  uint32_t currentOffset = 0;
  for (int sq = 0; sq < 64; sq++) {
    data[sq].rookPathsFast = rookPathsFast[sq];
    data[sq].squareOffsetsForRooks = currentOffset;
    currentOffset += (1ULL << std::popcount(rookPathsFast[sq]));
  }
  return data;
}();

static constexpr std::array<struct BishopData, 64> bishopData = []() {
  std::array<struct BishopData, 64> data{};
  uint32_t currentOffset = 0;
  for (int sq = 0; sq < 64; sq++) {
    data[sq].bishopPathsFast = bishopPathsFast[sq];
    data[sq].squareOffsetsForBishops = currentOffset;
    currentOffset += (1ULL << std::popcount(bishopPathsFast[sq]));
  }
  return data;
}();

constexpr ALWAYS_INLINE Bitboard
computeRookToLocations(const Bitboard allPieces, int sq) {
  Bitboard locations = 0;
  int rank = sq / 8;
  int file = sq % 8;

  for (int r = rank + 1; r < 8; r++) {
    locations |= squareIntToBitboard(r * 8 + file);
    if (squareIntToBitboard(r * 8 + file) & allPieces) {
      break;
    }
  }

  for (int r = rank - 1; r >= 0; r--) {
    locations |= squareIntToBitboard(r * 8 + file);
    if (squareIntToBitboard(r * 8 + file) & allPieces) {
      break;
    }
  }

  for (int f = file - 1; f >= 0; f--) {
    locations |= squareIntToBitboard(rank * 8 + f);
    if (squareIntToBitboard(rank * 8 + f) & allPieces) {
      break;
    }
  }

  for (int f = file + 1; f < 8; f++) {
    locations |= squareIntToBitboard(rank * 8 + f);
    if (squareIntToBitboard(rank * 8 + f) & allPieces) {
      break;
    }
  }

  return locations;
}

constexpr ALWAYS_INLINE Bitboard
computeBishopToLocations(const Bitboard allPieces, int sq) {
  Bitboard locations = 0;
  int rank = sq / 8;
  int file = sq % 8;

  for (int r = rank + 1, f = file - 1; r < 8 && f >= 0; r++, f--) {
    locations |= squareIntToBitboard(r * 8 + f);
    if (squareIntToBitboard(r * 8 + f) & allPieces) {
      break;
    }
  }

  for (int r = rank + 1, f = file + 1; r < 8 && f < 8; r++, f++) {
    locations |= squareIntToBitboard(r * 8 + f);
    if (squareIntToBitboard(r * 8 + f) & allPieces) {
      break;
    }
  }

  for (int r = rank - 1, f = file - 1; r >= 0 && f >= 0; r--, f--) {
    locations |= squareIntToBitboard(r * 8 + f);
    if (squareIntToBitboard(r * 8 + f) & allPieces) {
      break;
    }
  }

  for (int r = rank - 1, f = file + 1; r >= 0 && f < 8; r--, f++) {
    locations |= squareIntToBitboard(r * 8 + f);
    if (squareIntToBitboard(r * 8 + f) & allPieces) {
      break;
    }
  }

  return locations;
}

inline const std::array<Bitboard, 102400> rooksToLocations = []() {
  std::array<Bitboard, 102400> locations{};
  uint32_t currentOffset = 0;
  for (int sq = 0; sq < 64; sq++) {
    Bitboard currentPath = rookPathsFast[sq];
    uint8_t numberOfBits = std::popcount(currentPath);
    uint16_t maxNumOfCombinations = 1ULL << numberOfBits;

    for (uint64_t i = 0; i < maxNumOfCombinations; i++) {
      Bitboard occupancy = _pdep_u64(i, rookPathsFast[sq]);
      locations[currentOffset + i] = computeRookToLocations(occupancy, sq);
    }
    currentOffset += maxNumOfCombinations;
  }

  return locations;
}();

inline const std::array<Bitboard, 5248> bishopsToLocations = []() {
  std::array<Bitboard, 5248> locations{};
  uint16_t currentOffset = 0;
  for (int sq = 0; sq < 64; sq++) {
    Bitboard currentPath = bishopPathsFast[sq];
    uint8_t numberOfBits = std::popcount(currentPath);
    uint16_t maxNumOfCombinations = 1ULL << numberOfBits;

    for (uint64_t i = 0; i < maxNumOfCombinations; i++) {
      Bitboard occupancy = _pdep_u64(i, bishopPathsFast[sq]);
      locations[currentOffset + i] = computeBishopToLocations(occupancy, sq);
    }
    currentOffset += maxNumOfCombinations;
  }

  return locations;
}();

constexpr ALWAYS_INLINE Bitboard
getRookQueenLocationsFast(const Bitboard pieces, int sq) {
  const auto idx = _pext_u64(pieces, rookData[sq].rookPathsFast);
  Bitboard locations =
      rooksToLocations[rookData[sq].squareOffsetsForRooks + idx];
  return locations;
}

constexpr ALWAYS_INLINE Bitboard
getBishopQueenLocationsFast(const Bitboard pieces, int sq) {
  const auto idx = _pext_u64(pieces, bishopData[sq].bishopPathsFast);
  Bitboard locations =
      bishopsToLocations[bishopData[sq].squareOffsetsForBishops + idx];
  return locations;
}
