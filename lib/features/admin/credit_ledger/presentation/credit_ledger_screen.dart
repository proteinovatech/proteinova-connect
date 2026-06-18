import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

class CreditLedgerScreen extends StatelessWidget {
  const CreditLedgerScreen({super.key});
  bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < 768;

bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= 768 &&
    MediaQuery.of(context).size.width < 1200;

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= 1200;

    

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
final cardWidth = (screenWidth - 56) / 2;
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

           isMobile(context)
    ? Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Credit Ledger",
            style: TextStyle(
              fontSize: getWidth(context, 28),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: getHeight(context, 6)),
          const Text(
            "Track customer credit balances across branches and warehouse",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),

    SizedBox(width: getWidth(context, 12)),

    SizedBox(
      width: 130,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffF5C400),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text("Refresh"),
      ),
    ),
  ],
)
    : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Credit Ledger",
                style: TextStyle(
                  fontSize: getWidth(context, 28),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: getHeight(context, 6)),
              const Text(
                "Track customer credit balances across branches and warehouse",
              ),
            ],
          ),
          SizedBox(
      width: 130,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffF5C400),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text("Refresh"),
      ),)
        ],
      ),
            const SizedBox(height: 24),

            /// Summary Cards
Wrap(
  spacing: 16,
  runSpacing: 16,
  children: [
    SizedBox(
      width: cardWidth,
      child: _summaryCard(
        icon: Icons.account_balance_wallet_outlined,
        iconColor: Colors.red,
        title: "Total Outstanding",
        value: "₹ 0.00",
      ),
    ),
    SizedBox(
      width: cardWidth,
      child: _summaryCard(
        icon: Icons.currency_rupee,
        iconColor: Colors.deepPurple,
        title: "Total Charged",
        value: "₹ 0.00",
      ),
    ),
    SizedBox(
      width: cardWidth,
      child: _summaryCard(
        icon: Icons.check_circle,
        iconColor: Colors.green,
        title: "Total Received",
        value: "₹ 0.00",
      ),
    ),
    SizedBox(
      width: cardWidth,
      child: _summaryCard(
        icon: Icons.access_time,
        iconColor: Colors.orange,
        title: "Pending Customers",
        value: "0",
      ),
    ),
    SizedBox(
      width: screenWidth-40,
      child: _summaryCard(
        icon: Icons.people_outline,
        iconColor: Colors.blue,
        title: "Cleared Customers",
        value: "0",
      ),
    ),
  ],
),
      const SizedBox(height: 24),

            /// Filter Section
   Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// Search Field
Row(
  children: [
    Expanded(
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search customer name...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),

    const SizedBox(width: 12),

    SizedBox(
      height: 56,
      width: 120,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff08152F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Search",
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  ],
),
      const SizedBox(height: 16),

      const Row(
        children: [
          Icon(Icons.filter_alt_outlined),
          SizedBox(width: 8),
          Text(
            "Filters",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      _dropdown("All Locations"),

      const SizedBox(height: 12),

      _dropdown("All Branches/Warehouse"),

      const SizedBox(height: 12),

      _dropdown("All Status"),

      const SizedBox(height: 16),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffF5C400),
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: const Text(
            "Apply",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ],
  ),
),       
           const SizedBox(height: 24),

            /// Customer Balance Table
            Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [

                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(text: "Customer Balances "),
                          TextSpan(
                            text: "(0 customers)",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 1),

                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.people_outline,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "No credit transactions found",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
         
      ])),
    );
  }

  static Widget _summaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dropdown(String hint) {
    return DropdownButtonFormField<String>(
      value: null,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      hint: Text(hint),
      items: const [
        DropdownMenuItem(
          value: "1",
          child: Text("Option 1"),
        ),
      ],
      onChanged: (value) {},
    );
  }
 Widget _responsiveCard(
  BuildContext context, {
  required IconData icon,
  required Color iconColor,
  required String title,
  required String value,
}) {
  final screenWidth = MediaQuery.of(context).size.width;

  double width;

  if (screenWidth >= 1200) {
    width = (screenWidth - 140) / 5;
  } else if (screenWidth >= 768) {
    width = (screenWidth - 80) / 2;
  } else {
    width = screenWidth - getWidth(context, 40);
  }

  return SizedBox(
    width: width,
    child: _summaryCard(
      icon: icon,
      iconColor: iconColor,
      title: title,
      value: value,
    ),
  );
}

}