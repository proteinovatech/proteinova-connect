import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/inventory/presentation/receivestock.dart';
import 'package:proteinova_connect/features/inventory/widget/order_shipmentcard.dart';
import 'package:proteinova_connect/features/inventory/widget/shipment_filter_row.dart';
import 'package:proteinova_connect/features/inventory/widget/shipmentcard.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
   bool isClicked = false;
  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background1,
    body: Padding(
      padding: EdgeInsets.only(left: size.height*0.01, right:size.height*0.01 ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                  SizedBox(height: size.height*0.01,),
         Padding(
  padding: EdgeInsets.symmetric(
    horizontal: size.width * 0.04,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: size.height * 0.06),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        
          Image.asset(
            "assets/erplogo.png",
            height: 40,
            width: 130,
          ),

                    Row(
            children: [
              Icon(Icons.notifications_outlined),
              SizedBox(width: size.width * 0.02),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
),
          Divider(),
           Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text("Incoming Queue", style: AppTextStyles.headingText25),
              Text("Manage Stock Shipments", style: AppTextStyles.bodyText16),

              SizedBox(height: size.height * 0.02),

              Row(
                children: [
                   
                  const ShipmentCard(
                    title: "Expected Today",
                    count: "4 Shipments",
                    subtitle: "Totaling 2,150 Tray",
                    icon: Icons.event,
                  ),
                  const ShipmentCard(
                    title: "Ready for Unloading",
                    count: "2 Shipments",
                    subtitle: "Requires immediate action",
                    icon: Icons.local_shipping_outlined,
                  ),
                ],
              ),
                            

              SizedBox(height: size.height * 0.02),
              ShipmentFilterRow(),

              SizedBox(height: size.height * 0.02),

              Text("Shipments", style: AppTextStyles.headingText22),

              OrderShipmentcard(
                orderId: "PO-2023-119",
                dateTime: "Oct 24, 2023 • 08:30 AM",
                status: "Ready for Unload",
                statusBgColor: AppColors.green,
                statusTextColor: AppColors.background,
                buttonColor: AppColors.amber600,
                supplier: "Apex Farms",
                product: "Jumbo White",
                quantity: "500 Tray",
                buttonText: "Receive Stock",
                onReceiveTap: () {
                    Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Receivestock(),
                ),
              );
                },
              ),

              OrderShipmentcard(
                orderId: "PO-2023-120",
                dateTime: "Oct 24, 2023 • 09:15 AM",
                status: "Pending Inspection",
                statusBgColor: AppColors.deepOrange,
                statusTextColor: AppColors.background,
                buttonColor: AppColors.background,
                supplier: "Valley Co-op",
                product: "Large Brown",
                quantity: "850 Tray",
                buttonText: "Inspect & Receive",
                onReceiveTap: () {},
              ),
              OrderShipmentcard(
                orderId: "PO-2023-121",
                dateTime: "Oct 24, 2023 • 02:00 PM",
                status: "In Transit (ETA 2hr)",
                statusBgColor: AppColors.containerColor2,
                statusTextColor: AppColors.textSecondary,
                buttonColor: AppColors.background,
                supplier: "Sunrise Poultry",
                product: "Med White",
                quantity: "1,200 Tray",
                buttonText: "View Details",
                onReceiveTap: () {},
              ),
              OrderShipmentcard(
                orderId: "PO-2023-118",
                dateTime: "Oct 23, 2023 • 04:00 PM",
                status: "Delayed",
                statusBgColor: AppColors.redAccent,
                statusTextColor: AppColors.background,
                buttonColor: AppColors.background,
                supplier: "Sunrise Poultry",
                product: "Organic",
                quantity: "300 Tray",
                buttonText: "Track Shipment",
                onReceiveTap: () {},
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),
      );
  }
}