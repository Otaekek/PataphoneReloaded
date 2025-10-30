import 'data.dart' show Graph;
import 'package:flutter/material.dart';

class GraphPage extends StatelessWidget {
  final Graph graph;
  GraphPage({required this.graph});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(graph.name)),
      body: ListView.builder(
        itemCount: graph.nodes.length,
        itemBuilder: (context, index) {
          final node = graph.nodes[index];
          return Card(
            child: ListTile(
              title: Text(node.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: node.attributes.entries.map((e) {
                  return Text("${e.key}: ${e.value.value}");
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}


