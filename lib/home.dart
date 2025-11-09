import 'package:flutter/material.dart';
import 'package:pataphone/camera.dart';
import 'package:camera/camera.dart';
import 'graphselector.dart';
import 'mapping.dart' show PolygonEditorScreen;

class HomePage extends StatelessWidget {
  List<CameraDescription> cameras;

  HomePage({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
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
              alignment: Alignment.center,
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
              Tab(icon: const Icon(Icons.lightbulb), text: "Light"),
              Tab(icon: const Icon(Icons.settings_overscan), text: "Mapping"),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            GraphSelector(),
            CameraWidget(cameras: cameras),
            GraphSelector(),
            PolygonEditorScreen(),
          ],
        ),
      ),
    );
  }
}
