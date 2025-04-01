import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiHelper {
  /// Gets the base URL for API requests based on the current platform and environment
  static String getBaseUrl() {
    // Find out what IP to use based on platform
    if (Platform.isAndroid && !kIsWeb) {
      // For Android emulator, use the special IP that points to host
      return 'http://10.0.2.2:4000/api';
    } 
    // For iOS simulator or desktop, localhost works
    else if ((Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isLinux) && !kIsWeb) {
      return 'http://localhost:4000/api';
    } 
    // When running in a web browser
    else if (kIsWeb) {
      return '/api'; // Relative path works in web browsers
    } 
    // For physical devices, use your computer's actual IP address
    else {
      // ⚠️ IMPORTANT: Replace with your computer's actual IP address
      // You can find it with 'ifconfig' or 'ipconfig' in terminal
      return 'http://YOUR_COMPUTER_IP:4000/api';
      
      // Uncomment and update the line below with your actual IP:
      // return 'http://192.168.1.X:4000/api';
    }
  }
  
  /// Checks if the current error is a connection issue that would benefit
  /// from using the development mock mode
  static bool isConnectionError(dynamic error) {
    if (error is SocketException) {
      return true;
    }
    
    // Check for specific error messages that indicate connection issues
    if (error.toString().contains('Connection failed') ||
        error.toString().contains('Connection refused') ||
        error.toString().contains('Operation not permitted') ||
        error.toString().contains('Connection timed out')) {
      return true;
    }
    
    return false;
  }
}