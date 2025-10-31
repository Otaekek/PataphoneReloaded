import 'dart:ffi' hide Size;

import 'package:flutter/material.dart';
import 'dart:math' as math;

class PolygonEditorScreen extends StatefulWidget {
  const PolygonEditorScreen({Key? key}) : super(key: key);

  @override
  State<PolygonEditorScreen> createState() => _PolygonEditorScreenState();
}

class _PolygonEditorScreenState extends State<PolygonEditorScreen> {
  late List<List<List<Offset>>> vertices = [
    [
      [Offset(0.0, 0.0), Offset(0.0, 1.0), Offset(1.0, 1.0), Offset(0.0, 0.0)],
    ],
    [
      [Offset(0.0, 0.0), Offset(0.0, 1.0), Offset(1.0, 1.0), Offset(0.0, 0.0)],
    ],
  ];
  int? selectedVertexIndex;
  int selectedPolygonIndex = 0;
  int selectedType = 0; // 0 = shape, 1 = cut
  bool showGrid = true;
  Color polygonColor = Colors.blue;
  double strokeWidth = 2.0;
  Size? _size;

  void _add_polygon(int in_selected_type) {
    setState(() {
      vertices[in_selected_type][selectedPolygonIndex] = [
        Offset(0.0, 0.0),
        Offset(0.0, 1.0),
        Offset(1.0, 1.0),
        Offset(0.0, 0.0),
      ];
      selectedPolygonIndex += 1;
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

  void _clearAll() {
    setState(() {
      vertices.clear();
      selectedVertexIndex = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapping'),
        actions: [
          IconButton(
            icon: Icon(showGrid ? Icons.grid_on : Icons.grid_off),
            onPressed: () {
              setState(() {
                showGrid = !showGrid;
              });
            },
            tooltip: 'Toggle Grid',
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _showColorPicker,
            tooltip: 'Change Color',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAll,
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: 
          LayoutBuilder(
            builder: (context, constraints) {
              _size = Size(constraints.maxWidth, constraints.maxHeight);
              return GestureDetector(
                onTapDown: (details) {},
                onPanUpdate: (details) {
                  if (vertices.isEmpty) {
                    return;
                  }
                  final polygon = vertices[selectedType][selectedPolygonIndex];
                  final localPosition = details.localPosition;
                  int? nearbyVertex = _findNearbyVertex(localPosition);
                  if (nearbyVertex != null) {
                    _moveVertex(
                      nearbyVertex,
                      polygon[nearbyVertex] + details.delta,
                    );
                  } else if (isPointInPolygon(details.localPosition, polygon)) {
                    for (var index = 0; index < polygon.length; index++) {
                      _moveVertex(index, polygon[index] + details.delta);
                    }
                  }
                },
                child: CustomPaint(
                  painter: PolygonPainter(
                    selectedVertexIndex: selectedVertexIndex,
                    showGrid: showGrid,
                    polygonColor: polygonColor,
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

      floatingActionButton: selectedVertexIndex != null
          ? FloatingActionButton(
              onPressed: _deleteSelectedVertex,
              tooltip: 'Delete Selected Vertex',
              backgroundColor: Colors.red,
              child: const Icon(Icons.delete),
            )
          : null,
    );
  }

  int? _findNearbyVertex(Offset position) {
    const threshold = 20.0;
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

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Polygon Color'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              [
                Colors.blue,
                Colors.red,
                Colors.green,
                Colors.orange,
                Colors.purple,
                Colors.teal,
                Colors.pink,
                Colors.amber,
              ].map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      polygonColor = color;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: polygonColor == color
                            ? Colors.black
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

class PolygonPainter extends CustomPainter {
  final List<List<List<Offset>>> vertices;
  final int? selectedVertexIndex;
  final int selectedType;
  final int selectedPolygonIndex;
  final bool showGrid;
  final Color polygonColor;
  final double strokeWidth;

  PolygonPainter({
    required this.selectedType,
    required this.selectedPolygonIndex,
    required this.vertices,
    required this.selectedVertexIndex,
    required this.showGrid,
    required this.polygonColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      _drawGrid(canvas, size);
    }

    for (var type = 0; type < 2 && type < vertices.length; type++) {
      for (var index = 0; index < vertices[type].length; index++) {
        var polygon = vertices[type][index];
        bool is_selected_polygon = false;
        // if (selectedPolygonIndex == index) {
        //   if (selectedType == type) {
        //     is_selected_polygon = true;
        //   }
        // }
        // Draw polygon fill
        if (polygon.isNotEmpty) {
          final fillPaint = Paint()
            ..color = polygonColor.withOpacity(0.3)
            ..style = PaintingStyle.fill;

          final path = Path()..moveTo(polygon[0].dx, polygon[0].dy);
          for (int i = 1; i < polygon.length; i++) {
            path.lineTo(polygon[i].dx, polygon[i].dy);
          }
          path.close();
          canvas.drawPath(path, fillPaint);
        }

        // Draw polygon edges
        if (polygon.length >= 2) {
          final edgePaint = Paint()
            ..color = polygonColor
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke;

          for (int i = 0; i < polygon.length; i++) {
            int nextIndex = (i + 1) % polygon.length;
            canvas.drawLine(polygon[i], polygon[nextIndex], edgePaint);
          }
        }

        // Draw polygon
        for (int i = 0; i < polygon.length; i++) {
          final isSelected = i == selectedVertexIndex && is_selected_polygon;
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
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    const gridSpacing = 50.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(PolygonPainter oldDelegate) {
    return true;
  }
}
