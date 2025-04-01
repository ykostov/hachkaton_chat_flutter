import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import '../models/kid_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DirectConnectionTest extends StatefulWidget {
  @override
  _DirectConnectionTestState createState() => _DirectConnectionTestState();
}

class _DirectConnectionTestState extends State<DirectConnectionTest> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  String _logOutput = '';
  bool _isLoading = false;
  String _connectionStatus = 'Not tested';

  @override
  void initState() {
    super.initState();
    // Select the appropriate default based on platform
    if (Platform.isAndroid) {
      _ipController.text = '10.0.2.2'; // Android emulator special IP
    } else if (Platform.isIOS) {
      _ipController.text = 'localhost'; // iOS simulator
    } else if (Platform.isMacOS) {
      _ipController.text = 'localhost'; // macOS app
    } else {
      _ipController.text = 'localhost'; // Default for other platforms
    }
    
    _nameController.text = 'Test Kid';
    _emailController.text = 'test@example.com';
    
    // Log platform information to help with debugging
    _log('Platform: ${Platform.operatingSystem}');
    _log('Using default IP: ${_ipController.text}');
  }

  void _log(String message) {
    setState(() {
      _logOutput = '$message\n$_logOutput';
    });
    print(message);
  }

  Future<void> _testHealthEndpoint() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing...';
    });

    final dio = _configureDio();
    final url = 'http://${_ipController.text}:4000/api/health';
    
    _log('Attempting to connect to: $url');
    
    try {
      final response = await dio.get(url);
      _log('Connection successful!');
      _log('Response: ${response.data}');
      setState(() {
        _connectionStatus = 'Connected successfully';
      });
    } catch (e) {
      _log('Connection failed: $e');
      setState(() {
        _connectionStatus = 'Connection failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLoginEndpoint() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing login...';
    });

    final dio = _configureDio();
    final url = 'http://${_ipController.text}:4000/api/kids/login';
    
    _log('Attempting to login at: $url');
    
    try {
      final response = await dio.post(
        url,
        data: {
          'name': _nameController.text,
          'email': _emailController.text,
        },
      );
      
      _log('Login successful!');
      _log('Response: ${response.data}');
      
      // Save the token and user data
      if (response.data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response.data['token']);
        
        // Create and save the kid user
        final kidData = response.data['kid'];
        if (kidData != null) {
          final kidUser = KidUser(
            id: kidData['id'].toString(),
            name: kidData['name'],
            email: kidData['email'],
          );
          
          await prefs.setString('kid_user', json.encode(kidUser.toJson()));
          _log('User data saved to SharedPreferences');
        }
      }
      
      setState(() {
        _connectionStatus = 'Login successful';
      });
    } catch (e) {
      _log('Login failed: $e');
      setState(() {
        _connectionStatus = 'Login failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Dio _configureDio() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Enable logging
    dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));
    
    // Configure HTTP client for self-signed certificates and debugging
    if (dio.httpClientAdapter is IOHttpClientAdapter) {
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    
    return dio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Direct Connection Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Status: $_connectionStatus', 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _connectionStatus.contains('successful') ? Colors.green : 
                      _connectionStatus.contains('failed') ? Colors.red : Colors.black,
              ),
            ),
            SizedBox(height: 16),
            
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'Server IP',
                helperText: 'Use "localhost" for iOS simulator, "10.0.2.2" for Android emulator',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Kid Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Kid Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testHealthEndpoint,
                    child: Text('Test Health Endpoint'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testLoginEndpoint,
                    child: Text('Test Login Endpoint'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_logOutput),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}