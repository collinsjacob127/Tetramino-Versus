/* Author: Jacob Collins
 * Tetraminos.dart
 * CINS 467
 * Spring 2023
 */
import 'blocks.dart';

class Tetramino {
  bool _initialized = false;

  int _type = 0;
  int _rotation = 0;
  var _blockRotations;
  var _block; 

  // Gives the number for the block to be represented as
  // Dictates the color of the block (moving)
  int getNum() { return _type+7; }
  // Dictates the color of the block (static)
  int getType() {return _type; }
  int getRotation() {return _rotation; }
  bool isInitialized() {return _initialized; }
  List getBlock() { return (_block != Null ? _block : []); }
  
  int getElement(int x, int y) {
    if (!_initialized) { return 0; }
    if (y >= _block.length) { return 0;}
    if (x >= _block[y].length) { return 0;}
    else { return _block[y][x] * _type; }
  }
  
  void initialize(int type, int  rotation) {
    _type = type;
    _initialized = true;
    _rotation = rotation;
    switch (type) {
      case 1: {_blockRotations = l1Block;} break;
      case 2: {_blockRotations = l2Block;} break;
      case 3: {_blockRotations = s1Block;} break;
      case 4: {_blockRotations = s2Block;} break;
      case 5: {_blockRotations = tBlock;} break;
      case 6: {_blockRotations = rBlock;} break;
      case 7: {_blockRotations = iBlock;} break;
      default: {_initialized = false;} break;
    }
    _block = _blockRotations[_rotation];
  }
  
  void testBlock() {
    if (!_initialized) {
      print("Not initialized!");
      return;
    }
    for (var i = 0; i < _block.length; i++) {
      print(_block[i]);
    }
    print("");
  }

  int getCw() { return (_rotation+1) % 4; }
  int getCcw() { return (_rotation+3) % 4; }
  List getCwBlock() { return _blockRotations[(_rotation+1) % 4]; }
  List getCcwBlock() { return _blockRotations[(_rotation+3) % 4]; }
  void rotateCw() { _block = getCwBlock(); 
                    _rotation = getCw(); }
  void rotateCcw() { _block = getCcwBlock(); 
                    _rotation = getCcw(); }
}