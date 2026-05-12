import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/Distribution/widget/dispatch_planning_widget.dart';
import 'package:proteinova_connect/services/dispatch_service.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';


class DispatchPlanningPage extends StatefulWidget {
  const DispatchPlanningPage({super.key});

  @override
  State<DispatchPlanningPage> createState() => _DispatchPlanningPageState();
}

class _DispatchPlanningPageState extends State<DispatchPlanningPage> {
  final TextEditingController _dispatchDateController = TextEditingController();
  final TextEditingController _arrivalDateController = TextEditingController();
  final TextEditingController _vehicleNoController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  final TextEditingController _plasticTraysController = TextEditingController(text: "0");
  final TextEditingController _paperTraysController = TextEditingController(text: "0");

  int? _selectedBranchId;
  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _availableStock = [];
  
  List<Map<String, dynamic>> _dispatchItems = [
    {'category': null, 'available_eggs': 0, 'eggs_to_dispatch': 0, 'trays_to_dispatch': 0}
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dispatchDateController.text = DateTime.now().toString().split(' ').first;
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final branches = await DispatchService.fetchBranches();
      final stock = await DispatchService.fetchWarehouseStock();
      if (mounted) {
        setState(() {
          _branches = branches;
          _availableStock = stock;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading initial data: $e")),
        );
      }
    }
  }

  void _addItem() {
    setState(() {
      _dispatchItems.add({
        'category': null,
        'available_eggs': 0,
        'eggs_to_dispatch': 0,
        'trays_to_dispatch': 0
      });
    });
  }

  void _updateItem(int index, {String? category, int? eggs}) {
    setState(() {
      if (category != null) {
        _dispatchItems[index]['category'] = category;
        final stock = _availableStock.firstWhere(
          (s) => s['category'] == category,
          orElse: () => {'total_eggs': 0},
        );
        _dispatchItems[index]['available_eggs'] = stock['total_eggs'];
      }
      if (eggs != null) {
        _dispatchItems[index]['eggs_to_dispatch'] = eggs;
        _dispatchItems[index]['trays_to_dispatch'] = (eggs / 30).ceil();
      }
    });
  }

  int get _totalEggs => _dispatchItems.fold(0, (sum, item) => sum + (item['eggs_to_dispatch'] as int));
  int get _totalProductTrays => _dispatchItems.fold(0, (sum, item) => sum + (item['trays_to_dispatch'] as int));
  int get _emptyPlasticTrays => int.tryParse(_plasticTraysController.text) ?? 0;
  int get _emptyPaperTrays => int.tryParse(_paperTraysController.text) ?? 0;
  int get _grandTotalTrays => _totalProductTrays + _emptyPlasticTrays + _emptyPaperTrays;

