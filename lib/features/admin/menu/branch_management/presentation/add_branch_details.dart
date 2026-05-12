import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/data/model/branch_form_data_model.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/data/services/branch_service.dart';
import 'package:proteinova_connect/features/branch/branch_details/widget/buildfield.dart';

class AddBranchDetails extends StatefulWidget {
  final BranchModel? branch;
  const AddBranchDetails({super.key, this.branch});

  @override
  State<AddBranchDetails> createState() => _AddBranchDetailsState();
}

class _AddBranchDetailsState extends State<AddBranchDetails> {
  final branchNameController = TextEditingController();
  final branchCodeController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final zipController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final maxStockController = TextEditingController();
  final notesController = TextEditingController();

  List<String> statuses = [];
  List<String> regions = [];
  List<ManagerModel> managers = [];
  Future<void> loadFormData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final data = await BranchService().fetchBranchFormData();

      if (!mounted) return;

      setState(() {
        statuses = data.statuses ?? [];
        regions = data.regions ?? [];
        managers = data.managers ?? [];

        isLoading = false;
      });

      print("Statuses => $statuses");
      print("Regions => $regions");
      print("Managers => ${managers.length}");
    } catch (e, stackTrace) {
      print("LOAD ERROR => $e");
      print(stackTrace);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.branch != null) {
      branchNameController.text = widget.branch!.branchName;
      branchCodeController.text = widget.branch!.branchCode;
      addressController.text = widget.branch!.addressLine1;
      cityController.text = widget.branch!.city;
      zipController.text = widget.branch!.postalZipCode;
      contactController.text = widget.branch!.contactNumber;
      emailController.text = widget.branch!.emailAddress;
      maxStockController.text =
          widget.branch!.maxStockCapacity?.toString() ?? "";
      notesController.text = widget.branch!.additionalNotes ?? "";
      selectedStatus = widget.branch!.status;
      selectedRegion = widget.branch!.region;
      selectedManager = widget.branch!.branchManagerId?.toString();
    }

    loadFormData();
  }

  bool isLoading = true;
  String? selectedStatus;
  String? selectedRegion;
  String? selectedManager;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background1,

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: 16,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),

                        Text(
                          widget.branch == null ? "Add Branch" : "Edit Branch",
                          style: AppTextStyles.headingText22,
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.02),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Basic Information",
                            style: AppTextStyles.headingText20,
                          ),

                          const Divider(),

                          SizedBox(height: size.height * 0.01),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Branch name*"),
                                    const SizedBox(height: 6),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),

                                        borderRadius: BorderRadius.circular(10),
                                      ),

                                      child: TextField(
                                        controller: branchNameController,
                                        decoration: InputDecoration(
                                          hintText: "e.g. Branch Central",

                                          hintStyle: AppTextStyles.bodyText14,

                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Branch code*"),
                                    const SizedBox(height: 6),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),

                                        borderRadius: BorderRadius.circular(10),
                                      ),

                                      child: TextField(
                                        controller: branchCodeController,
                                        decoration: InputDecoration(
                                          hintText: "e.g.BR-006",

                                          hintStyle: AppTextStyles.bodyText14,

                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: size.height * 0.02),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Region*"),

                                    const SizedBox(height: 6),

                                    Container(
                                      width: double.infinity,

                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),

                                        borderRadius: BorderRadius.circular(10),
                                      ),

                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,

                                          value:
                                              regions.contains(selectedRegion)
                                              ? selectedRegion
                                              : null,

                                          hint: Text(
                                            "Select Region",
                                            style: AppTextStyles.bodyText14,
                                          ),

                                          items: regions
                                              .map<DropdownMenuItem<String>>((
                                                region,
                                              ) {
                                                return DropdownMenuItem<String>(
                                                  value: region,
                                                  child: Text(region),
                                                );
                                              })
                                              .toList(),

                                          onChanged: (value) {
                                            setState(() {
                                              selectedRegion = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Status*"),
                                    const SizedBox(height: 6),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),

                                        borderRadius: BorderRadius.circular(10),
                                      ),

                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,

                                          value:
                                              statuses.contains(selectedStatus)
                                              ? selectedStatus
                                              : null,

                                          hint: Text(
                                            "Select Status",
                                            style: AppTextStyles.bodyText14,
                                          ),

                                          items: statuses
                                              .map<DropdownMenuItem<String>>((
                                                status,
                                              ) {
                                                return DropdownMenuItem<String>(
                                                  value: status,
                                                  child: Text(status),
                                                );
                                              })
                                              .toList(),

                                          onChanged: (value) {
                                            setState(() {
                                              selectedStatus = value;
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
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Location & Contact",
                            style: AppTextStyles.headingText20,
                          ),

                          const Divider(),

                          SizedBox(height: size.height * 0.01),

                          Text(
                            "Address line1",
                            style: AppTextStyles.bodyText14dark,
                          ),

                          SizedBox(height: size.height * 0.01),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),

                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),

                            child: TextField(
                              controller: addressController,
                              decoration: InputDecoration(
                                hintText:
                                    "Street address,P.O.box,company name,c/o",

                                hintStyle: AppTextStyles.bodyText14,

                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          SizedBox(height: size.height * 0.02),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("City*"),
                                    const SizedBox(height: 6),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),

                                        borderRadius: BorderRadius.circular(10),
                                      ),

                                      child: TextField(
                                        controller: cityController,
                                        decoration: InputDecoration(
                                          hintText: "City",

                                          hintStyle: AppTextStyles.bodyText14,

                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Postal/Zip code*"),
                                    const SizedBox(height: 6),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),

                                        borderRadius: BorderRadius.circular(10),
                                      ),

                                      child: TextField(
                                        controller: zipController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: "Zip Code",

                                          hintStyle: AppTextStyles.bodyText14,

                                          border: InputBorder.none,

                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 14,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: size.height * 0.02),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Contact number*"),
                                    const SizedBox(height: 6),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),

                                        borderRadius: BorderRadius.circular(10),
                                      ),

                                      child: TextField(
                                        controller: contactController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: "+980657321",

                                          hintStyle: AppTextStyles.bodyText14,

                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Email Address*"),
                                    const SizedBox(height: 6),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),

                                        borderRadius: BorderRadius.circular(10),
                                      ),

                                      child: TextField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          hintText: "branch@gmail.com",

                                          hintStyle: AppTextStyles.bodyText14,

                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Management & Operations",
                            style: AppTextStyles.headingText20,
                          ),

                          const Divider(),

                          SizedBox(height: size.height * 0.02),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Branch Manager*"),
                                    const SizedBox(height: 6),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),

                                        borderRadius: BorderRadius.circular(10),
                                      ),

                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,

                                          value: selectedManager,

                                          hint: Text(
                                            "Select Manager",
                                            style: AppTextStyles.bodyText14,
                                          ),

                                          items: managers
                                              .map<DropdownMenuItem<String>>((
                                                manager,
                                              ) {
                                                return DropdownMenuItem<String>(
                                                  value: manager.id.toString(),
                                                  child: Text(manager.email),
                                                );
                                              })
                                              .toList(),

                                          onChanged: (value) {
                                            setState(() {
                                              selectedManager = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("MAX Stock*"),
                                    const SizedBox(height: 6),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),

                                        borderRadius: BorderRadius.circular(10),
                                      ),

                                      child: TextField(
                                        controller: maxStockController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: "e.g.5000",

                                          hintStyle: AppTextStyles.bodyText14,

                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.02),
                          Text(
                            "Additional Notes",
                            style: AppTextStyles.bodyText14dark,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),

                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),

                              borderRadius: BorderRadius.circular(10),
                            ),

                            child: TextField(
                              controller: notesController,
                              maxLines: 4,

                              decoration: InputDecoration(
                                hintText:
                                    "Any specific operational details for this branch..",

                                hintStyle: AppTextStyles.bodyText14,

                                border: InputBorder.none,

                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),

                            decoration: BoxDecoration(
                              color: AppColors.background,
                              border: Border.all(color: AppColors.background),

                              borderRadius: BorderRadius.circular(10),
                            ),

                            child: Text(
                              "Clear Form",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyText14dark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final body = {
                                "branch_name": branchNameController.text,
                                "branch_code": branchCodeController.text,
                                "region": selectedRegion,
                                "status": selectedStatus,
                                "address_line1": addressController.text,
                                "city": cityController.text,
                                "postal_zip_code": zipController.text,
                                "contact_number": contactController.text,
                                "email_address": emailController.text,
                                "branch_manager_id": int.tryParse(
                                  selectedManager ?? "0",
                                ),
                                "max_stock_capacity":
                                    int.tryParse(maxStockController.text) ?? 0,
                                "additional_notes": notesController.text,
                                "created_by": 1,
                              };

                              try {
                                if (widget.branch == null) {
                                  await BranchService().createBranch(
                                    data: body,
                                  );
                                } else {
                                  await BranchService().updateBranch(
                                    id: widget.branch!.id,
                                    data: body,
                                  );
                                }

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      widget.branch == null
                                          ? "Branch Created Successfully"
                                          : "Branch Updated Successfully",
                                    ),
                                  ),
                                );

                                Navigator.pop(context, true);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              }
                            },

                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),

                              decoration: BoxDecoration(
                                color: AppColors.amber600,
                                border: Border.all(color: AppColors.amber600),

                                borderRadius: BorderRadius.circular(10),
                              ),

                              child: Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Icon(Icons.check),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.branch == null
                                        ? "Save Branch"
                                        : "Update Branch",
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyText14dark,
                                  ),
                                ],
                              ),
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
