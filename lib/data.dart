import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

import 'package:pataphone/utils.dart';

import 'node.dart';


class Graph {
  final String name;
  final String uniqueId;
  final List<Node> nodes;
  final int version;
  late Image preview;
  bool is_active = false;

  bool compare(Graph other) {
    final sameId = other.uniqueId == uniqueId;
    final sameName = other.name == name;
    bool sameNode = true;
    if (nodes.length != other.nodes.length) {
      return false;
    }
    for (var i = 0; i < nodes.length; ++i) {
      if (!nodes[i].compare(other.nodes[i])) {
        return false;
      }
    }
    return sameId &&
        sameName &&
        sameNode &&
        version == other.version &&
        //is_active == other.is_active &&
        sameNode;
  }

  Graph(
    Image? image, {
    required this.name,
    required this.version,
    required this.uniqueId,
    required this.nodes,
    required this.is_active,
  }) {
    preview = image ?? load_preview();
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
    final image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: rgbaBytes,
      numChannels: 4,
      format: img.Format.uint8,
    );
    // Encode to PNG
    final bmp = Uint8List.fromList(img.encodeBmp(image));

    // Return a Flutter Image widget
    return Image.memory(bmp);
  }

  Image load_preview() {
    final image = Image.asset('assets/images/eye.png');
    return image;
  }

  factory Graph.fromJson(
    String name,
    Map<String, dynamic> graphJson,
    Map<String, dynamic> nodesJson,
    Image? image,
  ) {
    List<Node> nodes = [];
    final uniqueId = graphJson["id"];
    final nodeNames = graphJson['nodes_name'];
    for (var nodeName in nodeNames) {
      if (nodesJson.containsKey(nodeName)) {
        if (filter_nodes(nodesJson[nodeName])) {
          nodes.add(Node.fromJson(name, nodeName, nodesJson[nodeName]));
        }
      }
    }
    return Graph(
      image,
      name: graphJson["name"],
      version: graphJson["version"],
      nodes: nodes,
      uniqueId: uniqueId,
      is_active: graphJson["is_active"],
    );
  }
}

bool filter_nodes(Map<String, dynamic> node) {
  for (var value in node.values) {
    if (map_type(value["type"]) != "undefined") {
      return true;
    }
  }
  return false;
}
