/// currently_in_use_bottomsheet.dart

import 'package:flutter/material.dart';

class CurrentlyInUseBottomSheet extends StatelessWidget {
  const CurrentlyInUseBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,

      decoration: const BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.vertical(
          top: Radius.circular(34),
        ),
      ),

      child: SingleChildScrollView(
        child: Column(
          children: [

            /// TOP HANDLE
            const SizedBox(height: 12),

            Container(
              width: 70,
              height: 5,

              decoration: BoxDecoration(
                color: Colors.grey.shade300,

                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 26),

            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),

              child: Row(
                children: [

                  /// ICON
                  Container(
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.10),

                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: Colors.green,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 16),

                  /// TITLE
                  const Expanded(
                    child: Text(
                      "Currently In Use",

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  /// CLOSE BUTTON
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: const Icon(
                      Icons.close,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Divider(
              color: Colors.grey.shade300,
              height: 1,
            ),

            /// TABLE HEADER
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),

              color: const Color(0xffFAFAFA),

              child: const Row(
                children: [

                  Expanded(
                    flex: 3,

                    child: Text(
                      "ASSET DETAILS",

                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,

                    child: Text(
                      "CATEGORY",

                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,

                    child: Text(
                      "LOCATION",

                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,

                    child: Text(
                      "STATUS",

                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            /// EMPTY ICON
            Icon(
              Icons.inventory_2_outlined,
              size: 120,
              color: Colors.grey.shade300,
            ),

            const SizedBox(height: 28),

            /// TITLE
            const Text(
              "No assets match this category.",

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            /// SUBTITLE
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
              ),

              child: Text(
                "Try adjusting your filters or clear them to see all assets.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 32),

            /// BUTTON
            Container(
              width: 220,
              height: 58,

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(18),

                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),

              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(Icons.tune, size: 22),

                  SizedBox(width: 10),

                  Text(
                    "Adjust Filters",

                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}