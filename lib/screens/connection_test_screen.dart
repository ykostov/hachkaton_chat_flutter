import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart'; // Add this import for IOHttpClientAdapter
import 'dart:io';

class ConnectionTestScreen extends StatefulWidget {
  @override
  _ConnectionTestScreenState createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  final Dio _dio = Dio();
  String _connectionStatus = 'Not tested';
  String _serverResponse = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _configureHttpClient();
  }

  void _configureHttpClient() {
    if (_dio.httpClientAdapter is IOHttpClientAdapter) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (cert, host, port) => true;
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

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing...';
      _serverResponse = '';
    });

    try {
      // Try to connect to Phoenix on port 4000
      final response = await _dio.get('http://localhost:4000/api/health',
          options: Options(
            sendTimeout: Duration(seconds: 5),
            receiveTimeout: Duration(seconds: 5),
          ));

      setState(() {
        _isLoading = false;
        _connectionStatus = 'Successfully connected!';
        _serverResponse = response.data.toString();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _connectionStatus = 'Connection failed';
        if (e is DioException) {
          _serverResponse = 'Error: ${e.type}\nMessage: ${e.message}\n';
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
        title: Text('Connection Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Status:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              _connectionStatus,
              style: TextStyle(
                fontSize: 16,
                color: _connectionStatus.contains('Success')
                    ? Colors.green
                    : _connectionStatus == 'Testing...'
                        ? Colors.blue
                        : Colors.red,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Server Response:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_serverResponse),
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testConnection,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Test Connection'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}