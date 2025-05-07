import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(SpeechConnectApp());
}

class SpeechConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      home: HomeScreen(),
    );
  }
}
