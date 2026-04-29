import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/daily_closing/widget/checkitem.dart';
import 'package:proteinova_connect/features/daily_closing/widget/infobox.dart';
import 'package:proteinova_connect/features/daily_closing/widget/summary_block.dart';
import 'package:proteinova_connect/features/daily_closing/widget/summary_item.dart';
import 'package:proteinova_connect/features/daily_closing/widget/summary_row.dart';
import 'package:proteinova_connect/features/sales/widget/buildrow.dart';

class DailyClosing extends StatefulWidget {
  const DailyClosing({super.key});

  @override
  State<DailyClosing> createState() => _DailyClosingState();
}

class _DailyClosingState extends State<DailyClosing> {
  bool isExpanded = true;
  double openingStock = 45000;
double stockReceived = 15000;
double totalSales = 26000;
double totalExpenses = 4000;
double get grandTotal => openingStock + stockReceived + totalSales - totalExpenses;
  @override
  Widget build(BuildContext context) {
     final Size size =MediaQuery.of(context).size;
    return Scaffold(
       backgroundColor: AppColors.background1,
           body: Padding(padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: size.height * 0.07),
      Row(
        children: [
           IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
          Text(
            "Daily Closing",
            style: AppTextStyles.headingText22,
          ),
        ],
      ),
       SizedBox(height: size.height * 0.01),
      Text("Verify all details before closing the day.Once closed,entires cannot be edited",style: AppTextStyles.bodyText14,),
 SizedBox(height: size.height * 0.01),
 Divider(),
 SizedBox(height: size.height * 0.01),
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
      Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
   Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      "Stock Summary",
      style: AppTextStyles.headingText20,
    ),
    IconButton(
      icon: Icon(
        isExpanded
            ? Icons.keyboard_arrow_up
            : Icons.keyboard_arrow_down,
      ),
      onPressed: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
    ),
  ],
),
if (isExpanded) ...[ SizedBox(height: size.height * 0.02),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Eggs (With trays)",
            style: AppTextStyles.bodyText14dark,
          ),

           SizedBox(height: size.height * 0.02),
                   Row(
            children: [
             Expanded(child: stockItem("100", "Opening Stock")),
              const SizedBox(width: 10),
              Expanded(child: stockItem("200", "Received")),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          Row(
            children: [
              Expanded(child: stockItem("150", "Sold")),
              const SizedBox(width: 10),
              Expanded(child: stockItem("250", "Closing")),
            ],
          ),
        ],
      ),
    ),
   SizedBox(height: size.height * 0.02),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Plastic Trays (With Eggs)",
            style: AppTextStyles.bodyText14dark,
          ),
 SizedBox(height: size.height * 0.02),
                   Row(
            children: [
              Expanded(child: stockItem("100", "Opening Stock")),
              const SizedBox(width: 10),
              Expanded(child: stockItem("200", "Received")),
            ],
          ),
         SizedBox(height: size.height * 0.02),
          Row(
            children: [
              Expanded(child: stockItem("150", "Sold")),
              const SizedBox(width: 10),
              Expanded(child: stockItem("250", "Closing")),
            ],
          ),
        ],
      ),
    ),
   SizedBox(height: size.height * 0.02),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Paper Trays(With Eggs)",
            style: AppTextStyles.bodyText14dark,
          ),
           SizedBox(height: size.height * 0.02),
                   Row(
            children: [
              Expanded(child: stockItem("100", "Opening Stock")),
              const SizedBox(width: 10),
              Expanded(child: stockItem("200", "Received")),
            ],
          ),
           SizedBox(height: size.height * 0.02),
          Row(
            children: [
              Expanded(child: stockItem("150", "Sold")),
              const SizedBox(width: 10),
              Expanded(child: stockItem("250", "Closing")),
            ],
          ),
        ],
      ),
    ),
  SizedBox(height: size.height * 0.02),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Empty Trays",
            style: AppTextStyles.bodyText14dark,
          ),

         SizedBox(height: size.height * 0.02),

                   Row(
            children: [
              Expanded(child: stockItem("100", "Opening Stock")),
              const SizedBox(width: 10),
              Expanded(child: stockItem("200", "Received")),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          Row(
            children: [
              Expanded(child: stockItem("150", "Sold")),
              const SizedBox(width: 10),
              Expanded(child: stockItem("250", "Closing")),
            ],
          ),
        ],
      ),
    ),
   SizedBox(height: size.height * 0.02),
   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
     children: [
             Text("Total",style: AppTextStyles.headingText22,),
Container(height: 35,width: 70,
  decoration: BoxDecoration(color:AppColors.background,
  border: Border.all(color: AppColors.border2)),
  child: Center(child: Text("500",style: AppTextStyles.headingText20,)))
     ],
   )
  ],
   ],
)),
 SizedBox(height: size.height * 0.02),
