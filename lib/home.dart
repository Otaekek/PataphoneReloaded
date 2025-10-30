import 'package:flutter/material.dart';

import 'graphselector.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 4,
      child: Scaffold(
        appBar: AppBar(
            flexibleSpace: Align(
            alignment: Alignment(0, -5.5),
            child: Image.asset(
              'images/eye1.png',
              height: 120,
              width: 120,
              fit: BoxFit.contain,
            ),
          ),
          shadowColor: Theme.of(context).shadowColor,
          bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: const Icon(Icons.cloud_outlined), text: "Graphs"),
              Tab(icon: const Icon(Icons.beach_access_sharp), text: "Record"),
              Tab(icon: const Icon(Icons.brightness_5_sharp), text: "Light"),
              Tab(icon: const Icon(Icons.brightness_5_sharp), text: "Settings"),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            GraphSelector(),
            GraphSelector(),
            GraphSelector(),
            GraphSelector(),
          ],
        ),
      ),
    );
  }
}
