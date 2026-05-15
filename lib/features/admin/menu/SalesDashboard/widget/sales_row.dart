import 'package:flutter/material.dart';

class SalesRow extends StatelessWidget {
  final String order;
  final String date;
  final String customer;
  final String branch;
  final String items;
  final String amount;
  final String status;
  final bool paid;

  const SalesRow({
    super.key,
    required this.order,
    required this.date,
    required this.customer,
    required this.branch,
    required this.items,
    required this.amount,
    required this.status,
    required this.paid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),

        decoration: BoxDecoration(
          color: Colors.white,

          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// ORDER DETAILS
            Expanded(
              flex: 32,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    order,

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(date, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),

            /// CUSTOMER
            Expanded(
              flex: 20,

              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Text(
                    customer,

                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ),
            ),

            /// BRANCH
            Expanded(
              flex: 20,

              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Text(
                    branch,

                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ),
            ),

            /// ITEMS
            Expanded(
              flex: 18,

              child: Center(
                child: Text(
                  items,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            /// AMOUNT
            Expanded(
              flex: 18,

              child: Center(
                child: Text(
                  amount,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            /// STATUS
            Expanded(
              flex: 18,

              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: paid ? Colors.green : Colors.red.withOpacity(.1),

                    borderRadius: BorderRadius.circular(30),

                    border: paid ? null : Border.all(color: Colors.red),
                  ),

                  child: Text(
                    status,

                    style: TextStyle(
                      color: paid ? Colors.white : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),

            /// ACTION
            const Expanded(
              flex: 14,

              child: Column(
                children: [
                  Icon(Icons.remove_red_eye_outlined, size: 18),

                  SizedBox(height: 2),

                  Text("View", style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
