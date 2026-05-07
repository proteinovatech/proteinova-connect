import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proteinova_connect/branch_bottom_navigator.dart';
import 'package:proteinova_connect/features/auth/presentation/signup_screen.dart';
import 'package:proteinova_connect/features/purchase/purchase_bottom_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigateUser();
  }

  Future<void> _navigateUser() async {
  await Future.delayed(const Duration(seconds: 3));

  final prefs = await SharedPreferences.getInstance();

  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? role = prefs.getString('role')?.toLowerCase();

  if (!mounted) return;

  Widget nextScreen;

  if (isLoggedIn && role != null) {
    if (role == "purchase") {
      nextScreen = const PurchaseBottomNavigator();
    } else if (role == "branch") {
      nextScreen = const BranchBottomNavigator();
    } else {
      nextScreen = const SignupScreen();
    }
  } else {
    nextScreen = const SignupScreen();
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => nextScreen),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset("assets/erplogo.png"))
    );
  }
}