import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Privacy Policy\n\n"
            "Effective Date: 09 October 2026\n\n"
            "1. Information We Collect\n"
            "We may collect personal and organizational data as necessary to provide our services and manage internal processes.\n\n"
            "2. How We Use Your Information\n"
            "The data collected is used strictly for internal operational purposes, analytics, and ensuring the seamless functionality of the application.\n\n"
            "3. Data Security\n"
            "We implement robust security measures to protect your data. However, no method of transmission is 100% secure.\n\n"
            "4. Third-Party Access\n"
            "We do not sell or share your data with unauthorized third parties.\n\n"
            "5. Contact Us\n"
            "For any privacy-related inquiries, please contact our support team.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
