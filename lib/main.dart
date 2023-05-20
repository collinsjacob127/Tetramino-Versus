import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:async/async.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'dart:core';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'engine/tetraminos.dart';
import 'engine/grid.dart';
import 'engine/game.dart';
import 'storage.dart';
import 'add_photos.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  int points = 0; int level = 0; int high_score = 0;
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
    level = game.getStage();
    playing = game.playing;
  });}

  // Timer functions
  void _handleEvent() {setState(() {
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
      case 0: {return Colors.black; break;}
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
    if (!started) {return Colors.black; }
    switch (piece.getElement(i % 4, (i / 4).floor())) {
      case 0: {return Colors.black; break;}
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

  // Form controller
  final _myController = TextEditingController(); 
  final _storage = UserStorage();
  String? _username;
  late String username = "Unnamed user";
  String downloadURL = "https://www.google.com/url?sa=i&url=https%3A%2F%2Fuxwing.com%2Fsmile-icon&psig=AOvVaw3ZpOFbha06n0uqXMX8ajl8&ust=1684659501482000&source=images&cd=vfe&ved=0CBAQjRxqFwoTCOiUs-vDg_8CFQAAAAAdAAAAABAE";

  void _printLatestValue(){ 
    if (kDebugMode) { 
      print('Text field input: ${_myController.text}'); 
    } 
  } 

  Widget photoWidget(AsyncSnapshot<QuerySnapshot>snapshot, int index){
    // try{
    //   return Column(
    //     children: [
    //       // ListTile(
    //       //   leading: const Icon(Icons.person),
    //       //   title: Text(snapshot.data!.docs[index]['title']),
    //       // ),
    //       Image.network(snapshot.data!.docs[index]['downloadURL']),
    //     ],
    //     );
    // } catch(e){
      // return Text('Error: $e');
      return Text('');
    // }
  }
              
  Widget _userWidget(AsyncSnapshot<QuerySnapshot>snapshot, int index, int length){
    int unreversed_index = (length-1)-index;
    try{
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
        ),
        margin: const EdgeInsets.all(5.0),
        alignment:  Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(5.0),
              width: 60,
              alignment: Alignment.center,
              child: Text(
                (unreversed_index+1).toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                )
              )
            ),
            Container(
              margin: const EdgeInsets.all(5.0),
              width: 100,
              alignment: Alignment.center,
              child: Text(
                snapshot.data!.docs[index]['username'].toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                )
              )
            ),
            Container(
              margin: const EdgeInsets.all(5.0),
              width: 100,
              alignment: Alignment.center,
              child: Text(
                snapshot.data!.docs[index]['highscore'].toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                )
              )
            ),
            Container(
              margin: const EdgeInsets.all(5.0),
              width: 50,
              alignment: Alignment.center,
              child: Text(
                snapshot.data!.docs[index]['level'].toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                )
              )
            ),
            // Container(
            //   margin: const EdgeInsets.all(5.0),
            //   width: 10,
            //   // height:100,
            //   alignment: Alignment.center,
            //   child: photoWidget(snapshot, index),
            // )
          ],
        ),
      );
    } catch(e){
      // return Text('Error: $e');
      return Text('');
    }
  }

  Widget userWidget(AsyncSnapshot<QuerySnapshot>snapshot, int index, int length){
    int reversed_index = (length-1)-index;
    if (index == 0) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[600],
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(5.0),
                  width: 60,
                  alignment: Alignment.center,
                  child: Text(
                    // snapshot.data!.docs[index].id,
                    "Rank",
                    // "    Name   |   Score   |   Level   |    Pfp    ",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(5.0),
                  width: 100,
                  alignment: Alignment.center,
                  child: Text(
                    // snapshot.data!.docs[index].id,
                    "Name",
                    // "    Name   |   Score   |   Level   |    Pfp    ",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(5.0),
                  width: 100,
                  alignment: Alignment.center,
                  child: Text(
                    // snapshot.data!.docs[index].id,
                    "Score",
                    // "    Name   |   Score   |   Level   |    Pfp    ",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(5.0),
                  width: 70,
                  alignment: Alignment.center,
                  child: Text(
                    // snapshot.data!.docs[index].id,
                    "Level",
                    // "    Name   |   Score   |   Level   |    Pfp    ",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Container(
                //   margin: const EdgeInsets.all(5.0),
                //   width: 10,
                //   child: Text( "",),
                // ),
              ],
            ),
            _userWidget(snapshot, reversed_index, length),
          ],
        ),
      );
    } else { return _userWidget(snapshot, reversed_index, length); }
  }

  // Future<Position> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the 
  //     // App to enable the location services.
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale 
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
    
  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately. 
  //     return Future.error(
  //       'Location permissions are permanently denied, we cannot request permissions.');
  //   } 

  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //   return await Geolocator.getCurrentPosition();
  // }

  // getAddressFromLatLng(context, double lat, double lng) async {
  //   String _host = 'https://maps.google.com/maps/api/geocode/json';
  //   final key = 'AIzaSyAXFZnO850nwmQi5P56agCTbD8Cg6YTP2U';
  //   final url = '$_host?key=$mapApiKey&language=en&latlng=$lat,$lng';
  //   if(lat != null && lng != null){
  //     var response = await http.get(Uri.parse(url));
  //     if(response.statusCode == 200) {
  //       Map data = jsonDecode(response.body);
  //       String _formattedAddress = data["results"][0]["formatted_address"];
  //       print("response ==== $_formattedAddress");
  //       return _formattedAddress;
  //     } else return null;
  //   } else return null;
  // }

  // Future<Address> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }

  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //   final currentLocation = await Geolocator.getCurrentPosition();
  //   final currentAddress = await GeoCode().reverseGeocoding(
  //       latitude: currentLocation.latitude,
  //       longitude: currentLocation.longitude);
  //   return currentAddress;
  // }

  // _fetchLocation() async {
  //   Position position = await _geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.best);///Here you have choose level of distance
  //   latitude = position.latitude.toString() ?? '';
  //   longitude = position.longitude.toString() ?? '';
  //   var placemarks = await _geolocator.placemarkFromCoordinates(position.latitude, position.longitude);
  //   address ='${placemarks.first.name.isNotEmpty ? placemarks.first.name + ', ' : ''}${placemarks.first.thoroughfare.isNotEmpty ? placemarks.first.thoroughfare + ', ' : ''}${placemarks.first.subLocality.isNotEmpty ? placemarks.first.subLocality+ ', ' : ''}${placemarks.first.locality.isNotEmpty ? placemarks.first.locality+ ', ' : ''}${placemarks.first.subAdministrativeArea.isNotEmpty ? placemarks.first.subAdministrativeArea + ', ' : ''}${placemarks.first.postalCode.isNotEmpty ? placemarks.first.postalCode + ', ' : ''}${placemarks.first.administrativeArea.isNotEmpty ? placemarks.first.administrativeArea : ''}';
  //   print("latitude"+latitude);
  //   print("longitude"+longitude);
  //   print("adreess"+address);
  // }

  // Future<void> _saveUsername() async {
  //   username = _myController.text;
  //   try {
  //     Address pos = await _determinePosition();
  //     try {
  //       String? _city = pos.city;
  //       if (_city is String) {
  //         city = _city;
  //         print(city);
  //       }
  //     } on Exception catch (_) {
  //       if (kDebugMode) {
  //         print("City not pulled from pos properly");
  //       }
  //     }
  //   } on Exception catch (e) {
  //     if (kDebugMode) {
  //       print("never reached: $e");
  //     }
  //   }
  //   _upload();
  // }

  List<Widget> leaderboard = <Widget>[];

  List<Widget> getLeaderboard(){
    if (playing && leaderboard != <Widget>[]) { return leaderboard; }
    else return <Widget>[
      StreamBuilder(
        stream: FirebaseFirestore.instance.collection('highscores').orderBy('highscore').snapshots(),
        builder:(context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            default:
              if(snapshot.hasError){
                // return Text('Error: ${snapshot.error}');
                return Text('');
              } else {
                return Expanded(
                  child: Scrollbar(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder:(context, index) {
                        _upload();
                        return userWidget(snapshot, index, snapshot.data!.docs.length);
                      },
                    ),
                  ),
                );
              }
          }
        },
      ),
    ];
  }

  Future<void> _saveUsername() async {
    username = _myController.text;
    _upload();
  }

  Future<void> _upload() async {
    User user = await _storage.readUserInfo(username);
    if ((user.high_score < high_score) && (high_score > 0)) {
      _storage.writeUserInfo(username, high_score, level, downloadURL);
    }
  }

  @override
  void initState() { // Game startup
    super.initState();
    leaderboard = getLeaderboard();
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
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left:400),
                    alignment: Alignment.center,
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
                                'LEVEL ${level}',
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
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        width:380,
                        height:480,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white)
                        ),
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(left:20),
                        child: Column(
                          children: getLeaderboard(),
                        )
                      ),
                      Row(
                        children: <Widget>[
                          ElevatedButton(
                            onPressed:() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:(context) => AddPhotos(title: 'Add a photo', username: username),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600]),
                            child: const Icon(Icons.photo_camera),
                          ),
                          Container(
                            margin: EdgeInsets.all(30.0),
                            width:150,
                            height:40,
                            child: TextField(
                              controller: _myController,
                              maxLines: 1,
                              style: TextStyle(color: Colors.grey),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Enter Username" ,
                                labelStyle: TextStyle(color: Colors.grey[300]),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _saveUsername,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600]),
                            child: const Text(
                              "Set username",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ]
                      )
                    ]
                  )
                ]
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