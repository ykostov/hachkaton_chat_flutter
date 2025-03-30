import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kid_user.dart';

class AuthService {
  // This would be your actual API URL in production
  final String baseUrl = 'http://your-phoenix-api-url';
  
  Future<KidUser?> loginKid(String email, String name) async {
    // This is a placeholder for the actual API call
    // In a real implementation, you would verify the kid's credentials with your API
    
    // Simulating a successful login for demo purposes
    await Future.delayed(Duration(seconds: 1));
    
    // Create a mock kid user
    final kidUser = KidUser(
      id: '123',
      name: name,
      email: email,
    );
    
    // Save user info to local storage
    await _saveUserToPrefs(kidUser);
    
    return kidUser;
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('kid_user');
  }
  
  Future<KidUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('kid_user');
    
    if (userStr != null) {
      return KidUser.fromJson(json.decode(userStr));
    }
    
    return null;
  }
  
  Future<void> _saveUserToPrefs(KidUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kid_user', json.encode(user.toJson()));
  }
}