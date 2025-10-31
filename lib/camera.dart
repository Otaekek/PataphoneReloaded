import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraWidget extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraWidget({super.key, required this.cameras});
  @override
  State<CameraWidget> createState() => _CameraWidgetState(cameras: cameras);
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController? controller;
  final List<CameraDescription> cameras;
  _CameraWidgetState({required this.cameras});

  @override
  void initState() {
    super.initState();
    if (cameras.isEmpty) {
      return;
    }
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller
        ?.initialize()
        .then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        })
        .catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                // Handle access errors here.
                break;
              default:
                // Handle other errors here.
                break;
            }
          }
        });
  }
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return Scaffold(body: CameraPreview(controller!));
    }
    return Scaffold(body: Center(child: Text("No Camera found")),);
  }
}