  Future<void> _submitDispatch() async {
    if (_selectedBranchId == null ||
        _vehicleNoController.text.isEmpty ||
        _driverNameController.text.isEmpty ||
        _dispatchDateController.text.isEmpty ||
        _arrivalDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final activeItems = _dispatchItems
        .where((i) => i['category'] != null && i['eggs_to_dispatch'] > 0)
        .toList();

    if (activeItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one item with eggs")),
      );
      return;
    }

    // Stock Validation
    for (var item in activeItems) {
      if (item['eggs_to_dispatch'] > item['available_eggs']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Insufficient stock for ${item['category']}. Available: ${item['available_eggs']}"),
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final dispatchData = {
        "branch_id": _selectedBranchId,
        "dispatch_date": _dispatchDateController.text,
        "expected_arrival_date": _arrivalDateController.text,
        "vehicle_number": _vehicleNoController.text,
        "driver_name": _driverNameController.text,
        "driver_number": _driverNumberController.text,
        "notes": _notesController.text,
        "empty_plastic_trays": _emptyPlasticTrays,
        "empty_paper_trays": _emptyPaperTrays,
        "dispatch_items": activeItems
            .map((i) => {
                  "product_category": i['category'],
                  "quantity": i['eggs_to_dispatch'],
                  "quantity_trays": i['trays_to_dispatch'],
                })
            .toList(),
      };

      final success = await DispatchService.createDispatch(dispatchData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dispatch created successfully!")),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create dispatch. Please check your connection.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background1,

      appBar: AppBar(
        backgroundColor: AppColors.background1,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),

        titleSpacing: 0,

        title: const Text(
          "Dispatch Planning",
          style: AppTextStyles.headingText22,
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// TITLE
              const Text(
                "New Dispatch",
                style: AppTextStyles.headingText25,
              ),

              const SizedBox(height: 4),

              Text(
                "Manage dispatching to update inventory",
                style: AppTextStyles.bodyText12,
              ),

              const SizedBox(height: 22),

              /// SHOP & DISPATCH INFO
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("1", "Shop & Dispatch Info"),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Select Shop *", style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Container(
                                height: 54,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _selectedBranchId,
                                    isExpanded: true,
                                    hint: Text("Select Branch", style: AppTextStyles.bodyText12),
                                    items: _branches.map((b) => DropdownMenuItem<int>(
                                      value: b['id'],
                                      child: Text(b['branch_name'] ?? "", style: const TextStyle(fontSize: 13)),
                                    )).toList(),
                                    onChanged: (val) => setState(() => _selectedBranchId = val),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: buildField(
                            label: "Dispatch Date *",
                            hint: "YYYY-MM-DD",
                            controller: _dispatchDateController,
                            icon: Icons.calendar_today,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 7)),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (picked != null) {
                                setState(() => _dispatchDateController.text =
                                    picked.toString().split(' ').first);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: buildField(
                            label: "Expected Arrival Date *",
                            hint: "YYYY-MM-DD",
                            controller: _arrivalDateController,
                            icon: Icons.calendar_today,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (picked != null) {
                                setState(() => _arrivalDateController.text =
                                    picked.toString().split(' ').first);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: buildField(
                            label: "Vehicle No. *",
                            hint: "TN 32 B 2134",
                            controller: _vehicleNoController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: buildField(
                            label: "Driver Name *",
                            hint: "John Doe",
                            controller: _driverNameController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: buildField(
                            label: "Driver Number *",
                            hint: "9876543210",
                            controller: _driverNumberController,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// ITEMS TO DISPATCH
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: sectionTitle("2", "Items to Dispatch")),
                        GestureDetector(
                          onTap: _addItem,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xffE8C400)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add, size: 16),
                                SizedBox(width: 4),
                                Text("Add Item", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(flex: 4, child: Text("Product", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("Available\n(Eggs)", textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("Eggs\n(Entry)", textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("Trays\n(Auto)", textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    const SizedBox(height: 4),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _dispatchItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _dispatchItems[index];
                        return Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                height: 42,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: item['category'],
                                    isExpanded: true,
                                    hint: const Text("Category", style: TextStyle(fontSize: 11)),
                                    items: _availableStock.map((s) => DropdownMenuItem<String>(
                                      value: s['category'],
                                      child: Text(s['category'] ?? "", style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                                    )).toList(),
                                    onChanged: (val) => _updateItem(index, category: val),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text("${item['available_eggs']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(border: InputBorder.none),
                                  onChanged: (val) => _updateItem(index, eggs: int.tryParse(val) ?? 0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                  color: Colors.grey.shade50,
                                ),
                                child: Center(
                                  child: Text("${item['trays_to_dispatch']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("$_totalEggs Eggs", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text("$_totalProductTrays Trays", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// EMPTY TRAY DISPATCH
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("3", "Empty Tray Dispatch"),
                    const SizedBox(height: 6),
                    Text(
                      "Specify additional empty trays being dispatched along with the product",
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: trayCard(
                              iconColor: Colors.blue,
                              title: "Plastic Trays",
                              subtitle: "(Empty)",
                              desc: "Durable plastic trays used for return purposes",
                              extra: "",
                              controller: _plasticTraysController,
                              onChanged: () => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: trayCard(
                              iconColor: Colors.orange,
                              title: "Paper Trays",
                              subtitle: "(Empty)",
                              desc: "Paper pulp trays used for transport",
                              extra: "Non - Returnable",
                              controller: _paperTraysController,
                              onChanged: () => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// DISPATCH SUMMARY
              buildCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        sectionTitle("4", "Dispatch Summary"),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: const Icon(Icons.description, color: Colors.blue, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    summaryRow("Total Products", "${_dispatchItems.where((i) => i['category'] != null).length} Types"),
                    summaryRow("Total Eggs", "$_totalEggs"),
                    summaryRow("Product Trays", "$_totalProductTrays"),
                    summaryRow("Plastic Trays (Empty Returnable)", "$_emptyPlasticTrays"),
                    summaryRow("Paper Trays (Empty Non-Returnable)", "$_emptyPaperTrays"),
                    summaryRow("Grand Total Trays (Prod + Empty)", "$_grandTotalTrays"),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// OVERALL DISPATCH
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("5", "Overall Dispatch"),
                    const SizedBox(height: 18),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.shield_outlined, size: 20, color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Plastic trays are returnable", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                        SizedBox(height: 8),
                                        Text("Paper trays are non - returnable", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Overall Dispatch",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "$_grandTotalTrays Trays $_totalEggs Eggs",
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// NOTES
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Notes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: "Enter any additional notes...",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// BUTTONS
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300, width: 1.2),
                        ),
                        child: const Center(
                          child: Text("Cancel", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: InkWell(
                      onTap: _isSaving ? null : _submitDispatch,
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xffFFD600),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: _isSaving
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Text("Dispatch Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// CARD
  static Widget buildCard({required Widget child}) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }

  /// SECTION TITLE
  static Widget sectionTitle(String number, String title) {
    return Row(
      children: [
        Container(
          height: 26,
          width: 26,

          decoration: const BoxDecoration(
            color: Color(0xffFFD600),
            shape: BoxShape.circle,
          ),

          child: Center(
            child: Text(
              number,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// FIELD
  static Widget buildField({
    required String label,
    required String hint,
    bool dropdown = false,
    IconData? icon,
    TextEditingController? controller,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: onTap == null && !dropdown,
                    keyboardType: keyboardType,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (dropdown) const Icon(Icons.keyboard_arrow_down),
                if (icon != null) Icon(icon, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  
}
