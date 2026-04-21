import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'results_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Identificador de plantas',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const PlantIdentifier(),
    );
  }
}

class PlantIdentifier extends StatefulWidget {
  const PlantIdentifier({super.key});

  @override
  State<PlantIdentifier> createState() => _PlantIdentifierState();
}

class _PlantIdentifierState extends State<PlantIdentifier> {
  XFile? _image;
  String _selectedOrgan = 'auto';
  String _identificationResult = '';
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();
  final List<String> _organOptions = [
    'auto',
    'leaf',
    'flower',
    'fruit',
    'bark',
  ];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _identifyPlant() async {
    if (_image == null) {
      return;
    }

    setState(() {
      _loading = true;
    });

    final uri = Uri.parse(
      'https://my-api.plantnet.org/v2/identify/all?include-related-images=true&no-reject=true&nb-results=20&lang=pt&api-key=2b10plbJZOxKGi928aEVLxYLle',
    );
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('images', _image!.path),
    );
    request.fields['organs'] = _selectedOrgan;

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        // Debug: Print the number of results received
        final results = data['results'] as List?;
        print('PlantNet API returned ${results?.length ?? 0} results');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(identificationData: data),
          ),
        );
      } else {
        setState(() {
          _identificationResult = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _identificationResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _testWithSampleData() async {
    try {
      // Read the local sample JSON file
      final jsonString = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/response_1751302164030.json');
      final data = jsonDecode(jsonString);

      final results = data['results'] as List?;
      print('Sample data has ${results?.length ?? 0} results');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(identificationData: data),
        ),
      );
    } catch (e) {
      setState(() {
        _identificationResult = 'Error loading sample data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plant Identifier')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null) Image.file(File(_image!.path), height: 250),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedOrgan,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedOrgan = newValue!;
                });
              },
              items: _organOptions.map<DropdownMenuItem<String>>((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _identifyPlant,
              child: const Text('Identify Plant'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _testWithSampleData,
              child: const Text('Test with Sample Data'),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const CircularProgressIndicator()
            else
              Text(_identificationResult, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
