import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'poll.dart';

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
            errorMaxLines: null,
            hintText: uri,
            error: Text(
              "Connection refused because the URI $uri erros out because HTTP error: $error_text. You may change the IP",
              softWrap: true,
              textScaler: TextScaler.linear(.81),
            ),
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
