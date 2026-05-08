import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_state.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/product_input_model.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/product_summary_model.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_event.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_state.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/additional_cost_card.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/product_specificationcard.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/purchase_employeecard.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/purchase_shimmer.dart';

import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/purchase_summarycard.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/supplier_locationcard.dart';

class Newpurchase extends StatefulWidget {
  final bool isEdit;
  final String? warehouselocation;
final Map<String, dynamic>? purchaseData;
  const Newpurchase({super.key,
  required this.isEdit,
  required this.purchaseData,
  this.warehouselocation

 });
 

  @override
  State<Newpurchase> createState() => _NewpurchaseState();
}

class _NewpurchaseState extends State<Newpurchase> {
   final TextEditingController totalAdditionalCostController = TextEditingController();
  final TextEditingController costPerTrayController = TextEditingController();
  final TextEditingController totalCostController = TextEditingController();
 final TextEditingController supplierNameController = TextEditingController();
  final TextEditingController supplierLocationController = TextEditingController(); 
final TextEditingController quantityController = TextEditingController();
final TextEditingController countController = TextEditingController();
final TextEditingController neccController = TextEditingController();
final TextEditingController minusController = TextEditingController();
final TextEditingController trayController = TextEditingController();
final TextEditingController rateController = TextEditingController();
final TextEditingController descriptionController = TextEditingController();
 final TextEditingController totalEggsController = TextEditingController();
final TextEditingController branchController=TextEditingController();
final TextEditingController numberController=TextEditingController();
final TextEditingController typeController=TextEditingController();
final TextEditingController contactController=TextEditingController();
final TextEditingController driverController=TextEditingController();
final TextEditingController categoryController = TextEditingController();
final TextEditingController loadingController=TextEditingController();
final TextEditingController unloadingController=TextEditingController();
final TextEditingController transportController=TextEditingController();
final TextEditingController miscController=TextEditingController();
final TextEditingController brokerNameController = TextEditingController();
 final TextEditingController brokerNumController = TextEditingController();
 final TextEditingController brokerFeeController=TextEditingController();

bool _isDataLoaded = false;
void calculateSummary() {
  final quantity = double.tryParse(quantityController.text) ?? 0;
  final rate = double.tryParse(rateController.text) ?? 0;

  final loading = 500;   // later connect from controller
  final unloading = 300;
  final transport = 1000;
  final misc = 200;

  final totalCost = (quantity * rate) + loading + unloading + transport + misc;

  setState(() {
    
  });
}
void _refresh() {
  setState(() {}); 
}
@override
void initState() {
  super.initState();

 context.read<PurchaseBloc>().add(FetchPurchaseInitData());

  quantityController.addListener(_refresh);
  rateController.addListener(_refresh);
  loadingController.addListener(_refresh);
  unloadingController.addListener(_refresh);
  transportController.addListener(_refresh);
  miscController.addListener(_refresh);
  brokerFeeController.addListener(_refresh);

   WidgetsBinding.instance.addPostFrameCallback((_) {
    if (widget.isEdit && widget.purchaseData != null) {
      _fillEditData(widget.purchaseData!);
    }
  });
}
void _fillEditData(Map<String, dynamic> data) {
  if (_isDataLoaded) return;

 
  supplier = data['supplier_company_name'] ?? '';
location = data['warehouse_location'] ?? '';

 
   final List items = data['items'] ?? [];

  List<ProductInput> editProducts = [];
 
  int totalTrays = 0;
int totalEggs = 0;
double totalItemCost = 0;
  for (var item in items) {
    editProducts.add(ProductInput(
      category: item['egg_category_grade'] ?? '',
      quantity: (item['trays'] ?? 0).toString(),
      rate: (item['per_egg_price'] ?? 0).toString(),
      totalEggs: ((item['trays'] ?? 0) * (item['capacity'] ?? 30)).toString(),
    ));
  }

  final List expenses = data['expenses'] ?? [];

  double loading = 0;
  double unloading = 0;
  double transport = 0;
  double misc = 0;

  for (var exp in expenses) {
    final amount = (exp['amount'] ?? 0).toDouble();

    switch (exp['expense_type']) {
      case "LOADING":
        loading += amount;
        break;
      case "UNLOADING":
        unloading += amount;
        break;
      case "TRANSPORT":
        transport += amount;
        break;
      case "MISC":
        misc += amount;
        break;
    }
  }

  loadingController.text = loading.toString();
  unloadingController.text = unloading.toString();
  transportController.text = transport.toString();
  miscController.text = misc.toString();

 double additionalCost = loading + unloading + transport + misc;
double totalCost = totalItemCost + additionalCost;

 setState(() {
    products = editProducts;

    loadingController.text = loading.toString();
    unloadingController.text = unloading.toString();
    transportController.text = transport.toString();
    miscController.text = misc.toString();

    totalAdditionalCostController.text = additionalCost.toStringAsFixed(2);
    totalCostController.text = totalCost.toStringAsFixed(2);

    costPerTrayController.text =
        totalTrays == 0 ? "0" : (totalCost / totalTrays).toStringAsFixed(2);

    _isDataLoaded = true;
  });
}
@override
void didChangeDependencies() {
  super.didChangeDependencies();

  final supplierState = context.watch<SupplierBloc>().state;

  if (widget.isEdit && widget.purchaseData != null && supplierState is SupplierLoaded) {
    final data = widget.purchaseData!;
    final suppliers = supplierState.suppliers;

   final supplier = suppliers
    .where((s) => s.id == data['supplier_id'])
    .toList();

supplierNameController.text =
    supplier.isNotEmpty ? supplier.first.companyName : '';

    
  }
}


@override
void dispose() {
  supplierNameController.dispose();
  supplierLocationController.dispose();
  categoryController.dispose();
  quantityController.dispose();
  rateController.dispose();
  totalEggsController.dispose();

  loadingController.dispose();
  unloadingController.dispose();
  transportController.dispose();
  miscController.dispose();

  totalAdditionalCostController.dispose();
  costPerTrayController.dispose();
  totalCostController.dispose();
   brokerNameController.dispose();
   brokerNumController.dispose();

  super.dispose();
}
int supplierId = 0;
String supplier = "";
String location = "";
String category = "";
String warehouselocation="";

List<ProductInput> products = [ProductInput(),];

  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    final productSummaries = products
    .map((p) => ProductSummary(
      category: p.category,
      quantity: p.quantity,
      rate: p.rate,
      totalEggs: p.totalEggs,
    ))
    .toList();
    return Scaffold(backgroundColor: AppColors.background1,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        title:  Text("New Purchase",style: AppTextStyles.headingText25,),

      actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
               child: const Icon(
    Icons.person,
    color: Colors.white,
    size: 20,
  ),
            ),
          ),
        ],),

        body: BlocBuilder<PurchaseBloc, PurchaseState>(
  builder: (context, state) {
    final Size size = MediaQuery.of(context).size;
     
    
    if (state is PurchaseLoading) {
      return const PurchaseShimmer();
    }

    if (state is PurchaseError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context
                    .read<PurchaseBloc>()
                    .add(FetchPurchaseInitData());
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (state is PurchaseLoaded) { 
final supplierState = context.watch<SupplierBloc>().state;

String supplierName = "";

if (supplierState is SupplierLoaded) {
  try {
    final supplier = supplierState.suppliers.firstWhere(
      (s) => s.id == widget.purchaseData!['supplier_id'],
    );
    supplierName = supplier.companyName;
  } catch (e) {
    supplierName = "";
    supplierNameController.text = supplierName;
  }
}

      return SingleChildScrollView(
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
                padding: EdgeInsets.only(
                  left: size.width * 0.02,
                ),
                child: Text(
                  "Record new form procurement and \nstock.",
                  style: AppTextStyles.bodyText16,
                ),
              ),

              SizedBox(height: size.height * 0.02),

            
              SupplierLocationCard(
  
  onChanged: (sup, loc, id) {
    setState(() {
      supplier = sup;
      location = loc;
      supplierId = id;
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
                
  onProductsChanged: (updatedList) {
    setState(() {
      products = updatedList;
    });
  },
               
                countController: countController,
                trayController: trayController,
                quantityController: quantityController,
                neccController: neccController,
                minusController: minusController,
                rateController: rateController,
               
                loadingController: loadingController,
                unloadingController: unloadingController,
                transportController: transportController,
                miscController: miscController,
              ),

              SizedBox(height: size.height * 0.02),

             AdditionalCostCard(
  loadingController: loadingController,
  unloadingController: unloadingController,
  transportController: transportController,
  miscController: miscController,
  brokerFeeController: brokerFeeController,
),

SizedBox(height: size.height * 0.02),
            
              PurchaseEmployeecard(
                driverController: driverController,
                branchController: branchController,
                numberController: numberController,
                typeController: typeController,
                contactController: contactController,
                descriptionController: descriptionController,
                
              ),

              SizedBox(height: size.height * 0.02),
            
              PurchaseSummaryCard(
                supplier: supplier,
                location: location,
                 warehouselocation: widget.purchaseData?['warehouse_location'] ?? '',
              products:productSummaries,
                loading: loadingController.text,
                unloading: unloadingController.text,
                transport: transportController.text,
                misc: miscController.text,
                brokerFee: brokerFeeController.text,
               brokerName: brokerNameController.text,
               brokerNumber: brokerNumController.text,
               description: descriptionController.text,
              ),

              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      );
    }

    // fallback (initial state)
    return const SizedBox();
  },
),
    );
  }
}