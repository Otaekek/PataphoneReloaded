import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'data.dart';
import 'dart:async';
import 'package:image/image.dart' as img;
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

  void changeParameter(String graph_id, String node_id,  String param_name, String value) async {
    for (var graph in graphs.values) {
      graph.is_active = false;
    }
    notifyListeners();
    Uri uri = Uri.parse("http://$urlString:4242/change_parameter?graph=$graph_id&node_id=$node_id&param_name=$param_name&value=$value");
    await http.post(uri);
  }

  void changeActiveShader(String id) async {
    for (var graph in graphs.values) {
      graph.is_active = false;
    } 
    if (graphs.containsKey(id)) {
      graphs[id]!.is_active = true;
    }
    notifyListeners();
    Uri uri = Uri.parse("http://$urlString:4242/set_active_graph?graph=$id");
    await http.post(uri);
  }
  // Custom constructor
  Future<void> fetchGraphs() async {
    Uri uri = Uri.parse("http://$urlString:4242/get_graphs");

    bool something_changed = false;
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        connected = true;
        final jsonData = json.decode(response.body);
        if (jsonData == null || !jsonData.containsKey("graphs_name")) {
          return;
        }
        final graphNames = (jsonData['graphs_name'] as List).cast<String>();
        final graphsData = jsonData['graphs'];
        List<Graph> newGraphs = [];
        for (var graphName in graphNames) {
          if (graphsData.containsKey( graphName)) {
            dynamic graphData = graphsData[graphName];
            final nodesData = graphData['nodes'];
            Image? image;
            if (graphData["has_preview"]) {
              var id = graphData["id"];
              Uri uri_images = Uri.parse("http://$urlString:4242/get_image/$id");
              var image_data = await http.get(uri_images);
              var bmp = img.decodeBmp(image_data.bodyBytes)!;
              image = Image.memory(Uint8List.fromList(img.encodeBmp(bmp)));
            }
            Graph graph = Graph.fromJson(graphName, graphData, nodesData, image);
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
        var newGrapsAsMap = {
          for (var graph in newGraphs) graph.uniqueId: graph,
        };
        var toRemove = [];
        for (var graph_id in graphs.keys) {
          if (!newGrapsAsMap.containsKey(graph_id)) {
            toRemove.add(graph_id);
            something_changed = true;
          }
        }
        for (var i = 0; i < toRemove.length; ++i) {
          graphs.remove(toRemove[i]);
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
    Timer.periodic(const Duration(seconds: 1), (_) async {
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
