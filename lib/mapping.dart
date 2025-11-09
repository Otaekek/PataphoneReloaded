
import 'package:flutter/material.dart';

class PolygonEditorScreen extends StatefulWidget {
  const PolygonEditorScreen({super.key});

  @override
  State<PolygonEditorScreen> createState() => _PolygonEditorScreenState();
}

class _PolygonEditorScreenState extends State<PolygonEditorScreen> {
  late List<List<List<Offset>>> vertices;
  int? selectedVertexIndex;
  int selectedPolygonIndex = 0;
  int selectedType = 0; // 0 = shape, 1 = cut
  bool showGrid = true;
  bool wireFrame = false;
  Color polygonColor = Colors.blue;
  double strokeWidth = 2.0;
  Offset? panBeginPosision;
  Size? _size;
  List<Offset> make_default_polygon() {
    return [
      Offset(1 / 16, 1 / 16),
      Offset(1 / 16, 11 / 16),
      Offset(15 / 16, 11 / 16),
      Offset(15 / 16, 1 / 16),
    ];
  }

  _PolygonEditorScreenState() {
    vertices = [
      [make_default_polygon()],
      [make_default_polygon()],
      [make_default_polygon()],
    ];
  }
  void _add_polygon() {
    setState(() {
      for (var i = 0; i < 3; ++i) {
        var newIndex = vertices[i].length;
        vertices[i].add([]);
        vertices[i][newIndex] = make_default_polygon();
        selectedPolygonIndex = newIndex;
      }
      selectedVertexIndex = null;
    });
  }

  void _moveVertex(int index, Offset newPosition) {
    setState(() {
      vertices[selectedType][selectedPolygonIndex][index] = newPosition;
    });
  }

  void _deleteSelectedVertex() {
    if (selectedVertexIndex != null) {
      setState(() {
        vertices.removeAt(selectedVertexIndex!);
        selectedVertexIndex = null;
      });
    }
  }

  void _clear() {
    setState(() {
      for (var i = 0; i < 2; ++i) {
        if (vertices[i].length > 1) {
          vertices[i].removeAt(selectedPolygonIndex);
          selectedPolygonIndex = 0;
          selectedVertexIndex = null;
        }
      }
    });
  }

  bool isPointInPolygon(Offset point, List<Offset> polygon) {
    Path path = Path();

    path.moveTo(polygon[0].dx, polygon[0].dy);
    for (int i = 1; i < polygon.length; i++) {
      path.lineTo(polygon[i].dx, polygon[i].dy);
    }
    path.close();

    return path.contains(point);
  }

  Offset toFractionnal(Offset offset, Size? size) {
    return Offset(offset.dx / size!.width, offset.dy / size.height);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _add_polygon();
            },
            tooltip: 'New Polygon',
          ),

          IconButton(
            icon: Icon(selectedType == 0 ? Icons.cut : Icons.hexagon),
            onPressed: () {
              setState(() {
                selectedType = selectedType == 1 ? 0 : 1;
              });
            },
            tooltip: 'New Polygon',
          ),

          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _reset,
            tooltip: 'Reset',
          ),
          IconButton(
            icon: Icon(
              wireFrame == false ? Icons.polyline_outlined : Icons.polyline,
            ),
            onPressed: () {
              setState(() {
                wireFrame = !wireFrame;
              });
            },
            tooltip: 'WireFrame',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clear,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _size = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            onTapDown: (details) {
              final localPosition = toFractionnal(details.localPosition, _size);
              setState(() {
                selectedVertexIndex = _findNearbyVertex(localPosition);
              });
              panBeginPosision = localPosition;
              if (selectedVertexIndex == null) {
                for (var i = 0; i < vertices[selectedType].length; ++i) {
                  if (isPointInPolygon(
                    localPosition,
                    vertices[selectedType][i],
                  )) {
                    setState(() {
                      selectedPolygonIndex = i;
                    });
                    return;
                  }
                }
              }
            },
            onPanStart: (details) {
              final localPosition = toFractionnal(details.localPosition, _size);
              setState(() {
                selectedVertexIndex = _findNearbyVertex(localPosition);
              });
              panBeginPosision = localPosition;
              if (selectedVertexIndex == null) {
                for (var i = 0; i < vertices[selectedType].length; ++i) {
                  if (isPointInPolygon(
                    localPosition,
                    vertices[selectedType][i],
                  )) {
                    setState(() {
                      selectedPolygonIndex = i;
                    });
                    return;
                  }
                }
              }
            },
            onPanEnd: (dertails) {
              setState(() {
                selectedVertexIndex = null;
              });
            },
            onPanUpdate: (details) {
              if (vertices.isEmpty) {
                return;
              }
              final polygon = vertices[selectedType][selectedPolygonIndex];
              final localPosition = toFractionnal(details.localPosition, _size);
              final delta = toFractionnal(details.delta, _size);
              int? nearbyVertex =
                  selectedVertexIndex ?? _findNearbyVertex(localPosition);
              if (nearbyVertex != null) {
                _moveVertex(nearbyVertex, polygon[nearbyVertex] + delta);
              } else if (isPointInPolygon(localPosition, polygon) &&
                  nearbyVertex == null) {
                for (var index = 0; index < polygon.length; index++) {
                  _moveVertex(index, polygon[index] + delta);
                }
              }
            },
            child: CustomPaint(
              painter: PolygonPainter(
                selectedVertexIndex: selectedVertexIndex,
                showGrid: showGrid,
                strokeWidth: strokeWidth,
                vertices: vertices,
                selectedType: selectedType,
                selectedPolygonIndex: selectedPolygonIndex,
              ),
              child: Container(),
            ),
          );
        },
      ),

      //   floatingActionButton: selectedVertexIndex != null
      //       ? FloatingActionButton(
      //           onPressed: _deleteSelectedVertex,
      //           tooltip: 'Delete Selected Vertex',
      //           backgroundColor: Colors.red,
      //           child: const Icon(Icons.delete),
      //         )
      //       : null,
    );
  }

  int? _findNearbyVertex(Offset position) {
    const threshold = 0.05;
    for (
      int i = 0;
      i < vertices[selectedType][selectedPolygonIndex].length;
      i++
    ) {
      if ((vertices[selectedType][selectedPolygonIndex][i] - position)
              .distance <
          threshold) {
        return i;
      }
    }
    return null;
  }

  void _reset() {
    setState(() {
      vertices = [[], [], []];
      _add_polygon();
      selectedType = 0;
      selectedPolygonIndex = 0;
      selectedVertexIndex = null;
    });
  }

  //  void _showColorPicker() {
  //    showDialog(
  //      context: context,
  //      builder: (context) => AlertDialog(
  //        title: const Text('Choose Polygon Color'),
  //        content: Wrap(
  //          spacing: 10,
  //          runSpacing: 10,
  //          children:
  //              [
  //                Colors.blue,
  //                Colors.red,
  //                Colors.green,
  //                Colors.orange,
  //                Colors.purple,
  //                Colors.teal,
  //                Colors.pink,
  //                Colors.amber,
  //              ].map((color) {
  //                return GestureDetector(
  //                  onTap: () {
  //                    setState(() {
  //                      polygonColor = color;
  //                    });
  //                    Navigator.pop(context);
  //                  },
  //                  child: Container(
  //                    width: 50,
  //                    height: 50,
  //                    decoration: BoxDecoration(
  //                      color: color,
  //                      shape: BoxShape.circle,
  //                      border: Border.all(
  //                        color: polygonColor == color
  //                            ? Colors.black
  //                            : Colors.transparent,
  //                        width: 3,
  //                      ),
  //                    ),
  //                  ),
  //                );
  //              }).toList(),
  //        ),
  //      ),
  //    );
  //  }
}

