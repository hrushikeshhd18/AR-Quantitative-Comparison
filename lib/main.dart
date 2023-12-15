import 'package:flutter/material.dart';
import 'package:testlocation/arcore_pages/arcore_navigation.dart';
import 'package:testlocation/arkit_pages/arkir_navigation.dart';

import 'arcore_pages/arcore_runtime_material.dart';
import 'arcore_pages/remote_object.dart';
import 'arcore_pages/texture_and_rotation.dart';
import 'home/home_page.dart';

void main() => runApp(MaterialApp(
    theme: ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.red,
    ),
    darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange
    ),
    home: MyApp()));

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:  HomePage());
  }
}
