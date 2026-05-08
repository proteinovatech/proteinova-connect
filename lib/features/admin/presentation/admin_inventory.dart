import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/widget/inventory_card.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';

class AdminInventory extends StatefulWidget {
  const AdminInventory({super.key});

  @override
  State<AdminInventory> createState() => _AdminInventoryState();
}

class _AdminInventoryState extends State<AdminInventory> {
  final List<Map<String, dynamic>> inventoryData = [
    {
      "title": "White Export",
      "value": 11060,
      "progress": 0.82,
    },
    {
      "title": "AA",
      "value": 5680,
      "progress": 0.48,
    },
    {
      "title": "White Small Egg",
      "value": 2400,
      "progress": 0.22,
    },
    {
      "title": "White Medium",
      "value": 3060,
      "progress": 0.40,
    },
    {
      "title": "Medium",
      "value": 560,
      "progress": 0.15,
    },
    {
      "title": "White",
      "value": 5390,
      "progress": 0.47,
    },
    {
      "title": "Brown",
      "value": 4790,
      "progress": 0.55,
    },
  ];

  final List<Map<String, dynamic>> activities = [
    {
      "title": "In Transit: PO-34",
      "subtitle": "Arriving: 2024-05-06 • 2 hours ago",
      "icon": Icons.local_shipping_outlined,
      "color": Colors.red,
    },
    {
      "title": "Received: PO-33",
      "subtitle": "Received • 2 hours ago",
      "icon": Icons.check,
      "color": Colors.green,
    },
    {
      "title": "In Transit: PO-32",
      "subtitle": "Arriving: 2024-05-05 • 23 hours ago",
      "icon": Icons.local_shipping_outlined,
      "color": Colors.red,
    },
    {
      "title": "Ordered: PO-31",
      "subtitle": "Ordered • 23 hours ago",
      "icon": Icons.description_outlined,
      "color": Colors.grey,
    },
  ];

