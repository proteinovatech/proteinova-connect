import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/home/presentation/newpurchase.dart';
import 'package:proteinova_connect/features/home/widget/purchasecard.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
   int selectedIndex = 0;

  final List<String> tabs = [
    "All Purchanses",
    "In transit",
    "Recevied",
    "Drafts",
    "Pending"
  ];

  @override
  Widget build(BuildContext context) {
     final Size size=MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        
        padding:EdgeInsets.only(left:size.width*0.05,right: size.width*0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height:size.height*0.07,),
            Padding(
            padding: EdgeInsets.only(left:size.width*0.8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
             
            ),
          ),
            Divider(),
            
            Text("Purchase",style: AppTextStyles.headingText25,),
              Text("Manage Purchase orders and Incoming stocks. ",
              style: AppTextStyles.bodyText16,
              ),
               SizedBox(height: size.height*0.02,),
               GestureDetector(
                onTap: (){Navigator.push(context, 
                MaterialPageRoute(builder: (context)=>Newpurchase()));},
                 child: Container(
                  width:size.width*0.90,
                           padding: const EdgeInsets.all(12),
                           decoration: BoxDecoration(
                             color: AppColors.amber600,
                             borderRadius: BorderRadius.circular(12),
                           ),
                           
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             mainAxisSize: MainAxisSize.min,
                             children: [
                         Icon(Icons.add, color:AppColors.dark),
                         SizedBox(width: 8),
                         Text(
                           "New Purchanse Entry",
                           style: AppTextStyles.headingText21,
                           
                         ),
                             ],
                           ),
                         ),
               ),
        SizedBox(height:size.height*0.03,),
       SizedBox(
  height:size.height*0.05,
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: tabs.length,
    separatorBuilder: (context, index) => const SizedBox(width: 20), // 🔥 space between items
    itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tabs[index],
              style: AppTextStyles.bodyText16.copyWith(
                color: selectedIndex == index
                    ? AppColors.dark
                    : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: selectedIndex == index
                    ? AppColors.amber500
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
            )
          ],
        ),
      );
    },
  ),
),
Divider(),
SizedBox(height: size.height * 0.03,),
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  height: MediaQuery.of(context).size.height * 0.05,
  width: double.infinity, // 🔥 full width
  decoration: BoxDecoration(
    color: AppColors.background,
   border: BoxBorder.all(color:Color.fromARGB(255, 196, 193, 193))
  ),
  child: Row(
    children: [
      Icon(Icons.search, color: Colors.grey),
      SizedBox(width: 10),
      Expanded(
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search drafts by Id or supplier ...",
            
            border: InputBorder.none,
          ),
        ),
      ),
    ],
  ),
),
SizedBox(height: size.height * 0.03,),
Row(
  children: [
    
    Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border:BoxBorder.all(color:Color.fromARGB(255, 196, 193, 193))
         
        ),
        child: Row(
          children: [
            Icon(Icons.filter_alt_outlined, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "All Suppliers",
                style: AppTextStyles.bodyText16,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    ),

    const SizedBox(width: 10),


    Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
           border:BoxBorder.all(color:Color.fromARGB(255, 196, 193, 193))
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Last 30 days",
                style: AppTextStyles.bodyText16,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            
          ],
        ),
        
      ),
      
    ),
  
  ],
),
SizedBox(height: size.height * 0.03,),
Expanded(
  child: SingleChildScrollView(
    child: Column(
      children: [
        PurchaseCard(
          status: "Received",
          statusColor: Colors.green,
          textColor: Colors.white,
          supplier: "Apex Farms",
        ),
       

        SizedBox(height: size.height * 0.02),

        PurchaseCard(
          status: "Draft",
          statusColor: Color.fromARGB(255, 199, 209, 231),
          textColor: Colors.blue,
          supplier: "Valley Farms",
        ),

        SizedBox(height: size.height * 0.02),

        PurchaseCard(
          status: "In transit",
          statusColor: Color.fromARGB(255, 245, 205, 190),
          textColor: Colors.brown,
          supplier: "Sunrise Poultry",
        ),
      ],
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}