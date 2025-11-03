import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'data.dart';
import 'dart:async';

class GraphService extends ChangeNotifier {
  Map<String, Graph> graphs = {};
  late String urlString;
  bool connected = false;
  String error = "";

  GraphService() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      urlString = '127.0.0.1';
    } else {
      urlString = '10.0.2.2';
    }
  }
  void update_uri({input = String}) {
    urlString = input;
    notifyListeners();
  }

  // Custom constructor
  Future<void> fetchGraphs() async {
    Uri uri = Uri.parse("http://$urlString:4242/get_graphs");
    bool something_changed = false;
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        connected = true;
        //print(response.body);
        final jsonData = json.decode(response.body);
        if (jsonData == null || !jsonData.containsKey("graphs_name")) {
          return;
        }
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
        for (var graph in newGraphs) {
          if (graphs.containsKey(graph.uniqueId)) {
            // graph itself is modified
            if (!graphs[graph.uniqueId]!.compare(graph)) {
              graphs[graph.uniqueId] = graph;
              something_changed = true;
            }
          } else {
            graphs[graph.uniqueId] = graph;
            something_changed = true;
          }
        }
        var newGrapsAsMap = { for (var graph in newGraphs) graph.uniqueId : graph };
        for (var graph_id in graphs.keys) {
          if (!newGrapsAsMap.containsKey(graph_id)) {
            graphs.remove(graph_id);
            something_changed = true;
          }
        }
      } else {
        graphs = {};
        error = response.statusCode.toString();
        connected = false;
      }
    } catch (e) {
      print(e.toString());
      error = e.toString();
      graphs = {};
      connected = false;
    }
    if (something_changed) {
      notifyListeners();
    }
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
