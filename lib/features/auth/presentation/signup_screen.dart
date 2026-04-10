import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/purchase_bottom_navigator.dart';
import 'package:proteinova_connect/features/auth/widget/custom_textfield.dart';
import 'package:proteinova_connect/features/auth/widget/role_toggle.dart';
import 'package:proteinova_connect/features/purchase_dashboard/presentation/purchase_dashboard.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
 String selectedRole = "Purchase";
  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    
    return Scaffold(backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
             Stack(
  children: [
    SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      child: Image.asset(
        "assets/signup image.jpeg",
        fit: BoxFit.cover,
      ),
    ),

    // 🔥 Gradient overlay (fade to white)
    Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
      ),
    ),
  ],
),
            Padding(
              padding:  EdgeInsets.only(left:size.width*0.05,right: size.width*0.05),
              child: Column(mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  SizedBox(height: size.height*0.02,),
                  Text("Sign in",style: AppTextStyles.headingText25,),
                   SizedBox(height: size.height*0.01),
                  Text("Enter your credentials to access your distribution system. ",
                  style: AppTextStyles.bodyText16,),
                   SizedBox(height: size.height*0.04),
                  Text("System Role",style: AppTextStyles.buttonText16,),
                  // default
                  RoleToggle(
                  onChanged: (value) {
                  setState(() {
                  selectedRole = value; // ✅ update state
                  });
                  print("Selected Role: $value");
                  },
                  ),
            SizedBox(height: size.height*0.03),
            Text("Email or Phone",style: AppTextStyles.buttonText16,),
            CustomTextField(
              hintText: "Email",
              controller: emailController,
            ),
            SizedBox(height: size.height*0.03),
            Text("Password",style: AppTextStyles.buttonText16,),
            CustomTextField(
              hintText: "Password",
              controller: passwordController,
              isPassword: true,
            ),
            SizedBox(height: size.height*0.02),
            Padding(
              padding:  EdgeInsets.only(left: size.width*0.54),
              child: Text("Forgot password?",style: AppTextStyles.browntext,),
            ),
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: AppColors.amber600
                ),
              
              child: ElevatedButton(
                onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  PurchaseBottomNavigator(),
              ),
            );
                 
                },
                style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
                ),
                child: const Text(
            "Sign In",
            style: AppTextStyles.containerText
                ),
              ),
            )
                  ],),
            ),
          ],
        ),
      ),);
  }
}