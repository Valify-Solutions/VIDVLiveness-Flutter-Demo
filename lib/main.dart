import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:vidvliveness_flutter_plugin/vidvliveness_flutter_plugin.dart';
import 'package:pretty_http_logger/pretty_http_logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _LivenessResult = 'No result yet';
  final _vidvlivenessFlutterPlugin = VidvlivenessFlutterPlugin();

  // Example credentials, replace with real values
  final String baseURL = '';
  final String bundleKey = '';
  final String userName = '';
  final String password = '';
  final String clientID = '';
  final String clientSecret = '';

  // Configuration parameters
  bool _enableSmile = true;
  bool _enableLookLeft = true;
  bool _enableLookRight = true;
  bool _enableCloseEyes = true;
  int _trials = 3;
  int _instructions = 4;
  int _timer = 10;
  bool _enableVoiceover = true;

  // Function to generate a token using the provided credentials
  Future<String?> getToken() async {
    final String url = '$baseURL/api/o/token/';
    HttpWithMiddleware httpWithMiddleware = HttpWithMiddleware.build(middlewares: [
      HttpLogger(logLevel: LogLevel.BODY),
    ]);
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final String body = 'username=$userName&password=$password&client_id=$clientID&client_secret=$clientSecret&grant_type=password';

    final http.Response response = await httpWithMiddleware.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['access_token'];
    } else {
      print('Failed to retrieve token: ${response.statusCode}');
      return null;
    }
  }

  // Function to start the SDK after generating the token
  Future<void> startSDK() async {
    String? token;

    try {
      token = await getToken();
      if (token == null) {
        setState(() {
          _LivenessResult = 'Failed to get token';
        });
        return;
      }
    } catch (e) {
      setState(() {
        _LivenessResult = 'Error retrieving token: $e';
      });
      return;
    }

    final Map<String, dynamic> params = {
      "base_url": baseURL,
      "access_token": token,
      "bundle_key": bundleKey,
      "enableSmile": _enableSmile,
      "enableLookLeft": _enableLookLeft,
      "enableLookRight": _enableLookRight,
      "enableCloseEyes": _enableCloseEyes,
      "trials": _trials,
      "instructions": _instructions,
      "timer": _timer,
      "primaryColor": "#FFFFFF", // replace with actual hex color code
      "enableVoiceover": _enableVoiceover,
    };

    try {
      final String? result = await VidvlivenessFlutterPlugin.startLiveness(params);
      setState(() {
        _LivenessResult = result ?? 'Failed to start Liveness process.';
      });
    } on PlatformException catch (e) {
      setState(() {
        _LivenessResult = 'Failed to start SDK: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Liveness Plugin Example'),
        ),
        body: SingleChildScrollView( // Make the entire body scrollable
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Configuration Options',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              CheckboxListTile(
                title: const Text('Enable Smile'),
                value: _enableSmile,
                onChanged: (bool? value) {
                  setState(() {
                    _enableSmile = value ?? true;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Enable Look Left'),
                value: _enableLookLeft,
                onChanged: (bool? value) {
                  setState(() {
                    _enableLookLeft = value ?? true;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Enable Look Right'),
                value: _enableLookRight,
                onChanged: (bool? value) {
                  setState(() {
                    _enableLookRight = value ?? true;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Enable Close Eyes'),
                value: _enableCloseEyes,
                onChanged: (bool? value) {
                  setState(() {
                    _enableCloseEyes = value ?? true;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Adjustments for trials, instructions, and timer
              const Text('Trials (default: 3):'),
              Slider(
                value: _trials.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _trials.toString(),
                onChanged: (double value) {
                  setState(() {
                    _trials = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text('Instructions (default: 4):'),
              Slider(
                value: _instructions.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _instructions.toString(),
                onChanged: (double value) {
                  setState(() {
                    _instructions = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text('Timer (default: 10):'),
              Slider(
                value: _timer.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                label: _timer.toString(),
                onChanged: (double value) {
                  setState(() {
                    _timer = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 20),

              CheckboxListTile(
                title: const Text('Enable Voiceover'),
                value: _enableVoiceover,
                onChanged: (bool? value) {
                  setState(() {
                    _enableVoiceover = value ?? true;
                  });
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: startSDK,
                child: const Text('Start Liveness'),
              ),
              const SizedBox(height: 20),

              Text(
                'Liveness Result: $_LivenessResult\n',
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
