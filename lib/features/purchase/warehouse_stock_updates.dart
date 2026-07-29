import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_event.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_state.dart';


class WarehouseStockUpdates extends StatefulWidget {
  const WarehouseStockUpdates({super.key});

  @override
  State<WarehouseStockUpdates> createState() => _WarehouseStockUpdatesState();
}

class _WarehouseStockUpdatesState extends State<WarehouseStockUpdates> {
  String getDisplayStatus(String? status) {
  if (status == "RECEIVED") {
    return "Received to Warehouse";
  }
  return "In Transit";
}
  @override
void initState() {
  super.initState();

  context.read<PurchaseBloc>().add(
    GetCachedPurchasesEvent(),
  );
}
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
            appBar: AppBar(
        backgroundColor:AppColors.background,
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: 90,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Warehouse Stock Updates",
             style: AppTextStyles.headingText25.copyWith(
  fontSize: getFontSize(context, 22, tablet: 28),
),
            ),

            SizedBox(height: 4),

            Text(
              "Track inventory movements and stock changes",
              style: TextStyle(
  color: Colors.grey,
  fontSize: getFontSize(context, 12, tablet: 14),
),
            ),
          ],
        ),

    ),
      backgroundColor:AppColors.background,
 body: BlocBuilder<PurchaseBloc, PurchaseState>(
  builder: (context, state) {
    if (state is PurchaseLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is PurchaseError) {
      return Center(
        child: Text(state.message),
      );
    }

if (state is PurchaseLoaded) {
   print("Purchase Response:");
  print(state.purchases);
   final today = DateTime.now();

bool isToday(String? date) {
  if (date == null || date.isEmpty) return false;

  final d = DateTime.parse(date);

  return d.year == today.year &&
      d.month == today.month &&
      d.day == today.day;
}
                     
  final todayTransit = state.purchases.where((p) {
  return p["movement_status"] != "RECEIVED" &&
      isToday(p["expected_arrival"]);
}).length;

final todayReached = state.purchases.where((p) {
  return p["movement_status"] == "RECEIVED" &&
      isToday(p["expected_arrival"]);
}).length;

final totalReceived = state.purchases.where((p) {
  return p["movement_status"] == "RECEIVED";
}).length;
                  
 

  final arrivals = state.purchases.where(
  (p) => p["movement_status"] != "RECEIVED",
).toList();

final availableStock = state.purchases.where(
  (p) => p["movement_status"] == "RECEIVED",
).toList();



  return SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.all(getWidth(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

                _buildOverviewCards( 
                  todayTransit,
                  todayReached,
                  totalReceived,
                  ),
                const SizedBox(height: 15),

                      

          /// New Stock Arrivals
          Text(
            "New Stock Arrivals",
            style: AppTextStyles.headingText16.copyWith(
  fontSize: getFontSize(context, 16, tablet: 20),
),
          ),

          SizedBox(height: getHeight(context, 12)),

          arrivals.isEmpty
    ? Container(
        width: double.infinity,
        padding: EdgeInsets.all(
          getWidth(context, 16),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            getWidth(context, 16),
          ),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: const Center(
          child: Text(
            "No new stock arrivals",
          ),
        ),
      )
      
    :ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: arrivals.length,
            itemBuilder: (context, index) {
              final purchase = arrivals[index];

              final items =
                  purchase["items"] as List? ?? [];

             final trays = items.fold<int>(
  0,
  (sum, item) => sum + ((item["trays"] ?? 0) as int),
);

final totalAmount = items.fold<double>(
  0.0,
  (sum, item) {
    final trays = item["trays"] ?? 0;
    final capacity = item["capacity"] ?? 30;
    final rate = double.tryParse(
          item["per_egg_price"]?.toString() ?? "0",
        ) ??
        0.0;

    return sum + (trays * capacity * rate);
  },
);
              
             

              return buildActivityCard(
                context,
                type: "DELIVERY",
                refId: "PO-${purchase["id"]}",
                trays: trays,
                category: items.isNotEmpty
                    ? items.first["egg_category_grade"] ?? "--"
                    : "--",
                amount: totalAmount,
                from: purchase["purchased_location"] ?? "--",
                to: purchase["warehouse_location"] ?? "--",
                time: purchase["created_at"]
        ?.toString()
        .split("T")
        .first ??
    "--",
               status: getDisplayStatus(
  purchase["movement_status"]?.toString(),
),
              );
            },
          ),

          SizedBox(height: getHeight(context, 24)),

          /// Available Stock
          Text(
            "Available Stock",
            style: AppTextStyles.headingText16,
          ),

          SizedBox(height: getHeight(context, 12)),

         availableStock.isEmpty
    ? Container(
        width: double.infinity,
        padding: EdgeInsets.all(
          getWidth(context, 16),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            getWidth(context, 16),
          ),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: const Center(
          child: Text("No stock available"),
        ),
      )
    : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: availableStock.length,
            itemBuilder: (context, index) {
              final purchase =
                  availableStock[index];

              final items =
                  purchase["items"] as List? ?? [];

              final trays = items.fold<int>(
  0,
  (sum, item) => sum + ((item["trays"] ?? 0) as int),
);

final totalAmount = items.fold<double>(
  0.0,
  (sum, item) {
    final trays = item["trays"] ?? 0;
    final capacity = item["capacity"] ?? 30;
    final rate = double.tryParse(
          item["per_egg_price"]?.toString() ?? "0",
        ) ??
        0.0;

    return sum + (trays * capacity * rate);
  },
);
              

              return buildActivityCard(
                context,
                type: "PURCHASE",
                refId: "PO-${purchase["id"]}",
                trays: trays,
                category: items.isNotEmpty
                    ? items.first["egg_category_grade"] ?? "--"
                    : "--",
                amount: totalAmount,
                from: purchase["purchased_location"] ?? "--",
                to: purchase["warehouse_location"] ?? "--",
               time: purchase["created_at"]
        ?.toString()
        .split("T")
        .first ??
    "--",
               status: getDisplayStatus(
  purchase["movement_status"]?.toString(),
),
              );
            },
          ),
        ],
      ),
    ),
  );
} return const SizedBox();
}

    
  ));}
    Widget _buildOverviewCards( int todayTransit,
  int todayReached,
  int totalReceived,) {
    
  final cards = [
    {
      "title": "TODAY IN TRANSIT",
      "count":todayTransit ,
      "icon": Icons.local_shipping,
      "color": Colors.blue,
    },
    {
      "title": "TODAY REACHED",
      "count":todayReached,
      "icon": Icons.check_circle,
      "color": Colors.green,
    },
    {
      "title": "TOTAL RECEIVED",
      "count": totalReceived ,
      "icon": Icons.inventory,
      "color": Colors.orange,
    },
  ];

  return LayoutBuilder(
    builder: (context, constraints) {
      final cardWidth = (constraints.maxWidth - 12) / 2;

      return Column(
        children: [
          // First row
          Row(
            children: [
              SizedBox(
                width: cardWidth,
                child: _overviewCard(cards[0]),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: cardWidth,
                child: _overviewCard(cards[1]),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Second row - centered
          Center(
            child: SizedBox(
              width: cardWidth,
              child: _overviewCard(cards[2]),
            ),
          ),
        ],
      );
    },
  );
}

Widget _overviewCard(Map card) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(18),
  border: Border(
    top: BorderSide(
      color: card["color"] as Color,
      width: 4,
    ),
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ],
),
    child: Row(
      children: [
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: (card["color"] as Color).withOpacity(.12),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            card["icon"],
            color: card["color"],
            size: 28,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card["title"],
                style: AppTextStyles.bodyText12.copyWith(
  fontSize: getFontSize(context, 11, tablet: 13),
),
              ),
              const SizedBox(height: 6),
              Text(
                "${card["count"]}",
                style: AppTextStyles.headingText20.copyWith(
  fontSize: getFontSize(context, 20, tablet: 24),
),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}



  }
 Widget buildActivityCard(
  BuildContext context, {
  required String type,
  required String refId,
  required int trays,
  required String from,
  required String to,
  required String time,
  required String status,
  required String category,
required double amount,
}) {
  final isTablet = MediaQuery.of(context).size.width >= 600;
  return Container(
    margin: EdgeInsets.only(bottom: getHeight(context, 16)),
    padding: EdgeInsets.all(getWidth(context, 16)),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(getWidth(context, 18)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: getWidth(context, 12),
          offset: Offset(0, getHeight(context, 4)),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ref Circle
        Container(
          width: getWidth(context, 52),
          height: getWidth(context, 52),
          decoration: const BoxDecoration(
            color: Color(0xFFE8F0FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              refId,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: getFontSize(context, 11, tablet: 13),
              ),
            ),
          ),
        ),
  
        SizedBox(width: getWidth(context, 16)),
  
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: getFontSize(context, 13, tablet: 15),
                  ),
                  children: [
                    TextSpan(
                      text: "$type ",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          " ($trays trays) moved from $from to $to",
                    ),
                  ],
                ),
              ),
              
        SizedBox(height: getHeight(context, 10)),
Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Category",
            style: AppTextStyles.bodyText10dark.copyWith(
  fontSize: getFontSize(context, 10, tablet: 12),
),
          ),
          Text(
            category,
            style: AppTextStyles.containerText.copyWith(
  fontSize: getFontSize(context, 13, tablet: 15),
),
          ),
        ],
      ),
    ),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "Amount",
            style: AppTextStyles.bodyText10dark.copyWith(
  fontSize: getFontSize(context, 10, tablet: 12),
),
          ),
          
          Text(
            "₹${amount.toStringAsFixed(0)}",
            style: AppTextStyles.containerText.copyWith(
  fontSize: getFontSize(context, 13, tablet: 15),
),
          ),
        ],
      ),
    ),
  ],
),
SizedBox(height: getHeight(context, 12)),

  
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: getWidth(context, 12),
                runSpacing: getHeight(context, 8),
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: getWidth(context, 16),
                        color: Colors.grey,
                      ),
                      SizedBox(width: getWidth(context, 6)),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: getFontSize(context, 11, tablet: 13),
                        ),
                      ),
                    ],
                  ),
  
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(context, 10),
                      vertical: getHeight(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: status == "Received to Warehouse"
                          ? Colors.green.withOpacity(.1)
                          : Colors.blue.withOpacity(.1),
                      borderRadius:
                          BorderRadius.circular(getWidth(context, 20)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: status == "Received to Warehouse"
                            ? Colors.green
                            : Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: getFontSize(context, 10, tablet: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
  

SizedBox(height: getHeight(context, 12)),
  
        Container(
  width: isTablet ? getWidth(context, 42) : getWidth(context, 35),
  height: isTablet ? getWidth(context, 42) : getWidth(context, 35),
  decoration: BoxDecoration(
    color: type == "PURCHASE"
        ? Colors.green
        : AppColors.blue,
    borderRadius: BorderRadius.circular(
      isTablet ? getWidth(context, 16) : getWidth(context, 14),
    ),
  ),
  child: Icon(
    type == "PURCHASE"
        ? Icons.shopping_cart_outlined
        : Icons.local_shipping_outlined,
    color: Colors.white,
    size: getFontSize(context, 22, tablet: 26),
  ),
),
      ],
    ),
  );
}


