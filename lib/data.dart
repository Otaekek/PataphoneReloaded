class NodeAttribute {
  final String type;
  dynamic value;

  NodeAttribute({required this.type, required this.value});

  factory NodeAttribute.fromJson(Map<String, dynamic> json) {
    return NodeAttribute(
      type: json['type'] ?? 'unknown',
      value: json['value'],
    );
  }
}

class Node {
  final String name;
  final Map<String, NodeAttribute> attributes;

  Node({required this.name, required this.attributes});

  factory Node.fromJson(String name, Map<String, dynamic> json) {
    Map<String, NodeAttribute> attributes = {};
    json.forEach((key, value) {
      attributes[key] = NodeAttribute.fromJson(value);
    });
    return Node(name: name, attributes: attributes);
  }
}

class Graph {
  final String name;
  final List<Node> nodes;

  Graph({required this.name, required this.nodes});

  factory Graph.fromJson(String name, Map<String, dynamic> graphJson, Map<String, dynamic> nodesJson) {
    List<Node> nodes = [];
    final nodeNames = (graphJson['nodes_name'] as List).cast<String>();
    for (var nodeName in nodeNames) {
      if (nodesJson.containsKey(nodeName)) {
        nodes.add(Node.fromJson(nodeName, nodesJson[nodeName]));
      }
    }
    return Graph(name: name, nodes: nodes);
  }
}
