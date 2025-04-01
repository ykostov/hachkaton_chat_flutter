import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kid_user.dart';
import '../helpers/api_helper.dart'; // Import the new helper

class AuthService {
  // Use the helper to determine the correct base URL
  final String baseUrl = ApiHelper.getBaseUrl();
  final Dio _dio = Dio();
  
  // Token key for shared preferences
  static const String _tokenKey = 'auth_token';
  static const String _kidUserKey = 'kid_user';
  
  AuthService() {
    _initDio();
  }
  
  void _initDio() async {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // For development only - allow HTTP connections
    if (_dio.httpClientAdapter is IOHttpClientAdapter) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

    // Add logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint('Making request: ${options.method} ${options.uri}');
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(_tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('Request headers: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('Received response: ${response.statusCode}');
          debugPrint('Response data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          debugPrint('Request error: ${error.message}');
          debugPrint('Error type: ${error.type}');
          if (error.response != null) {
            debugPrint('Error response: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
  }
  
  // Login a kid with email and name
  Future<KidUser?> loginKid(String email, String name) async {
    try {
      debugPrint('Attempting to login kid: $name, $email');
      
      final response = await _dio.post(
        '/kids/login',
        data: {
          'email': email,
          'name': name,
        },
      );
      
      debugPrint('Login response: ${response.data}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        
        // Get token from response
        final String token = data['token'] ?? '';
        
        // Create kid user from response data
        final kidUser = KidUser(
          id: data['kid']['id'],
          name: data['kid']['name'],
          email: data['kid']['email'],
        );
        
        // Save token and user info
        await _saveAuthToken(token);
        await _saveUserToPrefs(kidUser);
        
        return kidUser;
      } else {
        debugPrint('Login failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      
      // For development testing, you can fall back to a mock response
      // Remove this in production!
      if (e is DioException && ApiHelper.isConnectionError(e.error)) {
        debugPrint('Using mock response for development due to connection issue');
        final kidUser = KidUser(
          id: '123',
          name: name,
          email: email,
        );
        
        await _saveAuthToken('mock_dev_token');
        await _saveUserToPrefs(kidUser);
        
        return kidUser;
      }
      
      rethrow;
    }
  }
  
  // Logout function
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      if (token != null) {
        // Clear shared preferences
        await prefs.remove(_tokenKey);
        await prefs.remove(_kidUserKey);
        
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Logout error: $e');
      
      // For testing, still clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_kidUserKey);
      
      return true;
    }
  }
  
  // Get current user from local storage
  Future<KidUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_kidUserKey);
    final token = prefs.getString(_tokenKey);
    
    if (userStr != null && token != null) {
      return KidUser.fromJson(json.decode(userStr));
    }
    
    return null;
  }
  
  // Save auth token
  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  // Get auth token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Save user to preferences
  Future<void> _saveUserToPrefs(KidUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kidUserKey, json.encode(user.toJson()));
  }
}