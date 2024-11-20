import 'package:flutter/material.dart';
import 'package:photo_to_length/rectangle_cropper.dart';
import 'package:photo_to_length/screens/focus_first.dart';
import 'package:photo_to_length/screens/focus_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FocusFirst(),
    );
  }
}
