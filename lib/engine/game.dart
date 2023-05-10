/* Author: Jacob Collins
 * Game.dart
 * CINS 467
 * Spring 2023
 */
import 'dart:math';
import 'dart:core';
import 'tetraminos.dart';
import 'grid.dart';

class Game {
  // Grid
  Grid grid = Grid(); // <- I find this amusing
  int rows = 20, cols = 10;
  int xpos = 4, ypos = 0;
  // Pieces
  Tetramino piece = Tetramino();
  Tetramino next_piece = Tetramino();
  Tetramino held_piece = Tetramino();
  List pieces = [];
  // Tracking game state
  bool playing = false;
  bool piece_moving = true;
  bool game_over = false;
  int points = 0; int high_score = 0; 
  int rows_cleared = 0;
  int n_placed = 0;
  double gravity = 4.0/256;
  int stage = 0;
  final int stage_pcs_cnt = 20;

  void showGrid() { 
    print("-----------------POINTS: ${getPoints()}----------------");
    grid.showGrid(grid.grid); 
    print("------------------------------------------");
  }

  /* INTERACTING WITH FLUTTER */
  int getStage() { stage=(rows_cleared / 10).floor(); return stage; } 
  int getHighScore() => high_score;
  void setHighScore(int pts) {
    high_score = pts;
  }

  /* MODIFYING GAMESTATE */
  void start() { 
    game_over = false;
    playing = true;
    grid.setDims(rows, cols);
    renewPieces();
    addPiece();
  }
  void pause() { playing = false; }
  void unpause() { playing = true; }
  void restart() {
    points = 0;
    n_placed = 0;
    rows_cleared = 0;
    grid = Grid();
    held_piece = Tetramino();
    grid.clearAboveRows(rows-1);
    start();
  }

  /* HANDLING PIECES */
  void holdPiece() {
    if (!playing || !piece_moving || game_over) {return;}
    if (!held_piece.isInitialized()) {
      held_piece.initialize(piece.getType(), piece.getRotation());
      grid.clearTempPiece(xpos, ypos, piece);
      addPiece();
    } else {
      if (grid.move(xpos, ypos, xpos, ypos, piece, held_piece)) {
        int type = piece.getType(); int rot = piece.getRotation();
        piece.initialize(held_piece.getType(), held_piece.getRotation());
        held_piece.initialize(type, rot);
      }
    }
  }
  void renewPieces() {
    pieces = [for(var i=1; i<8; i+=1) i];
    pieces.shuffle();
  }
  // Spawn the new controllable piece
  bool addPiece() {
    piece.initialize(pieces.removeAt(0), 0);
    if (pieces.length == 0) { renewPieces(); }
    next_piece = Tetramino();
    next_piece.initialize(pieces[0], 0);
    // piece.testBlock();
    xpos = (cols/2).floor(); ypos = -1;
    return grid.move(xpos, ypos, xpos, ypos, piece, piece);
  }
  void solidifyPiece() { 
    if (grid.solidify(xpos, ypos, piece)) {
      n_placed++; 
      points += 10;
    } else {
      incrementTime();
    } 
  }

  /* MOVEMENT */
  void moveLeft(){
    if(playing && piece_moving) { 
      if (grid.move(xpos, ypos, xpos-1, ypos, piece, piece)) { xpos--; }
    }
  }
  void moveRight(){
    if (playing && piece_moving) {
      if(grid.move(xpos, ypos, xpos+1, ypos, piece, piece)) {xpos++;}
    }
  }
  void rotateCw(){if(playing && piece_moving){grid.rotate(xpos, ypos, piece, 1);}}
  void rotateCcw(){if(playing && piece_moving){grid.rotate(xpos, ypos, piece, -1); }}
  bool moveDown() { 
    if (grid.move(xpos, ypos, xpos, ypos+1, piece, piece)) 
      { ypos++; piece_moving = true; } 
      else { solidifyPiece(); piece_moving = false; }
      return piece_moving;
  }
  void drop() { while (moveDown()) {} }

  int rowClearPoints(List cleared_rows) {
    int rows_ina_row = 0;
    int pts = 0;
    for (int i = 0; i < cleared_rows.length; i++) {
      if (cleared_rows[i] == 1) {
        rows_ina_row++;
        rows_cleared++;
        pts += rows_ina_row * 100 * getStage();
      } else {
        rows_ina_row = 0;
      }
      if (rows_ina_row == 4) {
        rows_ina_row = 0;
        pts += rows_ina_row * 500 * getStage();
      }
    }
    return pts;
  }

  int getPoints() => points;

  void endGame() { game_over = true; }

  void incrementTime() {
    if (playing && !game_over) {
      if (!piece_moving) { // If move down failed, add a new piece
        points += rowClearPoints(grid.checkRowClear());
        if (high_score < points) { high_score = points; }
        if (!addPiece()) {endGame();} // If a piece failed to add, end game
        else {piece_moving = true;} // Successfully added new piece
      } 
    } 
  }

  void _setGravity(int s, int stage, int g) {
    if (stage >= s) { gravity = (g / 256); }
  }
  double getGravity() {
    gravity_chart.forEach((s, g) => _setGravity(s, stage, g));
    return gravity;
  }

  var gravity_chart = {
    0:	4,
    5:	5,
    10:	6,
    15:	8,
    20:	10,
    30:	12,
    40: 14,
    50:	16,
    60:	24,
    70:	32,
    80:	48,
    90:	64,
    100: 80,
    200: 120,
  };
}
