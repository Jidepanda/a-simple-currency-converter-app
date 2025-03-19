import 'package:flutter/material.dart';

// My Files
import './currencyConverterPage.dart';
import './frontPage.dart'; // Import the new FrontPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Currency Converter",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 71, 42, 3)),
        useMaterial3: true,
      ),
      home: const FrontPage(), // Set FrontPage as the initial screen
    );
  }
}