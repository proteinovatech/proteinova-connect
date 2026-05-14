import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/inventory/data/inventory_repository.dart';

class ReceiveStockScreen extends StatefulWidget {
  final int id;

  const ReceiveStockScreen({super.key, required this.id});

  @override
  State<ReceiveStockScreen> createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends State<ReceiveStockScreen> {
  final InventoryRepository _repository = InventoryRepository();

  Map<String, dynamic>? purchase;
  bool isLoading = true;
  bool isSubmitting = false;

  List<Map<String, dynamic>> trayDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchPurchase();
  }

  Future<void> _fetchPurchase() async {
    try {
      final data = await _repository.fetchPurchaseById(widget.id);

      final items = data['items'] ?? [];

      trayDetails = items.map<Map<String, dynamic>>((item) {
        final trays = int.tryParse(item['trays'].toString()) ?? 0;
        final capacity = int.tryParse(item['capacity'].toString()) ?? 30;

        final eggs = trays * capacity;

        return {
          "product": item['egg_category_grade'] ?? "",
          "trayType": item['tray_type'] ?? "",
          "received": eggs,
          "damaged": 0,
          "good": eggs,
          "notes": "",
        };
      }).toList();

      setState(() {
        purchase = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _updateTray(int index, String field, dynamic value) {
    setState(() {
      trayDetails[index][field] = value;

      final received =
          int.tryParse(trayDetails[index]['received'].toString()) ?? 0;

      final damaged =
          int.tryParse(trayDetails[index]['damaged'].toString()) ?? 0;

      trayDetails[index]['good'] = received - damaged;
    });
  }

  Future<void> _confirmReceive() async {
    setState(() => isSubmitting = true);

    try {
      final itemsToPost = trayDetails.map((detail) {
        return {
          "egg_category_grade": detail['product'],
          "damaged_eggs": int.tryParse(detail['damaged'].toString()) ?? 0,
          "received_eggs": int.tryParse(detail['received'].toString()) ?? 0,
        };
      }).toList();

      await _repository.receiveStock(widget.id, itemsToPost);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stock received successfully")),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final items = purchase?['items'] ?? [];

    final totalEggs = (items as List).fold<int>(0, (int sum, dynamic item) {
      final trays = int.tryParse(item['trays'].toString()) ?? 0;

      final capacity = int.tryParse(item['capacity'].toString()) ?? 30;

      return sum + (trays * capacity);
    });

    final totalTrays = (items as List).fold<int>(0, (int sum, dynamic item) {
      return sum + (int.tryParse(item['trays'].toString()) ?? 0);
    });
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          "Receive Stock",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Text(
                  "PO-${purchase?['id']}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Ready for Unload",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              "Manage and receive incoming shipments from suppliers to update inventory",
              style: TextStyle(color: Colors.grey.shade700),
            ),

            const SizedBox(height: 18),

            /// RECEIVED INFO
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Received Info",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _infoItem("Receive No.", "${purchase?['id']}"),
                      ),

                      Expanded(
                        child: _infoItem(
                          "Purchase Date",
                          purchase?['created_at'] ?? "",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _infoItem(
                          "Vehicle No.",
                          purchase?['vehicle_number'] ?? "",
                        ),
                      ),

                      Expanded(
                        child: _infoItem(
                          "Driver Name",
                          purchase?['driver_name'] ?? "",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _infoItem("Broker Name", purchase?['broker_name'] ?? "N/A"),

                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "From Supplier",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 8),

                        Text(purchase?['supplier_company_name'] ?? ""),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// RECEIVED ITEMS
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Received Items",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),

                  const SizedBox(height: 20),

                  ListView.builder(
                    itemCount: items.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = items[index];

                      final trays = int.tryParse(item['trays'].toString()) ?? 0;

                      final capacity =
                          int.tryParse(item['capacity'].toString()) ?? 30;

                      final eggs = trays * capacity;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _row("Product", item['egg_category_grade']),

                              _row("Tray Type", item['tray_type']),

                              _row("Trays", trays.toString()),

                              _row("Eggs", eggs.toString()),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// SUMMARY
            _buildCard(
              child: Column(
                children: [
                  _summaryRow("Total Trays", totalTrays.toString()),

                  _summaryRow("Total Eggs", totalEggs.toString()),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// TRAY DETAILS
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tray Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),

                  const SizedBox(height: 20),

                  ListView.builder(
                    itemCount: trayDetails.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final detail = trayDetails[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _row("Product", detail['product']),

                            _row("Tray Type", detail['trayType']),

                            const SizedBox(height: 14),

                            TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Received Eggs",
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(
                                text: detail['received'].toString(),
                              ),
                              onChanged: (v) {
                                _updateTray(
                                  index,
                                  "received",
                                  int.tryParse(v) ?? 0,
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Damaged Eggs",
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(
                                text: detail['damaged'].toString(),
                              ),
                              onChanged: (v) {
                                _updateTray(
                                  index,
                                  "damaged",
                                  int.tryParse(v) ?? 0,
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            TextField(
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: "Good Eggs",
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(
                                text: detail['good'].toString(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Damage trays will not be added to your usable stock.",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFACC15),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: isSubmitting ? null : _confirmReceive,
                    child: isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text("Confirm Receive"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _infoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

        const SizedBox(height: 6),

        Text(value),
      ],
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

          Text(value),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),

          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
