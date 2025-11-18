import 'package:flutter/material.dart';
import 'package:pataphone/camera.dart';
import 'package:camera/camera.dart';
import 'graphselector.dart';
import 'mapping.dart' show PolygonEditorScreen;

class HomePage extends StatefulWidget {
  List<CameraDescription> cameras;

  HomePage({super.key, required this.cameras});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late List<CameraDescription> cameras;
  late Widget mapWidget;

  @override
  void initState() {
    super.initState();
    cameras = widget.cameras;
    mapWidget = PolygonEditorScreen();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is a snackbar')),
                );
              },
            ),
          ],
          flexibleSpace: Align(
            child: Image.asset(
              alignment: Alignment(0.0, -0.3),
              'assets/images/eye1.png',
              height: 220,
              width: 120,
              fit: BoxFit.contain,
            ),
          ),
          shadowColor: Theme.of(context).shadowColor,
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: const Icon(Icons.desktop_windows_outlined),
                text: "Shaders",
              ), // Should be named graphs, but this is more intuitive
              Tab(icon: const Icon(Icons.camera_alt), text: "Record"),
              // Tab(icon: const Icon(Icons.lightbulb), text: "Light"),
              Tab(icon: const Icon(Icons.settings_overscan), text: "Mapping"),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            GraphSelector(),
            CameraWidget(cameras: cameras),
            //   GraphSelector(),
            mapWidget,
          ],
        ),
      ),
    );
  }
}