  final List<Map<String, dynamic>> orders = [
    {
      "po": "PO-34",
      "supplier": "X Eggs Farms",
      "location": "Chennai",
      "product": "40 Trays",
      "status": "Pending",
    },
    {
      "po": "PO-33",
      "supplier": "GD Farms",
      "location": "Chennai",
      "product": "White export, white small eggs",
      "status": "Received",
    },
    {
      "po": "PO-32",
      "supplier": "Oval Acres",
      "location": "Chennai",
      "product": "Brown eggs",
      "status": "In Transit",
    },
    {
      "po": "PO-31",
      "supplier": "J Farms",
      "location": "Salem",
      "product": "White export size",
      "status": "Review Dmg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TOP HEADER CONTAINER
              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      children: [
                        const Icon(
                          Icons.menu,
                          size: 22,
                        ),

                        const SizedBox(width: 12),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Inventory Overview",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),

                              decoration: BoxDecoration(
                                color: const Color(0xffFFF3B0),
                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 14,
                                  ),

                                  SizedBox(width: 5),

                                  Text(
                                    "Role Warehouse & Admin",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        const Icon(
                          Icons.notifications_none_outlined,
                          size: 24,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// STOCK SECTION
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Incoming Stock Queue",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                "Manage and monitor incoming shipments from suppliers",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () {},

                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xffFFD400),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),

                          child: const Text(
                            "+ Add Sale",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// GRID CARDS
              GridView.count(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),

                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,

                children: const [
                  InventoryCard(
                    title: "Expected Today",
                    value: "1 Shipments",
                    subtitle: "Tracking Information",
                    icon: Icons.calendar_today_outlined,
                    iconColor: Colors.black87,
                  ),

                  InventoryCard(
                    title: "Ready for Unloading",
                    value: "4 Shipments",
                    subtitle: "Awaiting Confirmation",
                    icon: Icons.inventory_2_outlined,
                    iconColor: Colors.green,
                  ),

                  InventoryCard(
                    title: "Delayed in Transit",
                    value: "12 Shipments",
                    subtitle: "₹70,000 Loss / Pending",
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.red,
                  ),

                  InventoryCard(
                    title: "Current Stock",
                    value: "30,990",
                    subtitle: "+2.4% from last week",
                    icon: Icons.refresh,
                    iconColor: Colors.black87,
                    isPositive: true,
                  ),

                  InventoryCard(
                    title: "Damaged Stock",
                    value: "21 Units",
                    subtitle: "0.4% damage rate",
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.red,
                  ),

                  InventoryCard(
                    title: "Stock Value",
                    value: "₹ 192,894",
                    subtitle: "Total inventory value",
                    icon: Icons.attach_money,
                    iconColor: Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// INVENTORY LEVELS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Inventory Levels",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),

                          decoration: BoxDecoration(
                            color:
                                const Color(0xffEAF2FF),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),

                          child: const Text(
                            "View Details",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff1E73FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    ListView.separated(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: inventoryData.length,

                      separatorBuilder:
                          (context, index) =>
                              const SizedBox(height: 16),

                      itemBuilder: (context, index) {
                        final item = inventoryData[index];

                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(
                                  item["title"].toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),

                                Text(
                                  item["value"].toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(
                                      10),

                              child:
                                  LinearProgressIndicator(
                                value:
                                    item["progress"],
                                minHeight: 6,
                                backgroundColor:
                                    const Color(
                                        0xffE9EDF5),
                                valueColor:
                                    const AlwaysStoppedAnimation<
                                        Color>(
                                  Color(0xff1E73FF),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

                         Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recent Activity",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ListView.separated(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: activities.length,

                      separatorBuilder:
                          (context, index) =>
                              const Padding(
                        padding:
                            EdgeInsets.symmetric(
                                vertical: 14),
                        child: Divider(height: 1),
                      ),

                      itemBuilder: (context, index) {
                        final item = activities[index];

                        return Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 38,
                              width: 38,

                              decoration: BoxDecoration(
                                color: item["color"],
                                shape: BoxShape.circle,
                              ),

                              child: Icon(
                                item["icon"],
                                color: Colors.white,
                                size: 18,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    item["title"],
                                    style:
                                        const TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 6),

                                  Text(
                                    item["subtitle"],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors
                                          .grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                                     Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Purchase Orders",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons
                                    .calendar_month,
                              ),
                            ),

                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.person_outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText:
                            "Search PO, Supplier, or Items...",
                        prefixIcon:
                            const Icon(Icons.search),
                        filled: true,
                        fillColor:
                            Colors.grey.shade100,
                        contentPadding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,

                      itemBuilder: (context, index) {
                        final item = orders[index];

                        return Container(
                          margin:
                              const EdgeInsets.only(
                                  bottom: 5),

                          padding:
                              const EdgeInsets.all(5),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                                    18),
                          ),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                                                          Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,

                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [
                                      Text(
                                        item["po"]
                                            .toString(),
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 4),

                                      const Text(
                                        "07 May 2026 • 10:45 AM",
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),

                                  PopupMenuButton(
                                    itemBuilder:
                                        (context) => [
                                      const PopupMenuItem(
                                        value: "view",
                                        child:
                                            Text("View"),
                                      ),

                                      const PopupMenuItem(
                                        value: "edit",
                                        child:
                                            Text("Edit"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                                                            Row(
                                children: [
                                  const Icon(
                                    Icons
                                        .storefront_outlined,
                                    size: 18,
                                    color: Colors.grey,
                                  ),

                                  const SizedBox(
                                      width: 8),

                                  Expanded(
                                    child: Text(
                                      "${item["supplier"]} • ${item["location"]}",
                                      style:
                                          const TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight
                                                .w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                                  Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                  const Icon(
                                    Icons
                                        .inventory_2_outlined,
                                    size: 18,
                                    color: Colors.grey,
                                  ),

                                  const SizedBox(
                                      width: 8),

                                  Expanded(
                                    child: Text(
                                      item["product"]
                                          .toString(),
                                      style:
                                          const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              _buildStatus(
                                item["status"]
                                    .toString(),
                              ),
                            ],
                          ),
                        );
                        
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case "Received":
        bgColor = Colors.green.shade100;
        textColor = Colors.green;
        break;

      case "In Transit":
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange;
        break;

      case "Review Dmg":
        bgColor = Colors.yellow.shade100;
        textColor = Colors.orange.shade900;
        break;

      case "Pending":
        bgColor = Colors.red.shade100;
        textColor = Colors.red;
        break;
        

      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.black87;
    }

    return Align(
      alignment: Alignment.centerLeft,

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
        ),

        child: Text(
          status,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}