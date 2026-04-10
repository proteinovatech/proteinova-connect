import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/purchase_dashboard/presentation/newpurchase.dart';
import 'package:proteinova_connect/features/purchase_dashboard/widget/purchasecard.dart';

class PurchaseDashboard extends StatefulWidget {
  const PurchaseDashboard({super.key});

  @override
  State<PurchaseDashboard> createState() => _PurchaseDashboardState();
}

class _PurchaseDashboardState extends State<PurchaseDashboard> {
  int selectedIndex = 0;

  final List<String> tabs = [
    "All Purchases",
    "In Transit",
    "Received",
    "Drafts",
    "Pending"
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔹 HEADER (FIXED)
            SizedBox(height: size.height * 0.07),

            Align(
              alignment: Alignment.centerRight,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
              ),
            ),

            const Divider(),

            /// 🔹 SCROLL STARTS HERE ✅
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text("Purchase", style: AppTextStyles.headingText25),
                    Text(
                      "Manage Purchase orders and Incoming stocks.",
                      style: AppTextStyles.bodyText16,
                    ),

                    SizedBox(height: size.height * 0.02),

                    /// BUTTON
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Newpurchase(),
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
                              "New Purchase Entry",
                              style: AppTextStyles.headingText20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

                    /// TABS
                    SizedBox(
                      height: size.height * 0.05,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: tabs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 20),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  tabs[index],
                                  style:
                                      AppTextStyles.bodyText16.copyWith(
                                    color: selectedIndex == index
                                        ? AppColors.dark
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  height: 3,
                                  width: 40,
                                  color: selectedIndex == index
                                      ? AppColors.amber500
                                      : Colors.transparent,
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const Divider(),

                    SizedBox(height: size.height * 0.02),

                    /// SEARCH
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      height: 45,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText:
                                    "Search drafts by Id or supplier ...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

                    /// FILTERS
                    Row(
                      children: [
                        Expanded(
                          child: filterBox(
                              Icons.filter_alt_outlined,
                              "All Suppliers"),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: filterBox(
                              Icons.calendar_today,
                              "Last 30 days"),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.03),

                    /// CARDS
                    PurchaseCard(
                      status: "Received",
                      statusColor: Colors.green,
                      textColor: Colors.white,
                      supplier: "Apex Farms",
                      orderId: 'mnbjghjg',
                      dateTime: '17.00',
                      bottomId: '156271',
                      items: 'mszjkshxls()',
                      itemboxes: ',mbdckjsc',
                    ),

                    SizedBox(height: size.height * 0.02),

                    PurchaseCard(
                      status: "Draft",
                      statusColor: Color(0xFFC7D1E7),
                      textColor: Colors.blue,
                      supplier: "Valley Farms",
                      orderId: 'ahdkah',
                      dateTime: '27.00',
                      bottomId: 'bnamvdhj',
                      items: 'hvjcka()',
                      itemboxes: 'mcsbdkjc',
                    ),

                    SizedBox(height: size.height * 0.02),

                    PurchaseCard(
                      status: "In Transit",
                      statusColor: Color(0xFFF5CDBE),
                      textColor: Colors.brown,
                      supplier: "Sunrise Poultry",
                      orderId: 'Hxl,L',
                      dateTime: '15.09',
                      bottomId: 'ZMBCSJB',
                      items: 'amx,jkxbs()',
                      itemboxes: 'cmsbcmsd',
                    ),

                    SizedBox(height: size.height * 0.05),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterBox(IconData icon, String text) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          const Icon(Icons.keyboard_arrow_down,
              color: Colors.grey),
        ],
      ),
    );
  }
}