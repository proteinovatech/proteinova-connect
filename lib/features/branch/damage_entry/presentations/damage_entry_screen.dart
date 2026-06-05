import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/damage_entry/bloc/damage_bloc.dart';
import 'package:proteinova_connect/features/branch/damage_entry/bloc/damage_event.dart';
import 'package:proteinova_connect/features/branch/damage_entry/bloc/damage_state.dart';

class DamageEntryScreen extends StatefulWidget {
  const DamageEntryScreen({super.key});

  @override
  State<DamageEntryScreen> createState() => _DamageEntryScreenState();
}
 

class _DamageEntryScreenState extends State<DamageEntryScreen> {
  
  final TextEditingController eggController = TextEditingController();
   @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

  final bloc = context.read<DamageBloc>();

  bloc.add(FetchDamageCategoriesEvent(branchId: 11));
  bloc.add(FetchDamageHistoryEvent(branchId: 11));

});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.background1,
          scrolledUnderElevation: 0,
          elevation: 0,
          title:  Row(
    children: [

      const Icon(
        Icons.error_outline_rounded,
        color: Colors.red,
        size: 28,
      ),

      const SizedBox(width: 8),

      Text(
        "Global Damage Entry",
        style: AppTextStyles.headingText22,
      ),
    ],
  ),
          ),
          body:  BlocListener<DamageBloc, DamageState>(
            listenWhen: (previous, current) {

    return previous.isSubmitting && !current.isSubmitting;
  },

  listener: (context, state) {
    
    if (!state.isSubmitting && state.error == null) {

      if (eggController.text.isNotEmpty) {

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Damage reported successfully"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );

        eggController.clear();
      }
    }

    if (state.error != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text(state.error!),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  },

  child:BlocBuilder<DamageBloc, DamageState>(
  builder: (context, state) {

   if (state.isLoadingCategories && state.categories.isEmpty) {
  return const Center(child: CircularProgressIndicator());
}

    return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                 
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                       boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  
                         Center(
              child: Text(
                "Report Damage",
                style: AppTextStyles.headingText20
              ),
                        ),
                  
                        const SizedBox(height: 20),
                  
                         Text(
              "Egg Category *",
              style: AppTextStyles.buttonText16,
                        ),
                  
                        const SizedBox(height: 8),
                  Container(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300),
  ),
  child: BlocBuilder<DamageBloc, DamageState>(
    builder: (context, state) {

      if (state.isLoadingCategories) {
        return const Padding(
          padding: EdgeInsets.all(12),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final categories = state.categories;
      print(state.selectedCategory);
print(categories.length);
return DropdownButton<String>(
  isExpanded: true,
  underline: const SizedBox(),

  value: state.selectedCategory,

  hint: const Text("Select Category"),

  items: categories.map((category) {
    return DropdownMenuItem<String>(
      value: category.eggCategoryGrade,
      child: Text(
        "${category.eggCategoryGrade} (${category.eggsAvailable} eggs available)",
      ),
    );
  }).toList(),

  onChanged: (value) {
    if (value != null) {
      context.read<DamageBloc>().add(
            SelectCategoryEvent(value),
          );
    }
  },
);
    },
  ),
),
                  
                        const SizedBox(height: 20),
                  
                         Text(
              "Number of Damaged Eggs *",
              style: AppTextStyles.buttonText16,
                        ),
                  
                        const SizedBox(height: 8),
                  
                        TextField(
  controller: eggController,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    hintText: "e.g. 5",
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),
                  
                        const SizedBox(height: 10),
                  
                        const Center(
              child: Text(
                "Maximum limit: 1320 eggs",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
                        ),
                  
                        const SizedBox(height: 20),
                  
                        SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
               onPressed: state.isSubmitting
    ? null
    : () {
        

        if (state.selectedCategory == null || eggController.text.isEmpty) return;

        context.read<DamageBloc>().add(
              ReportDamageEvent(
                branchId: 11,
                category: state.selectedCategory!,
                damagedEggs: eggController.text,
              ),
            );
      },
                child: state.isSubmitting
    ? const CircularProgressIndicator(color: Colors.white)
    :  Text("Report Damage",style:AppTextStyles.whiteText ,),
              ),
                        ),
                      ],
                    ),
                  ),
              
                  const SizedBox(height: 20),
              
                  /// RIGHT CONTAINER
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                       boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  
                        const Center(
              child: Text(
                "Damage History",
                style: AppTextStyles.headingText20
              ),
                        ),
                  
                        const SizedBox(height: 20),
               state.history.isEmpty
  ? const Center(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Text("No history found"),
    ),
  )


                    :ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: state.history.length,
  itemBuilder: (context, index) {

    final item = state.history[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              item.date,
              style: AppTextStyles.bodyText16,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.category,
              style: AppTextStyles.headingText16
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.egg, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      "${item.damagedEggs} Eggs",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text("${item.trays} Trays"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  
  },)          
                      ],
                    ),
                  ),
                
                ],
              ),
            ),);
   } )));
   }
  }
