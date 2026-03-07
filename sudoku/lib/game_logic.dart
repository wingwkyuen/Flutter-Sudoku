import 'dart:async';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

import 'constants.dart';

/// Handles all game logic for Sudoku
class SudokuGameLogic {
  late List<List<List<int>>> gameList;
  late List<List<int>> game;
  late List<List<int>> gameCopy;
  late List<List<int>> gameSolved;
  bool gameOver = false;
  int timesCalled = 0;

  /// Get a new Sudoku game with the specified difficulty
  Future<List<List<List<int>>>> getNewGame(
      [String difficulty = DEFAULT_DIFFICULTY]) async {
    int emptySquares;
    switch (difficulty) {
      case 'test':
        emptySquares = TEST_EMPTY_SQUARES;
        break;
      case 'beginner':
        emptySquares = BEGINNER_EMPTY_SQUARES;
        break;
      case 'easy':
        emptySquares = EASY_EMPTY_SQUARES;
        break;
      case 'medium':
        emptySquares = MEDIUM_EMPTY_SQUARES;
        break;
      case 'hard':
        emptySquares = HARD_EMPTY_SQUARES;
        break;
      default:
        emptySquares = TEST_EMPTY_SQUARES;
        break;
    }
    SudokuGenerator generator = SudokuGenerator(emptySquares: emptySquares);
    return [generator.newSudoku, generator.newSudokuSolved];
  }

  /// Create a deep copy of the game grid
  static List<List<int>> copyGrid(List<List<int>> grid) {
    return grid.map((row) => [...row]).toList();
  }

  /// Initialize game board from scratch or load new game
  Future<void> setGame(int mode, [String difficulty = DEFAULT_DIFFICULTY]) async {
    if (mode == 1) {
      // Create empty board with independent rows
      game = List<List<int>>.generate(
          BOARD_SIZE, (_) => List<int>.filled(BOARD_SIZE, 0));
      gameCopy = List<List<int>>.generate(
          BOARD_SIZE, (_) => List<int>.filled(BOARD_SIZE, 0));
      gameSolved = List<List<int>>.generate(
          BOARD_SIZE, (_) => List<int>.filled(BOARD_SIZE, 0));
    } else {
      gameList = await getNewGame(difficulty);
      game = gameList[0];
      gameCopy = copyGrid(game);
      gameSolved = gameList[1];
    }
  }

  /// Show the solution
  void showSolution() {
    game = copyGrid(gameSolved);
    gameOver = true;
  }

  /// Check if the current game state is solved
  bool isSolved() {
    try {
      return SudokuUtilities.isSolved(game);
    } on InvalidSudokuConfigurationException {
      return false;
    }
  }

  /// Update a cell with a new value
  void updateCell(int row, int col, int value) {
    game[row][col] = value;
  }

  /// Restore game to the initially loaded state
  void restartGame() {
    game = copyGrid(gameCopy);
    gameOver = false;
  }

  /// Reset for a new game
  void reset() {
    timesCalled = 0;
    gameOver = false;
  }
}
