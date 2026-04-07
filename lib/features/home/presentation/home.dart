import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
     final Size size=MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height:size.height*0.05,),
          Text("Purchase",style: AppTextStyles.heading1,),
            Text("Manage Purchase orders and Incoming stocks. ",
            style: AppTextStyles.body,),
             SizedBox(height: size.height*0.05,),
             Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.add, color: Colors.black),
      SizedBox(width: 8),
      Text(
        "Add Stock",
        style: AppTextStyles.body,
      ),
    ],
  ),
),
SizedBox(height: size.height * 0.05),
        ],
      ),
    );
  }
}