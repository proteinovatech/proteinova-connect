import 'package:flutter/material.dart';

class CreditLedgerScreen extends StatelessWidget {
  const CreditLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Credit Ledger",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Track customer credit balances across branches and warehouse",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF5C400),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    "Refresh",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Summary Cards
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: Colors.red,
                    title: "Total Outstanding",
                    value: "₹ 0.00",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _summaryCard(
                    icon: Icons.currency_rupee,
                    iconColor: Colors.deepPurple,
                    title: "Total Charged",
                    value: "₹ 0.00",
                  ),
                ),]),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        icon: Icons.check_circle,
                        iconColor: Colors.green,
                        title: "Total Received",
                        value: "₹ 0.00",
                      ),
                    ),
                  
                const SizedBox(width: 16),
                Expanded(
                  child: _summaryCard(
                    icon: Icons.access_time,
                    iconColor: Colors.orange,
                    title: "Pending Customers",
                    value: "0",
                  ),
                ),],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
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
      TextField(
        decoration: InputDecoration(
          hintText: "Search customer name...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      const SizedBox(height: 12),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff08152F),
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: const Text(
            "Search",
            style: TextStyle(color: Colors.white),
          ),
        ),
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
          ],
        ),
      ),
    );
  }

  static Widget _summaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
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
}