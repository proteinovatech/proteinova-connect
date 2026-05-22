import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/bloc/branch_form_bloc/branch_form_bloc.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/data/model/branch_form_data_model.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/data/services/branch_service.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_branch_management_skeleton_loader.dart';
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
  final regionController = TextEditingController();
  final zipController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final maxStockController = TextEditingController();
  final notesController = TextEditingController();


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
      regionController.text = widget.branch!.region;
      selectedManager = widget.branch!.branchManagerId?.toString();
    }

     context.read<BranchFormBloc>().add(
    LoadBranchFormDataEvent(),
  );
  }

  bool isLoading = true;
  String? selectedStatus;
  String? selectedRegion;
  String? selectedManager;
  @override
  Widget build(BuildContext context) {
   return BlocConsumer<
    BranchFormBloc,
    BranchFormState>(
      
  listener: (context, state) {

    if (state is BranchFormSuccess) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(state.message),
        ),
      );

      Navigator.pop(context, true);
    }

    if (state is BranchFormError) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(state.message),
        ),
      );
    }
  },

  builder: (context, state) {
      List<String> statuses = [];
    List<ManagerModel> managers = [];

    if (state is BranchFormLoaded) {
      statuses = state.statuses;
      managers = state.managers;
    }

    return Scaffold(
      backgroundColor: AppColors.white,

      body: state is BranchFormLoading
          ? Center(child: const AdminBranchManagementSkeletonLoader())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context, 18),
                  vertical: getHeight(context, 16),
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

                    SizedBox(height: getHeight(context, 2)),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),

                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.09),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 5),
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
                          SizedBox(height: getHeight(context, 6)),
                          const Divider(),

                          SizedBox(height: getHeight(context, 12)),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Branch name*"),
                                    SizedBox(height: getHeight(context, 6)),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getWidth(context, 12),
                                        vertical: getHeight(context, 14),
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

                              SizedBox(width: getWidth(context, 16)),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Branch code*"),
                                    SizedBox(height: getHeight(context, 6)),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getWidth(context, 12),
                                        vertical: getHeight(context, 14),
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

                          SizedBox(height: getHeight(context, 12)),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Region*"),

                                    SizedBox(height: getHeight(context, 6)),

                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getWidth(context, 10),
                                      ),

                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),

                                      child: TextField(
                                        controller: regionController,
                                        style: AppTextStyles.formInputs15,
                                        decoration: const InputDecoration(
                                          hintText: "Enter Region",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: getWidth(context, 16)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Status*"),
                                    SizedBox(height: getHeight(context, 6)),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getWidth(context, 12),
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

                    SizedBox(height: getHeight(context, 18)),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),

                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.09),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 5),
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
                          SizedBox(height: getHeight(context, 6)),
                          const Divider(),

                          SizedBox(height: getHeight(context, 12)),

                          Text(
                            "Address line1",
                            style: AppTextStyles.bodyText14dark,
                          ),

                          SizedBox(height: getHeight(context, 12)),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(context, 12),
                              vertical: getHeight(context, 14),
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

                          SizedBox(height: getHeight(context, 14)),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("City*"),
                                    SizedBox(height: getHeight(context, 6)),

                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getWidth(context, 12),
                                        vertical: getHeight(context, 5),
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

                              SizedBox(width: getWidth(context, 6)),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Postal/Zip code*"),
                                    SizedBox(height: getHeight(context, 12)),

                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getWidth(context, 12),
                                        vertical: getHeight(context, 2),
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

                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: getWidth(context, 12),
                                            vertical: getHeight(context, 14),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: getHeight(context, 12)),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Contact number*"),
                                    SizedBox(height: getHeight(context, 12)),

                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getWidth(context, 12),
                                        vertical: getHeight(context, 6),
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

                              SizedBox(width: getWidth(context, 4)),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Email Address*"),
                                    SizedBox(height: getHeight(context, 12)),

                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getWidth(context, 12),
                                        vertical: getHeight(context, 6),
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

                    SizedBox(height: getHeight(context, 12)),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),

                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.09),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 5),
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
                          SizedBox(height: getHeight(context, 6)),
                          const Divider(),

                          SizedBox(height: getHeight(context, 12)),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("Branch Manager*"),
                                    SizedBox(height: getHeight(context, 12)),

                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getWidth(context, 12),
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

                              SizedBox(width: getWidth(context, 8)),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildField("MAX Stock*"),
                                    SizedBox(height: getHeight(context, 12)),

                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getWidth(context, 12),
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
                          SizedBox(height: getHeight(context, 12)),
                          Text(
                            "Additional Notes",
                            style: AppTextStyles.bodyText14dark,
                          ),
                          SizedBox(height: getHeight(context, 12)),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(context, 12),
                              vertical: getHeight(context, 12),
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

                    SizedBox(height: getHeight(context, 12)),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(context, 12),
                              vertical: getHeight(context, 14),
                            ),

                            decoration: BoxDecoration(
                              color: AppColors.background,
                              border: Border.all(color: AppColors.border),

                              borderRadius: BorderRadius.circular(10),
                            ),

                            child: Text(
                              "Clear Form",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyText14dark,
                            ),
                          ),
                        ),
                        SizedBox(width: getWidth(context, 4)),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final body = {
                                "branch_name": branchNameController.text,
                                "branch_code": branchCodeController.text,
                                "region": regionController.text,
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
                              padding: EdgeInsets.symmetric(
                                horizontal: getWidth(context, 12),
                                vertical: getHeight(context, 14),
                              ),

                              decoration: BoxDecoration(
                                color: AppColors.amber600,
                                border: Border.all(color: AppColors.amber600),

                                borderRadius: BorderRadius.circular(10),
                              ),

                              child: Row(
                                children: [
                                  SizedBox(width: getWidth(context, 6)),
                                  Icon(Icons.check),
                                  SizedBox(width: getWidth(context, 6)),
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
      },
);
  }
}
