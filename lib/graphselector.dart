import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'connection.dart' show NoConnection;
import 'graph.dart' show GraphPage;
import 'poll.dart';
import 'dart:math';
import 'package:image/image.dart' as img;

class GraphSelector extends StatelessWidget {
  const GraphSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final graphService = Provider.of<GraphService>(context);
    final ThemeData theme = Theme.of(context);
    Widget graphsBody = ListView.builder(
      itemCount: graphService.graphs.length,
      itemBuilder: (context, index) {
        var keys = graphService.graphs.keys.toList();
        var val = graphService.graphs[keys[index]];
        final graph = val!;
        final height = graph.preview.height ?? 100;
        return Material(
          color: graph.is_active ? Colors.purple.withAlpha(70) : null,
          child: Row(
            children: [
              Card.outlined(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GraphPage(graph: graph, preview: graph.preview)),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image(
                      image: ResizeImage(
                        graph.preview.image,
                        width:
                            MediaQuery.widthOf(context) ~/
                            2.5, //min(MediaQuery.widthOf(context) ~/ 2, 256),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      height: height / 2,
                      width: (MediaQuery.widthOf(context) ~/ 2.5).toDouble(),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        graph.name,
                        softWrap: true,
                        textScaler: TextScaler.linear(.9),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        graphService.changeActiveShader(graph.uniqueId);
                      },
                      tooltip: 'Set active',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    Widget errcon = NoConnection(
      error_text: graphService.error,
      uri: graphService.urlString,
    );
    Widget body = graphService.connected ? graphsBody : errcon;
    return Scaffold(body: body);
  }
}

class GraphCard extends StatelessWidget {
  const GraphCard({super.key, required this.cardName});
  final String cardName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Center(child: Text(cardName)),
    );
  }
}
