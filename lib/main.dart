import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(CurrencyApp());
}

class CurrencyApp extends StatelessWidget {
  const CurrencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CurrencyConverter(),
    );
  }
}

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final List<String> currencies = ["USD", "INR", "EUR", "GBP", "JPY"];

  String fromCurrency = "USD";
  String toCurrency = "INR";

  double amount = 1;
  double result = 0;
  double rate = 0;

  Map<String, dynamic> rates = {};

  @override
  void initState() {
    super.initState();
    fetchRates();
  }

  Future<void> fetchRates() async {
    try {
      final response = await http.get(
        Uri.parse("https://api.exchangerate-api.com/v4/latest/$fromCurrency"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          rates = data["rates"];
          rate = rates[toCurrency];
          convert();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No Internet ❌")),
      );
    }
  }

  void convert() {
    if (rates.isNotEmpty) {
      setState(() {
        result = amount * rate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff1e3c72), Color(0xff2a5298)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Currency Converter 💱",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 30),

                // Amount Card
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Amount",
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                    onChanged: (val) {
                      amount = double.tryParse(val) ?? 0;
                      convert();
                    },
                  ),
                ),

                SizedBox(height: 20),

                // Dropdown Row
                Row(
                  children: [
                    Expanded(child: buildDropdown(fromCurrency, true)),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(child: buildDropdown(toCurrency, false)),
                  ],
                ),

                SizedBox(height: 40),

                // Result Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Converted Amount",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        result.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        toCurrency,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Rate Text
                Center(
                  child: Text(
                    "1 $fromCurrency = $rate $toCurrency",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(String value, bool isFrom) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: SizedBox(),
        items: currencies.map((c) {
          return DropdownMenuItem(value: c, child: Text(c));
        }).toList(),
        onChanged: (val) {
          setState(() {
            if (isFrom) {
              fromCurrency = val!;
              fetchRates();
            } else {
              toCurrency = val!;
              rate = rates[toCurrency] ?? 0;
              convert();
            }
          });
        },
      ),
    );
  }
}
