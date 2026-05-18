import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/branch_details/widget/buildfield.dart';

class BranchDetails extends StatefulWidget {
  const BranchDetails({super.key});

  @override
  State<BranchDetails> createState() => _BranchDetailsState();
}

class _BranchDetailsState extends State<BranchDetails> {
  @override
  Widget build(BuildContext context) {
     final Size size =MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: AppColors.background1,
           body: Padding(padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: size.height * 0.06),
      Row(
                children: [
                   IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
          Text(
            "Branch Details",
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
        // ignore: deprecated_member_use
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

      SizedBox(height: size.height * 0.01),
      Divider(),
      SizedBox(height: size.height * 0.01),

    Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(child: buildField("Branch name*")),
    SizedBox(width: 16),
    Expanded(child: buildField("Branch code*")),
  ],
),
          SizedBox(height: size.height * 0.01),
     Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(child: buildField("Region*")),
    SizedBox(width: 16),
    Expanded(child: buildField("Status*")),
  ],
),
      SizedBox(height: size.height * 0.02),
           Text(
        "Location & Contact",
        style: AppTextStyles.headingText20,
      ),
        Divider(),
      SizedBox(height: size.height * 0.01),

Text(
  "Address line1",
  style: AppTextStyles.bodyText14dark,
),

SizedBox(height: size.height * 0.01),

Text(
  "Street Address, P.O. Box, Company Name, C/O, Very long address continues here...",
  style: AppTextStyles.bodyText14,
  softWrap: true,
  overflow: TextOverflow.visible,
),
      SizedBox(height: size.height * 0.02),
      Row(
  children: [
    Expanded(child: buildField("City*")),
    SizedBox(width: 16),
    Expanded(child: buildField("Postal/Zip code*")),
  ],
),
      SizedBox(height: size.height * 0.02),
       Row(
  children: [
    Expanded(child: buildField("Contact number*")),
    SizedBox(width: 16),
    Expanded(child: buildField("Email Address*")),
  ],
),
       SizedBox(height: size.height * 0.02),
           Text(
        "Management & Operations",
        style: AppTextStyles.headingText20,
      ),
        Divider(),
          SizedBox(height: size.height * 0.02),
    Row(
  children: [
    Expanded(child: buildField("Branch Manager*")),
    SizedBox(width: 16),
    Expanded(child: buildField("MAX Stock*")),
  ],
),
SizedBox(height: size.height * 0.01),
],
  ),
),
SizedBox(height: size.height * 0.02),
      ])))
    );
  }
}
