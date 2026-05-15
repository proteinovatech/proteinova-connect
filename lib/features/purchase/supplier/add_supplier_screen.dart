import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/supplier_request_model.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/services/supplier_service.dart';

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
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
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        title: const Text(
          "Add New Supplier",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: Colors.grey),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// SUPPLIER NAME
                Text(
                  "Supplier Company Name",
                  style: AppTextStyles.buttonText16
                ),

                const SizedBox(height: 8),

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


                const SizedBox(height: 18),

                /// LOCATION + STATUS
                Row(
                  children: [
                    /// LOCATION
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            "Location / Region",
                            style: AppTextStyles.buttonText16
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
                           Text(
                            "Status",
                            style: AppTextStyles.buttonText16
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

                const SizedBox(height: 18),

                /// PRIMARY CONTACT
                 Text(
                  "Primary Contact Name",
                  style: AppTextStyles.buttonText16
                ),

                const SizedBox(height: 8),

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


                const SizedBox(height: 18),

                /// EMAIL + PHONE
                Row(
                  children: [
                    /// EMAIL
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            "Email Address",
                            style: AppTextStyles.buttonText16
                          ),

                          const SizedBox(height: 8),

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

                    const SizedBox(width: 12),

                    /// PHONE
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            "Phone Number",
                            style: AppTextStyles.buttonText16
                          ),

                          const SizedBox(height: 8),

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

                const SizedBox(height: 28),

                /// BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /// CANCEL
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),

                    const SizedBox(width: 12),

                    /// SAVE
                    // ElevatedButton(
                    //   onPressed: () {},
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: const Color(0xfffacc15),
                    //     foregroundColor: Colors.black,
                    //     elevation: 0,
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 18,
                    //       vertical: 14,
                    //     ),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //   ),
                    //   child: const Text(
                    //     "Save Supplier",
                    //     style: TextStyle(fontWeight: FontWeight.w600),
                    //   ),
                    // ),
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
                        backgroundColor: const Color(0xfffacc15),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Save Supplier",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
