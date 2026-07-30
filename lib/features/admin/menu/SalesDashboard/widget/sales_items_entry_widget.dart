import 'package:flutter/material.dart';

class SalesItemModel {
  String id;
  String? productId;
  double availableTrays;
  double eggs;
  double trays;
  double purRate;
  double expRate;
  double totalCost;

  SalesItemModel({
    required this.id,
    this.productId,
    this.availableTrays = 0,
    this.eggs = 0,
    this.trays = 0,
    this.purRate = 0,
    this.expRate = 0,
    this.totalCost = 0,
  });
}

class SalesItemsEntryWidget extends StatefulWidget {
  final List<dynamic> products;
  final Function(List<SalesItemModel>)? onItemsChanged;

  const SalesItemsEntryWidget({
    super.key,
    required this.products,
    this.onItemsChanged,
  });

  @override
  State<SalesItemsEntryWidget> createState() => _SalesItemsEntryWidgetState();
}

class _SalesItemsEntryWidgetState extends State<SalesItemsEntryWidget> {
  List<SalesItemModel> items = [];

  @override
  void initState() {
    super.initState();
    _addNewItem();
  }

  void _addNewItem() {
    setState(() {
      items.add(SalesItemModel(id: DateTime.now().millisecondsSinceEpoch.toString()));
    });
    _notifyChanges();
  }

  void _removeItem(String id) {
    if (items.length > 1) {
      setState(() {
        items.removeWhere((item) => item.id == id);
      });
      _notifyChanges();
    }
  }

  void _updateItem(int index, String field, dynamic value) {
    setState(() {
      final item = items[index];
      
      if (field == 'product_id') {
        item.productId = value.toString();
        final selectedProduct = widget.products.firstWhere(
          (p) => p['id'].toString() == value.toString(),
          orElse: () => null,
        );
        
        if (selectedProduct != null) {
          item.availableTrays = (selectedProduct['available_trays'] ?? 0).toDouble();
          item.purRate = (selectedProduct['pur_rate'] ?? 0).toDouble();
          item.expRate = (selectedProduct['exp_rate'] ?? 0).toDouble();
        } else {
          item.availableTrays = 0;
          item.purRate = 0;
          item.expRate = 0;
        }
        item.totalCost = item.eggs * (item.purRate + item.expRate);
      } else if (field == 'eggs') {
        final eggCount = double.tryParse(value.toString()) ?? 0;
        item.eggs = eggCount;
        item.trays = (eggCount / 30).ceilToDouble();
        item.totalCost = eggCount * (item.purRate + item.expRate);
      } else if (field == 'trays') {
        final trayCount = double.tryParse(value.toString()) ?? 0;
        item.trays = trayCount;
        item.eggs = trayCount * 30;
        item.totalCost = item.eggs * (item.purRate + item.expRate);
      }
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    if (widget.onItemsChanged != null) {
      widget.onItemsChanged!(items);
    }
  }

  double get totalEggs => items.fold(0, (sum, item) => sum + item.eggs);
  double get totalTrays => items.fold(0, (sum, item) => sum + item.trays);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sales Items",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              GestureDetector(
                onTap: _addNewItem,
                child: Row(
                  children: [
                    const Icon(Icons.add, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "Add Item",
                      style: TextStyle(
                        color: Colors.amber.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade100, thickness: 1),
          const SizedBox(height: 16),

          // Items List
          ...items.asMap().entries.map((entry) {
            int index = entry.key;
            SalesItemModel item = entry.value;
            return _buildItemCard(index, item);
          }),

          const SizedBox(height: 10),

          // Totals Summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Items Summary",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                    fontSize: 15,
                  ),
                ),
                Text(
                  "${totalEggs.toInt()} Eggs / ${totalTrays.toInt()} Trays",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(int index, SalesItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of individual item card (if multiple, show delete)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Product Category *",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              if (items.length > 1)
                GestureDetector(
                  onTap: () => _removeItem(item.id),
                  child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text("Select option", style: TextStyle(color: Color(0xFF94A3B8))),
                value: item.productId,
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                items: widget.products.map((p) {
                  return DropdownMenuItem<String>(
                    value: p['id'].toString(),
                    child: Text(p['name'] ?? p['category_name'] ?? 'Unknown'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) _updateItem(index, 'product_id', val);
                },
              ),
            ),
          ),

          if (item.productId != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: "Eggs (Entry)",
                    value: item.eggs > 0 ? item.eggs.toInt().toString() : "",
                    onChanged: (val) => _updateItem(index, 'eggs', val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: "Trays (Auto)",
                    value: item.trays > 0 ? item.trays.toInt().toString() : "",
                    onChanged: (val) => _updateItem(index, 'trays', val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _infoRow("Available", "${item.availableTrays.toInt()} Trays"),
                  const SizedBox(height: 6),
                  _infoRow("Pur/Egg Rate", "₹${item.purRate.toStringAsFixed(2)}"),
                  const SizedBox(height: 6),
                  _infoRow("Exp/Per Egg", "₹${item.expRate.toStringAsFixed(2)}"),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade300, height: 1),
                  const SizedBox(height: 8),
                  _infoRow(
                    "Total Cost",
                    "₹${item.totalCost.toStringAsFixed(2)}",
                    isBold: true,
                    valueColor: Colors.blue.shade700,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.shade300),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isBold ? const Color(0xFF334155) : const Color(0xFF64748B),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: valueColor ?? (isBold ? const Color(0xFF0F172A) : const Color(0xFF475569)),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
