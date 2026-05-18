import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/branch/addexpense/bloc/expense_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Addexpense extends StatefulWidget {
  const Addexpense({super.key});

  @override
  State<Addexpense> createState() => _AddexpenseState();
}

class _AddexpenseState extends State<Addexpense> {
  String? selectedCategory;
  String selectedPayment = "";
  String fileName = "Choose File";
  int? branchId;

  final TextEditingController dateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<String> categoryList = [
    "SALARY",
    "PURCHASE",
    "TRANSPORT",
    "MAINTANANCE",
    "RENT",
    "PACKING",
    "GENERAL",
  ];

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadBranchId();
  }

  Future<void> _loadBranchId() async {
    final prefs = await SharedPreferences.getInstance();
    branchId = prefs.getInt("branch_id");
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
          setState(() => fileName = file.name);
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
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category")),
      );
      return;
    }
    if (selectedPayment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a payment method")),
      );
      return;
    }
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an amount")),
      );
      return;
    }

    context.read<ExpenseBloc>().add(
      SubmitExpense(data: {
        "branch_id": branchId ?? 0,
        "expense_date": dateController.text,
        "category": selectedCategory,
        "amount": amountController.text,
        "payment_method": selectedPayment,
        "description": descriptionController.text,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseSubmitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else if (state is ExpenseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background1,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.05),

                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text("Add Expense", style: AppTextStyles.headingText22),
                  ],
                ),

                SizedBox(height: size.height * 0.01),
                const Divider(),
                SizedBox(height: size.height * 0.01),

                // Expense Date
                Text("Expense Date*", style: AppTextStyles.headingText20),
                SizedBox(height: size.height * 0.01),
                GestureDetector(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // Category Dropdown
                Text("Expense Category*", style: AppTextStyles.headingText20),
                SizedBox(height: size.height * 0.01),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: selectedCategory,
                  hint: const Text("Select Category"),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: categoryList.map((item) {
                    return DropdownMenuItem(value: item, child: Text(item));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedCategory = value),
                ),

                SizedBox(height: size.height * 0.02),

                // Amount
                Text("Amount (₹)*", style: AppTextStyles.bodyText16),
                SizedBox(height: size.height * 0.01),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter amount",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // Payment Method
                Text("Payment Method*", style: AppTextStyles.headingText20),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedPayment = "CASH"),
                        child: Container(
                          height: getHeight(context, 45),
                          decoration: BoxDecoration(
                            border: Border.all(color: selectedPayment == "CASH" ? Colors.blue : AppColors.border2),
                            borderRadius: BorderRadius.circular(8),
                            // ignore: deprecated_member_use
                            color: selectedPayment == "CASH" ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.money),
                              SizedBox(width: 6),
                              Text("Cash"),
                            ],
                          ),
                        ),
                      ),
                    ),
                     SizedBox(width: getWidth(context, 10),),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedPayment = "UPI"),
                        child: Container(
                          height: getHeight(context,45),
                          decoration: BoxDecoration(
                            border: Border.all(color: selectedPayment == "UPI" ? Colors.blue : Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            // ignore: deprecated_member_use
                            color: selectedPayment == "UPI" ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet),
                                SizedBox(width: getWidth(context, 6)),
                              Text("UPI"),
                            ],
                          ),
                        ),
                      ),
                    ),
                     SizedBox(width: getWidth(context, 10)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedPayment = "BANK"),
                        child: Container(
                          height: getHeight(context, 45),
                          decoration: BoxDecoration(
                            border: Border.all(color: selectedPayment == "BANK" ? Colors.blue : Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            // ignore: deprecated_member_use
                            color: selectedPayment == "BANK" ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance),
                             SizedBox(width: getWidth(context, 6)),
                              Text("Bank"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.02),

                // Description
                Text("Description*", style: AppTextStyles.bodyText16),
                SizedBox(height: size.height * 0.01),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter description",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // Attachment
                RichText(
                  text: const TextSpan(
                    text: "Attachment ",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    children: [TextSpan(text: "(Optional)", style: TextStyle(color: Colors.grey))],
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                InkWell(
                  onTap: pickFile,
                  child: Container(
                    height: getHeight(context, 100),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.upload_file),
                            SizedBox(width: getWidth(context, 8)),
                            Flexible(child: Text(fileName, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const Text("PDF, JPG, PNG (Max 5MB)", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: getHeight(context, 6)),
                const Divider(),
                SizedBox(height: size.height * 0.02),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = null;
                            selectedPayment = "";
                            fileName = "Choose File";
                            amountController.clear();
                            descriptionController.clear();
                          });
                        },
                        child: Container(
                          height: getHeight(context, 45),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("Reset", style: AppTextStyles.bodyText14dark),
                        ),
                      ),
                    ),
                    SizedBox(width: getWidth(context, 10)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Confirm"),
                              content: const Text("Are you sure you want to save this expense?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
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
                        child: BlocBuilder<ExpenseBloc, ExpenseState>(
                          builder: (context, state) {
                            final isSubmitting = state is ExpenseSubmitting;
                            return Container(
                              height:getHeight(context, 45),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:AppColors.amber600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: isSubmitting
                                  ? SizedBox(height:getHeight(context, 20), width:getWidth(context, 20), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text("Save Expense", style: AppTextStyles.whiteText),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}