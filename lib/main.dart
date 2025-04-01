import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/direct_connection_test.dart'; // Add this import
import 'services/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kid Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'OpenSans',
      ),
      home: FutureBuilder(
        future: AuthService().getCurrentUser(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData) {
            return ChatScreen();
          }
          
          // For testing purposes, you can change this to:
          // return DirectConnectionTest();
          return LoginScreen();
        },
      ),
      routes: {
        '/login': (ctx) => LoginScreen(),
        '/chat': (ctx) => ChatScreen(),
        '/direct_test': (ctx) => DirectConnectionTest(), // Add this route
      },
    );
  }
}