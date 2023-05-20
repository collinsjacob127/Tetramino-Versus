import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class User{
  String username = 'Player';
  int highscore = 0;
  int level = 0;
  String city = 'Chico';
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

  Future<void> writeUserInfo(String name, int highscore, int level, String city) async {
    _loading = true;
    if(!isInitialized){
      await initializeDefault();
    }
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('highscores').doc(name).set({
      'username': name,
      'highscore': highscore,
      'level': level,
      'city': city,
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

  Future<User> readUserInfo() async {
    _loading = true;
    User user = new User();
    if(!isInitialized){
      await initializeDefault();
    }
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot ds = await firestore.collection('users')
      .doc('uC2FKdn8oH6ljxeKJQ3d')
      .get();
    _loading = false;
    if(ds.data() != null){
      Map<String, dynamic> data = (ds.data() as Map<String, dynamic>);
      if(data.containsKey('username')){
        user.username = data['username'];
      }
      if(data.containsKey('highscore')){
        user.highscore = data['highscore'];
      }
      if(data.containsKey('level')){
        user.level = data['level'];
      }
      if(data.containsKey('city')){
        user.city = data['city'];
      }
    }
    return user;
  }
}