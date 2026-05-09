import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/menu/presentation/add_branch_details.dart';
import 'package:proteinova_connect/features/admin/menu/widget/info_cards.dart';

class BranchManagement extends StatefulWidget {
  const BranchManagement({super.key});

  @override
  State<BranchManagement> createState() => _BranchManagementState();
}

class _BranchManagementState extends State<BranchManagement> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
       appBar: AppBar(
        automaticallyImplyLeading: false,
  backgroundColor: const Color(0xffF7F7F7),
  elevation: 0,

  

  titleSpacing: 16,

  title: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    mainAxisAlignment:
        MainAxisAlignment.center,
    children: [

      const Text(
        "Branch Management",
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 8),

      Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),

        decoration: BoxDecoration(
          color: const Color(0xffFFF7D6),
          borderRadius:
              BorderRadius.circular(30),
        ),

        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            Icon(
              Icons.verified_user_outlined,
              size: 14,
              color: Colors.black,
            ),

            SizedBox(width: 6),

            Text(
              "Role: Inventory & Ops Admin",
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ],
  ),

  actions: [

    Container(
      margin: const EdgeInsets.only(
        right: 10,
        top: 12,
        bottom: 12,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,vertical: 5
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),

      child: Row(
        children: const [

          Text(
            "All Branches",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(Icons.arrow_drop_down_outlined)
        ],
      ),
    ),

   Icon(
        Icons.notifications_none_outlined,
        size: 20,
        color: Colors.black,
      ),
   
  ],
),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
           Expanded(
             child: InfoCards(
              title: "Total Active Branches",
               value: "0", 
               percent: "+ 1", 
               subtitle: "new branch this year", 
               icon: Icons.trending_up,
                topIcon: Icons.store_outlined, 
                topIconColor: AppColors.blueAccent, 
                iconColor: AppColors.green),
           ),
              const SizedBox(width: 10,),
              Expanded(
                child: InfoCards(
                            title: "Total Egg Stock",
                             value: "0", 
                             percent: "Live", 
                             subtitle: "across all grades", 
                             icon: Icons.trending_up,
                topIcon: Icons.stacked_bar_chart, 
                topIconColor: AppColors.deepOrange, 
                iconColor: AppColors.green),
              )
          ],),
           const SizedBox(height: 10,),
           Row(children: [
           Expanded(
             child: InfoCards(
              title: "Total Sales Today",
               value: "₹0", 
               percent: "+5.4%", 
               subtitle: "vs yesterday", 
               icon: Icons.trending_up,
                topIcon:  Icons.currency_rupee, 
                topIconColor: Colors.deepPurple, 
                iconColor: AppColors.green),
           ),
              const SizedBox(width: 10,),
              Expanded(
                child: InfoCards(
                            title: "Branch Revenue (MTD)",
                             value: "₹0", 
                             percent: "+0%", 
                             subtitle: "vs last month", 
                             icon: Icons.trending_up,
                topIcon: Icons.currency_rupee, 
                topIconColor: AppColors.green, 
                iconColor: AppColors.green),
              )
          ],),
          const SizedBox(height: 10,),
          Container(
  padding: const EdgeInsets.all(16),

  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),

    border: Border.all(
      color: Colors.grey.shade300,
    ),
  ),

  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [

      Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [

          const Text(
            "Branch Directory",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddBranchDetails(),
      ),
    );
  },

  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 10,
    ),

    decoration: BoxDecoration(
      color: const Color(0xffFACC15),
      borderRadius: BorderRadius.circular(12),
    ),

    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Icon(
          Icons.add,
          size: 18,
          color: Colors.black,
        ),

        SizedBox(width: 6),

        Text(
          "Add New Branch",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  ),
)
        ],
      ),

      const SizedBox(height: 20),
     Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
              ),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                        12),

                border: Border.all(
                  color:
                      Colors.grey.shade300,
                ),
              ),

              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText:
                      "Filter name or location...",
                  icon: Icon(
                    Icons.search,
                    size: 20,
                  ),
                ),
              ),
            ),
        
      const SizedBox(height: 10),
      /// FILTER ROW
      Row(
        children: [

          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
              ),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                        12),

                border: Border.all(
                  color:
                      Colors.grey.shade300,
                ),
              ),

              child:
                  DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: "All Regions",

                  isExpanded: true,

                  items: const [

                    DropdownMenuItem(
                      value: "All Regions",
                      child: Text(
                        "All Regions",
                      ),
                    ),

                    DropdownMenuItem(
                      value: "North",
                      child: Text("North"),
                    ),

                    DropdownMenuItem(
                      value: "South",
                      child: Text("South"),
                    ),
                  ],

                  onChanged: (value) {},
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
              ),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                        12),

                border: Border.all(
                  color:
                      Colors.grey.shade300,
                ),
              ),

              child:
                  DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: "All Statuses",

                  isExpanded: true,

                  items: const [

                    DropdownMenuItem(
                      value:
                          "All Statuses",
                      child: Text(
                        "All Statuses",
                      ),
                    ),

                    DropdownMenuItem(
                      value: "Active",
                      child: Text(
                        "Active",
                      ),
                    ),

                    DropdownMenuItem(
                      value: "Inactive",
                      child: Text(
                        "Inactive",
                      ),
                    ),
                  ],

                  onChanged: (value) {},
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10,),
      Container(
         width: double.infinity, 
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background1,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
      Expanded(
        flex: 2,
        child: Text(
          "BRANCH\nDETAILS",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyText12dark,
        ),
      ),
      
      Expanded(
        flex: 2,
        child: Text(
          "BRANCH\nMANAGER",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyText12dark,
        ),
      ),
      
      Expanded(
        flex: 2,
        child: Text(
          "STATUS",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyText12dark,
        ),
      ),
      
      Expanded(
        flex: 2,
        child: Text(
          "CURRENT\nSTOCK",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyText12dark,
        ),
      ),
      
      Expanded(
        flex: 2,
        child: Text(
          "SALES\n(MTD)",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyText12dark,
        ),
      ),
      
      Expanded(
        flex: 2,
        child: Text(
          "ACTIONS",
           textAlign: TextAlign.center,
          style: AppTextStyles.bodyText12dark,
        ),
      ),
          ],
        ),
      ),
      const SizedBox(height: 20,),
       Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Text("No branches found",
            style: AppTextStyles.bodyText14dark,),
             Text("Add a new branch to get started",
            style: AppTextStyles.bodyText14,),

          ],),
          
       ),
       const SizedBox(height: 10,),
    ],
  ),
),

        ],),
      ),
    );
  }
}