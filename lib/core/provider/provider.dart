import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/models/user_model.dart';

class ProviderApp with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  int mainColor = 0xFF00BCD4;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  UserModel? user;
  init() {
    getToken();
    getUserDetails();
    getValuePref();
  }

  Future getToken() async {
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getToken().then(
          (token) async => await firebaseFirestore
              .collection('users')
              .doc(firebaseAuth.currentUser?.uid)
              .update({'push_token': token}),
        );
  }

  getUserDetails() async {
    String myId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(myId)
        .get()
        .then((value) {
      user = UserModel.fromJson(value.data()!);
      notifyListeners();
    });
  }

  changeMode(bool darkMode) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    sharedPreferences.setBool('darkMode', darkMode);
  }

  changeMainColor(int color) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    mainColor = color;
    notifyListeners();
    sharedPreferences.setInt('mainColor', color);
  }

  getValuePref() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    themeMode = sharedPreferences.getBool('darkMode') ?? false
        ? ThemeMode.dark
        : ThemeMode.light;
    mainColor = sharedPreferences.getInt('mainColor') ?? 0xFF00BCD4;
    notifyListeners();
  }
}
