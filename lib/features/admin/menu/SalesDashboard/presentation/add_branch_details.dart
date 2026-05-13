import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/branch_details/widget/buildfield.dart';

class AddBranchDetails extends StatefulWidget {
  const AddBranchDetails({super.key});

  @override
  State<AddBranchDetails> createState() => _AddBranchDetailsState();
}

class _AddBranchDetailsState extends State<AddBranchDetails> {
  String? selectedStatus;
  String? selectedRegion;
  String? selectedManager;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background1,

      body: SafeArea(
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  Text("Branch Details", style: AppTextStyles.headingText22),
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

                                    value: selectedRegion,

                                    hint: Text(
                                      "Select Region",
                                      style: AppTextStyles.bodyText14,
                                    ),

                                    items: const [
                                      DropdownMenuItem(
                                        value: "North",
                                        child: Text("North"),
                                      ),

                                      DropdownMenuItem(
                                        value: "South",
                                        child: Text("South"),
                                      ),
                                    ],

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

                                    value: selectedStatus,

                                    hint: Text(
                                      "Select Status",
                                      style: AppTextStyles.bodyText14,
                                    ),

                                    items: const [
                                      DropdownMenuItem(
                                        value: "Active",
                                        child: Text("Active"),
                                      ),

                                      DropdownMenuItem(
                                        value: "Inactive",
                                        child: Text("Inactive"),
                                      ),
                                    ],

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

                    Text("Address line1", style: AppTextStyles.bodyText14dark),

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
                        decoration: InputDecoration(
                          hintText: "Street address,P.O.box,company name,c/o",

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
                                  decoration: InputDecoration(
                                    hintText: "Zip Code",

                                    hintStyle: AppTextStyles.bodyText14,

                                    border: InputBorder.none,

                                    contentPadding: const EdgeInsets.symmetric(
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

                                    items: const [
                                      DropdownMenuItem(
                                        value: "Manager 1",
                                        child: Text("Manager 1"),
                                      ),

                                      DropdownMenuItem(
                                        value: "Manager 2",
                                        child: Text("Manager 2"),
                                      ),
                                    ],

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
                            "Save Branch",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyText14dark,
                          ),
                        ],
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
