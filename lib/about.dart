import 'package:flutter/material.dart';

// My Dart files
import './currencyConverterPage.dart';

class About extends StatelessWidget {

  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Currency Converter"
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CurrencyConverterPage()),
              );
            }, 
          )
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(5),
        child: Text("Simple currency converter app developed in class"),
      )
    );
  }
}