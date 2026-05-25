import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/services/dispatch_service.dart';

class DispatchPlanningPage extends StatefulWidget {
  const DispatchPlanningPage({super.key});

  @override
  State<DispatchPlanningPage> createState() => _DispatchPlanningPageState();
}

class PaymentRow {
  String id;
  String method; // 'Cash', 'UPI', 'Card', 'RTGS/NEFT', 'Credit'
  double? amount;
  String? app; // for UPI: 'Google Pay', 'PhonePe', 'Paytm', 'Other'
  String? reference;
  String? notes;
  String? cashPersonName;
  String? cashContactNumber;
  String? bankAccountName;

  PaymentRow({
    required this.id,
    this.method = 'Cash',
    this.amount,
    this.app = 'Google Pay',
    this.reference = '',
    this.notes = '',
    this.cashPersonName = '',
    this.cashContactNumber = '',
    this.bankAccountName = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method,
      'amount': amount?.toString() ?? '',
      'app': app ?? '',
      'reference': reference ?? '',
      'notes': notes ?? '',
      'cash_person_name': cashPersonName ?? '',
      'cash_contact_number': cashContactNumber ?? '',
      'bank_account_name': bankAccountName ?? '',
    };
  }
}

class DispatchItem {
  String id;
  String category;
  int trays;
  int eggs;
  TextEditingController trayController;
  TextEditingController eggController;

  DispatchItem({
    required this.id,
    this.category = '',
    this.trays = 0,
    this.eggs = 0,
  })  : trayController = TextEditingController(text: trays == 0 ? '' : trays.toString()),
        eggController = TextEditingController(text: eggs == 0 ? '' : eggs.toString());

