import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class NodeAttribute {
  final String type;
  dynamic value;
  final String name;

  bool compare(NodeAttribute other) {
    return value == other.value || name != other.name;
  }
  NodeAttribute({required this.name, required this.type, required this.value});

  factory NodeAttribute.fromJson(String name, Map<String, dynamic> json) {
    return NodeAttribute(name: name, type: json['type'] ?? 'unknown', value: json['value']);
  }
}

class Node {
  final String name;
  final Map<String, NodeAttribute> attributes;

  bool compare(Node other) {
    if (attributes.length != other.attributes.length || name != other.name) {
      return false;
    }
    bool ret = true;
    var l1 = List.from(attributes.values);
    var l2 = List.from(other.attributes.values);
    
    for (var i = 0; i < attributes.length; ++i)
    {
      if (!l1[i].compare(l2[i])) {
        ret = false;
      }
    }
    return ret;
  }
  Node({required this.name, required this.attributes});

  factory Node.fromJson(String name, Map<String, dynamic> json) {
    Map<String, NodeAttribute> attributes = {};
    json.forEach((key, value) {
      attributes[key] = NodeAttribute.fromJson(key, value);
    });
    return Node(name: name, attributes: attributes);
  }
}

class Graph {
  final String name;
  final String uniqueId;
  final List<Node> nodes;
  late Image preview;
  bool is_active = false;

  bool compare(Graph other) {
    final same_id = other.uniqueId == uniqueId;
    final same_name = other.name == name;
    final same_preview = preview.hashCode == other.preview.hashCode;
    bool same_node = false; 
    if (nodes.length != other.nodes.length) {
      return false;
    }
    for (var i = 0; i < nodes.length; ++i) {
      if (!nodes[i].compare(other.nodes[i])) {
        return false;
      }
    }
    return same_id && same_name && same_node;//same_preview && same_node;
  }
  Graph(
    Map<String, dynamic>? preview_data, {
    required this.name,
    required this.uniqueId,
    required this.nodes,
  }) {
    preview = load_preview(preview_data)!;
  }

  ui.Image rawRgbaToUiImageSync(Uint8List rgbaBytes, int width, int height) {
    ui.Image? result;
    final completer = Completer<ui.Image>();

    ui.decodeImageFromPixels(
      rgbaBytes,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (img) => completer.complete(img),
    );

    // Block until the image is ready
    result = completer.future.asStream().first as ui.Image;
    return result;
  }
Image imageFromRgba(ByteBuffer rgbaBytes, int width, int height) {
  // Decode raw RGBA bytes into an Image package image
  final image = img.Image.fromBytes(width: width, height: height, bytes: rgbaBytes, numChannels: 4, format: img.Format.uint8);
  // Encode to PNG
  final bmp = Uint8List.fromList(img.encodeBmp(image));

  // Return a Flutter Image widget
  return Image.memory(bmp);
}
  Image load_preview(Map<String, dynamic>? preview_data) {
    if (preview_data == null) {
      final file = File("./images/eye.png");
      return Image.file(file);
    } else {
      var size_x = preview_data["preview_size_x"];
      var size_y = preview_data["preview_size_y"];
      final data = base64Decode(preview_data["data"]);
      return imageFromRgba(data.buffer, size_x, size_y);
    }
  }

  factory Graph.fromJson(
    String name,
    Map<String, dynamic> graphJson,
    Map<String, dynamic> nodesJson,
  ) {
    List<Node> nodes = [];
    final unique_id = graphJson["id"];
    final nodeNames = graphJson['nodes_name'];
    for (var nodeName in nodeNames) {
      if (nodesJson.containsKey(nodeName)) {
        nodes.add(Node.fromJson(nodeName, nodesJson[nodeName]));
      }
    }
    return Graph(
      graphJson["preview"],
      name: graphJson["name"],
      nodes: nodes,
      uniqueId: unique_id,
    );
  }
}
