import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/services/dispatch_service.dart';

class DispatchPlanningPage extends StatefulWidget {
  const DispatchPlanningPage({super.key});

  @override
  State<DispatchPlanningPage> createState() => _DispatchPlanningPageState();
}

class _DispatchItem {
  int id;
  String category;
  int trays;
  int eggs;
  TextEditingController eggController;
  TextEditingController trayController;

  _DispatchItem({
    required this.id,
    this.category = '',
    this.trays = 0,
    this.eggs = 0,
  }) : eggController = TextEditingController(text: eggs.toString()),
       trayController = TextEditingController(text: trays.toString());

  void dispose() {
    eggController.dispose();
    trayController.dispose();
  }
}

class _DispatchPlanningPageState extends State<DispatchPlanningPage> {
  // Form Controllers
  final TextEditingController _dispatchDateController = TextEditingController();
  final TextEditingController _arrivalDateController = TextEditingController();
  final TextEditingController _vehicleNoController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverPhoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _plasticTraysController = TextEditingController(
    text: "0",
  );
  final TextEditingController _paperTraysController = TextEditingController(
    text: "0",
  );

  String? _selectedShopName;
  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _warehouseStock = [];

  final List<_DispatchItem> _items = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _dispatchDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());
    _items.add(_DispatchItem(id: DateTime.now().millisecondsSinceEpoch));
    _fetchInitialData();
  }

  @override
  void dispose() {
    _dispatchDateController.dispose();
    _arrivalDateController.dispose();
    _vehicleNoController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _notesController.dispose();
    _plasticTraysController.dispose();
    _paperTraysController.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    try {
      setState(() => _isLoading = true);
      final branches = await DispatchService.fetchBranches();
      final stock = await DispatchService.fetchWarehouseStock();
      setState(() {
        _branches = branches;
        _warehouseStock = stock;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load initial data";
        _isLoading = false;
      });
    }
  }

  // Item Management
  void _addItem() {
    setState(() {
      _items.add(_DispatchItem(id: DateTime.now().millisecondsSinceEpoch));
    });
  }

  void _removeItem(int id) {
    if (_items.length > 1) {
      setState(() {
        final index = _items.indexWhere((item) => item.id == id);
        if (index != -1) {
          _items[index].dispose();
          _items.removeAt(index);
        }
      });
    }
  }

  void _handleItemChange(int id, String field, dynamic value) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    setState(() {
      if (field == 'category') {
        _items[index].category = value;
      } else if (field == 'trays') {
        final trays = int.tryParse(value.toString()) ?? 0;
        _items[index].trays = trays;
        _items[index].eggs = trays * 30;
        _items[index].eggController.text = _items[index].eggs.toString();
      } else if (field == 'eggs') {
        final eggs = int.tryParse(value.toString()) ?? 0;
        _items[index].eggs = eggs;
        _items[index].trays = (eggs / 30).ceil().toInt();
        _items[index].trayController.text = _items[index].trays.toString();
      }
    });
  }

  Map<String, dynamic> _getAvailableStock(String category) {
    if (category.isEmpty) return {'eggs': 0, 'trays': 0};
    final stockInfo = _warehouseStock.firstWhere(
      (s) => s['category'].toString().toLowerCase() == category.toLowerCase(),
      orElse: () => {'category': category, 'total_eggs': 0},
    );
    final totalEggs = int.tryParse(stockInfo['total_eggs'].toString()) ?? 0;
    return {'eggs': totalEggs, 'trays': (totalEggs / 30).floor()};
  }

  // Summary Calculations
  int get _totalItemTrays => _items.fold(0, (sum, item) => sum + item.trays);
  int get _totalItemEggs => _items.fold(0, (sum, item) => sum + item.eggs);
  int get _grandTotalTrays {
    final plastic = int.tryParse(_plasticTraysController.text) ?? 0;
    final paper = int.tryParse(_paperTraysController.text) ?? 0;
    return _totalItemTrays + plastic + paper;
  }

  Future<void> _handleSubmit() async {
    try {
      setState(() {
        _errorMessage = null;
        _isSaving = true;
      });

      // Validation
      if (_selectedShopName == null ||
          _dispatchDateController.text.isEmpty ||
          _arrivalDateController.text.isEmpty ||
          _vehicleNoController.text.isEmpty ||
          _driverNameController.text.isEmpty ||
          _driverPhoneController.text.isEmpty) {
        throw Exception("Please fill in all required dispatch info fields");
      }

      if (_driverPhoneController.text.length != 10) {
        throw Exception("Driver number must be exactly 10 digits");
      }

      final validItems = _items
          .where((item) => item.category.isNotEmpty && item.trays > 0)
          .toList();

      if (validItems.isEmpty) {
        throw Exception("Please add at least one valid item with trays > 0");
      }

      // Stock Validation
      for (final item in validItems) {
        final available = _getAvailableStock(item.category);
        if (item.trays > (available['trays'] as int)) {
          throw Exception(
            "Insufficient stock for ${item.category}. You entered ${item.trays} trays, but only ${available['trays']} are available.",
          );
        }
      }

      final payload = {
        "shop_name": _selectedShopName,
        "dispatch_date": _dispatchDateController.text,
        "arrival_date": _arrivalDateController.text,
        "vehicle_number": _vehicleNoController.text,
        "driver_name": _driverNameController.text,
        "driver_phone": _driverPhoneController.text,
        "notes": _notesController.text,
        "plastic_trays": int.tryParse(_plasticTraysController.text) ?? 0,
        "paper_trays": int.tryParse(_paperTraysController.text) ?? 0,
        "items": validItems
            .map(
              (item) => {
                "egg_category_grade": item.category,
                "trays": item.trays,
              },
            )
            .toList(),
      };

      final success = await DispatchService.createDispatch(payload);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Dispatch created successfully!")),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception("Failed to create dispatch on server.");
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isSaving = false;
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1000;

    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFFF1F5F9),
=======
      backgroundColor: AppColors.white,

      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),

        titleSpacing: 0,

        title: const Text(
          "Dispatch Planning",
          style: AppTextStyles.headingText21,
        ),
      ),

