/* Author: Jacob Collins
 * Grid.dart
 * CINS 467
 * Spring 2023
 */
import 'dart:core';
import 'tetraminos.dart';

class Grid {
  int gridHeight = 20; 
  int gridWidth = 10;
  var grid = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  ];
  
  // Initializer for grid given a height and width
  void setDims(height, width) {
    gridHeight = height;
    gridWidth = width;
    List<List<int>> temp = [];
    for (int i = 0; i < gridHeight; i++) {
      temp.add(List<int>.filled(width, 0));
    }
    grid = temp;
  }

  int getElement(x, y) {
    int val = grid[y][x];
    if (val > 7) {
      val -= 7;
    }
    return val;
  }

  void showGrid(List<dynamic> grid) {
    for (int i = 0; i < grid.length; i++) {
      print(grid[i]);
    }
  }

  bool solidify(int x, int y, Tetramino piece) {
    var block = piece.getBlock();
    if (checkClearance(x, y, piece.getBlock())) {
      for (int i = 0; i < block.length; i++) {
        for (int j = 0; j < block[i].length; j++) {
          if (block[i][j] == 1) {
            grid[y+i][x+j] = piece.getType(); // Color based on type (static piece)
          }
        }
      } 
      return true;
    } else { return false; }
  }

  bool move(int x1, int y1, int x2, int y2, Tetramino piece1, Tetramino piece2) {
    var block1 = piece1.getBlock();
    var block2 = piece2.getBlock();
    if (checkClearance(x2, y2, piece2.getBlock())) {
      // Erase old tiles
      for (int i = 0; i < block1.length; i++) {
        for (int j = 0; j < block1[i].length; j++) {
          // Erase dynamic piece (checks block which is always 1)
          if (block1[i][j] == 1) { grid[y1+i][x1+j] = 0; }
        }
      }
      // Draw new tiles
      for (int i = 0; i < block2.length; i++) {
        for (int j = 0; j < block2[i].length; j++) {
          // Draw dynamic piece
          if (block2[i][j] == 1) { grid[y2+i][x2+j] = piece2.getNum(); } 
        }
      }
    } else { return false; }
    return true;
  }

  /* Rotate a block on the grid
   * @param int x - The x position
   * @param int y - The y position
   * @param Tetramino piece - The piece to be rotated
   * @param int rotation - The rotation to apply
   *                     - 1 => Clockwise rotation
   *                     - -1 => Counterclockwise rotation
   */
  bool rotate(int x, int y, Tetramino piece, int rotation) {
    var block1 = piece.getBlock();
    var block2 = [];
    bool fits = false;
    switch (rotation) {
      case 1: { block2 = piece.getCwBlock(); } break;
      case -1: { block2 = piece.getCcwBlock(); } break;
      default: {}
    }
    fits = checkClearance(x, y, block2); 
    if (fits) {
      // Erase old tiles
      for (int i = 0; i < block1.length; i++) {
        for (int j = 0; j < block1[i].length; j++) {
          // Erase dynamic piece (block contents always 1)
          if (block1[i][j] == 1) { grid[y+i][x+j] = 0; }
        }
      }
      // Draw new tiles
      for (int i = 0; i < block2.length; i++) {
        for (int j = 0; j < block2[i].length; j++) {
          // Draw dynamic piece (block contents always 1)
          if (block2[i][j] == 1) { grid[y+i][x+j] = piece.getNum(); }
        }
      }
      switch (rotation) {
        case 1: { piece.rotateCw(); } break;
        case -1: { piece.rotateCcw(); } break;
        default: {}
      }
    } else { return false; }
    return true;
  }

  bool checkClearance(int x, int y, List block) { // SWITCH FROM PIECE TO BLOCK
    // Root position of piece
    int height = y; int width = x;
    for (int i = block.length-1; i >= 0; i--) { // Upwards by row 
          height = y + i;
      for (int j = block[i].length-1; j >= 0; j--) { // Rightwards by column
          width = x + j;
        if (block[i][j] == 1) {
          // Check bounds
          if (width >= gridWidth || width < 0) { return false; }
          if (height >= gridHeight || height < 0) { return false; }
          // Check collision (Values set to 1-7 for static)
          if (grid[height][width] != 0 && grid[height][width] < 8) { return false; } 
        }
      }
    }
    return true;
  }

  // Recursively clear full rows and swap with their above row
  void clean(List rows_cleared) {
    for (int i = 0; i <= gridHeight; i++) {
      for (int j = 0; j < gridWidth; j++) {
        // Dynamic or 0 
        if (grid[i][j] > 7 || grid[i][j] == 0) { 
          grid[i][j] = 0;
        }
      }
    }
  }

  void clearAboveRows(int i) {
    for (int j = 0; j <= i; j++) {
      for (int k = 0; k < gridWidth; k++) {
        grid[j][k] = 0;
      }
    }
  }

  void clearTempPiece(int x, int y, Tetramino piece) {
    List block = piece.getBlock();
    for (int i = 0; i < block.length; i++) {
      for (int j = 0; j < block[i].length; j++) {
        // Erase dynamic piece (checks block which is always 1)
        if (block[i][j] == 1) { grid[y+i][x+j] = 0; }
      }
    }
  }

  void swapRows(int r1, int r2) {
    if (r1 >= gridHeight) { return;}
    if (r2 >= gridHeight) { return;}
    for (int i = 0; i < gridWidth; i++) {
      int temp = grid[r1][i];
      grid[r1][i] = grid[r2][i];
      grid[r2][i] = temp;
    }
  }

  /* Check each row for if it is full.
   * If the row is full, clear it and move everything down
   * (Set the top row to zeroes)
   */
  List checkRowClear() {
    List rows_cleared = List<int>.filled(gridHeight, 0);
    List rows_empty = List<int>.filled(gridHeight, 0);
    int n_empty = 0;
    //print("BEFORE:");
    // showGrid(grid);
    // Check cleared rows
    for (int i = 0; i < gridHeight; i++) {
      bool cleared = true, empty = true;
      for (int j = 0; j < gridWidth; j++) {
        // Dynamic or 0 
        if (grid[i][j] > 7 || grid[i][j] == 0) { 
          cleared = false; 
          grid[i][j] = 0;
        } else { empty = false; }
      }
      if (cleared) { rows_cleared[i] = 1; }
      if (empty) {rows_empty[i] = 1; n_empty++; }
    }
    // Update grid
    int n_cleared = 0;
    for (int i = gridHeight-1; i >= 0; i--) { // Go from the bottom to the top
      if (!(rows_empty[i] == 1)) { // Copy rows that aren't empty lower
        swapRows(i, i+n_cleared);
      }
      if (rows_cleared[i] == 1) { 
        n_cleared++; // Account for the number of cleared rows we've passed
      }
      if (rows_empty[i] == 1){
        clearAboveRows(i+n_cleared); // Ensures that no temp block duplication happens
        // print("i: ${i}, n_cleared: ${n_cleared}");
        break;
      }
    }
    // print("AFTER:");
    // showGrid(grid);
    // print("${rows_empty}");
    // print("${rows_cleared}");
    return rows_cleared;
  }
}
