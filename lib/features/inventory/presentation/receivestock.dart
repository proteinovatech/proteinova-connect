import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/inventory/widget/receiveditem.dart';
import 'package:proteinova_connect/features/inventory/widget/traydetailcard.dart';
import 'package:proteinova_connect/features/sales/widget/buildrow.dart';

class Receivestock extends StatefulWidget {
  const Receivestock({super.key});

  @override
  State<Receivestock> createState() => _ReceivestockState();
}

class _ReceivestockState extends State<Receivestock> {
   bool isExpanded = true;
   bool isTrayExpanded = true;
     bool isReceivedExpanded = true;
       bool isLoading = true;

  Map<String, dynamic> receiveInfo = {};

  Map<String, dynamic> summary = {};

  List receivedItems = [];
    Future<void> fetchReceiveStock() async {

    try {

       final response = await http.get(
      Uri.parse(ApiConstants.dashboard),
      headers: {
        "Accept": "application/json",
      },
    );
      if (response.statusCode == 200) {

        final data = jsonDecode(
          response.body,
        );

        setState(() {

          receiveInfo =
              data["receive_info"] ?? {};

          summary =
              data["summary"] ?? {};

          receivedItems =
              data["received_items"] ?? [];

          isLoading = false;
        });

      } else {

        setState(() {
          isLoading = false;
        });

        print(
          "Status Code : ${response.statusCode}",
        );
      }

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      print("ERROR : $e");
    }
  }


  @override
  Widget build(BuildContext context) {  
      
    return Scaffold(
      backgroundColor: AppColors.background1,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            scrolledUnderElevation: 0,
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
    color: AppColors.background
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Received Info",
        style: AppTextStyles.headingText22,
      ),
      const SizedBox(height: 10),
      Divider(color: Colors.grey.shade300),
      const SizedBox(height: 10),
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
      SizedBox(height: 10,),
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
  Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  decoration: BoxDecoration(
    color: AppColors.background,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Received Items",
            style: AppTextStyles.headingText20,
          ),
          IconButton(
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              isReceivedExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
            onPressed: () {
              setState(() {
                isReceivedExpanded = !isReceivedExpanded;
              });
            },
          ),
        ],
      ),
      const SizedBox(height: 6),
      if (isReceivedExpanded)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Receiveditem(title: "White Eggs (With trays)"),
            SizedBox(height: 6),
            Receiveditem(title: "Brown Eggs (With trays)"),
            SizedBox(height: 6),
            Receiveditem(title: "White Eggs (With trays)"),
          ],
        ),
    ],
  ),
),
        const SizedBox(height: 10),
       Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), 
  decoration: BoxDecoration(
    color: AppColors.background,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(5), 
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min, // 👈 important (no extra height)
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Tray details",
            style: AppTextStyles.headingText20,
          ),
          IconButton(
            iconSize: 20, 
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(), 
            icon: Icon(
              isTrayExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
            onPressed: () {
              setState(() {
                isTrayExpanded = !isTrayExpanded;
              });
            },
          ),
        ],
      ),
      const SizedBox(height: 6), 
          if (isTrayExpanded)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TrayDetailsCard(title: "Plastic Tray (With Eggs)"),
            SizedBox(height: 6),
            TrayDetailsCard(title: "Paper Tray (With Eggs)"),
            SizedBox(height: 6),
            TrayDetailsCard(title: "Empty Tray"),
          ],
        ),
    ],
  ),
), Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Summary",
              style: AppTextStyles.headingText22,
            ),
            Icon(Icons.inventory_outlined,color: Colors.blue,)]),
            SizedBox(height: 10,),
           Container(
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color.fromARGB(255, 204, 203, 203))
  ),
  child: Column(
    children: [
      buildSummaryRow("Total Trays", "400"),
      const SizedBox(height: 5),
      const Divider(),
      buildSummaryRow("Total Eggs", "12,000"),
      const SizedBox(height: 5),
      const Divider(),
       buildSummaryRow("Plastic Trays", "300"),
      const SizedBox(height: 5),
      const Divider(),
      buildSummaryRow("Paper Trays", "50"),
      const SizedBox(height: 5),
      const Divider(),
       buildSummaryRow("Empty Trays", "0"),
    ],
  ),
),
            SizedBox(height: 5,),
            Divider(),
            SizedBox(height: 10,),
            Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Bill Summery",
    style: AppTextStyles.headingText22,
  ),
),
                 Container(
  padding: const EdgeInsets.all(10),
  margin: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border:Border.all(color: const Color.fromARGB(255, 218, 217, 217)) 
     ),
  child: Column(
    children: [
       buildSummaryRow("Total Trays", "400"),
      const SizedBox(height: 5),
      const Divider(),
       buildSummaryRow("Items(3)", "\$10,000"),
      const SizedBox(height: 5),
      const Divider(),

      buildSummaryRow("Transport Charge", "\$200"),
      const SizedBox(height: 5),
      const Divider(),

      buildSummaryRow("Other Charge", "0"),
      const SizedBox(height: 5),
      const Divider(color: Colors.black),

      buildSummaryRow("Total Amount", "\$10,200", isBold: true),
      const Divider(color: Colors.black),

      buildSummaryRow("Discount", "\$100"),
      const SizedBox(height: 5),
      const Divider(),

       buildSummaryRow("Net Amount", "\$10,100", isBold: true),
    ],
  ),
)
            ]) 
    ],
  ),
)),
SizedBox(height: 5,),
Row(
  children: [
    Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border2)
        ),
        child: Text(
          "Cancel",
          style:  AppTextStyles.bodyText14dark
        ),
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          "Confirm Receive",
          style:  AppTextStyles.bodyText14dark
        ),
      ),
    ),
  ],
)
   ])
        )
    );
  }
}