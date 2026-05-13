import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter, FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:proteinova_connect/features/admin/supplier/models/supplier_model.dart';
import 'package:proteinova_connect/features/admin/supplier/services/supplier_service.dart';

class AddSupplierBottomSheet extends StatefulWidget {
  final Supplier? supplierToEdit;

  const AddSupplierBottomSheet({super.key, this.supplierToEdit});

  @override
  State<AddSupplierBottomSheet> createState() => _AddSupplierBottomSheetState();
}

class _AddSupplierBottomSheetState extends State<AddSupplierBottomSheet> {
  final TextEditingController companyController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final SupplierService _supplierService = SupplierService();

  String status = "Active";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.supplierToEdit != null) {
      companyController.text = widget.supplierToEdit!.name;
      locationController.text = widget.supplierToEdit!.location;
      contactController.text = widget.supplierToEdit!.owner;
      emailController.text = widget.supplierToEdit!.email;
      phoneController.text = widget.supplierToEdit!.phone;
      status = widget.supplierToEdit!.active ? "Active" : "Inactive";
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          ),
          child: Column(
            children: [
              /// TOP HANDLE
              const SizedBox(height: 12),

              Container(
                width: 70,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 24),

              /// HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Supplier Details",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.close, size: 30),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Divider(color: Colors.grey.shade200),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// COMPANY NAME
                      const Text(
                        "Supplier Company Name",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 14),

                      customField(
                        controller: companyController,
                        hint: "e.g. Apex Farms",
                      ),

                      const SizedBox(height: 28),

                      /// LOCATION + STATUS
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Location / Region",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                customField(
                                  controller: locationController,
                                  hint: "Location / Region",
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 18),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Status",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Container(
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xffE5E7EB),
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: status,
                                      isExpanded: true,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                      ),
                                      items: ["Active", "Inactive"]
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          status = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      /// CONTACT NAME
                      const Text(
                        "Primary Contact Name",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 14),

                      customField(
                        controller: contactController,
                        hint: "e.g. Jane Doe",

                        inputFormatters: [
                          NameCapitalFormatter(),

                          /// ONLY LETTERS + SPACE
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z ]'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      /// EMAIL + PHONE
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  "Email Address",

                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                customField(
                                  controller: emailController,
                                  hint: "name@gmail.com",

                                  keyboardType: TextInputType.emailAddress,

                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9@._-]'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Phone number",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                customField(
                                  controller: phoneController,
                                  hint: "+91 00000-00000",

                                  keyboardType: TextInputType.phone,

                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              /// BOTTOM BUTTONS
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 58,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xffE5E7EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: SizedBox(
                        height: 58,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffF4C400),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: isLoading ? null : () async {
                            if (companyController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Company name is required")),
                              );
                              return;
                            }

                            setState(() {
                              isLoading = true;
                            });

                            try {
                              final newSupplier = Supplier(
                                id: widget.supplierToEdit?.id ?? '',
                                name: companyController.text.trim(),
                                location: locationController.text.trim(),
                                owner: contactController.text.trim(),
                                phone: phoneController.text.trim(),
                                email: emailController.text.trim(),
                                active: status == 'Active',
                              );

                              if (widget.supplierToEdit != null) {
                                await _supplierService.updateSupplier(widget.supplierToEdit!.id, newSupplier);
                              } else {
                                await _supplierService.addSupplier(newSupplier);
                              }

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(widget.supplierToEdit != null ? "Supplier Updated" : "Supplier Added"),
                                ),
                              );
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          },
                          child: isLoading 
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Text(
                                widget.supplierToEdit != null ? "Update Supplier" : "Save Supplier",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// EMAIL VALIDATION FUNCTION
  bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  Widget customField({
    required TextEditingController controller,
    required String hint,

    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,

    /// ADD THIS
    bool isError = false,
  }) {
    return TextField(
      controller: controller,

      keyboardType: keyboardType,
      inputFormatters: inputFormatters,

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: const TextStyle(color: Color(0xff9CA3AF)),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide(
            color: isError ? Colors.red : const Color(0xffE5E7EB),
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide(
            color: isError ? Colors.red : const Color(0xffE5E7EB),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide(
            color: isError ? Colors.red : const Color(0xffF4C400),

            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class NameCapitalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.toLowerCase();

    /// EVERY WORD FIRST LETTER CAPITAL
    text = text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');

    return TextEditingValue(
      text: text,

      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
