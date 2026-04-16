import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/inventory/widget/traydetailcard.dart';

class Receivestock extends StatefulWidget {
  const Receivestock({super.key});

  @override
  State<Receivestock> createState() => _ReceivestockState();
}

class _ReceivestockState extends State<Receivestock> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
          appBar: AppBar(
        title: const Text("Receive Stock"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
          child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          
          Text(
          "RCN-2016-04-001",
          style: AppTextStyles.headingText22,
              ),
          
          Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Ready for unload",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
              ),
            ],
          ),
  Text("Manage and receive incoming shipment for suppliers to upload inventery",
style: AppTextStyles.bodyText12,),
SizedBox(height: 10,),
Expanded(child: SingleChildScrollView(
  child: Column(
    children: [
     Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      // 🔹 Main Title
      Text(
        "Received Info",
        style: AppTextStyles.headingText22,
      ),

      const SizedBox(height: 10),

      // 🔹 Divider
      Divider(color: Colors.grey.shade300),

      const SizedBox(height: 10),

      // 🔹 Titles Row
      Row(
        children: const [
          Expanded(
            child: Text(
              "Receive No.",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "Receiving Date",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 6),

           Row(
        children: const [
          Expanded(
            child: Text(
              "RCN-2016-04-001",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "11 april 2026",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
Divider(color: Colors.grey.shade300),

      const SizedBox(height: 10),

      // 🔹 Titles Row
      Row(
        children: const [
          Expanded(
            child: Text(
              "Vehicle No.",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "Driver Name",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 6),

           Row(
        children: const [
          Expanded(
            child: Text(
              "TN 32 B 2134",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "John",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      Container(
        width: 170,
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(12),
    color: const Color.fromARGB(255, 185, 196, 216)
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        "From Supplier",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),

      const SizedBox(height: 6),

      // 🔹 Subtitle
      const Text(
        "A2B form",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 13,
        ),
      ),

    ],
  ),
)
    ],
  ),
),
SizedBox(height: 10,),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      "Tray details",
      style: AppTextStyles.headingText20,
    ),

    Icon(
      Icons.keyboard_arrow_down,
      size: 24,
    ),
  ],
),
   const SizedBox(height: 10),

   Column(
  children: const [

    TrayDetailsCard(title: "Plastic Tray (With Eggs)"),

    TrayDetailsCard(title: "Paper Tray (With Eggs)"),

    TrayDetailsCard(title: "Empty Tray"),

  ],
)
    ],
  ),
))
  ])
        )
    );
  }
}