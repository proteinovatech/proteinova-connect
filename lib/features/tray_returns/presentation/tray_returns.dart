import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/stock.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/stockdetails.dart';
import 'package:proteinova_connect/features/tray_returns/presentation/tray_records.dart';

class TrayReturn extends StatefulWidget {
  const TrayReturn({super.key});

  @override
  State<TrayReturn> createState() => _TrayReturnState();
}

class _TrayReturnState extends State<TrayReturn> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background1,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.05),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    "Tray Return",
                    style: AppTextStyles.headingText22,
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                children: [
                  Expanded(
                    child: Stock(
                      title: "Refund/Credit",
                      value: "₹4,200",
                      percent: "13.5%",
                      subtitle: "Yesterday",
                      icon: Icons.attach_money,
                      iconBg: const Color(0xFFE6EBF0),
                      iconColor: Colors.grey,
                      highlightUnit: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Stockdetails(
                      title: "Damaged",
                      value: "100 trays",
                      icon: Icons.dangerous_outlined,
                      iconBg: const Color(0xFFE6EBF0),
                      iconColor: Colors.grey,
                      highlightUnit: true,
                    ),
                  ),
                ],
              ),              
           SizedBox(height: size.height*0.02,),
              Row(
                children: [
                  Expanded(
                    child: Stock(
                      title: "Another Item",
                      value: "₹2,000",
                      percent: "5%",
                      subtitle: "Today",
                      icon: Icons.attach_money,
                      iconBg: const Color(0xFFE6EBF0),
                      iconColor: Colors.grey,
                      highlightUnit: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Stockdetails(
                      title: "Returned",
                      value: "50 trays",
                      icon: Icons.inventory_2_outlined,
                      iconBg: const Color(0xFFE6EBF0),
                      iconColor: Colors.grey,
                      highlightUnit: true,
                    ),
                  ),
                ],
              ),           
           SizedBox(height: size.height*0.02,),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TrayRecords(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.amber600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: AppColors.dark),
                      const SizedBox(width: 8),
                      Text(
                        "Tray Records",
                        style: AppTextStyles.headingText20,
                      ),
                    ],
                  ),
                ),
              ),            
           SizedBox(height: size.height*0.02,),
                           Text(
                "Recent Tray Returns",
                style: AppTextStyles.headingText20,
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor:
                      MaterialStateProperty.all(Colors.grey.shade300),
                  columns: const [
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("From")),
                    DataColumn(label: Text("Tray Type")),
                    DataColumn(label: Text("Qty")),
                    DataColumn(label: Text("Condition")),
                    DataColumn(label: Text("Reasons")),
                    DataColumn(label: Text("Price")),
                  ],
                  rows: [
                    buildSummaryRow("11 Apr 26", "Green Agro",
                        "Plastic (with Eggs)", "50", "Good",
                        "Return after use", "₹250"),
                    buildSummaryRow("07 Apr 26", "Sunrise Traders",
                        "Paper (with Eggs)", "20", "Damaged",
                        "Broken corners", "₹50"),
                    buildSummaryRow("05 Apr 26", "Daily Needs Store",
                        "Empty Trays", "100", "Good",
                        "Return after use", "₹0"),
                    buildSummaryRow("05 Apr 26", "Valley Farm",
                        "Plastic (with Eggs)", "15", "Scrap",
                        "Not usable", "₹0"),
                  ],
                ),
              ),
           SizedBox(height: size.height*0.02,),
         Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
         Text(
        "Refund/Credit Summary",
        style: AppTextStyles.headingText20,
      ),
      SizedBox(height: size.height * 0.02),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.border2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total Refund",
              style: AppTextStyles.bodyText14dark,
            ),
            Text(
              "₹15,000",
              style: AppTextStyles.headingText20,
            ),
          ],
        ),
      ),
       SizedBox(height: size.height * 0.01),
       Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Pending Refund",
              style: AppTextStyles.bodyText14dark,
            ),
            Text(
              "₹500",
              style: AppTextStyles.headingText20,
            ),
          ],
        ),
      ), SizedBox(height: size.height * 0.01),
       Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.border2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total Credit",
              style: AppTextStyles.bodyText14dark,
            ),
            Text(
              "₹4,000",
              style: AppTextStyles.headingText20,
            ),
          ],
        ),
      ), SizedBox(height: size.height * 0.01),
       Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Pending Credit",
              style: AppTextStyles.bodyText14dark,
            ),
            Text(
              "₹2,300",
              style: AppTextStyles.headingText20,
            ),
          ],
        ),
      ),
    ],
  ),
),
 SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
  DataRow buildSummaryRow(
    String date,
    String from,
    String tray,
    String qty,
    String condition,
    String reason,
    String price,
  ) {
    return DataRow(cells: [
      DataCell(Text(date)),
      DataCell(Text(from)),
      DataCell(Text(tray)),
      DataCell(Text(qty)),
      DataCell(conditionWidget(condition)),
      DataCell(Text(reason)),
      DataCell(Text(price)),
    ]);
  }
  Widget conditionWidget(String condition) {
    Color color;
    switch (condition) {
      case "Good":
        color = Colors.green;
        break;
      case "Damaged":
        color = Colors.red;
        break;
      case "Scrap":
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        condition,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}