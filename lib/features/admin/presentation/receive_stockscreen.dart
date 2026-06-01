import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
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
    final totalTrays = (items as List).fold<int>(0, (sum, item) => sum + (int.tryParse(item['trays'].toString()) ?? 0));
    final totalEggs = items.fold<int>(0, (sum, item) => sum + ((int.tryParse(item['trays'].toString()) ?? 0) * (int.tryParse(item['capacity'].toString()) ?? 30)));

    final double itemsTotal = items.fold<double>(0, (sum, item) {
      final trays = double.tryParse(item['trays'].toString()) ?? 0;
      final capacity = double.tryParse(item['capacity'].toString()) ?? 30;
      final price = double.tryParse(item['per_egg_price'].toString()) ?? 0;
      return sum + (trays * capacity * price);
    });

    final expenses = purchase?['expenses'] ?? [];
    final double otherCharge = (expenses as List).fold<double>(0, (sum, e) => sum + (double.tryParse(e['amount'].toString()) ?? 0));
    final double totalAmount = itemsTotal + otherCharge;

    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(),
                    const SizedBox(height: 30),
                    
                    /// INFO GRID
                    LayoutBuilder(builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: isWide ? 1 : 1, child: _buildInfoCard()),
                              if (isWide) const SizedBox(width: 20),
                              if (isWide) Expanded(flex: 2, child: _buildItemsCard(items, itemsTotal, totalTrays, totalEggs)),
                              if (isWide) const SizedBox(width: 20),
                              if (isWide) Expanded(flex: 1, child: _buildSummaryCard(totalTrays, totalEggs, items)),
                            ],
                          ),
                          if (!isWide) ...[
                            const SizedBox(height: 20),
                            _buildItemsCard(items, itemsTotal, totalTrays, totalEggs),
                            const SizedBox(height: 20),
                            _buildSummaryCard(totalTrays, totalEggs, items),
                          ]
                        ],
                      );
                    }),

                    const SizedBox(height: 30),

                    /// TRAY DETAILS & BILL SUMMARY
                    LayoutBuilder(builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildTrayDetailsCard()),
                          const SizedBox(width: 20),
                          if (isWide) Expanded(flex: 1, child: _buildBillSummaryCard(items.length, itemsTotal, otherCharge, totalAmount)),
                        ],
                      );
                    }),
                    
                    if (MediaQuery.of(context).size.width <= 900) ...[
                      const SizedBox(height: 20),
                      _buildBillSummaryCard(items.length, itemsTotal, otherCharge, totalAmount),
                    ],

                    const SizedBox(height: 30),
                    _buildNotesAndActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          const SizedBox(width: 8),
          const Text("Settings", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xffFEF3C7), borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.verified_user, size: 16, color: Colors.amber),
                const SizedBox(width: 6),
                const Text("Role: Admin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
 Wrap(
  crossAxisAlignment: WrapCrossAlignment.center,
  spacing: getWidth(context, 12),
  runSpacing: getHeight(context, 8),
  children: [
    RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "Receive Stock: ",
            style: TextStyle(
              fontSize: getWidth(context, 24),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: "PO-${purchase?['id']}",
            style: TextStyle(
              fontSize: getWidth(context, 24),
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),

    Container(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(context, 12),
        vertical: getHeight(context, 4),
      ),
      decoration: BoxDecoration(
        color: const Color(0xff16A34A),
        borderRadius: BorderRadius.circular(
          getWidth(context, 8),
        ),
      ),
      child: Text(
        "Ready for Unload",
        style: TextStyle(
          color: Colors.white,
          fontSize: getWidth(context, 12),
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),      const SizedBox(height: 8),
        const Text("Manage and receive incoming shipments from suppliers to update inventory", style: TextStyle(color: Color(0xff6B7280), fontSize: 16)),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xffE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Received Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(height: 40),
          _infoRow("Receive No.", "${purchase?['id']}"),
          _infoRow("Purchase Date", purchase?['created_at']?.split('T').first ?? "N/A"),
          _infoRow("Vehicle No.", purchase?['vehicle_number'] ?? "N/A"),
          _infoRow("Driver Name", purchase?['driver_name'] ?? "N/A"),
          _infoRow("Broker Name", purchase?['broker_name'] ?? "N/A"),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xffF9FAFB), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("From Supplier", style: TextStyle(fontSize: 12, color: Color(0xff6B7280), fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(purchase?['supplier_company_name'] ?? "N/A", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xff6B7280), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildItemsCard(List items, double itemsTotal, int totalTrays, int totalEggs) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xffE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Received Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(height: 40),
          ...items.asMap().entries.map((entry) {
            final _ = entry.key;
            final item = entry.value;
            final trays = int.tryParse(item['trays'].toString()) ?? 0;
            final capacity = int.tryParse(item['capacity'].toString()) ?? 30;
            final eggs = trays * capacity;
            final price = double.tryParse(item['per_egg_price'].toString()) ?? 0;
            final totalPrice = eggs * price;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['egg_category_grade'] ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xffE0E7FF), borderRadius: BorderRadius.circular(6)),
                        child: Text(item['tray_type'] ?? "N/A", style: const TextStyle(color: Color(0xff4338CA), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Trays", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text("$trays", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Eggs", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text("$eggs", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Price/Egg", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text("₹${price.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Price", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("₹${totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff16A34A), fontSize: 16)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xffFEF9C3), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Grand Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("$totalTrays Trays / $totalEggs Eggs", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
                    Text("₹${itemsTotal.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int totalTrays, int totalEggs, List items) {
    final trayTypeSummary = <String, int>{};
    for (var item in items) {
      final type = item['tray_type'] ?? "Other";
      final count = int.tryParse(item['trays'].toString()) ?? 0;
      trayTypeSummary[type] = (trayTypeSummary[type] ?? 0) + count;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xffE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Icon(Icons.description_outlined, color: Color(0xff6B7280)),
            ],
          ),
          const Divider(height: 40),
          _summaryRow("Total Trays", "$totalTrays"),
          _summaryRow("Total Eggs", "$totalEggs"),
          ...trayTypeSummary.entries.map((e) => _summaryRow(e.key, "${e.value}")).toList(),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xff6B7280))),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTrayDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xffE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tray Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...trayDetails.asMap().entries.map((entry) {
            final idx = entry.key;
            final detail = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(detail['product'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xffE0E7FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(detail['trayType'], style: const TextStyle(color: Color(0xff4338CA), fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Received", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.all(10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              controller: TextEditingController(text: detail['received'].toString())..selection = TextSelection.collapsed(offset: detail['received'].toString().length),
                              onChanged: (v) => _updateTray(idx, "received", int.tryParse(v) ?? 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Damaged", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.all(10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              controller: TextEditingController(text: detail['damaged'].toString())..selection = TextSelection.collapsed(offset: detail['damaged'].toString().length),
                              onChanged: (v) => _updateTray(idx, "damaged", int.tryParse(v) ?? 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Good", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(color: const Color(0xffDCFCE7), borderRadius: BorderRadius.circular(8)),
                              child: Text("${detail['good']}", textAlign: TextAlign.center, style: const TextStyle(color: Color(0xff166534), fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Add notes...",
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (v) => _updateTray(idx, "notes", v),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text("Damage trays will not be added to your usable stock.", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummaryCard(int itemCount, double itemsTotal, double otherCharge, double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xffE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bill Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(height: 40),
          _summaryRow("Items ($itemCount)", "₹${itemsTotal.toStringAsFixed(0)}"),
          _summaryRow("Other Charge", "₹${otherCharge.toStringAsFixed(0)}"),
          const Divider(height: 40, color: Colors.black),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("₹${totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesAndActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Notes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Enter any additional notes...",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffE5E7EB))),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _confirmReceive,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFEF3C7),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isSubmitting 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined, size: 20),
                        SizedBox(width: 8),
                        Text("Confirm Receive", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
