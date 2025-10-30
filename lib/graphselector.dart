import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'graph.dart' show GraphPage;
import 'poll.dart';

class GraphSelector extends StatelessWidget {
  const GraphSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final graphService = Provider.of<GraphService>(context);
    final ThemeData theme = Theme.of(context);
    Widget graphsBody = GridView.builder(
      itemCount: graphService.graphs.length,
      itemBuilder: (context, index) {
        final graph = graphService.graphs[index];
        return Card.outlined(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GraphPage(graph: graph)),
            ),
            borderRadius: BorderRadius.circular(
              10,
            ), // Match card's border radius
            child: GraphCard(cardName: graph.name),
          ),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.61,
      ),
    );

    Widget errcon = NoConnection(
      error_text: graphService.error,
      uri: graphService.url_string,
    );
    Widget body = graphService.connected ? graphsBody : errcon;
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Graph Selector"),),),
      body: body,
    );
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

class NoConnection extends StatelessWidget {
  final String error_text;
  final String uri;
  const NoConnection({super.key, required this.error_text, required this.uri});

  @override
  Widget build(BuildContext context) {
    final graphService = Provider.of<GraphService>(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: TextField(
          onChanged: (value) {
            // send data to the ChangeNotifier
            graphService.update_uri(input: value);
          },
          decoration: InputDecoration(
            errorText:
                "Connection refused because the URI $uri erros out because HTTP error: $error_text. You may change the URI",
            hintText: uri,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}
