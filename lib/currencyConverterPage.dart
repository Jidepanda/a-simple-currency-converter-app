import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './about.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverterPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  String _fromCurrency = 'NGN';
  String _toCurrency = 'USD';
  double _conversionRate = 0.0;
  String _result = "";
  Map<String, double> _rates = {};
  bool _isLoading = true;

  Future<void> fetchData() async {
    final Uri uri = Uri.parse('https://api.exchangerate-api.com/v4/latest/$_fromCurrency');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _rates = (data['rates'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, value.toDouble()),
          );
          _updateConversionRate();
          _isLoading = false;
          print('Fetched rates: $_rates');
          print('Conversion rate ($_fromCurrency to $_toCurrency): $_conversionRate');
        });
      } else {
        setState(() {
          _result = "Error fetching rates: Status ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = "Error: $e. Tap to retry";
        _isLoading = false;
      });
    }
  }

  void _updateConversionRate() {
    if (_fromCurrency == _toCurrency) {
      _conversionRate = 1.0;
    } else {
      _conversionRate = _rates[_toCurrency]! / _rates[_fromCurrency]!;
    }
  }

  void _convert() {
    if (_controller.text.isEmpty) {
      setState(() => _result = "Please enter an amount");
      return;
    }
    double? value = double.tryParse(_controller.text);
    if (value != null && _conversionRate > 0) {
      double convertedValue = value * _conversionRate;
      setState(() {
        _result = convertedValue.toStringAsFixed(2);
        print('Conversion: $value $_fromCurrency = $convertedValue $_toCurrency');
      });
    } else {
      setState(() => _result = "Invalid input or rate");
    }
  }

  void _switchCurrencies() {
    setState(() {
      String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _controller.clear();
      _result = "";
      _isLoading = true;
      fetchData(); // Refresh rates with new base currency
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final List<String> currencies = ['NGN', 'USD', 'EUR'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Currency Converter"),
        backgroundColor: Colors.purple[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const About()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4A148C),
                    Color(0xFFAB47BC),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          value: _fromCurrency,
                          items: currencies.map((String currency) {
                            return DropdownMenuItem<String>(
                              value: currency,
                              child: Text(
                                currency,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null && newValue != _fromCurrency) {
                              setState(() {
                                _fromCurrency = newValue;
                                _isLoading = true;
                                _result = "";
                                _controller.clear();
                              });
                              fetchData();
                            }
                          },
                          dropdownColor: Colors.purple[800],
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.swap_horiz, color: Colors.white),
                          onPressed: _switchCurrencies,
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          value: _toCurrency,
                          items: currencies.map((String currency) {
                            return DropdownMenuItem<String>(
                              value: currency,
                              child: Text(
                                currency,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null && newValue != _toCurrency) {
                              setState(() {
                                _toCurrency = newValue;
                                _updateConversionRate();
                                _result = "";
                                _controller.clear();
                              });
                            }
                          },
                          dropdownColor: Colors.purple[800],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: "Amount",
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _result.isEmpty ? "0.00" : _result,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_result.contains("Error")) {
                                setState(() => _isLoading = true);
                                fetchData();
                              } else {
                                _convert();
                              }
                            },
                      child: const Text("Convert"),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildKeypadButton("7"),
                              _buildKeypadButton("8"),
                              _buildKeypadButton("9"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildKeypadButton("4"),
                              _buildKeypadButton("5"),
                              _buildKeypadButton("6"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildKeypadButton("1"),
                              _buildKeypadButton("2"),
                              _buildKeypadButton("3"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildKeypadButton("C"),
                              _buildKeypadButton("0"),
                              _buildKeypadButton("."),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKeypadButton(String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          if (value == "C") {
            _controller.clear();
            setState(() => _result = "");
          } else if (value == "." && _controller.text.contains(".")) {
            return;
          } else if (_controller.text.length < 15) {
            _controller.text += value;
          }
        },
        child: Text(value),
      ),
    );
  }
}
