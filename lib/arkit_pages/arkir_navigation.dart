import 'dart:async';
import 'dart:math';
import '../component/info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ARKitDetectionPage extends StatefulWidget {
  @override
  _ARKitDetectionPageState createState() => _ARKitDetectionPageState();
}

enum WidgetDistance { ready, navigating }
enum WidgetCompass { scanning, directing }
enum TtsState { playing, stopped }

class _ARKitDetectionPageState extends State<ARKitDetectionPage> {
  WidgetDistance situationDistance = WidgetDistance.navigating;
  WidgetCompass situationCompass = WidgetCompass.directing;

  late ARKitController arkitController;
  bool anchorWasFound = false;
  late FlutterTts flutterTts;
  int _clearDirection = 0;
  double distance = 0;
  int _distance = 0;
  double targetDegree = 0;
  late Timer timer;
  TtsState ttsState = TtsState.stopped;

  //calculation formula of angel between 2 different points
  double angleFromCoordinate(
      double lat1, double long1, double lat2, double long2) {
    double dLon = (long2 - long1);

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double brng = atan2(y, x);

    brng = vector.degrees(brng);
    brng = (brng + 360) % 360;
    //brng = 360 - brng; //remove to make clockwise
    return brng;
  }

  Future _speak() async {
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setPitch(1.0);

    if (_distance != 0) {
      var result =
          await flutterTts.speak('Distance of faculty is $_distance meters');
      if (result == 1) setState(() => ttsState = TtsState.playing);
    }
  }

  //device compass
  void calculateDegree() {
    FlutterCompass.events!.listen((CompassEvent event) {
      setState(() {
        if (targetDegree != null && event.heading != null) {
          _clearDirection = (targetDegree.truncate() - event.heading!.truncate()).toInt();
        }
      });
    });
  }

  //distance between faculty and device coordinates
  void _getlocation() async {
    //if you want to check location service permissions use checkGeolocationPermissionStatus method
    Position position = await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    //todo add the current location 13.09515812406401, 77.59503710907903 13.104767251985633, 77.58087865557246
    final double _facultypositionlat = 13.104767251985633;
    final double _facultypositionlong = 77.58087865557246;

    distance = await Geolocator.distanceBetween(position.latitude,
        position.longitude, _facultypositionlat, _facultypositionlong);

    targetDegree = angleFromCoordinate(position.latitude, position.longitude,
        _facultypositionlat, _facultypositionlong);
    calculateDegree();
  }
  void requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isDenied) {
      // Permission denied by user
      // Handle the denial scenario (e.g., show a message or navigate to a settings screen)
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied by user
      // Provide guidance to the user on how to enable the permission manually (e.g., show a dialog with instructions)
    } else if (status.isGranted) {
      // Permission granted by user
      // Proceed with accessing the device's location
      _getlocation(); // Call your method to access location here
    }
  }

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _getlocation(); //first run
    flutterTts = FlutterTts();
    timer = new Timer.periodic(Duration(seconds: 7), (timer) {
      _getlocation();
      if (distance < 50 && distance != 0 && distance != null) {
        setState(() {
          situationDistance = WidgetDistance.ready;
          situationCompass = WidgetCompass.scanning;
        });
      } else {
        setState(() {
          _distance = distance.truncate();
          situationDistance = WidgetDistance.navigating;
          situationCompass = WidgetCompass.directing;
        });
      }
    });
  }

  @override
  void dispose() {
    arkitController?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('Fırat AR'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => CustomDialog());
              })
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                Color.fromARGB(190, 207, 37, 7),
                Colors.transparent
              ])),
        ),
      ),
      body: distanceProvider(),
      floatingActionButton: compassProvider());

  Widget readyWidget() {
    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ARKitSceneView(
            detectionImagesGroupName: 'AR Resources',
            onARKitViewCreated: onARKitViewCreated,
          ),
          anchorWasFound
              ? Container()
              :Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(' Distance of Faculty : $_distance m.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.blueGrey,
                        color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget navigateWidget() {
    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ARKitSceneView(
            detectionImagesGroupName: 'AR Resources',
            onARKitViewCreated: onARKitViewCreated,
          ),
          anchorWasFound
              ? Container()
              : Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(' Distance of Faculty : $_distance m.',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.blueGrey,
                              color: Colors.white)),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget scanningWidget() {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      onPressed: null,
      child: Ink(
          decoration: const ShapeDecoration(
            color: Colors.lightBlue,
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(Icons.remove_red_eye),
            color: Colors.white,
            onPressed: () {},
          )),
    );
  }

  Widget directingWidget() {
  return FloatingActionButton(
    backgroundColor: Colors.blue,
    onPressed: null,
    child: RotationTransition(
      turns: new AlwaysStoppedAnimation(
        _clearDirection > 0 ? _clearDirection / 360 : (_clearDirection + 360) / 360,
      ),
      child: GestureDetector(
        onTap: () {
          // Call the speech function when the arrow icon is tapped
          _speak();
        },
        child: Ink(
          decoration: const ShapeDecoration(
            color: Colors.lightBlue,
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_upward),
            color: Colors.white,
            onPressed: () {},
          ),
        ),
      ),
    ),
  );

    return FloatingActionButton(
      backgroundColor: Colors.blue,
      onPressed: null,
      child: RotationTransition(
        turns: new AlwaysStoppedAnimation(_clearDirection > 0
            ? _clearDirection / 360
            : (_clearDirection + 360) / 360),
        //if you want you can add animation effect for rotate
        child: Ink(
          decoration: const ShapeDecoration(
            color: Colors.lightBlue,
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_upward),
            color: Colors.white,
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget compassProvider() {
    switch (situationCompass) {
      case WidgetCompass.scanning:
        return scanningWidget();
      case WidgetCompass.directing:
        return directingWidget();
    }
    return directingWidget();
  }

  Widget distanceProvider() {
    switch (situationDistance) {
      case WidgetDistance.ready:
        return readyWidget();
      case WidgetDistance.navigating:
        return navigateWidget();
    }
    return navigateWidget();
  }

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onAddNodeForAnchor = onAnchorWasFound;
  }

  void onAnchorWasFound(ARKitAnchor anchor) {
    if (anchor is ARKitImageAnchor) {
        //if you want to block AR while you aren't close to target > add "if (situationDistance==WidgetDistance.ready)" here
      setState(() => anchorWasFound = true);

      final materialCard = ARKitMaterial(
        lightingModelName: ARKitLightingModel.lambert,
        diffuse: ARKitMaterialImage('firatcard.png'),
      );

      final image =
          ARKitPlane(height: 0.4, width: 0.4, materials: [materialCard]);

      final targetPosition = anchor.transform.getColumn(3);
      final node = ARKitNode(
        geometry: image,
        position: vector.Vector3(
            targetPosition.x, targetPosition.y, targetPosition.z),
        eulerAngles: vector.Vector3.zero(),
      );
      arkitController.add(node);
    }
  }
}
