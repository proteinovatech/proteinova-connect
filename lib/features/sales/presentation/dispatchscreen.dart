import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/sales/widget/dispatchcard2.dart';
import 'package:proteinova_connect/features/sales/widget/dispatchcard3.dart';

class Dispatchscreen extends StatefulWidget {
  const Dispatchscreen({super.key});

  @override
  State<Dispatchscreen> createState() => _DispatchscreenState();
}

class _DispatchscreenState extends State<Dispatchscreen> {
  Size get size => MediaQuery.of(context).size;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background1,
    appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,

  // Logo on left
  title: Image.asset(
    "assets/erplogo.png",
    height: 40,
  ),

   actions: [
    Icon(Icons.search_outlined, color: Colors.black),
    SizedBox(width: 10),

    Icon(Icons.notifications_outlined, color: Colors.black),
    SizedBox(width: 10),

    CircleAvatar(
      radius: 16,
      backgroundColor: Colors.grey.shade300,
    ),
    SizedBox(width: 10),
  ],
),
     body: SingleChildScrollView(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: size.height * 0.02),
                Row(
          children: [
            Expanded(
              child: Dispatchcard2(
                title: "Active",
                value: "12/15",
                subtitle: "Vehicles",
                icon: Icons.local_shipping_outlined,
                iconBg: const Color.fromARGB(255, 230, 235, 240),
                iconColor: Colors.grey,
              ),
            ),
            SizedBox(width: size.width * 0.05),
            Expanded(
              child: Dispatchcard2(
                title: "Today's",
                value: "8",
                subtitle: "Dispatches",
                icon: Icons.inventory_outlined,
                iconBg: const Color.fromARGB(255, 230, 235, 240),
                iconColor: Colors.grey,
              ),
            ),
          ],
        ),
       SizedBox(height: size.height*0.01),
        Row(
          children: [
            Expanded(
              child: Dispatchcard2(
                title: "In",
                value: "120",
                subtitle: "Transit",
                icon: Icons.send_outlined,
                iconBg: const Color.fromARGB(255, 230, 235, 240),
                iconColor: Colors.grey,
              ),
            ),
            SizedBox(width: size.width * 0.05),
            Expanded(
              child: Dispatchcard2(
                title: "Delivered",
                value: "12,300",
                subtitle: "Total",
                icon: Icons.inventory_2_outlined,
                iconBg: const Color.fromARGB(255, 230, 235, 240),
                iconColor: Colors.grey,
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.05),
              Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent dispatches",
              style: AppTextStyles.headingText22,
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.filter_alt_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
         SizedBox(height: size.height*0.02),
DispatchCard3(
  id: "ASP-1045",
  status: "Pending",
  branch: "Northtown Branch (BR-001)",
  date: "Oct 24, 2023",
  totalQty: "12,500",
  vehicleDriver: "TRK-992 • Michael T.",
  showFullActions: true,
),
DispatchCard3(
  id: "ASP-1046",
  status: "Transit",
  branch: "City Branch",
  date: "Oct 25, 2023",
  totalQty: "8,200",
  vehicleDriver: "TRK-111 • John D.",  
),
 DispatchCard3(
  id: "ASP-1047",
  status: "Delivered",
  branch: "Down market (BR-001)",
  date: "Oct 26, 2023",
  totalQty: "8,200",
  vehicleDriver: "TRK-111 • John D.",  
),
DispatchCard3(
  id: "ASP-1048",
  status: "Delivered",
  branch: "Down market (BR-001)",
  date: "Oct 26, 2023",
  totalQty: "8,200",
  vehicleDriver: "TRK-111 • John D.",  
),  
DispatchCard3(
  id: "ASP-1049",
  status: "Delivered",
  branch: "South District (BR-005)",
  date: "Oct 27, 2023",
  totalQty: "8,200",
  vehicleDriver: "TRK-111 • John D.",  
),                            ],
    ),
  ),
),
    );
  }
}