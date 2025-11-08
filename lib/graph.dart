import 'package:pataphone/utils.dart';

import 'data.dart' show Graph, NodeAttribute;
import 'package:flutter/material.dart';

class GraphPage extends StatelessWidget {
  final Graph graph;
  final Image? preview;
  GraphPage({required this.graph, required this.preview});


  Widget makePreview() {
    return Card.outlined(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: preview!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(alignment: Alignment.center, child: Text(graph.name)),
        actions: [preview != null ? makePreview() : Text("")],
      ),
      body: ListView.builder(
        itemCount: graph.nodes.length,
        itemBuilder: (context, index) {
          final node = graph.nodes[index];
          var ret = node;
          return ret.build(context);
        },
      ),
    );
  }
}