Container(
    padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
      color: AppColors.background,
    ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Sales Summary",style: AppTextStyles.headingText20,),
      SizedBox(height: size.height * 0.01),
      Row(
        children: [
          Expanded(child: infoBox("₹26,000", "Total Sales")),
          const SizedBox(width: 10),
          Expanded(child: infoBox("₹18,750", "Cash Sales")),
          const SizedBox(width: 10),
          Expanded(child: infoBox("₹7,250", "UPI Sales")),
        ],
      ),
       SizedBox(height: size.height * 0.01),
      Divider(),
            Container(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Expense Summary",style: AppTextStyles.headingText20,),
      const SizedBox(height: 12),
      Row(
        children: [
           Expanded(child: infoBox("₹26,000", "Total ")),
          const SizedBox(width: 10),
          Expanded(child: infoBox("₹18,750", "Cash")),
          const SizedBox(width: 10),
          Expanded(child: infoBox("₹7,250", "UPI Sales")),
        ],
      ),
    ],
  ),
)
    ],
  ),
)
  ],
),
SizedBox(height: size.height * 0.02),
  Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300),
    color: Colors.white,
  ),
  child: Column(
    children: [
      SummaryBlock(
        heading: "Cash Summary",
        items: [
          SummaryItem("Opening Cash", "₹15,000"),
          SummaryItem("Added Cash", "₹5,000"),
          SummaryItem("Cash Sales", "₹18,000"),
          SummaryItem("Expenses", "-₹2,000"),
          SummaryItem("Closing Cash", "₹21,000"),
          SummaryItem("Difference", "₹0.00"),
        ],
      ),
      SizedBox(height: size.height * 0.01),
      SummaryBlock(
        heading: "Online Transaction Summary",
        items: [
          SummaryItem("UPI Sales", "₹7,120"),
          SummaryItem("Expenses(UPI)", "-₹1,110"),
          SummaryItem("Closing UPI", "₹4,210"),
           SummaryItem("Card Sales", "₹4,210"),
            SummaryItem("Expenses(Card)", "-₹4,210"),
             SummaryItem("Card Sales", "₹4,210"),
              SummaryItem("Total Collection", "₹4,210"),
        ],
      ),
      ],
  ),
),
 SizedBox(height: size.height * 0.01),

Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300),
  ),
  child: Column(
    children: [
      
Text(
  "Closing Stock Value (Estimated)",
  style: AppTextStyles.headingText20,
),
SizedBox(height: size.height * 0.02),
     buildSummaryRow("Eggs (with trays)", "₹50,000"),
       buildSummaryRow("Plastic Trays (with Eggs)", "₹30,000"),
      buildSummaryRow("Paper Trays (with Eggs)", "-₹2,000"),
       buildSummaryRow("Empty Trays", "₹20,000"),

      Divider(),

       buildSummaryRow(
        "Total Stock Value",
        "₹70,000",
        isBold: true,
      ),
    ],
  ),
),
SizedBox(height: size.height * 0.02),
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300),
    color: Colors.white,
  ),
  child:Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      "Today's summary",
      style: AppTextStyles.headingText20,
    ),
    SizedBox(height: size.height * 0.01),
    summaryRow("Opening Stock Value", "₹${openingStock.toInt()}"),
    summaryRow("Stock Received Value", "₹${stockReceived.toInt()}"),
    summaryRow("Total Sales", "₹${totalSales.toInt()}"),
    SizedBox(height: size.height * 0.01),
Divider(),
    summaryRow("Total Expenses", "₹${totalExpenses.toInt()}"),
    SizedBox(height: size.height * 0.01),
Divider(),
        summaryRow(
      "Grand Total",
      "₹${grandTotal.toInt()}",
    ),
  ],
)
),
SizedBox(height: size.height * 0.01),
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300),
    color: Colors.white,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Checklist",
        style: AppTextStyles.headingText20,
      ),
      SizedBox(height: size.height * 0.02),
     CheckItem(text: "Verified All Sales Entries"),
CheckItem(text: "Counted Physical Cash"),
CheckItem(text: "Checked Stock level"),
    ],
  ),
),
SizedBox(height: size.height * 0.02),
 
 SizedBox(height: size.height * 0.02),
Row(mainAxisAlignment: .end,
  children: [
   Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border2),
  ),child: Text("Save as Draft",style: AppTextStyles.containerText,)),
   SizedBox(width: size.width * 0.01),
  GestureDetector(
  onTap: () {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure you want to save this details?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                             },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  },
  child: Container(
    height: 45,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.yellow,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border2),
    ),
    alignment: Alignment.center,
    child: Text(
      "Close Day",
      style: AppTextStyles.containerText,
    ),
  ),
)
  ],
),
SizedBox(height: size.height * 0.02),],)))
    );
  }
  Widget stockItem(String value, String label) {
  return Column(
    children: [
       Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      Container(
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      
    ],
  );
}
}