import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'data.dart';
import 'dart:async';

class GraphService extends ChangeNotifier {
  List<Graph> graphs = [];
  String url_string = 'http://localhost:4242';
  bool connected = false;
  String error = "";

  void update_uri({input = String}) {
    url_string = input;
    notifyListeners();
  }
  // Custom constructor
  Future<void> fetchGraphs() async {
    Uri uri = Uri.parse("$url_string/get_graphs");
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final graphNames = (jsonData['graphs_name'] as List).cast<String>();
        final graphsData = jsonData['graphs'];
        List<Graph> newGraphs = [];
        for (var graphName in graphNames) {
          if (graphsData.containsKey(graphName)) {
              dynamic graphData = graphsData[graphName];
              final nodesData = graphData['nodes'];
              Graph graph = Graph.fromJson(graphName, graphData, nodesData);
              newGraphs.add(graph);
          }
        }
        graphs = newGraphs;
        connected = true;
      } else {
        graphs = [];
        error = response.statusCode.toString();
        connected = false;
      } 
    } catch (e)  {
        print(e.toString());
        error = e.toString();
        graphs = [];
        connected = false;
    }
    notifyListeners();
  }

bool _isPolling = false;

void startPolling() {

  Timer.periodic(const Duration(seconds: 2), (_) async {
    if (_isPolling) return;
    _isPolling = true;
    try {
      await fetchGraphs();
    } finally {
      _isPolling = false;
    }
  });
}
}