>>>>>>> c14a7fc04e3a7c011afb5259477d72267e330570
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
<<<<<<< HEAD
                    _buildPageTitle(),
                    if (_errorMessage != null) _buildErrorBanner(),
                    const SizedBox(height: 20),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
=======
                    sectionTitle("1", "Shop & Dispatch Info"),
                    SizedBox(height: getHeight(context, 18)),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Select Shop *",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: getHeight(context, 8)),
                              Container(
                                height: getHeight(context, 54),
                                padding: EdgeInsets.symmetric(
                                  horizontal: getWidth(context, 14),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.light,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _selectedBranchId,
                                    isExpanded: true,
                                    hint: Text(
                                      "Select Branch",
                                      style: AppTextStyles.bodyText12,
                                    ),
                                    items: _branches
                                        .map(
                                          (b) => DropdownMenuItem<int>(
                                            value: b['id'],
                                            child: Text(
                                              b['branch_name'] ?? "",
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => _selectedBranchId = val),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: getWidth(context, 12)),
                        Expanded(
                          child: buildField(
                            label: "Dispatch Date *",
                            context,
                            hint: "YYYY-MM-DD",
                            controller: _dispatchDateController,
                            icon: Icons.calendar_today,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 7),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 30),
                                ),
                              );
                              if (picked != null) {
                                setState(
                                  () => _dispatchDateController.text = picked
                                      .toString()
                                      .split(' ')
                                      .first,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: getHeight(context, 16)),
                    Row(
                      children: [
                        Expanded(
                          child: buildField(
                            label: "Expected Arrival Date *",
                            context,
                            hint: "YYYY-MM-DD",
                            controller: _arrivalDateController,
                            icon: Icons.calendar_today,
                            onTap: () async {

                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(
                                  const Duration(days: 1),
                                ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 30),
                                ),
                              );

                              if (picked != null) {
                                setState(
                                  () => _arrivalDateController.text = picked
                                      .toString()
                                      .split(' ')
                                      .first,
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(width: getWidth(context, 12)),
                        Expanded(
                          child: buildField(
                            label: "Vehicle No. *",
                            context,
                            hint: "TN 32 B 2134",
                            controller: _vehicleNoController,

                            /// CAPITAL + NUMBER ONLY
                            inputFormatters: [
                              UpperCaseTextFormatter(),
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Z0-9 ]'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: getHeight(context, 16)),
                    Row(
                      children: [
                        Expanded(
                          child: buildField(
                            label: "Driver Name *",
                            context,
                            hint: "John Doe",
                            controller: _driverNameController,

                            /// ONLY LETTERS + DOT + SPACE
                            inputFormatters: [
                              NameCapitalFormatter(),
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Za-z ]'),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: getWidth(context, 12)),

                        Expanded(
                          child: buildField(
                            label: "Driver Number *",
                            context,
                            hint: "9876543210",
                            controller: _driverNumberController,
                            keyboardType: TextInputType.phone,

                            /// ONLY NUMBERS
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,

                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: getHeight(context, 18)),

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
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(context, 12),
                              vertical: getHeight(context, 8),
                            ),
                            decoration: BoxDecoration(
                              color:AppColors.amber600,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:AppColors.amber600,
                              ),
                            ),
                            child: Row(
>>>>>>> c14a7fc04e3a7c011afb5259477d72267e330570
                              children: [
                                _buildDispatchInfoCard(),
                                const SizedBox(height: 20),
                                _buildItemsCard(),
                                const SizedBox(height: 20),
                                _buildEmptyTraysCard(),
                              ],
                            ),
                          ),
<<<<<<< HEAD
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _buildSummaryCard(),
                                const SizedBox(height: 20),
                                _buildOverallDispatchCard(),
                                const SizedBox(height: 20),
                                _buildNotesSection(),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildDispatchInfoCard(),
                          const SizedBox(height: 20),
                          _buildItemsCard(),
                          const SizedBox(height: 20),
                          _buildEmptyTraysCard(),
                          const SizedBox(height: 20),
                          _buildSummaryCard(),
                          const SizedBox(height: 20),
                          _buildOverallDispatchCard(),
                          const SizedBox(height: 20),
                          _buildNotesSection(),
=======
                        ),
                      ],
                    ),
                    SizedBox(height: getHeight(context, 20)),
                    const Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            "Product",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Available\n(Trays)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Eggs\n(Entry)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "Action",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: getHeight(context, 12)),
                    Divider(color: AppColors.border, thickness: 1),
                    SizedBox(height: getHeight(context, 4)),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _dispatchItems.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: getHeight(context, 12)),
                      itemBuilder: (context, index) {
                        final item = _dispatchItems[index];
                        return Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                height: getHeight(context, 42),
                                padding: EdgeInsets.symmetric(
                                  horizontal: getWidth(context, 10),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.border,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: item['category'],
                                    isExpanded: true,
                                    hint: const Text(
                                      "Category",
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    items: _productCategories.map((cat) {
                                      final stock = _availableStock.firstWhere(
                                        (s) =>
                                            s['category']
                                                .toString()
                                                .toLowerCase() ==
                                            cat.toLowerCase(),
                                        orElse: () => {'total_eggs': 0},
                                      );
                                      final int count =
                                          stock['total_eggs'] ?? 0;

                                      return DropdownMenuItem<String>(
                                        value: cat,
                                        child: Text(
                                          "$cat (${count})",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: count > 0
                                                ? AppColors.green
                                                : AppColors.redAccent,
                                            fontWeight: count > 0
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) =>
                                        _updateItem(index, category: val),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: getWidth(context, 8)),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  "${(item['available_eggs'] / 30).floor()} T",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: (item['available_eggs'] ?? 0) >= 30
                                         ? AppColors.green
                                         : AppColors.redAccent,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: getWidth(context, 8)),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: getHeight(context, 42),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "0",
                                  ),
                                  controller: TextEditingController(
                                    text: item['eggs_to_dispatch'].toString(),
                                  )..selection = TextSelection.collapsed(
                                      offset: item['eggs_to_dispatch'].toString().length,
                                    ),
                                  onChanged: (val) => _updateItem(
                                    index,
                                    eggs: int.tryParse(val) ?? 0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: getWidth(context, 8)),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: getHeight(context, 42),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.border,
                                  ),
                                ),
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "0",
                                  ),
                                  controller: TextEditingController(
                                    text: item['trays_to_dispatch'].toString(),
                                  )..selection = TextSelection.collapsed(
                                      offset: item['trays_to_dispatch'].toString().length,
                                    ),
                                  onChanged: (val) => _updateItem(
                                    index,
                                    trays: int.tryParse(val) ?? 0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: getWidth(context, 8)),
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  if (_dispatchItems.length > 1) {
                                    setState(() {
                                      _dispatchItems.removeAt(index);
                                    });
                                  }
                                },
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.redAccent,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: getHeight(context, 12)),
                    Divider(color: AppColors.border, thickness: 1),
                    SizedBox(height: getHeight(context, 10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$_totalEggs Eggs",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$_totalProductTrays Trays",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: getHeight(context, 18)),

              /// EMPTY TRAY DISPATCH
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("3", "Empty Tray Dispatch"),
                    const SizedBox(height: 6),
                    Text(
                      "Specify additional empty trays being dispatched along with the product",
                      style: AppTextStyles.bodyText13
                    ),
                    SizedBox(height: getHeight(context, 20)),

                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: trayCard(
                              iconColor: AppColors.blue,
                              title: "Plastic Trays",
                              subtitle: "(Empty)",
                              desc:
                                  "Durable plastic trays used for return purposes",
                              extra: "",
                              controller: _plasticTraysController,
                              onChanged: () => setState(() {}),
                            ),
                          ),
                          SizedBox(width: getWidth(context, 12)),
                          Expanded(
                            child: trayCard(
                              iconColor:AppColors.orange,
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

              SizedBox(height: getHeight(context, 18)),

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
                          child:  Icon(
                            Icons.description,
                            color: AppColors.blue,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: getHeight(context, 20)),
                    summaryRow(
                      "Total Products",
                      "${_dispatchItems.where((i) => i['category'] != null).length} Types",
                    ),
                    summaryRow("Total Eggs", "$_totalEggs"),
                    summaryRow("Product Trays", "$_totalProductTrays"),
                    summaryRow(
                      "Plastic Trays (Empty Returnable)",
                      "$_emptyPlasticTrays",
                    ),
                    summaryRow(
                      "Paper Trays (Empty Non-Returnable)",
                      "$_emptyPaperTrays",
                    ),
                    summaryRow(
                      "Grand Total Trays (Prod + Empty)",
                      "$_grandTotalTrays",
                    ),
                  ],
                ),
              ),

              SizedBox(height: getHeight(context, 18)),

              /// OVERALL DISPATCH
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("5", "Overall Dispatch"),
                    SizedBox(height: getHeight(context, 18)),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:  AppColors.border,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.shield_outlined,
                                      size: 20,
                                      color:  AppColors.border,
                                    ),
                                  ),
                                  SizedBox(width: getWidth(context, 10)),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Plastic trays are returnable",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: getHeight(context, 8)),
                                        const Text(
                                          "Paper trays are non - returnable",
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
                            ),
                          ),
                          SizedBox(width: getWidth(context, 12)),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.green),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppColors.green,
                                        size: 20,
                                      ),
                                      SizedBox(width: getWidth(context, 8)),
                                      const Expanded(
                                        child: Text(
                                          "Overall Dispatch",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AppColors.green,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: getHeight(context, 12)),
                                  Text(
                                    "$_grandTotalTrays Trays $_totalEggs Eggs",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
>>>>>>> c14a7fc04e3a7c011afb5259477d72267e330570
                        ],
                      ),
                    const SizedBox(height: 40),
                    _buildActionButtons(),
                  ],
                ),
              ),
