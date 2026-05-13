import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/tray_returns/presentation/widget/buildfield1.dart';
import 'package:proteinova_connect/features/tray_returns/presentation/widget/conditionbox.dart';

class TrayRecords extends StatefulWidget {
  const TrayRecords({super.key});

  @override
  State<TrayRecords> createState() => _TrayRecordsState();
}

class _TrayRecordsState extends State<TrayRecords> {
   String? selectedTransport;
  String selectedPayment = "";
  int selectedIndex = -1;
   String fileName = "Choose File";
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
    } else {
      print("User cancelled");
    }
  } catch (e) {
    print("ERROR: $e"); 
  }
}
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background1,
      appBar: AppBar(
         elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Tray Records",
          style: AppTextStyles.headingText22,
        ),
        centerTitle: false,
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        child: SingleChildScrollView(
          child: Column(
  children: [
    SizedBox(height: size.height * 0.03),

    buildRowField("Return from :", "Customer"),
    SizedBox(height: size.height * 0.02),

    buildRowField("Name :", "Valley farm"),
    SizedBox(height: size.height * 0.02),

    buildRowField("Return Date :", "Select date"),
    SizedBox(height: size.height * 0.02),

    buildRowField("Return to :", "Warehouse"),
    SizedBox(height: size.height * 0.02),

    buildRowField("Tray type :", "Trays"),
    SizedBox(height: size.height * 0.02),

    buildRowField("Quantity :", "50 trays"),
    SizedBox(height: size.height * 0.03),
    Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      "Conditions",
      style: AppTextStyles.headingText22,
    ),

   SizedBox(height: size.height * 0.02),

  Row(
  children: [
    Expanded(
      child: conditionBox(
        index: 0,
        selectedIndex: selectedIndex,
        onTap: () {
          setState(() {
            selectedIndex = 0;
          });
        },
        icon: Icons.check_circle,
        text: "Good",
        color: Colors.green,
      ),
    ),
    const SizedBox(width: 10),

    Expanded(
      child: conditionBox(
        index: 1,
        selectedIndex: selectedIndex,
        onTap: () {
          setState(() {
            selectedIndex = 1;
          });
        },
        icon: Icons.cancel,
        text: "Damaged",
        color: Colors.red,
      ),
    ),
    const SizedBox(width: 10),

    Expanded(
      child: conditionBox(
        index: 2,
        selectedIndex: selectedIndex,
        onTap: () {
          setState(() {
            selectedIndex = 2;
          });
        },
        icon: Icons.delete,
        text: "Scrap",
        color: Colors.orange,
      ),
    ),
  ],
)

  ],
),
SizedBox(height: size.height * 0.02),
Row(
  children: [
    Text("Attachment",style: AppTextStyles.headingText22,),
    Text("(Optional)",style: AppTextStyles.bodyText16,),
  ],
),
SizedBox(height: size.height * 0.01,),
  InkWell(
      onTap: () async {
        print("Tapped");
        await pickFile();
      },
      child: Container(
  height: 100,
  width: double.infinity,
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
    children: [
                 Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            const Icon(Icons.upload_file),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                fileName,
                textAlign: TextAlign.center, 
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      const Text(
        "PDF, JPG, PNG (Max 5MB)",
         textAlign: TextAlign.center,
         style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
    ],
  ),
)
    ),SizedBox(height: size.height * 0.02),
   Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.refresh, size: 18), // Reset icon
          SizedBox(width: 6),
          Text(
            "Reset",
            style: AppTextStyles.containerText,
          ),
        ],
      ),
    ),

    SizedBox(width: size.width * 0.01),

    GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Confirm"),
              content: Text("Are you sure you want to save this details?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Yes"),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save, size: 18), // Save icon
            SizedBox(width: 6),
            Text(
              "Save Returns",
              style: AppTextStyles.containerText,
            ),
          ],
        ),
      ),
    ),
  ],
),
SizedBox(height: size.height * 0.02),
   
  ],
)
          ),
        ),
      
    );
  }
}