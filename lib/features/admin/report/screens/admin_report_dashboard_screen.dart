import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/report/screens/expense_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/purchase_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/sales_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/warehouse_report_screen.dart';

import '../widgets/financial_summary_table.dart';
import '../widgets/report_filter_field.dart';
import '../widgets/report_stat_card.dart';
import '../widgets/revenue_chart_card.dart';
import '../widgets/top_branch_tile.dart';

class AdminReportDashboardScreen extends StatefulWidget {
  const AdminReportDashboardScreen({super.key});

  @override
  State<AdminReportDashboardScreen> createState() =>
      _AdminReportDashboardScreenState();
}

class _AdminReportDashboardScreenState
    extends State<AdminReportDashboardScreen> {
  String selectedReport = "Financial Summary";

  List<String> reportItems = [
    "Financial Summary",
    "Purchase Report",
    "Expense Report",
    "Branch Sales Report",
    "Warehouse Report",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// HEADER
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const SizedBox(width: 8),

                  const Expanded(
                    child: Text(
                      "Report Dashboard",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xffFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 18),

                        SizedBox(width: 6),

                        Text(
                          "Admin",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// SEARCH
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 58,

                      padding: const EdgeInsets.symmetric(horizontal: 18),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xffE5E7EB)),
                      ),

                      child: const Row(
                        children: [
                          Icon(Icons.search),

                          SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              "Search reports...",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Color(0xff9CA3AF)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Container(
                    width: 58,
                    height: 58,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xffE5E7EB)),
                    ),

                    child: const Icon(Icons.filter_alt_outlined),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// FILTER CARD
              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xffE5E7EB)),
                ),

                child: Column(
                  children: [
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.38,
                          child: const ReportFilterField(
                            hint: "dd-mm-yyyy",
                            prefix: Icons.calendar_month,
                          ),
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.38,
                          child: const ReportFilterField(
                            hint: "dd-mm-yyyy",
                            prefix: Icons.calendar_month,
                          ),
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.38,
                          child: const ReportFilterField(
                            hint: "All Branches",
                            dropdown: true,
                          ),
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.38,

                          child: Container(
                            height: 58,

                            padding: const EdgeInsets.symmetric(horizontal: 16),

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),

                              border: Border.all(
                                color: const Color(0xffE5E7EB),
                              ),
                            ),

                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedReport,

                                icon: const Icon(Icons.keyboard_arrow_down),

                                borderRadius: BorderRadius.circular(14),

                                isExpanded: true,

                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),

                                items: reportItems.map((item) {
                                  return DropdownMenuItem(
                                    value: item,

                                    child: Text(item),
                                  );
                                }).toList(),

                                onChanged: (value) {
                                  if (value == selectedReport) return;
                                  
                                  setState(() {
                                    selectedReport = value!;
                                  });

                                  Widget? nextScreen;
                                  if (selectedReport == "Purchase Report") {
                                    nextScreen = const PurchaseReportScreen();
                                  } else if (selectedReport == "Expense Report") {
                                    nextScreen = const ExpenseReportScreen();
                                  } else if (selectedReport == "Branch Sales Report") {
                                    nextScreen = const SalesReportScreen();
                                  } else if (selectedReport == "Warehouse Report") {
                                    nextScreen = const WarehouseReportScreen();
                                  }

                                  if (nextScreen != null) {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => nextScreen!,
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration: Duration.zero,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),

                        Container(
                          height: 58,
                          width: 150,
                          padding: const EdgeInsets.symmetric(horizontal: 18),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xffE5E7EB)),
                          ),

                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.picture_as_pdf),

                              SizedBox(width: 8),

                              Text(
                                "Export PDF",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 3),
                        Container(
                          height: 58,
                          width: 150,
                          padding: const EdgeInsets.symmetric(horizontal: 22),

                          decoration: BoxDecoration(
                            color: const Color(0xffFACC15),
                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.print),

                              SizedBox(width: 8),

                              Text(
                                "Print",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// STATS
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,

                children: [
                  ReportStatCard(
                    title: "Total Revenue",
                    amount: "₹ 1,234,567",
                    growth: "+12.5%",
                    icon: Icons.currency_rupee,
                    iconBg: const Color(0xffDCFCE7),
                    growthColor: Colors.green,
                  ),

                  ReportStatCard(
                    title: "Total Expenses",
                    amount: "₹ 456,789",
                    growth: "-8.2%",
                    icon: Icons.trending_down,
                    iconBg: const Color(0xffFEE2E2),
                    growthColor: Colors.red,
                  ),

                  ReportStatCard(
                    title: "Net Profit",
                    amount: "₹ 777,778",
                    growth: "+15.3%",
                    icon: Icons.trending_up,
                    iconBg: const Color(0xffDCFCE7),
                    growthColor: Colors.green,
                  ),

                  ReportStatCard(
                    title: "Total Orders",
                    amount: "1,456",
                    growth: "+5.8%",
                    icon: Icons.inventory_2,
                    iconBg: const Color(0xffE9D5FF),
                    growthColor: Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// CHART
              const RevenueChartCard(),

              const SizedBox(height: 24),

              /// TOP BRANCHES
              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xffE5E7EB)),
                ),

                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Top Performing Branches",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 24),

                    TopBranchTile(
                      branch: "Branch 03 - Northgate",
                      amount: "₹ 145,200",
                      progress: 0.82,
                    ),

                    SizedBox(height: 22),

                    TopBranchTile(
                      branch: "Branch 01 - Downtown",
                      amount: "₹ 120,400",
                      progress: 0.68,
                    ),

                    SizedBox(height: 22),

                    TopBranchTile(
                      branch: "Branch 02 - Westside",
                      amount: "₹ 95,100",
                      progress: 0.56,
                    ),

                    SizedBox(height: 22),

                    TopBranchTile(
                      branch: "Branch 04 - East End",
                      amount: "₹ 45,800",
                      progress: 0.35,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// TABLE
              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xffE5E7EB)),
                ),

                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Financial Summary by Branch",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 24),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: FinancialSummaryTable(),
                    ),

                    SizedBox(height: 24),

                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),

                        SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            "All amounts are in INR (₹)",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
