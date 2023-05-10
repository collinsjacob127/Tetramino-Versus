import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:async/async.dart';
import 'dart:async';
import 'dart:core';
import 'engine/tetraminos.dart';
import 'engine/grid.dart';
import 'engine/game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TETROMINO VERSUS',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'TETROMINO VERSUS'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Page elements
  Timer? timer; // Tick for updating gamestate
  final FocusNode _focusNode = FocusNode(); // Request keyboard focus
  final _rowController = TextEditingController();
  final _colController = TextEditingController();
  // Game DISPLAY elements
  double _width = 25.0, _height = 25.0;
  int rows = 20, cols = 10;
  var position; // The dimensions of the blocks
  // Game elements
  Game game = Game(); // Tetris game class
  bool playing = false, started = false;
  int gameSpeed = 600;
  int points = 0; int stage = 0; int high_score = 0;
  // Timer variables
  bool active = false;

  // Disposing focus node (necessary)
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void start() { 
    game.start(); 
    started = true;
    game.incrementTime();
  }
  void pause() {
    game.pause(); 
    playing = game.playing;
    timer?.cancel();
  }
  void unpause() { setState(() {
    game.unpause(); 
    playing = game.playing; 
    game.incrementTime();
    if (!started) {start();}
    timer = Timer(_getDuration(), _handleEvent); 
  });}
  void restart() {setState(() {
    game.restart(); 
    playing = game.playing; 
    // game.addPiece();
    game.incrementTime();
    game.setHighScore(high_score); 
    });;}

  void _incrementTime(){setState(() {
      game.incrementTime(); 
      game.moveDown();
      game.incrementTime(); 
      updateScores();
    });}

  void updateScores() {setState(() {
    points = game.getPoints();
    high_score = game.getHighScore();
    stage = game.getStage();
    playing = game.playing;
  });}

  // Timer functions
  void _handleEvent() {setState(() {
    // TODO: Handle timer event, e.g. update clock and speed 
    playing = game.playing;
    if (playing) { _incrementTime(); }
    timer = Timer(_getDuration(), _handleEvent); 
  });}

  Duration _getDuration() {
    final time = 6 / game.getGravity();
    return Duration( // seconds: time.toInt(),// microSeconds: (time * 1000000).toInt() % 1000,
      milliseconds: time.toInt(),
    );
  }
  void _resetTimer() {
    timer?.cancel();
    timer = Timer(_getDuration(), _handleEvent); 
  }
  // Handles the key events from the Focus widget and updates the
  // _message.
  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    bool handled = false;
    setState(() {
      if (event is RawKeyUpEvent) { return; }
      else {
        if (event.logicalKey == LogicalKeyboardKey.keyA
          ||event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          game.moveLeft();
          handled = true;
        }
        if(event.logicalKey == LogicalKeyboardKey.keyD) {
          game.moveRight();
          handled = true;
        }
        if(event.logicalKey == LogicalKeyboardKey.keyS) {
          game.moveDown();
          _resetTimer();
          handled = true;
        }
        if(event.logicalKey == LogicalKeyboardKey.space) {
          game.drop();
          _resetTimer();
          handled = true;
        }
        if(event.logicalKey == LogicalKeyboardKey.keyE 
                ||event.logicalKey == LogicalKeyboardKey.keyW) {
          game.rotateCw();
          handled = true;
        }
        if(event.logicalKey == LogicalKeyboardKey.keyQ) {
          game.rotateCcw();
          handled = true;
        }
        if(event.logicalKey == LogicalKeyboardKey.keyR) { 
          game.holdPiece();
          handled = true;
        }
        if(event.logicalKey == LogicalKeyboardKey.delete) {
          restart();
          handled = true;
        }
        game.incrementTime();
      }
      updateScores();
    });
    return handled
        ? KeyEventResult.handled
        : KeyEventResult.ignored;
  }

  Color? colorFromIndex(i) {
    switch (game.grid.getElement(i % cols, (i / cols).floor())) {
      case 0: {return Colors.grey[600]; break;}
      case 1: {return Colors.orange[900]; break;}
      case 2: {return Colors.blue[900]; break;}
      case 3: {return Colors.lightGreenAccent[700]; break;}
      case 4: {return Colors.red[700]; break;}
      case 5: {return Colors.purple[600]; break;}
      case 6: {return Colors.yellow[800]; break;}
      case 7: {return Colors.blue[500]; break;}
      default: {return Colors.grey[100];}
    }
  }

  Color? colorFromBlock(int i, Tetramino piece) {
    if (!started) {return Colors.grey[600]; }
    switch (piece.getElement(i % 4, (i / 4).floor())) {
      case 0: {return Colors.grey[600]; break;}
      case 1: {return Colors.orange[900]; break;}
      case 2: {return Colors.blue[900]; break;}
      case 3: {return Colors.lightGreenAccent[700]; break;}
      case 4: {return Colors.red[700]; break;}
      case 5: {return Colors.purple[600]; break;}
      case 6: {return Colors.yellow[800]; break;}
      case 7: {return Colors.blue[500]; break;}
      default: {return Colors.grey[100];}
    }
  }

  bool isNumeric(String s) {
    if (s == null) { return false; }
    return double.tryParse(s) != null;
  }

  void _setGameDims() {
    if (!isNumeric(_rowController.text) && !isNumeric(_colController.text)) { return; }
    int new_rows = int.parse(_rowController.text);
    int new_cols = int.parse(_colController.text);
  }

  @override
  void initState() { // Game startup
    super.initState();
    position = Offset(_width, _height); // Block dimensions
    rows = game.rows; 
    cols = game.cols;
    timer = Timer(_getDuration(), _handleEvent);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        
        body: Container( // Sets background color and alignment
          color: Colors.grey[900],
          alignment: Alignment.center,
          child: SingleChildScrollView( // Fixes page cutoff
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[ // Replace with Container ()
                  Container( // ******** TITLE AND SCORE DISPLAY **********
                    margin: const EdgeInsets.only(bottom: 20.0),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                        'TETROMINO VERSUS',
                        style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(fontSize: 45, color: Colors.red[500]),
                        ),
                        Text(
                        'HIGHSCORE: ${high_score}',
                        style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(fontSize: 25, color: Colors.grey[400]),
                        ),
                        Text(
                          'SCORE: ${points}',
                          style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(fontSize: 25, color: Colors.grey[400]),
                        ),
                        Text(
                          'LEVEL ${stage}',
                          style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(fontSize: 25, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Align( // ******** NEXT BLOCK PREVIEW **********
                        alignment: Alignment(-1, 1),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'HELD',
                              style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(fontSize: 25, color: Colors.grey[300]),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 10.0),
                              height:  106,
                              width:  106,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white)
                              ),
                              child: GridView.count(
                                crossAxisCount: 4,
                                children: List.generate(16, (blockIndex) {
                                  return Center(
                                    child: Container(
                                      width: _width,
                                      height: _height,
                                      color: colorFromBlock(blockIndex, game.held_piece),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ]
                        ),
                      ),
                      Container(
                        width: (((_width+1) * cols) + 2),
                        height: (((_height+1) * rows) + 2),
                        // margin: const EdgeInsets.only(right: 106.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white)
                        ),
                        child: AnimatedBuilder(
                          animation: _focusNode,
                          builder: (BuildContext context, Widget? child) {
                            if (!_focusNode.hasFocus) {
                              pause();
                              return GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).requestFocus(_focusNode);
                                  unpause();
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    child: Text('START (CLICK HERE)',
                                      style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(fontSize: 25, backgroundColor: Colors.grey[800], color: Colors.white),
                                    )
                                  ),
                              );
                            }
                            return Focus(
                              focusNode: _focusNode,
                              onKey: _handleKeyEvent,
                              child: GridView.count(
                                crossAxisCount: cols,
                                children: List.generate(rows*cols, (index) {
                                  return Center(
                                    child: Container(
                                      width: _width,
                                      height: _height,
                                      color: colorFromIndex(index),
                                    ),
                                  );
                                }),
                              ),
                            ); 
                          },
                        )
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            'NEXT',
                            style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontSize: 25, color: Colors.grey[300]),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10.0),
                            height:  106,
                            width:  106,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white)
                            ),
                            child: GridView.count(
                              crossAxisCount: 4,
                              children: List.generate(16, (blockIndex) {
                                return Center(
                                  child: Container(
                                    width: _width,
                                    height: _height,
                                    color: colorFromBlock(blockIndex, game.next_piece),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ]
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row( 
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlinedButton( onPressed: () { game.moveLeft(); updateScores(); }, child: const Text("LEFT")),
                          OutlinedButton( onPressed: () { game.moveRight();  updateScores(); }, child: const Text("RIGHT")),
                          OutlinedButton( onPressed: () { game.moveDown();  updateScores(); }, child: const Text("DOWN")),
                          OutlinedButton( onPressed: () { game.drop();  updateScores(); }, child: const Text("DROP")),
                          OutlinedButton( onPressed: () { game.rotateCcw(); updateScores(); }, child: const Text("Rot L")),
                          OutlinedButton( onPressed: () { game.rotateCw(); updateScores(); }, child: const Text("Rot R")),
                          OutlinedButton( onPressed: () { restart(); updateScores(); }, child: const Text("RESTART")),
                        ], // Button widget
                      ), // Row
                    ],
                  ), // Buttons 
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    alignment: Alignment.center,
                    child: Text(
                      'Keyboard Controls:',
                      style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(fontSize: 15, color: Colors.grey[400]),
                    )
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white)
                    ),
                    // alignment: Alignment.center,
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget> [
                        Container(
                          margin: const EdgeInsets.only(right: 10.0),
                          child: Text( 'A:\nS:\nD:\nR:\nTab:', 
                            textAlign: TextAlign.right,
                            style: Theme.of(context) .textTheme .headlineMedium!
                              .copyWith(fontSize: 15, color: Colors.grey[400]),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 10.0),
                          child: Text( 'Move Left \nMove Down \nMove Right \nHold Piece \nPause', 
                            style: Theme.of(context) .textTheme .headlineMedium!
                              .copyWith(fontSize: 15, color: Colors.grey[400]),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only( left: 10.0),
                          child: Text(
                            'Q:\nW/E:\nSpace:\nDel:',
                            textAlign: TextAlign.right,
                            style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontSize: 15, color: Colors.grey[400]),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only( left: 10.0),
                          child: Text(
                            'Rotate Left\nRotate Right\nDrop piece\nRestart',
                            style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontSize: 15, color: Colors.grey[400]),
                          ),
                        ),
                      ],
                    )
                  ),
                  // Container(
                  //   margin: const EdgeInsets.only(bottom: 10.0),
                  //   padding: const EdgeInsets.all(3.0),
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.white)
                  //   ),
                  //   // alignment: Alignment.center,
                  //   child: Row(
                  //     children: <Widget>[
                  //         TextField(
                  //           controller: _rowController, 
                  //           decoration: const InputDecoration(
                  //             border: OutlineInputBorder(),
                  //             labelText: 'Enter game height (Opt)',
                  //             hintText: 'Game height input box',
                  //           ),
                  //       ) ,
                  //         TextField(
                  //           controller: _colController, 
                  //           decoration: const InputDecoration(
                  //             border: OutlineInputBorder(),
                  //             labelText: 'Enter game width (Opt)',
                  //             hintText: 'Game width input box',
                  //           ),
                  //       ),
                  //       OutlinedButton(
                  //         style: OutlinedButton.styleFrom(
                  //           backgroundColor: Colors.red,
                  //           fixedSize: const Size.fromHeight(100),
                  //           surfaceTintColor: Colors.green,
                  //           padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  //           shape: const StadiumBorder(),
                  //           side: const BorderSide(width: 4, color: Colors.black),
                  //         ),
                  //         onPressed: _setGameDims,
                  //         child: const Text("LEFT"),
                  //       ),
                  //     ]
                  //   ),
                  // ),
                ], // Widget
              )
            )
          )
        ), // Scroll veiw (?)
      ),
    );
  }
}

// 
// 