  void dispose() {
    trayController.dispose();
    eggController.dispose();
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
  final TextEditingController _plasticTraysController = TextEditingController(text: "0");
  final TextEditingController _paperTraysController = TextEditingController(text: "0");

  // Customer Form Controllers
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerNumberController = TextEditingController();
  final TextEditingController _salesDateController = TextEditingController();

  String _dispatchType = 'branch'; // 'branch' or 'customer'
  String? _selectedShopName;

  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _warehouseStock = [];
  List<Map<String, dynamic>> _costPreview = [];
  final List<DispatchItem> _items = [];
  final List<PaymentRow> _payments = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dispatchDateController.text = todayStr;
    _salesDateController.text = todayStr;
    
    // Add default initial item and payment row
    _items.add(DispatchItem(id: DateTime.now().millisecondsSinceEpoch.toString()));
    _payments.add(PaymentRow(id: DateTime.now().millisecondsSinceEpoch.toString()));
    
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
    _customerNameController.dispose();
    _customerNumberController.dispose();
    _salesDateController.dispose();
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

  Future<void> _fetchCostPreview() async {
    final validItems = _items
        .where((item) => item.category.isNotEmpty && item.trays > 0)
        .toList();

    if (validItems.isEmpty) {
      setState(() {
        _costPreview = [];
      });
      return;
    }

    try {
      final itemsParam = jsonEncode(validItems.map((i) => {
        'grade': i.category,
        'trays': i.trays,
      }).toList());

      final dio = DioClient().dio;
      final response = await dio.get(
        '/api/purchase/dispatch-cost-preview',
        queryParameters: {'items': itemsParam},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _costPreview = List<Map<String, dynamic>>.from(data['cost_preview'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Error fetching cost preview: $e");
    }
  }

  Future<void> _handleShopChange(String? selectedShop) async {
    setState(() {
      _selectedShopName = selectedShop;
    });

    if (selectedShop == null || selectedShop.isEmpty) {
      _vehicleNoController.clear();
      _driverNameController.clear();
      _driverPhoneController.clear();
      return;
    }

    try {
      final dio = DioClient().dio;
      final response = await dio.get(
        '/api/dispatch/dashboard',
        queryParameters: {
          'search': selectedShop,
          'limit': 1,
        },
      );

      if (response.statusCode == 200) {
        final activeDispatches = response.data['active_dispatches'] as List?;
        final lastDispatch = activeDispatches != null && activeDispatches.isNotEmpty
            ? activeDispatches[0]
            : null;

        if (lastDispatch != null) {
          final vd = lastDispatch['vehicle_driver']?.toString() ?? "";
          final regExp = RegExp(r'^(.*?)(?:\s*\((.*?)\))?$');
          final match = regExp.firstMatch(vd);

          if (match != null) {
            if (match.group(1) != null) {
              _vehicleNoController.text = match.group(1)!.trim();
            }
            if (match.group(2) != null) {
              _driverNameController.text = match.group(2)!.trim();
            }
          }

          final b = _branches.firstWhere(
            (branch) => branch['branch_name'].toString() == selectedShop,
            orElse: () => {},
          );
          if (b.isNotEmpty && b['contact_number'] != null) {
            _driverPhoneController.text = b['contact_number'].toString();
          }
        } else {
          final b = _branches.firstWhere(
            (branch) => branch['branch_name'].toString() == selectedShop,
            orElse: () => {},
          );
          if (b.isNotEmpty) {
            _driverPhoneController.text = b['contact_number']?.toString() ?? '';
            final email = b['branch_manager_email']?.toString() ?? '';
            _driverNameController.text = email.isNotEmpty ? email.split('@')[0] : 'Manager';
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching last dispatch data: $e");
    }
    setState(() {});
  }

  Map<String, dynamic>? _getCostForGrade(String grade, int trays) {
    if (grade.isEmpty || trays <= 0) return null;
    try {
      return _costPreview.firstWhere(
        (c) =>
            c['grade'].toString().toLowerCase().trim() == grade.toLowerCase().trim() &&
            (int.tryParse(c['trays_requested'].toString()) ?? 0) == trays,
      );
    } catch (_) {
      return null;
    }
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

  // Item Management
  void _addItem() {
    setState(() {
      _items.add(DispatchItem(id: DateTime.now().millisecondsSinceEpoch.toString()));
    });
  }

  void _removeItem(String id) {
    if (_items.length > 1) {
      setState(() {
        final index = _items.indexWhere((item) => item.id == id);
        if (index != -1) {
          _items[index].dispose();
          _items.removeAt(index);
        }
      });
      _fetchCostPreview();
    } else {
      setState(() {
        _items[0].dispose();
        _items[0] = DispatchItem(id: DateTime.now().millisecondsSinceEpoch.toString());
      });
      _fetchCostPreview();
    }
  }

  void _handleItemChange(String id, String field, dynamic value) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    setState(() {
      if (field == 'category') {
        _items[index].category = value;
      } else if (field == 'trays') {
        final trays = int.tryParse(value.toString()) ?? 0;
        _items[index].trays = trays;
        _items[index].eggs = trays * 30;
        _items[index].eggController.text = trays == 0 ? '' : _items[index].eggs.toString();
      } else if (field == 'eggs') {
        final eggs = int.tryParse(value.toString()) ?? 0;
        _items[index].eggs = eggs;
        _items[index].trays = (eggs / 30).ceil();
        _items[index].trayController.text = _items[index].trays == 0 ? '' : _items[index].trays.toString();
      }
    });

    _fetchCostPreview();
  }

  // Payment Management
  void _addPaymentRow() {
    setState(() {
      _payments.add(PaymentRow(id: DateTime.now().millisecondsSinceEpoch.toString()));
    });
  }

  void _removePaymentRow(String id) {
    if (_payments.length > 1) {
      setState(() {
        _payments.removeWhere((p) => p.id == id);
      });
    }
  }

  void _handlePaymentChange(String id, String field, dynamic value) {
    final index = _payments.indexWhere((p) => p.id == id);
    if (index == -1) return;

    setState(() {
      if (field == 'method') {
        _payments[index].method = value;
        // reset fields
        _payments[index].amount = null;
        _payments[index].app = 'Google Pay';
        _payments[index].reference = '';
        _payments[index].cashPersonName = '';
        _payments[index].cashContactNumber = '';
      } else if (field == 'amount') {
        _payments[index].amount = double.tryParse(value.toString());
      } else if (field == 'app') {
        _payments[index].app = value;
      } else if (field == 'reference') {
        _payments[index].reference = value;
      } else if (field == 'cash_person_name') {
        _payments[index].cashPersonName = value;
      } else if (field == 'cash_contact_number') {
        _payments[index].cashContactNumber = value;
      }
    });
  }

  // Calculations
  int get _totalItemTrays => _items.fold(0, (sum, item) => sum + item.trays);
  int get _totalItemEggs => _items.fold(0, (sum, item) => sum + item.eggs);
  
  int get _grandTotalTrays {
    final plastic = int.tryParse(_plasticTraysController.text) ?? 0;
    final paper = int.tryParse(_paperTraysController.text) ?? 0;
    return _totalItemTrays + plastic + paper;
  }

  double get _grandTotalAmount {
    double total = 0;
    for (var item in _items) {
      final costEntry = _getCostForGrade(item.category, item.trays);
      if (costEntry != null) {
        total += double.tryParse(costEntry['total_cost'].toString()) ?? 0;
      }
    }
    return total;
  }

  double get _totalPaidAmount {
    double total = 0;
    for (var p in _payments) {
      if (p.method != 'Credit') {
        total += p.amount ?? 0;
      }
    }
    return total;
  }

  double get _balanceOrDebt {
    return (_grandTotalAmount - _totalPaidAmount).clamp(0.0, double.infinity);
  }

  Future<void> _handleSubmit() async {
    try {
      setState(() {
        _errorMessage = null;
        _isSaving = true;
      });

      // Validation
      if (_dispatchType == 'branch') {
        if (_selectedShopName == null || _selectedShopName!.isEmpty) {
          throw Exception("Please select a branch");
        }
        if (_dispatchDateController.text.isEmpty ||
            _arrivalDateController.text.isEmpty ||
            _vehicleNoController.text.isEmpty ||
            _driverNameController.text.isEmpty ||
            _driverPhoneController.text.isEmpty) {
          throw Exception("Please fill in all required dispatch info fields");
        }
        if (_driverPhoneController.text.length != 10) {
          throw Exception("Driver number must be exactly 10 digits");
        }
      } else {
        if (_customerNameController.text.isEmpty ||
            _customerNumberController.text.isEmpty ||
            _salesDateController.text.isEmpty) {
          throw Exception("Please fill in all customer details");
        }
        if (_customerNumberController.text.length != 10) {
          throw Exception("Customer number must be exactly 10 digits");
        }
        if (_dispatchDateController.text.isEmpty) {
          throw Exception("Please fill in the sales date");
        }
      }

      final validItems = _items
          .where((item) => item.category.isNotEmpty && item.trays > 0)
          .toList();

      if (validItems.isEmpty) {
        throw Exception("Please add at least one valid item with trays > 0");
      }

      // Check stock
      for (final item in validItems) {
        final available = _getAvailableStock(item.category);
        final availTrays = available['trays'] as int;
        if (item.trays > availTrays) {
          throw Exception(
            "Insufficient stock for ${item.category}. You entered ${item.trays} trays, but only $availTrays are available.",
          );
        }
      }

      // Payment Validations
      for (final p in _payments) {
        if (p.amount == null || p.amount! <= 0) {
          throw Exception("Please enter a valid amount for all payment methods");
        }
        if (p.method == "Cash") {
          if (p.cashPersonName == null || p.cashPersonName!.trim().isEmpty) {
            throw Exception("Cash Received Person Name is required for Cash payments.");
          }
          if (p.cashContactNumber == null || p.cashContactNumber!.trim().isEmpty) {
            throw Exception("Contact Number is required for Cash payments.");
          }
          if (p.cashContactNumber!.trim().length != 10) {
            throw Exception("Cash Contact Number must be exactly 10 digits.");
          }
        }
      }

      // Normalize payment details
      final totalPaid = _totalPaidAmount;
      final totalDebt = _payments
          .where((p) => p.method == "Credit")
          .fold<double>(0.0, (sum, p) => sum + (p.amount ?? 0));
      final finalMethod = _payments.length > 1 ? "SPLIT" : _payments[0].method;
      final upiApp = _payments.length == 1 && _payments[0].method == "UPI" ? _payments[0].app : null;

      final payload = {
        "shop_name": _dispatchType == 'branch'
            ? _selectedShopName
            : "Customer: ${_customerNameController.text}",
        "dispatch_date": _dispatchDateController.text,
        "arrival_date": _dispatchType == 'branch' ? _arrivalDateController.text : _dispatchDateController.text,
        "vehicle_number": _dispatchType == 'branch' ? _vehicleNoController.text : "SELF",
        "driver_name": _dispatchType == 'branch' ? _driverNameController.text : "CUSTOMER",
        "driver_phone": _dispatchType == 'branch' ? _driverPhoneController.text : "0000000000",
        "notes": _dispatchType == 'customer'
            ? "Customer Number: ${_customerNumberController.text} | Sales Date: ${_salesDateController.text}\n${_notesController.text}"
            : _notesController.text,
        "plastic_trays": int.tryParse(_plasticTraysController.text) ?? 0,
        "paper_trays": int.tryParse(_paperTraysController.text) ?? 0,
        "items": validItems.map((item) => {
          "egg_category_grade": item.category,
          "trays": item.trays,
        }).toList(),
        "dispatch_type": _dispatchType,
        "payment_method": finalMethod,
        "upi_app": upiApp,
        "other_upi_details": jsonEncode(_payments.map((p) => p.toJson()).toList()),
        "payment_amount": totalPaid,
        "debt_amount": totalDebt,
        "customer_name": _dispatchType == 'customer' ? _customerNameController.text : null,
        "customer_number": _dispatchType == 'customer' ? _customerNumberController.text : null,
        "sales_date": _dispatchType == 'customer' ? _salesDateController.text : null,
        "login_user_id": 1, // Default login user id
      };

      final dio = DioClient().dio;
      final response = await dio.post('/api/dispatch', data: payload);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final created = response.data['data'];

        final createdItems = validItems.map((item) {
          final costEntry = _getCostForGrade(item.category, item.trays);
          final totalCost = costEntry != null ? double.tryParse(costEntry['total_cost'].toString()) ?? 0 : 0.0;
          final eggs = item.eggs;
          return {
            'egg_category_grade': item.category,
            'trays': item.trays,
            'eggs': eggs,
            'total_cost': totalCost,
            'price_per_egg': eggs > 0 ? totalCost / eggs : 0.0,
          };
        }).toList();

        final createdDispatch = {
          'id': created['id'],
          'shop_name': payload['shop_name'],
          'dispatch_date': payload['dispatch_date'],
          'plastic_trays': payload['plastic_trays'],
          'paper_trays': payload['paper_trays'],
          'created_at': created['created_at'] ?? DateTime.now().toIso8601String(),
          'items': createdItems,
        };

        if (mounted) {
          _showSuccessDialog(createdDispatch);
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
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSuccessDialog(Map<String, dynamic> dispatch) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Sales Created Successfully!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Invoice ID: S${dispatch['id']}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      dispatch['shop_name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Date: ${dispatch['dispatch_date']}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ...(dispatch['items'] as List).map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${item['egg_category_grade']} (${item['trays']} T / ${item['eggs']} E)",
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Text(
                                  "₹${(item['total_cost'] as double).toStringAsFixed(2)}",
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Plastic Trays (Empty)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text("${dispatch['plastic_trays']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Paper Trays (Empty)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text("${dispatch['paper_trays']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Grand Total",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              "₹${_grandTotalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Invoice PDF generated and downloaded!")),
                            );
                          },
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text("Download PDF"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blueAccent,
                            side: const BorderSide(color: Colors.blueAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Pop Dialog
                            Navigator.pop(this.context, true); // Pop planning screen and refresh
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Okay, Go back", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.amber600)));
    }

    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1000;

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        titleSpacing: 0,
        title: const Text(
          "Warehouse Sales",
          style: AppTextStyles.headingText21,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              children: [
                                _buildDispatchInfoCard(),
                                const SizedBox(height: 20),
                                _buildItemsCard(),
                                const SizedBox(height: 20),
                                _buildEmptyTraysCard(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _buildSummaryCard(),
                                const SizedBox(height: 20),
                                _buildChoosePaymentCard(),
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
                          _buildChoosePaymentCard(),
                          const SizedBox(height: 20),
                          _buildSummaryCard(),
                          const SizedBox(height: 20),
                          _buildOverallDispatchCard(),
                          const SizedBox(height: 20),
                          _buildNotesSection(),
                        ],
                      ),
                    const SizedBox(height: 40),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Warehouse Sales Entry",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        SizedBox(height: 4),
        Text(
          "Manage sales to update inventory",
          style: TextStyle(color: Colors.grey, fontSize: 13),
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          child,
        ],
      ),
    );
  }

  Widget _buildDispatchInfoCard() {
    return _buildCard(
      title: _dispatchType == 'branch' ? "Select shop & Sales info" : "Customer Details",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  "Sales To *",
                  _dispatchType,
                  [
                    {'value': 'branch', 'label': 'Branch'},
                    {'value': 'customer', 'label': 'Customer'},
                  ],
                  (val) {
                    setState(() {
                      _dispatchType = val ?? 'branch';
                      _selectedShopName = null;
                      _customerNameController.clear();
                      _customerNumberController.clear();
                    });
                  },
                ),
              ),
              const SizedBox(width: 15),
              if (_dispatchType == 'branch')
                Expanded(
                  child: _buildDropdownField(
                    "Select Shop *",
                    _selectedShopName,
                    _branches.map((b) => {'value': b['branch_name'].toString(), 'label': b['branch_name'].toString()}).toList(),
                    (val) => _handleShopChange(val),
                  ),
                )
              else
                Expanded(
                  child: _buildTextField(
                    "Customer Name *",
                    _customerNameController,
                    hint: "Enter Customer Name",
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          if (_dispatchType == 'branch')
            Row(
              children: [
                Expanded(
                  child: _buildDateField("Sales Date *", _dispatchDateController),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDateField("Expected Arrival Date *", _arrivalDateController),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    "Customer Number *",
                    _customerNumberController,
                    hint: "Enter Customer Number",
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDateField("Sales Date *", _salesDateController),
                ),
              ],
            ),
          if (_dispatchType == 'branch') ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    "Vehicle No. *",
                    _vehicleNoController,
                    hint: "TN 32 B 2134",
                    uppercase: true,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTextField(
                    "Driver Name *",
                    _driverNameController,
                    hint: "John Doe",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildTextField(
              "Driver Number *",
              _driverPhoneController,
              hint: "9876543210",
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
          ] else ...[
            const SizedBox(height: 15),
            _buildDateField("Dispatch Date *", _dispatchDateController),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return _buildCard(
      title: "Sales Items",
      trailing: TextButton.icon(
        onPressed: _addItem,
        icon: const Icon(Icons.add, size: 16),
        label: const Text("Add Item"),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFFC107),
        ),
      ),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final available = _getAvailableStock(item.category);
              final costEntry = _getCostForGrade(item.category, item.trays);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildDropdownField(
                            "Product Category *",
                            item.category,
                            [
                              "White large", "White correct size", "white export", 
                              "white medium", "white pullet", "white small eggs", 
                              "Brown eggs", "country eggs", "quail eggs", "duck eggs"
                            ].map((cat) {
                              final avail = _getAvailableStock(cat);
                              return {'value': cat, 'label': "$cat (${avail['eggs'].toString()} eggs)"};
                            }).toList(),
                            (val) => _handleItemChange(item.id, 'category', val),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_items.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _removeItem(item.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (item.category.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Available Trays", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  "${available['trays']} Trays (${available['eggs']} Eggs)",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: available['eggs'] == 0
                                        ? Colors.red
                                        : (available['eggs'] < 500 ? Colors.orange : Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              "Eggs Entry",
                              item.eggController,
                              hint: "0",
                              keyboardType: TextInputType.number,
                              onChanged: (val) => _handleItemChange(item.id, 'eggs', val),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              "Trays Entry",
                              item.trayController,
                              hint: "0",
                              keyboardType: TextInputType.number,
                              onChanged: (val) => _handleItemChange(item.id, 'trays', val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (costEntry != null) ...[
                        const Divider(color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("FIFO Purchase Price (per egg)", style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(
                              "₹${double.parse((costEntry['loads']?[0]?['per_egg_purchase_price'] ?? 0).toString()).toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Expense Rate (per egg)", style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(
                              "₹${double.parse((costEntry['loads']?[0]?['expense_per_egg'] ?? 0).toString()).toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Item Cost", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                            Text(
                              "₹${double.parse((costEntry['total_cost'] ?? 0).toString()).toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Items Summary",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                ),
                Text(
                  "$_totalItemEggs Eggs / $_totalItemTrays Trays",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTraysCard() {
    return _buildCard(
      title: "Empty Tray Sales",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Specify additional empty trays being sold along with the product",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
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
                        children: const [
                          Text("Plastic Trays", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text("(Empty)", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text("Returnable", style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("Trays", style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _plasticTraysController,
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
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
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
                        children: const [
                          Text("Paper Trays", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text("(Empty)", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text("Non-Returnable", style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("Trays", style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _paperTraysController,
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoosePaymentCard() {
    return _buildCard(
      title: "Choose Payment",
      trailing: TextButton.icon(
        onPressed: _addPaymentRow,
        icon: const Icon(Icons.add, size: 16),
        label: const Text("Add Payment"),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFFC107),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Block
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text("Total Amount", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("₹${_grandTotalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                Expanded(
                  child: Column(
                    children: [
                      const Text("Paid Amount", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("₹${_totalPaidAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                Expanded(
                  child: Column(
                    children: [
                      const Text("Balance / Debt", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("₹${_balanceOrDebt.toStringAsFixed(2)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Dynamic Payment Rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _payments.length,
            itemBuilder: (context, index) {
              final p = _payments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                        Text("Payment Entry #${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                        if (_payments.length > 1)
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red, size: 16),
                            onPressed: () => _removePaymentRow(p.id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            "Method",
                            p.method,
                            ['Cash', 'UPI', 'Card', 'RTGS/NEFT', 'Credit'].map((m) => {'value': m, 'label': m}).toList(),
                            (val) => _handlePaymentChange(p.id, 'method', val),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Amount (₹) *", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => _handlePaymentChange(p.id, 'amount', val),
                                  decoration: InputDecoration(
                                    hintText: "0.00",
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Additional Conditional Fields
                    if (p.method == "Cash") ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Received By *", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                SizedBox(
                                  height: 40,
                                  child: TextField(
                                    onChanged: (val) => _handlePaymentChange(p.id, 'cash_person_name', val),
                                    decoration: InputDecoration(
                                      hintText: "Person Name",
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Contact Number *", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                SizedBox(
                                  height: 40,
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    onChanged: (val) => _handlePaymentChange(p.id, 'cash_contact_number', val),
                                    decoration: InputDecoration(
                                      hintText: "9876543210",
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else if (p.method == "UPI") ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              "UPI App *",
                              p.app,
                              ['Google Pay', 'PhonePe', 'Paytm', 'Other'].map((app) => {'value': app, 'label': app}).toList(),
                              (val) => _handlePaymentChange(p.id, 'app', val),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Reference ID", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                SizedBox(
                                  height: 40,
                                  child: TextField(
                                    onChanged: (val) => _handlePaymentChange(p.id, 'reference', val),
                                    decoration: InputDecoration(
                                      hintText: "UPI Transaction ID",
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else if (p.method == "Card" || p.method == "RTGS/NEFT") ...[
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Transaction Reference", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 40,
                            child: TextField(
                              onChanged: (val) => _handlePaymentChange(p.id, 'reference', val),
                              decoration: InputDecoration(
                                hintText: "Reference Number",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return _buildCard(
      title: "Dispatch Summary",
      trailing: const Icon(Icons.description_outlined, color: Colors.blueAccent),
      child: Column(
        children: [
          _summaryRow("Total Products", "${_items.where((i) => i.category.isNotEmpty).length} Types"),
          _summaryRow("Total Eggs", _totalItemEggs.toString()),
          _summaryRow("Product Trays", _totalItemTrays.toString()),
          _summaryRow("Plastic Trays (Empty)", _plasticTraysController.text.isEmpty ? "0" : _plasticTraysController.text),
          _summaryRow("Paper Trays (Empty)", _paperTraysController.text.isEmpty ? "0" : _paperTraysController.text),
          const Divider(height: 30, color: Color(0xFFE2E8F0)),
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.verified_user_outlined, color: Colors.blueAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Plastic trays are returnable. Paper trays are non-returnable.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
          const Divider(height: 30, color: Color(0xFFE2E8F0)),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 10),
              const Text(
                "Overall Sales",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const Spacer(),
              Text(
                "$_grandTotalTrays Trays / $_totalItemEggs Eggs",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
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
              elevation: 0,
            ),
            child: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Sales Create Now",
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

  // Dropdown Field Helper
  Widget _buildDropdownField(
    String label,
    String? value,
    List<Map<String, String>> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value == null || value.isEmpty ? null : value,
              hint: const Text("Select option", style: TextStyle(fontSize: 12, color: Colors.grey)),
              items: items
                  .map((e) => DropdownMenuItem(
                        value: e['value'],
                        child: Text(e['label'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // Date Field Helper
  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
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
              suffixIcon: const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  // Text Field Helper
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool uppercase = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: (val) {
              if (uppercase) {
                controller.value = TextEditingValue(
                  text: val.toUpperCase(),
                  selection: TextSelection.collapsed(offset: val.length),
                );
              }
              if (onChanged != null) onChanged(val);
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
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
              color: const Color(0xFF64748B),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isBold ? 15 : 13,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
