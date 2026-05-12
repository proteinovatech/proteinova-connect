import 'package:flutter/material.dart';

class ReceiveTraysScreen extends StatelessWidget {
  const ReceiveTraysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isSmall = width < 380;

    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xffF6F7FB),
        elevation: 0,
        scrolledUnderElevation: 0,

        leadingWidth: 70,

        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),

          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },

            child: const Center(
              child: Icon(
                Icons.arrow_back_outlined,
                size: 28,
                color: Colors.black,
              ),
            ),
          ),
        ),

        titleSpacing: 0,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Receive Trays",

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: isSmall ? 22 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xff0B132B),
              ),
            ),

            const SizedBox(height: 2),

            Text(
              "Manage and receive incoming trays",

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: isSmall ? 12 : 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 16 : 20,
            vertical: 16,
          ),

          child: Column(
            children: [
              /// APP BAR
              const SizedBox(height: 24),

              /// RECEIVED INFO CARD
              Container(
                width: double.infinity,

                padding: EdgeInsets.all(isSmall ? 16 : 20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withValues(alpha: 0.04),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    /// ICON
                    const SizedBox(width: 16),

                    /// TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Received Info",

                            style: TextStyle(
                              fontSize: isSmall ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff0B132B),
                            ),
                          ),

                          const SizedBox(height: 6),

                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Click ",

                                  style: TextStyle(
                                    fontSize: isSmall ? 13 : 15,
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                  ),
                                ),

                                TextSpan(
                                  text: "View",

                                  style: TextStyle(
                                    fontSize: isSmall ? 13 : 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff3B82F6),
                                  ),
                                ),

                                TextSpan(
                                  text: " on any record to see details.",

                                  style: TextStyle(
                                    fontSize: isSmall ? 13 : 15,
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// BUTTON ROW
              Row(
                children: [
                  /// CANCEL BUTTON
                  Expanded(
                    child: Container(
                      height: 58,

                      decoration: BoxDecoration(
                        color: const Color(0xffEEF2F7),

                        borderRadius: BorderRadius.circular(18),

                        border: Border.all(color: Colors.grey.shade300),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const Icon(
                            Icons.refresh,
                            color: Colors.black,
                            size: 22,
                          ),

                          const SizedBox(width: 10),

                          Text(
                            "Cancel",

                            style: TextStyle(
                              fontSize: isSmall ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  /// SAVE BUTTON
                  Expanded(
                    child: Container(
                      height: 58,

                      decoration: BoxDecoration(
                        color: const Color(0xffFFC107),

                        borderRadius: BorderRadius.circular(18),

                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.orange.withValues(alpha: 0.25),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Container(
                            width: 28,
                            height: 28,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              border: Border.all(color: Colors.black, width: 2),
                            ),

                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Text(
                            "Save",

                            style: TextStyle(
                              fontSize: isSmall ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              /// TABLE CARD
              Container(
                width: double.infinity,

                padding: EdgeInsets.all(isSmall ? 16 : 20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withValues(alpha: 0.04),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// TITLE
                    Text(
                      "Recent Tray Returns",

                      style: TextStyle(
                        fontSize: isSmall ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff0B132B),
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// TABLE
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: Container(
                        width: 720,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),

                          border: Border.all(color: Colors.grey.shade300),
                        ),

                        child: Column(
                          children: [
                            /// HEADER
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 16,
                              ),

                              decoration: const BoxDecoration(
                                color: Color(0xffF8FAFC),

                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                ),
                              ),

                              child: Row(
                                children: [
                                  tableHeader("Date"),
                                  tableHeader("From"),
                                  tableHeader("Tray Type"),
                                  tableHeader("Qty"),
                                  tableHeader("Condition"),
                                  tableHeader("Reasons"),
                                  tableHeader("Action"),
                                ],
                              ),
                            ),

                            Divider(height: 1, color: Colors.grey.shade300),

                            /// EMPTY
                            Container(
                              width: double.infinity,

                              padding: const EdgeInsets.symmetric(vertical: 50),

                              child: Column(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,

                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xffF8FAFC),
                                    ),

                                    child: const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 58,
                                      color: Color(0xff94A3B8),
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  Text(
                                    "No records found",

                                    style: TextStyle(
                                      fontSize: isSmall ? 22 : 26,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff0B132B),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    "No tray returns yet.",

                                    style: TextStyle(
                                      fontSize: isSmall ? 14 : 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// TABLE HEADER
  Widget tableHeader(String title) {
    return Expanded(
      child: Text(
        title,

        textAlign: TextAlign.center,

        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
