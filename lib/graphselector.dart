
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
        return Container(
//          shape: RoundedRectangleBorder(
//            side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
//            borderRadius: BorderRadius.circular(10),
//          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GraphPage(graph: graph)),
            ),
            borderRadius: BorderRadius.circular(
              10,
            ), // Match card's border radius
            //child: GraphCard(cardName: graph.name),
            child: Row(
              children: [
                Card.outlined( child: Image(
                  image: ResizeImage(
                    graph.preview.image,
                    width:
                    min(
                        MediaQuery.widthOf(context) ~/
                        2, 256)
                  ),
                )),
                Text(graph.name),
              ],
            ),
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
