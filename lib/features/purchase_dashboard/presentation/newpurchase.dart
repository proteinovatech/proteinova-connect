import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/purchase_dashboard/widget/product_specificationcard.dart';
import 'package:proteinova_connect/features/purchase_dashboard/widget/purchase_employeecard.dart';
import 'package:proteinova_connect/features/purchase_dashboard/widget/purchase_summarycard.dart';
import 'package:proteinova_connect/features/purchase_dashboard/widget/supplier_locationcard.dart';

class Newpurchase extends StatefulWidget {
  const Newpurchase({super.key});

  @override
  State<Newpurchase> createState() => _NewpurchaseState();
}

class _NewpurchaseState extends State<Newpurchase> {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  final TextEditingController neccController = TextEditingController();
  final TextEditingController minusController = TextEditingController();
  final TextEditingController trayController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final TextEditingController branchController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  final TextEditingController loadingController = TextEditingController();
  final TextEditingController unloadingController = TextEditingController();
  final TextEditingController transportController = TextEditingController();
  final TextEditingController miscController = TextEditingController();

  void calculateSummary() {
    final quantity = double.tryParse(quantityController.text) ?? 0;
    final rate = double.tryParse(rateController.text) ?? 0;

    final loading = 500; // later connect from controller
    final unloading = 300;
    final transport = 1000;
    final misc = 200;

    final totalCost =
        (quantity * rate) + loading + unloading + transport + misc;

    setState(() {
      // You can store this in a variable if needed
    });
  }

  @override
  void initState() {
    super.initState();

    quantityController.addListener(calculateSummary);
    rateController.addListener(calculateSummary);
    neccController.addListener(calculateSummary);
    minusController.addListener(calculateSummary);

    quantityController.addListener(_refresh);
    rateController.addListener(_refresh);
    countController.addListener(_refresh);
    neccController.addListener(_refresh);
    minusController.addListener(_refresh);

    loadingController.addListener(_refresh);
    unloadingController.addListener(_refresh);
    transportController.addListener(_refresh);
    miscController.addListener(_refresh);
  }

  void _refresh() {
    setState(() {});
  }

  String supplier = "";
  String location = "";
  String category = "";
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background1,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text("New Purchase", style: AppTextStyles.headingText25),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            // child: CircleAvatar(
            //   radius: 18,
            //   backgroundColor: Colors.grey.shade300,

            // ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: size.width * 0.04,
            right: size.width * 0.04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),

              Padding(
                padding: EdgeInsets.only(left: size.width * 0.02),
                child: Text(
                  "Record new form procurement and \nstock.",
                  style: AppTextStyles.bodyText16,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              SupplierLocationCard(
                onChanged: (sup, loc) {
                  setState(() {
                    supplier = sup;
                    location = loc;
                  });
                },
              ),
              SizedBox(height: size.height * 0.02),
              ProductSpecificationCard(
                onCategoryChanged: (cat) {
                  setState(() {
                    category = cat;
                  });
                },
                countController: countController,
                trayController: trayController,
                quantityController: quantityController,
                neccController: neccController,
                minusController: minusController,
                rateController: rateController,
                notesController: notesController,
                loadingController: loadingController,
                unloadingController: unloadingController,
                transportController: transportController,
                miscController: miscController,
              ),

              SizedBox(height: size.height * 0.02),
              PurchaseEmployeecard(
                branchController: branchController,
                numberController: numberController,
                typeController: typeController,
                contactController: contactController,
                notesController: notesController,
              ),
              SizedBox(height: size.height * 0.02),
              PurchaseSummaryCard(
                supplier:
                    supplier, // from Supplier card (you need to expose it)
                location: location, // same
                product: category,
                quantity: quantityController.text,
                rate: neccController.text,
                totalEggs: countController.text,
                loading:
                    loadingController.text, // replace later with controller
                unloading: unloadingController.text,
                transport: transportController.text,
                misc: miscController.text,
              ),
              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
