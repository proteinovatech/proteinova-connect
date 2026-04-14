import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proteinova_connect/purchase_bottom_navigator.dart';
import 'package:proteinova_connect/branch_bottom_navigator.dart';
import 'signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
  final prefs = await SharedPreferences.getInstance();

  final isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  final role = prefs.getString("role");

 
  if (!mounted) return; // ✅ important safety

  if (isLoggedIn && role != null) {
    if (role == "purchase") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PurchaseBottomNavigator(),
        ),
      );
    } else if (role == "branch") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BranchBottomNavigator(),
        ),
      );
    } else {
      // ❗ unknown role → fallback
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        ),
      );
    }
  } else {
    // ✅ First install OR not logged in
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SignupScreen(),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}