import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ChangeNotifierProvider;
import 'home.dart' show HomePage;
import 'poll.dart' show GraphService;
import 'package:window_manager/window_manager.dart'; 
import 'dart:io' show Platform;

void main()  {
  final graphService = GraphService();
  graphService.startPolling();
  // Set window size for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WidgetsFlutterBinding.ensureInitialized();
    () async {
      await windowManager.ensureInitialized();
    }();
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
  }


      ThemeData theme = ThemeData(
    // Define the default brightness and colors.
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple,
      // ···
      outlineVariant: const Color.fromARGB(255, 139, 40, 155),
      brightness: Brightness.dark,
    ),


    // Define the default `TextTheme`. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
    textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
      ),
      // ···
      titleLarge: GoogleFonts.oswald(
        fontSize: 30,
        fontStyle: FontStyle.italic,
      ),
      bodyMedium: GoogleFonts.merriweather(),
      displaySmall: GoogleFonts.pacifico(),
    ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => graphService,
      child: MaterialApp(theme: theme, home: HomePage()),
    ),
  );
}