<<<<<<< HEAD
            ),
          ],
=======

              SizedBox(height: getHeight(context, 18)),

              /// NOTES
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Notes",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: getHeight(context, 18)),
                    Container(
                      width: double.infinity,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration:  InputDecoration(
                          hintText: "Enter any additional notes...",
                          hintStyle: AppTextStyles.bodyText13,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: getHeight(context, 24)),

              /// BUTTONS
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: getHeight(context, 58),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Cancel",
                            style: AppTextStyles.bodyText14dark
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: getWidth(context, 14)),
                  Expanded(
                    child: InkWell(
                      onTap: _isSaving ? null : _submitDispatch,
                      child: Container(
                        height: getHeight(context, 58),
                        decoration: BoxDecoration(
                          color: AppColors.amber600,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: _isSaving
                              ? SizedBox(
                                  height: getHeight(context, 20),
                                  width: getWidth(context, 20),

                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.dark,
                                  ),
                                )
                              : const Text(
                                  "Dispatch Now",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: getHeight(context, 30)),
            ],
          ),
>>>>>>> c14a7fc04e3a7c011afb5259477d72267e330570
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
<<<<<<< HEAD
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          const SizedBox(width: 10),
          const Text(
            "Dispatch Planning",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
=======
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.09),
            offset: const Offset(0, 4),
>>>>>>> c14a7fc04e3a7c011afb5259477d72267e330570
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
=======
  /// SECTION TITLE
  static Widget sectionTitle(String number, String title) {
    return Row(
      children: [
        Container(
          height: 26,
          width: 26,

          decoration: const BoxDecoration(
            color:AppColors.amber600,
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

>>>>>>> c14a7fc04e3a7c011afb5259477d72267e330570
        Text(
          "New Dispatch",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 5),
        Text(
          "Manage dispatching to update inventory",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF87171)),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(
          color: Color(0xFFDC2626),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(height: 30),
          child,
        ],
      ),
    );
  }

  Widget _buildDispatchInfoCard() {
    return _buildCard(
      title: "Select shop & Dispatch info",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  "Select Shop *",
                  _selectedShopName,
                  _branches.map((b) => b['branch_name'].toString()).toList(),
                  (val) {
                    setState(() => _selectedShopName = val);
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildDateField(
                  "Dispatch Date *",
                  _dispatchDateController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  "Expected Arrival Date *",
                  _arrivalDateController,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  "Vehicle No. *",
                  _vehicleNoController,
                  hint: "TN 32 B 2134",
                  uppercase: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Driver Name *",
                  _driverNameController,
                  hint: "John Doe",
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  "Driver Number *",
                  _driverPhoneController,
                  hint: "9876543210",
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildItemsCard() {
    return _buildCard(
      title: "",
      child: Container(
        width: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
=======
        SizedBox(height: getHeight(context, 8)),

        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),

          child: Container(
            height: getHeight(context, 48),

            padding: EdgeInsets.symmetric(horizontal: getWidth(context, 14)),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),

              border: Border.all(color:AppColors.border),
            ),

            child: Row(
>>>>>>> c14a7fc04e3a7c011afb5259477d72267e330570
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      "2",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Items to Dispatch",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFFD700)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: _addItem,
                    child: Row(
                      children: const [
                        Icon(Icons.add, size: 14, color: Colors.black),
                        SizedBox(width: 2),
                        Text(
                          "Add Item",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            DataTable(
              columnSpacing: 8,
              horizontalMargin: 0,
              dividerThickness: 0,
              headingRowHeight: 40,
              columns: const [
                DataColumn(
                  label: Text(
                    "Product",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Available\n(Trays)",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Eggs\n(Entry)",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Trays\n(Entry)",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Action",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                  ),
                ),
              ],
              rows: _items.map((item) {
                final available = _getAvailableStock(item.category);
                return DataRow(
                  cells: [
                    DataCell(
                      _buildTableDropdown(
                        item.category,
                        (val) => _handleItemChange(item.id, 'category', val),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(
                          "${available['trays']} T",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      _buildTableInput(
                        item.eggController,
                        (val) => _handleItemChange(item.id, 'eggs', val),
                      ),
                    ),
                    DataCell(
                      _buildTableInput(
                        item.trayController,
                        (val) => _handleItemChange(item.id, 'trays', val),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _removeItem(item.id),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      Text(
                        "$_totalItemEggs Eggs",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "$_totalItemTrays Trays",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
  }

  Widget _buildEmptyTraysCard() {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1000;
    return _buildCard(
      title: "Empty Tray Dispatch",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Specify additional empty trays being dispatched along with the product",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: [
              SizedBox(
                width: isWide
                    ? (size.width * 0.7 - 65) / 2
                    : (size.width > 600
                          ? (size.width - 70) / 2
                          : double.infinity),
                child: _buildTrayTypeBox(
                  "Plastic Trays",
                  "(Empty)",
                  "Returnable",
                  "Durable plastic trays used for return purposes",
                  _plasticTraysController,
                  Colors.green,
                ),
              ),
              SizedBox(
                width: isWide
                    ? (size.width * 0.7 - 65) / 2
                    : (size.width > 600
                          ? (size.width - 70) / 2
                          : double.infinity),
                child: _buildTrayTypeBox(
                  "Paper Trays",
                  "(Empty)",
                  "Non-Returnable",
                  "Paper pulp trays used for transport",
                  _paperTraysController,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return _buildCard(
      title: "Dispatch Summary",
      trailing: const Icon(Icons.description_outlined, color: Colors.blue),
      child: Column(
        children: [
          _summaryRow(
            "Total Products",
            "${_items.where((i) => i.category.isNotEmpty).length} Types",
          ),
          _summaryRow("Total Eggs", _totalItemEggs.toString()),
          _summaryRow("Product Trays", _totalItemTrays.toString()),
          _summaryRow("Plastic Trays (Empty)", _plasticTraysController.text),
          _summaryRow("Paper Trays (Empty)", _paperTraysController.text),
          const Divider(height: 30),
          _summaryRow(
            "Grand Total Trays",
            _grandTotalTrays.toString(),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOverallDispatchCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.verified_user_outlined, color: Colors.blue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Plastic trays are returnable. Paper trays are non-returnable.",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 10),
              const Text(
                "Overall Dispatch",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                "$_grandTotalTrays Trays",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Text(
                "$_totalItemEggs Eggs",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildCard(
      title: "Notes",
      child: TextField(
        controller: _notesController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: "Enter any additional notes...",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          height: 50,
          width: 200,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Dispatch Now",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // Helper UI Builders
  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: const Text("Select shop"),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              controller.text = DateFormat('yyyy-MM-dd').format(date);
            }
          },
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool uppercase = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (val) {
            if (uppercase) controller.text = val.toUpperCase();
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableDropdown(String value, Function(String?) onChanged) {
    final categories = [
      "White large",
      "White correct size",
      "white export",
      "white medium",
      "white pullet",
      "white small eggs",
      "Brown eggs",
      "country eggs",
      "quail eggs",
      "duck eggs",
    ];
    return Container(
      width: 100,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value.isEmpty ? null : value,
          hint: const Text(
            "Category",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          items: categories
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 10)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTableInput(
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTrayTypeBox(
    String title,
    String tag,
    String badge,
    String desc,
    TextEditingController controller,
    Color badgeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 5),
              Text(
                tag,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: badgeColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const Divider(height: 20),
          Row(
            children: [
              const Text("Trays", style: TextStyle(fontSize: 12)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