class PolygonPainter extends CustomPainter {
  final List<List<List<Offset>>> vertices;
  final int? selectedVertexIndex;
  final int selectedType;
  final int selectedPolygonIndex;
  final bool showGrid;
  final double strokeWidth;

  PolygonPainter({
    required this.selectedType,
    required this.selectedPolygonIndex,
    required this.vertices,
    required this.selectedVertexIndex,
    required this.showGrid,
    required this.strokeWidth,
  });

  void paint_polygon(
    Canvas canvas,
    Size size,
    int type,
    int index,
    bool isSelectedPolygon,
  ) {
    var colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];
    var polygon = List.from(vertices[type][index]);
    for (var i = 0; i < polygon.length; i++) {
      polygon[i] = Offset(
        polygon[i].dx * size.width,
        polygon[i].dy * size.height,
      );
    }
    // if (selectedPolygonIndex == index) {
    //   if (selectedType == type) {
    //     is_selected_polygon = true;
    //   }
    // }
    // Draw polygon fill
    var alpha = 0.3;
    var polygonColor = colors[index % colors.length];
    Color color = polygonColor;
    if (type == 2) {
      color = Colors.white;
      alpha = 0.3;
    }
    if (polygon.isNotEmpty) {
      final fillPaint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      final path = Path()..moveTo(polygon[0].dx, polygon[0].dy);
      for (int i = 1; i < polygon.length; i++) {
        path.lineTo(polygon[i].dx, polygon[i].dy);
      }
      path.close();
      canvas.drawPath(path, fillPaint);
    }

    // Draw polygon edges

    if (polygon.length >= 2 && type != 2) {
      final edgePaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < polygon.length; i++) {
        int nextIndex = (i + 1) % polygon.length;
        canvas.drawLine(polygon[i], polygon[nextIndex], edgePaint);
      }
    }

    // Draw polygon
    for (int i = 0; i < polygon.length && type != 2; i++) {
      final isSelected = i == selectedVertexIndex && isSelectedPolygon;
      final vertexPaint = Paint()
        ..color = isSelected ? Colors.red : Colors.white
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = isSelected ? Colors.red : polygonColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(polygon[i], isSelected ? 8 : 6, vertexPaint);
      canvas.drawCircle(polygon[i], isSelected ? 8 : 6, borderPaint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      _drawGrid(canvas, size);
    }

    for (var index = 0; index < vertices[selectedType].length; index++) {
      bool isSelectedPolygon =
          selectedPolygonIndex == index && selectedType == selectedType;
      paint_polygon(canvas, size, 2, 0, false);
      if (isSelectedPolygon) {
        continue;
      }
      paint_polygon(canvas, size, selectedType, index, isSelectedPolygon);
    }
    paint_polygon(canvas, size, selectedType, selectedPolygonIndex, true);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    final gridspacingX = 0.2 * size.width / 3.2; // / 15/168888888888;
    final gridspacingY = 0.2 * size.height / 3.2; // / 15/168888888888;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridspacingX) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridspacingY) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(PolygonPainter oldDelegate) {
    return true;
  }
}
