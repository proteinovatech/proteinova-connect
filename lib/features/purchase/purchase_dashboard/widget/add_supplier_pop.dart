import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/supplier_request_model.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/services/supplier_service.dart';

class AddSupplierPopup extends StatefulWidget {
  const AddSupplierPopup({super.key});

  @override
  State<AddSupplierPopup> createState() => _AddSupplierPopupState();
}

class _AddSupplierPopupState extends State<AddSupplierPopup> {

  final TextEditingController supplierController =
      TextEditingController();

  final TextEditingController contactController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();
  final TextEditingController locationController =
    TextEditingController();

  String region = "Select region";
  String status = "Active";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add New Supplier",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// COMPANY NAME
              const Text(
                "Supplier Company Name",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: supplierController,
                decoration: InputDecoration(
                  hintText: "e.g. Apex Farms",
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// REGION + STATUS
              Row(
  children: [

    /// REGION
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Location / Region",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 8),

         TextField(
  controller: locationController,

  style: const TextStyle(
    fontSize: 15,
    color: Colors.black,
  ),

  decoration: InputDecoration(
    hintText: "e.g. Hyderabad, India",

    isDense: true,

    contentPadding:
        const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 16,
    ),

    border: OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(16),
    ),
  ),
),
        ],
      ),
    ),

    const SizedBox(width: 12),

    /// STATUS
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Status",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            isExpanded: true,
            value: status,

            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),

            items: ["Active", "Inactive"]
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),

            onChanged: (value) {
              setState(() {
                status = value!;
              });
            },

            decoration: InputDecoration(
              isDense: true,

              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),

              const SizedBox(height: 20),

              /// CONTACT NAME
              const Text(
                "Primary Contact Name",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  hintText: "e.g. Jane Doe",
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// EMAIL + PHONE
              Row(
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Email Address",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText:
                                "name@company.com",
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      16),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Phone Number",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
  controller: phoneController,
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ],
  decoration: InputDecoration(
    hintText: "+91 9876543210",
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 18,
    ),
  ),
),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// BUTTONS
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [

                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),

                  const SizedBox(width: 14),

                  ElevatedButton(
                    onPressed: () async {

  try {

    final supplier = SupplierRequestModel(

      supplierCompanyName:
          supplierController.text,

      supplierName:
          contactController.text,

      email:
          emailController.text,

      phoneNumber:
          phoneController.text,

      supplierLocation:
          locationController.text,

      status:
          status.toUpperCase(),
    );

    await SupplierService().postSupplier(
      supplier,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Supplier Added"),
      ),
    );

    Navigator.pop(context);

  } catch (e) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
      ),
    );
  }
},
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xfffacc15),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Save Supplier",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}