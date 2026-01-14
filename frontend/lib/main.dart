import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/customer_home_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const DonatriaApp());
}

class DonatriaApp extends StatelessWidget {
  const DonatriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Donatria',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
        ),
        useMaterial3: true,
      ),
      home: const AuthChecker(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/admin-dashboard': (context) => AdminDashboardScreen(),
        '/customer-home': (context) => CustomerHomeScreen(),
      },
    );
  }
}

// Auth Checker - Cek apakah user sudah login
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    // Cek apakah sudah ada token dan user
    if (ApiService.token != null && ApiService.currentUser != null) {
      // Sudah login, redirect berdasarkan role
      final role = ApiService.currentUser!.role;
      if (role == 'admin') {
        return AdminDashboardScreen();
      } else {
        return CustomerHomeScreen();
      }
    } else {
      // Belum login, ke login screen
      return LoginScreen();
    }
  }
}