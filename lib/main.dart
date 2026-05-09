// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:proteinova_connect/auth_bloc_provider.dart';
// import 'package:proteinova_connect/features/auth/presentation/signup_screen.dart';
// import 'package:proteinova_connect/features/auth/presentation/splashscreen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await dotenv.load(fileName: ".env");

//   runApp(AppBlocProvider(child: const MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       routes: {"/signup": (context) => const SignupScreen()},
//       home: const SignupScreen(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:proteinova_connect/admin_bottom_navigator.dart';
import 'package:proteinova_connect/features/admin/presentation/admin_inventory.dart';

import 'package:proteinova_connect/core/services/app_bloc.dart';
import 'package:proteinova_connect/features/admin/presentation/admin_dashboard.dart';
import 'package:proteinova_connect/features/branch/branch_bottom_navigator.dart';
import 'package:proteinova_connect/features/auth/presentation/signup_screen.dart';
import 'package:proteinova_connect/purchase_bottom_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await Hive.initFlutter();

  await Hive.openBox('purchaseBox');
  await Hive.openBox('purchaseBox');

  final prefs = await SharedPreferences.getInstance();

  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  final String role = prefs.getString('role') ?? '';

  Widget startScreen;

  if (isLoggedIn) {
    if (role == 'purchase') {
      startScreen = const PurchaseBottomNavigator();
    } else {
      startScreen = const BranchBottomNavigator();
    }
  } else {
    startScreen = const SignupScreen();
  }

  runApp(AppBlocProvider(child: MyApp(startScreen: startScreen)));
}

class MyApp extends StatelessWidget {
  final Widget? startScreen;

  const MyApp({super.key, this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      routes: {"/signup": (context) => const SignupScreen()},

      // home: startScreen ?? const SignupScreen(),
      home: AdminBottomNavigator(),
    );
  }
}
