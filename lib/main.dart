import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ChangeNotifierProvider;
import 'home.dart' show HomePage;
import 'poll.dart' show GraphService;
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;
import 'package:camera/camera.dart';

Future<void> main() async {
  final graphService = GraphService();
  graphService.startPolling();
  // Set window size for desktop platforms
  List<CameraDescription> _cameras = [];
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize window manager AFTER ensureInitialized
    await windowManager.ensureInitialized();
    // Common phone sizes:
    // iPhone 14 Pro: 393 x 852
    // iPhone 14 Pro Max: 430 x 932
    // Pixel 7: 412 x 915
    // Samsung Galaxy S21: 360 x 800

    WindowOptions windowOptions = const WindowOptions(
      size: Size(393, 692), // iPhone 14 Pro size
      minimumSize: Size(393, 692),
      center: true,
      title: 'PataPhone',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } else {
    _cameras = await availableCameras();
  }
  ThemeData theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple,
      outlineVariant: const Color.fromARGB(255, 139, 40, 155),
      brightness: Brightness.dark,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Colors.purple.shade100,
      inactiveTrackColor: Colors.purple.shade100,
      thumbColor: Colors.purple,
      overlayColor: Colors.purple.withOpacity(0.2),
    ),
    textTheme: TextTheme(
      displayLarge: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
      // ···
      titleLarge: GoogleFonts.oswald(fontSize: 30, fontStyle: FontStyle.italic),
      bodyMedium: GoogleFonts.merriweather(),
      displaySmall: GoogleFonts.pacifico(),
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => graphService,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: HomePage(cameras: _cameras),
      ),
    ),
  );
}
