import 'package:flutter/material.dart';

import '../data/asset_repository.dart';
import '../models/asset_model.dart';

Widget addAssetButton(BuildContext context, {VoidCallback? onAssetAdded}) {
  return GestureDetector(
    onTap: () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return AddAssetBottomSheet(onAssetAdded: onAssetAdded);
        },
      );
    },
    child: Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xffFFD600),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: Colors.black),
          SizedBox(width: 8),
          Text(
            "Add New Asset",
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

class AddAssetBottomSheet extends StatefulWidget {
  final VoidCallback? onAssetAdded;
  const AddAssetBottomSheet({super.key, this.onAssetAdded});

  @override
  State<AddAssetBottomSheet> createState() => _AddAssetBottomSheetState();
}

class _AddAssetBottomSheetState extends State<AddAssetBottomSheet> {
  final AssetRepository _repository = AssetRepository();
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final assetIdController = TextEditingController(
    text: "AST-${1000 + (DateTime.now().millisecond)}",
  );

  String selectedCategory = "Equipment";
  String selectedLocation = "Main Warehouse";
  String selectedStatus = "Available";
  bool isSaving = false;

  Future<void> _saveAsset() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter asset name")));
      return;
    }

    setState(() => isSaving = true);
    try {
      final newAsset = AssetModel(
        name: nameController.text,
        assetId: assetIdController.text,
        category: selectedCategory,
        quantity: int.tryParse(quantityController.text) ?? 0,
        location: selectedLocation,
        status: selectedStatus,
      );

      await _repository.createAsset(newAsset);
      if (mounted) {
        widget.onAssetAdded?.call();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Asset added successfully")),
        );
      }
    } catch (e) {
      setState(() => isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.60,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 70,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Add New Asset",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 28),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Divider(color: Colors.grey.shade300, height: 1),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildLabel("Asset Name"),
                      const SizedBox(height: 10),
                      buildField(
                        controller: nameController,
                        hint: "Enter asset name",
                      ),
                      const SizedBox(height: 22),
                      buildLabel("Asset ID"),
                      const SizedBox(height: 10),
                      buildField(
                        controller: assetIdController,
                        hint: "Asset ID",
                        enabled: false,
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel("Category"),
                                const SizedBox(height: 10),
                                _buildDropdown(
                                  value: selectedCategory,
                                  items: [
                                    "Equipment",
                                    "Furniture",
                                    "Vehicle",
                                    "Electronics",
                                  ],
                                  onChanged: (val) =>
                                      setState(() => selectedCategory = val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel("Quantity"),
                                const SizedBox(height: 10),
                                buildField(
                                  controller: quantityController,
                                  hint: "Enter quantity",
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel("Location"),
                                const SizedBox(height: 10),
                                _buildDropdown(
                                  value: selectedLocation,
                                  items: [
                                    "Main Warehouse",
                                    "Office A",
                                    "Office B",
                                    "Chennai Branch",
                                  ],
                                  onChanged: (val) =>
                                      setState(() => selectedLocation = val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel("Status"),
                                const SizedBox(height: 10),
                                _buildDropdown(
                                  value: selectedStatus,
                                  items: [
                                    "Available",
                                    "In Use",
                                    "Maintenance",
                                    "Damaged",
                                  ],
                                  onChanged: (val) =>
                                      setState(() => selectedStatus = val!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: InkWell(
                              onTap: isSaving ? null : _saveAsset,
                              child: Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  color: const Color(0xffFFD600),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: isSaving
                                      ? const CircularProgressIndicator(
                                          color: Colors.black,
                                        )
                                      : const Text(
                                          "Add Asset",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  Widget buildField({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xffF5F5F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
