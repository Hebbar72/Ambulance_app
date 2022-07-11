import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'map.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Map_My_India_project",
      home: MapPage(),
    );
  }
}
