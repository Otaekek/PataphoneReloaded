import 'package:flutter/material.dart';

import 'package:pataphone/utils.dart';
import 'package:provider/provider.dart';
import 'poll.dart' show GraphService;

class NodeAttribute extends StatefulWidget {
  final String type;
  final dynamic value;
  final bool isDefaultValue;
  final dynamic min;
  final dynamic max;
  final String attribute_name;
  final String graphs_name;
  final String node_name;
  final String defaultValue;

  const NodeAttribute({
    super.key,
    required this.type,
    required this.attribute_name,
    required this.graphs_name,
    required this.node_name,
    required this.defaultValue,
    this.value,
    this.isDefaultValue = true,
    this.min = -10,
    this.max = 10,
  });

  bool compare(NodeAttribute other) {
    return value == other.value && attribute_name == other.attribute_name;
  }

  @override
  _NodeAttributeState createState() => _NodeAttributeState();
}

class _NodeAttributeState extends State<NodeAttribute> {
  late dynamic value;
  late dynamic min;
  late dynamic max;
  late bool isDefaultValue;
  @override
  void initState() {
    super.initState();
    value = widget.value;
    min = widget.min;
    max = widget.max;
    isDefaultValue = widget.isDefaultValue;
  }

  dynamic parse_value(String value) {
    if (value.contains("x")) {
      return value;
    } else if (value.contains("alse")) {
      return 0.0;
    } else if (value.contains("rue")) {
      return 1.0;
    } else {
      return double.parse(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    var color = isDefaultValue == true ? Colors.purple : Colors.blue;
    final graphService = Provider.of<GraphService>(context);

    // Add your widget UI here
    if (widget.type == "float") {
      return Card(
        child: Column(
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_circle_up),
                    onPressed: () {
                      setState(() {
                        max *= 2;
                        min *= 2;
                      });
                    },
                    tooltip: 'multiply bounds',
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "${widget.attribute_name}: ${value.toStringAsFixed(2)}",
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.restore),
                    onPressed: () {
                      setState(() {
                        print(widget.defaultValue);
                        value = parse_value(widget.defaultValue);
                        min = widget.min;
                        max = widget.max;
                        //                        isDefaultValue = true;
                      });
                      graphService.changeParameter(
                        widget.graphs_name,
                        widget.node_name,
                        widget.attribute_name,
                        widget.defaultValue,
                      );
                    },
                    tooltip: 'reset',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(min.toStringAsFixed(2)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(
                      context,
                    ).copyWith(activeTrackColor: color, thumbColor: color),
                    child: Slider(
                      divisions: 20,
                      value: value,
                      onChanged: (inValue) {
                        graphService.changeParameter(
                          widget.graphs_name,
                          widget.node_name,
                          widget.attribute_name,
                          inValue.toString(),
                        );
                        setState(() {
                          isDefaultValue = false;
                          value = inValue;
                        });
                      },
                      min: min,
                      max: max,
                    ),
                  ),
                ),
                Align(child: Text(max.toStringAsFixed(2))),
              ],
            ),
          ],
        ),
      );
    }
    return Text("Unavailable");
  }

  static NodeAttribute fromJson(
    String graphName,
    String nodeName,
    String name,
    Map<String, dynamic> json,
  ) {
    dynamic value;
    dynamic min = -10;
    dynamic max = 10;
    String type = map_type(json["type"]);

    if (type == "float") {

      value = double.parse(json["values"].toString());
      min = -1.0;
      max = 1.0;
      while (value < min || value > max) {
        min *= 2.0;
        max *= 2.0;
      }
      min *= 2.0;
      max *= 2.0;
    }

    return NodeAttribute(
      defaultValue: json["default_value"],
      attribute_name: name,
      graphs_name: graphName,
      node_name: nodeName,
      type: type,
      value: value,
      min: min,
      max: max,
      isDefaultValue: json["is_default_value"],
    );
  }
}

class Node extends StatelessWidget {
  final String name;
  final Map<String, NodeAttribute> attributes;

  bool compare(Node other) {
    if (attributes.length != other.attributes.length || name != other.name) {
      return false;
    }
    bool ret = true;
    var l1 = List.from(attributes.values);
    var l2 = List.from(other.attributes.values);

    for (var i = 0; i < attributes.length; ++i) {
      if (l1[i].isDefaultValue != l2[i].isDefaultValue) {
        return false;
      }
      if (!l1[i].isDefaultValue) {
        if (!l1[i].compare(l2[i])) {
          return false;
        }
      }
    }
    return ret;
  }

  const Node({super.key, required this.name, required this.attributes});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Align(alignment: Alignment.topCenter, child: Text(name)),
      subtitle: Card.outlined(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: attributes.entries.map((e) {
            return e.value;
          }).toList(),
        ),
      ),
    );
  }

  factory Node.fromJson(
    String graph_name,
    String name,
    Map<String, dynamic> json,
  ) {
    Map<String, NodeAttribute> attributes = {};
    json.forEach((key, value) {
      if (map_type(value["type"]) != "undefined") {
        attributes[key] = _NodeAttributeState.fromJson(
          graph_name,
          name,
          key,
          value,
        );
      }
    });
    return Node(name: name, attributes: attributes);
  }
}
