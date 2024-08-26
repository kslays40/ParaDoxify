import 'package:flutter/material.dart';
import 'package:paradoxify/HomeScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paradoxify',
      theme: ThemeData(
        fontFamily: 'Quicksand'
      ),
      home: Homescreen(),
    );
  }
}

