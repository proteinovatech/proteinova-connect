import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/auth/widget/custom_textfield.dart';
import 'package:proteinova_connect/features/auth/widget/role_toggle.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    String selectedRole = "Purchase"; 
    return Scaffold(backgroundColor: AppColors.background,
      body: Padding(
        padding:  EdgeInsets.only(left:size.width*0.05,right: size.width*0.05),
        child: Column(mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height*0.05,),
            Text("Sign in",style: AppTextStyles.heading1,),
            Text("Enter your credentials to access your distribution system. ",style: AppTextStyles.body,),
             SizedBox(height: size.height*0.05,),
            Text("System Role",style: AppTextStyles.heading2,),
            // default
            RoleToggle(
  onChanged: (value) {
    selectedRole = value;
    print("Selected Role: $value");
  },
),
Text("Email or Phone",style: AppTextStyles.heading2,),
CustomTextField(
  hintText: "Email",
  controller: emailController,
),

CustomTextField(
  hintText: "Password",
  controller: passwordController,
  isPassword: true,
),
            ],),
      ),);
  }
}