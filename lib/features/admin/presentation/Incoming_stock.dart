import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/widget/incoming_widget.dart';

class IncomingStock extends StatelessWidget {
  const IncomingStock({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TOP BAR
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: Color(0xff111827),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "Incoming Stock Queue",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                "Manage and receive incoming shipments from suppliers to update inventory.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              /// CARDS
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.68,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// TOP INDICATOR
                              Center(
                                child: Container(
                                  width: 60,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// HEADER
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          "Expected Today Details",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        SizedBox(height: 6),

                                        Text(
                                          "View comprehensive shipment data for this category",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// CLOSE BUTTON
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFFE5E7EB),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.close, size: 18),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Divider(color: Colors.grey.shade300),

                              const SizedBox(height: 16),

                              /// TABLE HEADER
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  width: 650,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F7F7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "PO ID",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "SUPPLIER / VENDOR",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "PRODUCT DETAILS",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "TOTAL QUANTITY",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "ARRIVAL DATE",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              /// EMPTY STATE
                              Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 70,
                                        color: Colors.grey.shade300,
                                      ),

                                      const SizedBox(height: 18),

                                      const Text(
                                        "No shipments found",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Text(
                                        "There are currently no records for this specific category.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },

                child: buildOverviewCard(
                  title: "Expected Today",
                  value: "0 Shipments",
                  subtitle: "Totaling 0 eggs",
                  icon: Icons.event_available_outlined,
                  iconBg: const Color(0xFFF2F2F2),
                ),
              ),

              const SizedBox(height: 14),

              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// TOP INDICATOR
                              Center(
                                child: Container(
                                  width: 60,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// HEADER
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          "Ready for Unloading Details",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        SizedBox(height: 6),

                                        Text(
                                          "View comprehensive shipment data for this category",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// CLOSE BUTTON
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFFE5E7EB),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.close, size: 18),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Divider(color: Colors.grey.shade300),

                              const SizedBox(height: 16),

                              /// TABLE
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: 650,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        /// TABLE HEADER
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 12,
                                          ),

                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF7F7F7),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),

                                          child: const Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "PO ID",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "SUPPLIER / VENDOR",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "PRODUCT DETAILS",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "TOTAL QUANTITY",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "ARRIVAL DATE",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        /// ROW 1
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 14,
                                          ),

                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                          ),

                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              /// PO ID
                                              Expanded(
                                                flex: 1,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFE8F0FF,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      "PO-22",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 10,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 10),

                                              /// SUPPLIER
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const [
                                                    Text(
                                                      "X Eggs Farm",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    SizedBox(height: 3),

                                                    Text(
                                                      "Kattuva",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// PRODUCT
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const [
                                                    Text(
                                                      "Premium",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    SizedBox(height: 3),

                                                    Text(
                                                      "Standard quality eggs",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// QUANTITY
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const [
                                                    Text(
                                                      "1,500",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    SizedBox(height: 3),

                                                    Text(
                                                      "Total Eggs",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// DATE
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "2026-04-26",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        /// ROW 2
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 14,
                                          ),

                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              /// PO ID
                                              Expanded(
                                                flex: 1,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFE8F0FF,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      "PO-19",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 10,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 10),

                                              /// SUPPLIER
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const [
                                                    Text(
                                                      "X Eggs Farm",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    SizedBox(height: 3),

                                                    Text(
                                                      "Kattuva",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// PRODUCT
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const [
                                                    Text(
                                                      "Medium",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    SizedBox(height: 3),

                                                    Text(
                                                      "Medium, Brown",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// QUANTITY
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const [
                                                    Text(
                                                      "1,02,000",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    SizedBox(height: 3),

                                                    Text(
                                                      "Total Eggs",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// DATE
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "2026-04-30",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },

                child: buildOverviewCard(
                  title: "Ready for Unloading",
                  value: "2 Shipments",
                  subtitle: "Requires immediate actions",
                  icon: Icons.local_shipping_outlined,
                  iconBg: Colors.green,
                  iconColor: Colors.white,
                ),
              ),

              const SizedBox(height: 14),

              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.72,

                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(14),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              /// TOP INDICATOR
                              Center(
                                child: Container(
                                  width: 60,
                                  height: 5,

                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              /// HEADER
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: const [
                                        Text(
                                          "Upcoming Shipments Details",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        SizedBox(height: 6),

                                        Text(
                                          "View comprehensive shipment data for this category",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// CLOSE BUTTON
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFFE5E7EB),
                                      ),

                                      borderRadius: BorderRadius.circular(12),
                                    ),

                                    child: IconButton(
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),

                                      padding: EdgeInsets.zero,

                                      onPressed: () {
                                        Navigator.pop(context);
                                      },

                                      icon: const Icon(Icons.close, size: 18),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Divider(color: Colors.grey.shade300),

                              const SizedBox(height: 16),

                              /// TABLE AREA
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,

                                  child: SizedBox(
                                    width: 650,

                                    child: Column(
                                      children: [
                                        /// TABLE HEADER
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 12,
                                          ),

                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF7F7F7),

                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),

                                          child: const Row(
                                            children: [
                                              /// PO ID
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "PO ID",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ),

                                              SizedBox(width: 10),

                                              /// SUPPLIER
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "SUPPLIER / VENDOR",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ),

                                              /// PRODUCT
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "PRODUCT DETAILS",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ),

                                              /// QUANTITY
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "TOTAL QUANTITY",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ),

                                              /// DATE
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "ARRIVAL DATE",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        /// DATA ROW
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 14,
                                          ),

                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                          ),

                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                            children: [
                                              /// PO ID
                                              Expanded(
                                                flex: 1,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 5,
                                                          vertical: 5,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFE8F0FF,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      "PO-1",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 10,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 10),

                                              /// SUPPLIER
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,

                                                  children: const [
                                                    Text(
                                                      "X Eggs Farm",

                                                      style: TextStyle(
                                                        fontSize: 12,

                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    SizedBox(height: 3),

                                                    Text(
                                                      "Kattuva",

                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// PRODUCT
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,

                                                  children: const [
                                                    Text(
                                                      "AA",

                                                      style: TextStyle(
                                                        fontSize: 12,

                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    SizedBox(height: 3),

                                                    Text(
                                                      "AA, Brown, Medium",

                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// QUANTITY
                                              Expanded(
                                                flex: 2,

                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,

                                                  children: const [
                                                    Text(
                                                      "7,200",

                                                      style: TextStyle(
                                                        fontSize: 12,

                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    SizedBox(height: 3),

                                                    Text(
                                                      "Total Eggs",

                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// DATE
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "2026-05-30",

                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },

                child: buildOverviewCard(
                  title: "Upcoming Shipments",
                  value: "1 Shipments",
                  subtitle: "Next scheduled deliveries",
                  icon: Icons.send_outlined,
                  iconBg: Colors.blue,
                  iconColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              /// SEARCH BAR
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 12),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(color: Colors.grey.shade300),
              //   ),
              //   child: const TextField(
              //     style: TextStyle(fontSize: 13),
              //     decoration: InputDecoration(
              //       border: InputBorder.none,
              //       icon: Icon(Icons.search, size: 18),
              //       hintText: "Search PO, Supplier, or Driver...",
              //       hintStyle: TextStyle(fontSize: 12),
              //     ),
              //   ),
              // ),

              // const SizedBox(height: 16),

              /// FILTERS
              Row(
                children: [
                  Expanded(
                    child: buildFilterBox(
                      icon: Icons.calendar_month_outlined,
                      text: "Expected: Today",
                    ),
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: buildFilterBox(
                      icon: Icons.home_outlined,
                      text: "All Suppliers",
                    ),
                  ),

                  const SizedBox(width: 6),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.tune, size: 18),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// TABLE HEADER
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: 650,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      /// HEADER
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              "PURCHASE RECORD",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 3,
                            child: Text(
                              "SUPPLIER DETAILS",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 3,
                            child: Text(
                              "PRODUCT & QUANTITY",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              "STATUS",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 1,
                            child: Text(
                              "ACTION",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// ROWS
                      buildTableRow(
                        po: "PO-22",
                        date: "07 May 2026\n02:52 pm",
                        supplier: "X Eggs Farm",
                        location: "Kattuva",
                        quantity: "1,500 Eggs",
                        type: "Premium",
                        status: "Receive Stock",
                        isReceive: true,
                      ),

                      buildTableRow(
                        po: "PO-21",
                        date: "02 May 2026\n07:59 am",
                        supplier: "X Eggs Farm",
                        location: "Kattuva",
                        quantity: "2,400 Eggs",
                        type: "Brown, AA",
                        status: "PENDING",
                      ),
                      buildTableRow(
                        po: "PO-21",
                        date: "02 May 2026\n07:59 am",
                        supplier: "X Eggs Farm",
                        location: "Kattuva",
                        quantity: "2,400 Eggs",
                        type: "Brown, AA",
                        status: "PENDING",
                      ),
                      buildTableRow(
                        po: "PO-21",
                        date: "02 May 2026\n07:59 am",
                        supplier: "X Eggs Farm",
                        location: "Kattuva",
                        quantity: "2,400 Eggs",
                        type: "Brown, AA",
                        status: "PENDING",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
