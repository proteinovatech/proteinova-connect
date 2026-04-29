import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class Addexpense extends StatefulWidget {
  const Addexpense({super.key});

  @override
  State<Addexpense> createState() => _AddexpenseState();
}

class _AddexpenseState extends State<Addexpense> {
  String? selectedTransport;
  String selectedPayment = "";
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
final List<String> transportList = [
   "Salary",
  "Purchase",
  "Transport",
  "Maintanance",
  "Rent",
  "Paking",
  "General"
];
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
      SizedBox(height: size.height * 0.05),

      Row(
        children: [
           IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
          Text(
            "Add Expense",
            style: AppTextStyles.headingText22,
          ),
        ],
      ),

      SizedBox(height: size.height * 0.01,),
Divider(),
SizedBox(height: size.height * 0.01,),
Text("Expanse Date*",style: AppTextStyles.headingText20,),
SizedBox(height: size.height * 0.01,),
  Container(
      height: 35,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: const Text("11 april 2026"),
    ),
    SizedBox(height: size.height * 0.02,),
Text("Expanse Category*",style: AppTextStyles.headingText20,),
SizedBox(height: size.height * 0.01,),
 DropdownButtonFormField<String>(
  value: selectedTransport,
  hint: const Text("Transport"),
  decoration: InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  icon: const Icon(Icons.keyboard_arrow_down), // arrow icon
  items: transportList.map((item) {
    return DropdownMenuItem(
      value: item,
      child: Text(item),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedTransport = value;
    });
  },
),
SizedBox(height: size.height * 0.02,),
Text("Amount(₹)*",style: AppTextStyles.bodyText16,),
SizedBox(height: size.height * 0.01,),
  Container(
      height: 35,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: const Text("500"),
    ),
    SizedBox(height: size.height * 0.02,),
Text("Payment Method*",style: AppTextStyles.headingText20),
SizedBox(height: size.height * 0.01,),
  Row(
  children: [
       Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPayment = "Cash";
          });
        },
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedPayment == "Cash"
                  ? Colors.blue
                  : AppColors.border2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: selectedPayment == "Cash"
                ? Colors.blue.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.money),
              SizedBox(width: 6),
              Text("Cash"),
            ],
          ),
        ),
      ),
    ),

    const SizedBox(width: 10),
    Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPayment = "UPI";
          });
        },
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedPayment == "UPI"
                  ? Colors.blue
                  : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
            color: selectedPayment == "UPI"
                ? Colors.blue.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.account_balance_wallet),
              SizedBox(width: 6),
              Text("UPI"),
            ],
          ),
        ),
      ),
    ),
  ],
),
Text(
  "Description*",
  style: AppTextStyles.bodyText16,
),

SizedBox(height: size.height * 0.01),

TextField(
  maxLines: 3,
  decoration: InputDecoration(
    hintText: "Transport for stock from Warehouse",
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
),
SizedBox(height: size.height * 0.02),
RichText(
  text: TextSpan(
    text: "Attachment ",
    style: TextStyle(color: Colors.black, fontSize: 16),
    children: const [
      TextSpan(
        text: "(Optional)",
        style: TextStyle(color: Colors.grey),
      ),
    ],
  ),
),
SizedBox(height: size.height * 0.01,),
  InkWell(
      onTap: () async {
        print("Tapped"); // 🔥 debug
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
    ),
    const SizedBox(height: 6),
Divider(),
SizedBox(height:size.height * 0.02 ,),
Row(
  children: [
       Expanded(
      child: GestureDetector(
        onTap: () {
               },
        child: Container(
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "Reset",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    ),

    const SizedBox(width: 10),
   Expanded(
  child: GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Confirm"),
            content: const Text("Are you sure you want to save expenses?"),
            actions: [
                          TextButton(
                onPressed: () {
                  Navigator.pop(context); 
                },
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); 
                },
                child: const Text("Yes"),
              ),
            ],
          );
        },
      );
    },
    child: Container(
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "Save Expenses",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ),
)
  ],
),
SizedBox(height:size.height * 0.02 ,),
  ],
)
))
    );
  }
}
