import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms and Conditions"),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Terms and Conditions\n\n"
            "Effective Date: 09 October 2026\n\n"
            "Welcome to Proteinova Connect.\n\n"
            "By using this application, you agree to these terms and conditions. "
            "Please read them carefully. If you do not agree with any part of these terms, "
            "you must not use our application.\n\n"
            "1. Use of the App\n"
            "This app is intended for internal company use and authorized partners only.\n\n"
            "2. User Responsibilities\n"
            "You are responsible for maintaining the confidentiality of your account credentials.\n\n"
            "3. Data Privacy\n"
            "We value your privacy. Please refer to our Privacy Policy for details on how we handle your data.\n\n"
            "4. Changes to Terms\n"
            "We reserve the right to modify these terms at any time.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
