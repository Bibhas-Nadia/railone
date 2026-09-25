import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StationDistancePage extends StatefulWidget {
  const StationDistancePage({super.key});

  @override
  State<StationDistancePage> createState() => _StationDistancePageState();
}

class _StationDistancePageState extends State<StationDistancePage> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destController = TextEditingController();

  bool _isLoading = false;
  String _resultText = '';

  // Function to fetch distance from API
  Future<void> _fetchDistance() async {
    final sourceCode = _sourceController.text.trim().toUpperCase();
    final destCode = _destController.text.trim().toUpperCase();

    if (sourceCode.isEmpty || destCode.isEmpty) {
      setState(() => _resultText = 'Please enter both station codes.');
      return;
    }

    setState(() {
      _isLoading = true;
      _resultText = '';
    });

    try {
      // NOTE: Replace this URL with the specific endpoint from your RapidAPI dashboard
      // Example: Many APIs require you to search for a train between stations to get the distance
      final url = Uri.parse('https://indian-railways-api.p.rapidapi.com/distance?from=$sourceCode&to=$destCode');

      final response = await http.get(
        url,
        headers: {
          // Replace 'YOUR_RAPIDAPI_KEY' with your actual free key from rapidapi.com
          'X-RapidAPI-Key': 'YOUR_RAPIDAPI_KEY',
          'X-RapidAPI-Host': 'indian-railways-api.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Parse the exact distance from the JSON response.
        // Note: You might need to adjust "data['distance']" based on the specific API you choose on RapidAPI.
        final distance = data['distance'];

        setState(() {
          _resultText = 'Distance between $sourceCode and $destCode is $distance km';
        });
      } else {
        setState(() {
          _resultText = 'Error finding distance. Please check station codes. (Code: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _resultText = 'Network Error: Check your connection.\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Station Distance'),
        backgroundColor: const Color(0xFF143059),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter Station Codes (e.g., NDLS, SDAH, HWH)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'Source Station Code',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.train),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _destController,
              decoration: const InputDecoration(
                labelText: 'Destination Station Code',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchDistance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
              : const Text('Calculate Distance', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 32),
            if (_resultText.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  _resultText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
