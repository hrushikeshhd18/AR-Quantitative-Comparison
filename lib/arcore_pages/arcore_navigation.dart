import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

enum TtsState { playing, stopped }

class ARNavigationScreen extends StatefulWidget {
  @override
  _ARNavigationScreenState createState() => _ARNavigationScreenState();
}

class _ARNavigationScreenState extends State<ARNavigationScreen> {
  late ArCoreController arCoreController;
  late FlutterTts flutterTts;
  double targetDegree = 0;
  int _clearDirection = 0;
  int _distance = 0;
  double destinationLatitude = 13.104767251985633;
  double destinationLongitude = 77.58087865557246;
  TtsState ttsState = TtsState.stopped;
  late Timer timer;


  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    flutterTts = FlutterTts(); // Move this line here
    _getlocation();
    _initCompass();
    timer = Timer.periodic(Duration(seconds: 7), (timer) {
      _getlocation();
    });
  }

  @override
  void dispose() {
    arCoreController.dispose();
    flutterTts.stop();
    timer.cancel();
    super.dispose();
  }

  void _initCompass() {
    FlutterCompass.events!.listen((CompassEvent event) {
      setState(() {
        if (targetDegree != null && event.heading != null) {
          _clearDirection =
              (targetDegree.truncate() - event.heading!.truncate()).toInt();
        }
      });
    });
  }

  void _getlocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    targetDegree = 0;

    setState(() {
      _calculateDistanceAndDirection(position.latitude, position.longitude);
      _setARObject();
    });
  }

  void _setARObject() {
    arCoreController.removeNode(nodeName: "object");
    ArCoreNode objectNode = ArCoreNode(
      name: "object",
      shape: ArCoreCube(
        materials: [
          ArCoreMaterial(
            color: Color.fromARGB(255, 66, 134, 244),
          ),
        ],
        size: vector.Vector3(0, 0, 2.0),
      ),
      position: vector.Vector3(0, 0, -2.0),
    );
    arCoreController.addArCoreNode(objectNode);
  }

  Future _speak(String text) async {
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setPitch(1.0);

    var result = await flutterTts.speak(text);
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  void requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isDenied) {
      // Handle denied scenario
    } else if (status.isPermanentlyDenied) {
      // Handle permanently denied scenario
    } else if (status.isGranted) {
      // Location permission granted
      _getlocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AR Navigation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<bool>(
              future: Permission.location.isGranted,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while checking the permission status
                  return CircularProgressIndicator();
                } else if (snapshot.data == true) {
                  // Location permission is granted
                  return ArCoreView(
                    onArCoreViewCreated: _onArCoreViewCreated,
                  );
                } else {
                  // Location permission is not granted
                  return Center(
                    child: Text("Location permission not granted."),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Distance to Destination: $_distance meters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          //todo add a search bar here
          // LocationSearchWidget(
          //   onLocationSelected: (lat, lng) {
          //     setState(() {
          //       destinationLatitude = lat;
          //       destinationLongitude = lng;
          //     });
          //   },
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  _calculateDistanceAndDirection(
                      destinationLatitude, destinationLongitude);
                },
                child: Text('Navigate'),
              ),
              ElevatedButton(
                onPressed: () {
                  _stopNavigation();
                },
                child: Text('Stop Navigation'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    _setARObject();
  }

  void _calculateDistanceAndDirection(double destLat, double destLong) async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double distance = await Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      destLat,
      destLong,
    );

    setState(() {
      _distance = distance.truncate();
      targetDegree = _calculateTargetDegree(
        position.latitude,
        position.longitude,
        destLat,
        destLong,
      );

      _speak('Distance to destination is $_distance meters');
      _setARObject();
    });
  }

  double _calculateTargetDegree(
    double lat1,
    double long1,
    double lat2,
    double long2,
  ) {
    double dLon = (long2 - long1);

    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double brng = math.atan2(y, x);

    brng = vector.degrees(brng);
    brng = (brng + 360) % 360;

    return brng;
  }

  void _stopNavigation() {
    // Implement any additional actions needed when stopping navigation
  }
}



