/// =======================================
/// asset_table_widget.dart
/// =======================================

import 'package:flutter/material.dart';

class AssetTableWidget extends StatelessWidget {
  const AssetTableWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Container(
        width: 450,

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withValues(
                alpha: 0.03,
              ),
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          children: [

            /// TABLE HEADER
            Row(
              children: const [

                SizedBox(
                  width: 100,

                  child: Text(
                    "ASSET DETAILS",

                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(
                  width: 70,

                  child: Text(
                    "CATEGORY",

                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(
                  width: 70,

                  child: Text(
                    "QUANTITY",

                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(
                  width: 70,

                  child: Text(
                    "LOCATION",

                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(
                  width: 50,

                  child: Text(
                    "STATUS",

                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(
                  width: 50,

                  child: Text(
                    "ACTIONS",

                    textAlign:
                        TextAlign.end,

                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            Divider(
              height: 40,
              color: Colors.grey.shade200,
            ),

            const SizedBox(height: 40),

            /// EMPTY ICON
            Icon(
              Icons.assignment_outlined,
              size: 110,
              color: Colors.grey.shade300,
            ),

            const SizedBox(height: 24),

            const Text(
              "No assets found",

              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Get started by adding your first asset.",

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 28),

            /// BUTTON
            Container(
              width: 210,
              height: 54,

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  16,
                ),

                border: Border.all(
                  color:
                      Colors.grey.shade300,
                ),
              ),

              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                children: [

                  Icon(Icons.add),

                  SizedBox(width: 8),

                  Text(
                    "Add New Asset",

                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}