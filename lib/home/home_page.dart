import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:testlocation/arcore_pages/arcore_navigation.dart';
import 'package:testlocation/arcore_pages/arcore_runtime_material.dart';
import 'package:testlocation/arcore_pages/auto_detect_plane.dart';
import 'package:testlocation/arcore_pages/image_object.dart';
import 'package:testlocation/arcore_pages/remote_object.dart';
import 'package:testlocation/arcore_pages/texture_and_rotation.dart';
import 'package:testlocation/arkit_pages/arkir_navigation.dart';
import 'package:testlocation/arkit_pages/light_estimate_page.dart';
import 'package:testlocation/arkit_pages/ontap_page.dart';
import 'package:testlocation/arkit_pages/plane_detection_page.dart';
import 'package:testlocation/arkit_pages/snapshot_scene.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (Platform.isAndroid) {
      return AppBar(
        title: Text("AR-Quantitative-Comparison"),
        centerTitle: true,
      );
    } else if (Platform.isIOS) {
      return CupertinoNavigationBar(
        middle: Text("AR-Quantitative-Comparison"),
      );
    } else {
      // Default to AppBar for other platforms
      return AppBar(
        title: Text("AR-Quantitative-Comparison"),
        centerTitle: true,
      );
    }
  }

  Widget _buildBody() {
    if (Platform.isAndroid) {
      return AndroidUI();
    } else if (Platform.isIOS) {
      return IosUI();
    } else {
      // Default to a generic UI for other platforms
      return Container(
        height: 100,
        color: Colors.purpleAccent,
        child: Center(
          child: Text("Unsupported Platform"),
        ),
      );
    }
  }

}

class AndroidUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: InkWell(
            onTap: () {
              _navigateToARCoreScreen(context, index);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    _getImageUrl(index),
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.purple.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: Text(
                    _getTitle(index),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _getTitle(int index) {
  switch (index) {
    case 0:
      return 'AR Navigation Screen';
    case 1:
      return 'AR Core Runtime Materials';
    case 2:
      return 'Auto Detect Plane';
    case 3:
      return 'Image Object Screen';
    case 4:
      return 'Remote Object';
    case 5:
      return 'Object With Texture And Rotation';
    default:
      return 'Unknown Title';
  }
}

String _getImageUrl(int index) {
  switch (index) {
    case 0:
      return 'https://image.cnbcfm.com/api/v1/image/105796703-1552666018522press-image-ar.jpg';
    case 1:
      return 'https://media.sketchfab.com/models/e7d33789de2b4fd286cf9190b855de28/thumbnails/8deed91dc70e456589da7bb160d2c30a/0bf220ebb3d64c73940da08dbbb6daf4.jpeg';
    case 2:
      return 'https://www.androidauthority.com/wp-content/uploads/2019/04/ar-position-augmented-poly-models.jpg';
    case 3:
      return 'https://9to5google.com/2019/02/15/arcore-1-7-arcore-elements/arcore-elements-2/';
    case 4:
      return 'https://1.bp.blogspot.com/-w77dN1K4gIw/XmhL3fZwmGI/AAAAAAAAFdw/EFiTotESgEwB6L_Z2HS82azRB5PgBYHzACLcBGAsYHQ/w1200-h630-p-k-no-nu/Figure1.png';
    case 5:
      return 'https://nintendoboy.gitbooks.io/ios-ar-research/content/1*AGEgWXzAO6KK1Wmqu618rA.png';
    default:
      return 'https://www.queppelin.com/wp-content/uploads/2020/08/arcore-4-300x300.jpeg';
  }
}

void _navigateToARCoreScreen(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ARNavigationScreen(),
        ),
      );
      break;
    case 1:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ARCoreRuntimeMaterials(),
        ),
      );
      break;
    case 2:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AutoDetectPlane(),
        ),
      );
      break;
    case 3:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageObjectScreen(),
        ),
      );
      break;
    case 4:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RemoteObject(),
        ),
      );
      break;
    case 5:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ObjectWithTextureAndRotation(),
        ),
      );
      break;
    // Repeat for the other screens (Screen3, Screen4, Screen5, Screen6)
    default:
      break;
  }
}

class IosUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _navigateToARCoreScreen(context, index);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      _getImageUrl(index),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          CupertinoColors.systemPurple.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16.0,
                    left: 16.0,
                    right: 16.0,
                    child: Text(
                      _getTitle(index),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'ARKit Navigation Screen';
      case 1:
        return 'Light Estimation Screen';
      case 2:
        return 'RunTime Manipulation Screen';
      case 3:
        return 'Plane Detection Screen';
      case 4:
        return 'AR SnapShot Screen';
      default:
        return 'Default Name';
    }
  }

  String _getImageUrl(int index) {
    switch (index) {
      case 0:
        return 'https://image.cnbcfm.com/api/v1/image/105796703-1552666018522press-image-ar.jpg';
      case 1:
        return 'https://media.sketchfab.com/models/e7d33789de2b4fd286cf9190b855de28/thumbnails/8deed91dc70e456589da7bb160d2c30a/0bf220ebb3d64c73940da08dbbb6daf4.jpeg';
      case 2:
        return 'https://www.androidauthority.com/wp-content/uploads/2019/04/ar-position-augmented-poly-models.jpg';
      case 3:
        return 'https://9to5google.com/2019/02/15/arcore-1-7-arcore-elements/arcore-elements-2/';
      case 4:
        return 'https://1.bp.blogspot.com/-w77dN1K4gIw/XmhL3fZwmGI/AAAAAAAAFdw/EFiTotESgEwB6L_Z2HS82azRB5PgBYHzACLcBGAsYHQ/w1200-h630-p-k-no-nu/Figure1.png';
      default:
        return 'https://www.queppelin.com/wp-content/uploads/2020/08/arcore-4-300x300.jpeg';
    }
  }

  void _navigateToARCoreScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ARKitDetectionPage(),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => LightEstimatePage(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ManipulationPage(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => PlaneDetectionPage(),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => SnapshotScenePage(),
          ),
        );
        break;
      default:
        break;
    }
  }
}
