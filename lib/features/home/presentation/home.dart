import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/home/widget/filterbox.dart';
import 'package:proteinova_connect/features/home/widget/purchasecard.dart';
import 'package:proteinova_connect/features/purchase_dashboard/presentation/purchase_dashboard.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

            /// 🔹 FIXED HEADER
            SizedBox(height: size.height * 0.07),

            Align(
              alignment: Alignment.centerRight,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
              ),
            ),

            const Divider(),

         Expanded(
  child: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// TITLE
        Text("Purchase", style: AppTextStyles.headingText25),
        Text(
          "Manage purchase orders and incoming stocks.",
          style: AppTextStyles.bodyText16,
        ),

        SizedBox(height: size.height * 0.02),

        /// BUTTON
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const PurchaseDashboard(),
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

        /// TABS (KEEP THIS - it's OK)
        SizedBox(
          height: size.height * 0.06,
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
                      style: AppTextStyles.bodyText16.copyWith(
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
                        "Search by ID or supplier...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: size.height * 0.02),

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

        /// PURCHASE CARDS
        PurchaseCard(
          status: "Received",
          statusColor: Colors.green,
          textColor: Colors.white,
          supplier: "Apex Farms",
          orderId: 'ORD001',
          dateTime: '17 Apr 2026',
          bottomId: '156271',
          items: 'Item A',
          itemboxes: '20 boxes',
        ),

        SizedBox(height: size.height * 0.02),

        PurchaseCard(
          status: "Draft",
          statusColor: Color(0xFFC7D1E7),
          textColor: Colors.blue,
          supplier: "Valley Farms",
          orderId: 'ORD002',
          dateTime: '15 Apr 2026',
          bottomId: 'BNA123',
          items: 'Item B',
          itemboxes: '15 boxes',
        ),

        SizedBox(height: size.height * 0.02),

        PurchaseCard(
          status: "In Transit",
          statusColor: Color(0xFFF5CDBE),
          textColor: Colors.brown,
          supplier: "Sunrise Poultry",
          orderId: 'ORD003',
          dateTime: '13 Apr 2026',
          bottomId: 'ZMB456',
          items: 'Item C',
          itemboxes: '10 boxes',
        ),

        SizedBox(height: size.height * 0.05),
      ],
    ),
  ),
)
         
          ],
        ),
      ),
    );
  }

  
}