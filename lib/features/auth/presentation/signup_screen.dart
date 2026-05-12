import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/presentation/admin_dashboard.dart';
import 'package:proteinova_connect/admin_bottom_navigator.dart';
import 'package:proteinova_connect/features/branch/branch_bottom_navigator.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/auth/bloc/auth_bloc.dart';
import 'package:proteinova_connect/features/auth/bloc/auth_event.dart';

import 'package:proteinova_connect/features/auth/bloc/auth_state.dart';
import 'package:proteinova_connect/features/auth/widget/custom_textfield.dart';
import 'package:proteinova_connect/features/auth/widget/role_toggle.dart';
import 'package:proteinova_connect/features/purchase/purchase_bottom_navigator.dart';

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
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: size.height * 0.35,
                  width: double.infinity,
                  child: Image.asset("assets/warehouse.png", fit: BoxFit.cover),
                ),

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

                Positioned(
                  top: 20,
                  left: 5,
                  child: Image.asset(
                    "assets/erplogo.png",
                    height: 35,
                    width: 130,
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.02),

                  Text("Sign in", style: AppTextStyles.headingText25),

                  SizedBox(height: size.height * 0.01),

                  Text(
                    "Enter your credentials to access your distribution system.",
                    style: AppTextStyles.bodyText16,
                  ),

                  SizedBox(height: size.height * 0.04),

                  Text("System Role", style: AppTextStyles.buttonText16),

                  RoleToggle(
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                  ),

                  SizedBox(height: size.height * 0.03),

                  Text("Email or Phone", style: AppTextStyles.buttonText16),

                  CustomTextField(
                    hintText: "Email",
                    controller: emailController,
                  ),

                  SizedBox(height: size.height * 0.03),

                  Text("Password", style: AppTextStyles.buttonText16),

                  CustomTextField(
                    hintText: "Password",
                    controller: passwordController,
                    isPassword: true,
                  ),

                  SizedBox(height: size.height * 0.02),

                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: AppColors.amber600,
                    ),

                    child: BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthSuccessPurchase) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PurchaseBottomNavigator(),
                            ),
                          );
                        } else if (state is AuthSuccessBranch) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BranchBottomNavigator(),
                            ),
                          );
                        } else if (state is AuthSuccessAdmin) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminBottomNavigator(),
                            ),
                          );
                        } else if (state is AuthFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },

                      child: ElevatedButton(
                        onPressed: () {
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter all fields"),
                              ),
                            );
                            return;
                          }

                          context.read<AuthBloc>().add(
                            LoginRequested(
                              email: email,
                              password: password,
                              role: selectedRole,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),

                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              );
                            }

                            return const Text(
                              "Sign In",
                              style: AppTextStyles.containerText,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
