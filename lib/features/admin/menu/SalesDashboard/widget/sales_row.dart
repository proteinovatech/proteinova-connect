 import 'package:flutter/material.dart';

Widget salesRow({
    required String order,
    required String date,
    required String customer,
    required String items,
    required String amount,
    required String status,
    required bool paid,
  }) {
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

                const SizedBox(height: 4),

                Text(customer, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),

          /// ITEMS
          Expanded(
            flex: 18,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Text(
                  items,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                const Text("Eggs", style: TextStyle(fontSize: 12)),
              ],
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
            flex: 20,

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

