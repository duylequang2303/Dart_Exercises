import 'package:flutter/material.dart';

// ignore: unused_import — kept for easy switching to MapScreen
import 'maps_screen.dart';
import 'router_finder_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Maps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Default home screen: Route Finder
      home: const RouterFinderScreen(),
      // To switch to the full-map screen instead, comment out the line above
      // and uncomment the line below:
      // home: const MapScreen(),
    );
  }
}
