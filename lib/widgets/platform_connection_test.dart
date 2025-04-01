import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../helpers/api_helper.dart';

class PlatformConnectionTest extends StatefulWidget {
  @override
  _PlatformConnectionTestState createState() => _PlatformConnectionTestState();
}

class _PlatformConnectionTestState extends State<PlatformConnectionTest> {
  final Dio _dio = Dio();
  String _platformInfo = '';
  String _connectionStatus = 'Not tested';
  String _serverResponse = '';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _configureHttpClient();
    _detectPlatform();
  }
  
  void _detectPlatform() {
    String platform = 'Unknown';
    String special = '';
    
    if (kIsWeb) {
      platform = 'Web';
    } else if (Platform.isAndroid) {
      platform = 'Android';
      special = 'Host machine accessible at 10.0.2.2 on emulator';
    } else if (Platform.isIOS) {
      platform = 'iOS';
      special = 'Host machine accessible at localhost on simulator, needs IP on physical device';
    } else if (Platform.isMacOS) {
      platform = 'macOS';
    } else if (Platform.isWindows) {
      platform = 'Windows';
    } else if (Platform.isLinux) {
      platform = 'Linux';
    }
    
    setState(() {
      _platformInfo = 'Platform: $platform\n$special';
    });
  }

  void _configureHttpClient() {
    _dio.options.connectTimeout = Duration(seconds: 5);
    _dio.options.receiveTimeout = Duration(seconds: 5);
    
    if (_dio.httpClientAdapter is IOHttpClientAdapter) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    
    _dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));
  }

  Future<void> _testLocalhost() async {
    await _testConnection('http://localhost:4000/api/health');
  }
  
  Future<void> _testAndroidSpecial() async {
    await _testConnection('http://10.0.2.2:4000/api/health');
  }
  
  Future<void> _testCustomIp() async {
    final TextEditingController controller = TextEditingController();
    String? customIp = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter your computer\'s IP address'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '192.168.1.X',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text('TEST'),
          ),
        ],
      ),
    );
    
    if (customIp != null && customIp.isNotEmpty) {
      await _testConnection('http://$customIp:4000/api/health');
    }
  }

  Future<void> _testConnection(String url) async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing $url...';
      _serverResponse = '';
    });

    try {
      final response = await _dio.get(url);

      setState(() {
        _isLoading = false;
        _connectionStatus = 'Success: Connected to $url';
        _serverResponse = 'Response: ${response.data}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _connectionStatus = 'Failed: Could not connect to $url';
        
        if (e is DioException) {
          _serverResponse = 'Error Type: ${e.type}\n';
          _serverResponse += 'Message: ${e.message}\n';
          
          if (e.error != null) {
            _serverResponse += 'Underlying Error: ${e.error.toString()}\n';
          }
          
          if (e.response != null) {
            _serverResponse += 'Response: ${e.response!.data}';
          }
        } else {
          _serverResponse = 'Error: $e';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Platform Connection Test'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Platform information
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Information',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(_platformInfo),
                    SizedBox(height: 8),
                    Text('API Helper Recommended URL: ${ApiHelper.getBaseUrl()}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Connection status
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _connectionStatus,
                      style: TextStyle(
                        color: _connectionStatus.contains('Success')
                            ? Colors.green
                            : _connectionStatus.contains('Testing')
                                ? Colors.blue
                                : Colors.red,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Server Response',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_serverResponse),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Test buttons
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Test Connections',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _testLocalhost,
                      child: Text('Test Localhost (iOS Simulator)'),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _testAndroidSpecial,
                      child: Text('Test 10.0.2.2 (Android Emulator)'),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _testCustomIp,
                      child: Text('Test Custom IP (Physical Device)'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}