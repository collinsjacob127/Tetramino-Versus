import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class User{
  String _username = 'Player';
  int _highscore = 0;
  int _level = 0;
  String _downloadURL = 'Chico';

  User(String username, int highscore, int level, String downloadURL) {
    this._username = username;
    this._highscore = highscore;
    this._level = level;
    this._downloadURL = downloadURL;
  }

  int get high_score => _highscore;
  int get level => _level;
  String get downloadURL => _downloadURL;
  String get username => _username;
}

class UserStorage {
  bool _initialized = false;
  bool _loading = false;

  Future<void> initializeDefault() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
  }

  bool get isInitialized => _initialized;
  bool get isLoading => _loading;

  Future<void> writeUserInfo(String name, int highscore, int level, String downloadURL) async {
    _loading = true;
    if(!isInitialized){
      await initializeDefault();
    }
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('highscores').doc(name).set({
      'username': name,
      'highscore': highscore,
      'level': level,
      'downloadURL': downloadURL,
    }).then((value){
      if (kDebugMode) {
        print('User updated successfully');
      }
    }).catchError((error){
      if (kDebugMode) {
        print('writeUserInfo error: $error');
      }
    });
    _loading = false;
  }

  Future<User> readUserInfo(String username) async {
    _loading = true;
    if(!isInitialized){
      await initializeDefault();
    }
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot ds = await firestore.collection('highscores')
      .doc(username)
      .get();
    _loading = false;

    int highscore = 0;
    int level = 0;
    String downloadURL = "https://www.google.com/url?sa=i&url=https%3A%2F%2Fuxwing.com%2Fsmile-icon&psig=AOvVaw3ZpOFbha06n0uqXMX8ajl8&ust=1684659501482000&source=images&cd=vfe&ved=0CBAQjRxqFwoTCOiUs-vDg_8CFQAAAAAdAAAAABAE";
    if(ds.data() != null){
      Map<String, dynamic> data = (ds.data() as Map<String, dynamic>);
      if(data.containsKey('highscore')){
        highscore = data['highscore'];
      }
      if(data.containsKey('level')){
        level = data['level'];
      }
      if(data.containsKey('downloadURL')){
        downloadURL = data['downloadURL'];
      }
    }
     
    return new User(username, highscore, level, downloadURL);
  }
}