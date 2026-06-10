import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/branch/sales/data/datasource/branch_sales_remote_datasource.dart';
import 'package:proteinova_connect/features/branch/tray_returns/bloc/tray_return_bloc.dart';
import 'package:proteinova_connect/features/branch/tray_returns/widget/buildfield1.dart';
import 'package:proteinova_connect/features/branch/tray_returns/widget/conditionbox.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrayRecords extends StatefulWidget {
  const TrayRecords({super.key});

  @override
  State<TrayRecords> createState() => _TrayRecordsState();
}

class _TrayRecordsState extends State<TrayRecords> {
  final TextEditingController _returnFromController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _returnToController = TextEditingController();
  final TextEditingController _trayTypeController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String _selectedSettlementType = "CREDIT";
  String? _customerStatus; // 'found', 'not_found', null
  // ignore: unused_field
  List<String> _warehouses = [];

  int selectedIndex = 0;
  String fileName = "Choose File";
  int? branchId;

  @override
  void initState() {
    super.initState();
    _loadBranchId();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _loadBranchId() async {
    final prefs = await SharedPreferences.getInstance();
    branchId = prefs.getInt("branch_id");
    context.read<TrayReturnBloc>().add(FetchWarehouses());

    setState(() {
      _returnFromController.text = "Customer";
      _trayTypeController.text = "Plastic Tray";
    });
  }

  Future<void> _lookupCustomer(String number) async {
    if (number.length < 10) {
      setState(() => _customerStatus = null);
      return;
    }
    try {
      final ds = BranchSalesRemoteDatasource();
      final customer = await ds.findCustomerByNumber(number: number);
      if (customer != null) {
        setState(() {
          _nameController.text = customer['name'] ?? "";
          _customerStatus = 'found';
        });
      } else {
        setState(() => _customerStatus = 'not_found');
      }
    } catch (e) {
      setState(() => _customerStatus = 'not_found');
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );

      if (result != null) {
        final file = result.files.first;
        if (file.size <= 5 * 1024 * 1024) {
          setState(() {
            fileName = file.name;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("File must be less than 5MB")),
          );
        }
      }
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  void _submit() {
    if (_returnFromController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _qtyController.text.isEmpty ||
        selectedIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final String condition = selectedIndex == 0
        ? "Good"
        : selectedIndex == 1
        ? "Damaged"
        : "Scrap";

    final data = {
      "branch_id": branchId,
      "return_from_type": _returnFromController.text,
      "return_from_name": _nameController.text,
      "return_from_number": _numberController.text,
      "return_date": _dateController.text,
      "return_to": _returnToController.text,
      "tray_type": _trayTypeController.text,
      "quantity": int.tryParse(_qtyController.text) ?? 0,
      "condition": condition.toUpperCase(),
      "amount": double.tryParse(_amountController.text) ?? 0,
      "settlement_type": _selectedSettlementType,
      "remarks": _remarksController.text,
    };

    context.read<TrayReturnBloc>().add(SubmitTrayReturn(data: data));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return BlocListener<TrayReturnBloc, TrayReturnState>(
      listener: (context, state) {
        if (state is TrayReturnSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
          // Refresh list on previous screen
          if (branchId != null) {
            context.read<TrayReturnBloc>().add(
              FetchTrayReturnData(
                branchId: branchId!,
                date: _dateController.text,
              ),
            );
          }
        } else if (state is TrayReturnError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background1,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.background1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Tray Records", style: AppTextStyles.headingText22),
          centerTitle: false,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.03),
                buildDropdownField(
                  "Return from :",
                  "Select Type",
                  ["Customer", "Branch", "Supplier"],
                  value: _returnFromController.text,
                  onChanged: (val) {
                    if (val != null)
                      setState(() => _returnFromController.text = val);
                  },
                ),
                SizedBox(height: size.height * 0.02),
                buildRowField(
                  "Number :",
                  "Enter phone number",
                  controller: _numberController,
                  onChanged: (val) => _lookupCustomer(val),
                ),
                if (_customerStatus != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 130, bottom: 10),
                    child: Text(
                      _customerStatus == 'found'
                          ? "✓ Customer found"
                          : "+ New Customer",
                      style: TextStyle(
                        color: _customerStatus == 'found'
                            ? Colors.green
                            : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                SizedBox(height: size.height * 0.02),
                buildRowField(
                  "Name :",
                  "Customer/Branch Name",
                  controller: _nameController,
                ),
                SizedBox(height: size.height * 0.02),
                buildRowField(
                  "Return Date :",
                  "Select date",
                  controller: _dateController,
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dateController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(pickedDate);
                      });
                    }
                  },
                ),
                SizedBox(height: size.height * 0.02),
                BlocBuilder<TrayReturnBloc, TrayReturnState>(
                  builder: (context, state) {
                    List<String> warehouses = [];
                    if (state is TrayReturnLoaded) {
                      warehouses = state.warehouses
                          .map((w) => w['warehouse_name'].toString())
                          .toSet()
                          .toList();
                      if (_returnToController.text.isEmpty &&
                          warehouses.isNotEmpty) {
                        _returnToController.text = warehouses.first;
                      }
                    }

                    // Fallback to avoid crash if value is not in list
                    if (warehouses.isEmpty) {
                      warehouses = _returnToController.text.isEmpty
                          ? ["Loading..."]
                          : [_returnToController.text];
                    } else if (_returnToController.text.isNotEmpty &&
                        !warehouses.contains(_returnToController.text)) {
                      warehouses.insert(0, _returnToController.text);
                    }

                    return buildDropdownField(
                      "Return to :",
                      "Select Destination",
                      warehouses,
                      value: _returnToController.text,
                      onChanged: (val) {
                        if (val != null)
                          setState(() => _returnToController.text = val);
                      },
                    );
                  },
                ),
                SizedBox(height: size.height * 0.02),
                buildDropdownField(
                  "Tray type :",
                  "Select Tray",
                  ["Plastic Tray", "Paper Tray"],
                  value: _trayTypeController.text,
                  onChanged: (val) {
                    if (val != null)
                      setState(() => _trayTypeController.text = val);
                  },
                ),
                SizedBox(height: size.height * 0.02),
                buildRowField(
                  "Quantity :",
                  "Enter trays count",
                  controller: _qtyController,
                ),
                SizedBox(height: size.height * 0.02),
                buildDropdownField(
                  "Settlement :",
                  "Select Settlement",
                  ["CREDIT", "REFUND"],
                  value: _selectedSettlementType,
                  onChanged: (val) {
                    if (val != null)
                      setState(() => _selectedSettlementType = val);
                  },
                ),
                SizedBox(height: size.height * 0.02),
                buildRowField(
                  "Amount (₹) :",
                  "0",
                  controller: _amountController,
                ),
                SizedBox(height: size.height * 0.02),
                buildRowField(
                  "Remarks :",
                  "Optional",
                  controller: _remarksController,
                ),
                SizedBox(height: size.height * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Conditions", style: AppTextStyles.headingText22),
                    SizedBox(height: size.height * 0.02),
                    Row(
                      children: [
                        Expanded(
                          child: conditionBox(
                            index: 0,
                            selectedIndex: selectedIndex,
                            onTap: () => setState(() => selectedIndex = 0),
                            icon: Icons.check_circle,
                            text: "Good",
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: getWidth(context, 10)),
                        Expanded(
                          child: conditionBox(
                            index: 1,
                            selectedIndex: selectedIndex,
                            onTap: () => setState(() => selectedIndex = 1),
                            icon: Icons.cancel,
                            text: "Damaged",
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(width: getWidth(context, 10)),
                        Expanded(
                          child: conditionBox(
                            index: 2,
                            selectedIndex: selectedIndex,
                            onTap: () => setState(() => selectedIndex = 2),
                            icon: Icons.delete,
                            text: "Scrap",
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // SizedBox(height: size.height * 0.02),
                // Row(
                //   children: [
                //     Text("Attachment", style: AppTextStyles.headingText22),
                //     Text("(Optional)", style: AppTextStyles.bodyText16),
                //   ],
                // ),
                // SizedBox(height: size.height * 0.01),
                // InkWell(
                //   onTap: pickFile,
                //   child: Container(
                //     height: 100,
                //     width: double.infinity,
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 12,
                //       vertical: 8,
                //     ),
                //     decoration: BoxDecoration(
                //       border: Border.all(color: Colors.grey),
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             const Icon(Icons.upload_file),
                //             SizedBox(width:getWidth(context, 8)),
                //             Flexible(child: Text(fileName, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
                //           ],
                //         ),
                //         const Text(
                //           "PDF, JPG, PNG (Max 5MB)",
                //           textAlign: TextAlign.center,
                //           style: TextStyle(color: Colors.grey, fontSize: 12),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                SizedBox(height: size.height * 0.02),
                SizedBox(height: size.height * 0.02),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _returnFromController.clear();
                            _nameController.clear();
                            _returnToController.clear();
                            _trayTypeController.clear();
                            _qtyController.clear();
                            _numberController.clear();
                            _amountController.clear();
                            _remarksController.clear();
                            selectedIndex = -1;
                            fileName = "Choose File";
                          });
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.refresh, size: 18),
                              SizedBox(width: getWidth(context, 6)),
                              Text("Reset", style: AppTextStyles.containerText),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Confirm"),
                              content: const Text(
                                "Are you sure you want to save this details?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("No"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _submit();
                                  },
                                  child: const Text("Yes"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.amber600,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save, size: 18),
                              SizedBox(width: getWidth(context, 6)),
                              BlocBuilder<TrayReturnBloc, TrayReturnState>(
                                builder: (context, state) {
                                  if (state is TrayReturnSubmitting) {
                                    return const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  }

                                  return Text(
                                    "Save Returns",
                                    style: AppTextStyles.containerText,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
