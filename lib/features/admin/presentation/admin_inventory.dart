import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/presentation/Incoming_stock.dart';
import 'package:proteinova_connect/features/admin/widget/inventory_card.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import '../inventory/data/inventory_repository.dart';
import '../inventory/models/inventory_model.dart';

class AdminInventory extends StatefulWidget {
  const AdminInventory({super.key});

  @override
  State<AdminInventory> createState() => _AdminInventoryState();
}

class _AdminInventoryState extends State<AdminInventory> {
  final InventoryRepository _repository = InventoryRepository();
  AdminInventoryModel? inventoryModel;
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final data = await _repository.fetchInventoryData();
      final purchasesList = await _repository.fetchPurchases();
      setState(() {
        inventoryModel = AdminInventoryModel(
          metrics: data.metrics,
          purchases: purchasesList,
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching inventory: $e")));
      }
    }
  }

  List<PurchaseModel> get _filteredPurchases {
    final list = inventoryModel?.purchases ?? [];
    if (searchQuery.isEmpty) return list;
    return list.where((p) {
      final query = searchQuery.toLowerCase();
      return p.poNumber.toLowerCase().contains(query) ||
          p.supplierName.toLowerCase().contains(query) ||
          p.productName.toLowerCase().contains(query);
    }).toList();
  }

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },

                          child: const Icon(Icons.arrow_back, size: 22),
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
                                  Icon(Icons.person_outline, size: 14),

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

                        // const Spacer(),

                        // const Icon(Icons.notifications_none_outlined, size: 24),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// STOCK SECTION
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IncomingStock(),
                              ),
                            ).then((_) => _fetchData());
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFFD400),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          child: const Text(
                            "View Queue",
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
                physics: const NeverScrollableScrollPhysics(),

                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,

                children: [
                  InventoryCard(
                    title: "Expected Today",
                    value:
                        "${inventoryModel?.metrics.expectedToday ?? 0} Shipments",
                    subtitle: "Tracking Information",
                    icon: Icons.calendar_today_outlined,
                    iconColor: Colors.black87,
                  ),

                  InventoryCard(
                    title: "Ready for Unloading",
                    value:
                        "${inventoryModel?.metrics.readyForUnloading ?? 0} Shipments",
                    subtitle: "Awaiting Confirmation",
                    icon: Icons.inventory_2_outlined,
                    iconColor: Colors.green,
                  ),

                  InventoryCard(
                    title: "Delayed in Transit",
                    value:
                        "${inventoryModel?.metrics.delayedInTransit ?? 0} Shipments",
                    subtitle: "Pending updates",
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.red,
                  ),

                  InventoryCard(
                    title: "Current Stock",
                    value: "${inventoryModel?.metrics.currentStock ?? 0}",
                    subtitle: "Total units available",
                    icon: Icons.refresh,
                    iconColor: Colors.black87,
                    isPositive: true,
                  ),

                  InventoryCard(
                    title: "Damaged Stock",
                    value: "${inventoryModel?.metrics.damagedStock ?? 0} Units",
                    subtitle: "Reported damages",
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.red,
                  ),

                  InventoryCard(
                    title: "Stock Value",
                    value: "₹ ${inventoryModel?.metrics.stockValue ?? 0}",
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Inventory Levels",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),

                          decoration: BoxDecoration(
                            color: const Color(0xffEAF2FF),
                            borderRadius: BorderRadius.circular(8),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activities.length,

                      separatorBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1),
                      ),

                      itemBuilder: (context, index) {
                        final item = activities[index];

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["title"],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    item["subtitle"],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              icon: const Icon(Icons.calendar_month),
                            ),

                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.person_outline),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search PO, Supplier, or Items...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredPurchases.length,

                      itemBuilder: (context, index) {
                        final item = _filteredPurchases[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 5),

                          padding: const EdgeInsets.all(5),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        item.poNumber,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        item.createdAt,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),

                                  PopupMenuButton(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: "view",
                                        child: Text("View"),
                                      ),

                                      const PopupMenuItem(
                                        value: "edit",
                                        child: Text("Edit"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.storefront_outlined,
                                    size: 18,
                                    color: Colors.grey,
                                  ),

                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: Text(
                                      "${item.supplierName} • ${item.location}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 18,
                                    color: Colors.grey,
                                  ),

                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: Text(
                                      item.productName,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              _buildStatus(item.status),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

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
