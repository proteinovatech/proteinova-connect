import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:shimmer/shimmer.dart';
import '../bloc/item_bloc.dart';
import '../bloc/item_state.dart';
import '../bloc/item_event.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  List<Map<String, dynamic>> eggForms = [];
  List<Map<String, dynamic>> trayForms = [];

  @override
  void initState() {
    super.initState();
    context.read<ItemBloc>().add(FetchItemsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Stock updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              eggForms.clear();
              trayForms.clear();
            });
          } else if (state is ItemSubmitFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
          child: BlocBuilder<ItemBloc, ItemState>(
            builder: (context, state) {
              if (state is ItemLoading) {
                return _buildShimmerLoading();
              }

              if (state is ItemError) {
                return Center(
                  child: Text(
                    "Error loading data: ${state.message}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              int plasticTrays = 0;
              int paperTrays = 0;
              int eggs = 0;
              List<dynamic> eggCategories = [];
              List<dynamic> plasticTraysList = [];
              List<dynamic> paperTraysList = [];

              bool isSubmitting = false;

              if (state is ItemLoaded) {
                plasticTrays = state.plasticTrays;
                paperTrays = state.paperTrays;
                eggs = state.eggs;
                eggCategories = state.eggCategories;
                plasticTraysList = state.plasticTraysList;
                paperTraysList = state.paperTraysList;
                isSubmitting = state.isSubmitting;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section matching Asset Management
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: Icon(Icons.arrow_back, size: 24),
                          ),
                        ),
                        SizedBox(width: getWidth(context, 12)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Items Management",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7E6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.verified_user_outlined,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "Warehouse",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: getHeight(context, 24)),

                    // Grid Cards
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                      children: [
                        GestureDetector(
                          onTap: () => _openDetailsModal(
                            context,
                            "Plastic Trays Breakdown",
                            plasticTraysList,
                          ),
                          child: _buildItemCard(
                            title: "Plastic Trays",
                            value: "$plasticTrays",
                            icon: Icons.inventory_2_outlined,
                            iconColor: Colors.blue,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openDetailsModal(
                            context,
                            "Paper Trays Breakdown",
                            paperTraysList,
                          ),
                          child: _buildItemCard(
                            title: "Paper Trays",
                            value: "$paperTrays",
                            icon: Icons.inventory_outlined,
                            iconColor: Colors.orange,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openDetailsModal(
                            context,
                            "Eggs Breakdown",
                            eggCategories,
                          ),
                          child: _buildItemCard(
                            title: "Total Eggs",
                            value: "$eggs",
                            icon: Icons.egg_outlined,
                            iconColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: getHeight(context, 16)),

                    // Dropdowns for Egg and Tray (Dynamic Forms)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildDynamicEggSection(eggCategories),
                    ),
                    SizedBox(height: getHeight(context, 16)),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildDynamicTraySection([
                        ...plasticTraysList,
                        ...paperTraysList,
                      ]),
                    ),
                    SizedBox(height: getHeight(context, 20)),

                    if (eggForms.isNotEmpty || trayForms.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  context.read<ItemBloc>().add(
                                    SubmitStockEvent(
                                      eggForms: eggForms,
                                      trayForms: trayForms,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF0F172A,
                            ), // AppColors.primary
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Submit Stock",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    SizedBox(height: getHeight(context, 40)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            direction: ShimmerDirection.ltr,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          SizedBox(height: getHeight(context, 16)),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            direction: ShimmerDirection.rtl,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          SizedBox(height: getHeight(context, 16)),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: List.generate(
              3,
              (index) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                direction: index % 2 == 0
                    ? ShimmerDirection.ltr
                    : ShimmerDirection.rtl,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetailsModal(
    BuildContext context,
    String title,
    List<dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                if (data.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        "No detailed data available yet.",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: SingleChildScrollView(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1.2),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  "Category/Type",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  "Quantity",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          ...data.map((item) {
                            final categoryName = item is Map
                                ? (item["category"] ?? "Unknown")
                                : "Unknown";
                            final val = item is Map
                                ? (item["total_eggs"] ??
                                      item["quantity"] ??
                                      item["count"] ??
                                      0)
                                : 0;
                            final displayValue =
                                "${int.tryParse(val.toString())?.toString() ?? val}";

                            return TableRow(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFF1F5F9),
                                    width: 1,
                                  ),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    categoryName.toString(),
                                    style: const TextStyle(
                                      color: Color(0xFF334155),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    displayValue,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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
  }

  Widget _buildDynamicEggSection(List<dynamic> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.egg_outlined, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Egg Stock Forms",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.grey, size: 28),
              onPressed: () {
                setState(() {
                  eggForms.add({"category": "", "quantity": ""});
                });
              },
            ),
          ],
        ),
        const Divider(),
        ...eggForms.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> form = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Egg Item ${index + 1}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            eggForms.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownButton<String>(
                      value: form["category"].toString().isEmpty
                          ? null
                          : form["category"],
                      isExpanded: true,
                      hint: const Row(
                        children: [
                          Icon(
                            Icons.egg_outlined,
                            size: 20,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 10),
                          Text("Select Category"),
                        ],
                      ),
                      underline: const SizedBox(),
                      items: categories.map((c) {
                        final catName = c is Map
                            ? (c["category"] ?? "Unknown").toString()
                            : c.toString();
                        return DropdownMenuItem(
                          value: catName,
                          child: Text(catName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          form["category"] = value ?? "";
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        form["quantity"] = val;
                      },
                      decoration: const InputDecoration(
                        hintText: "Enter quantity",
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.numbers,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDynamicTraySection(List<dynamic> trayTypes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Tray Stock Forms",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.grey, size: 28),
              onPressed: () {
                setState(() {
                  trayForms.add({"trayType": "", "quantity": ""});
                });
              },
            ),
          ],
        ),
        const Divider(),
        ...trayForms.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> form = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tray Item ${index + 1}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            trayForms.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownButton<String>(
                      value: form["trayType"].toString().isEmpty
                          ? null
                          : form["trayType"],
                      isExpanded: true,
                      hint: const Row(
                        children: [
                          Icon(
                            Icons.all_inbox_outlined,
                            size: 20,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 10),
                          Text("Select Tray Type"),
                        ],
                      ),
                      underline: const SizedBox(),
                      items: trayTypes.map((t) {
                        final trayName = t is Map
                            ? (t["category"] ?? "Unknown").toString()
                            : t.toString();
                        return DropdownMenuItem(
                          value: trayName,
                          child: Text(trayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          form["trayType"] = value ?? "";
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        form["quantity"] = val;
                      },
                      decoration: const InputDecoration(
                        hintText: "Enter quantity",
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.numbers,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
