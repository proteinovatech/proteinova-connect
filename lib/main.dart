import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:proteinova_connect/auth_bloc_provider.dart';
import 'package:proteinova_connect/features/auth/presentation/signup_screen.dart';
import 'package:proteinova_connect/features/auth/presentation/splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
   await Hive.initFlutter();
  await Hive.openBox('purchaseBox');

  runApp(AppBlocProvider(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {"/signup": (context) => const SignupScreen()},
      home: const SignupScreen(),
    );
  }
}
