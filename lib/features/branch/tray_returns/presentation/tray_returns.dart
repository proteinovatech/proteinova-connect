import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/stock.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/stockdetails.dart';
import 'package:proteinova_connect/features/branch/tray_returns/bloc/tray_return_bloc.dart';
import 'package:proteinova_connect/features/branch/tray_returns/data/model/tray_return_model.dart';
import 'package:proteinova_connect/features/branch/tray_returns/presentation/tray_records.dart';
import 'package:proteinova_connect/features/branch/tray_returns/presentation/tray_return_shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrayReturn extends StatefulWidget {
  const TrayReturn({super.key});

  @override
  State<TrayReturn> createState() => _TrayReturnState();
}

class _TrayReturnState extends State<TrayReturn> {
  int? branchId;
  String? currentDate;
  String selectedReturnFrom = "Customer";

  List<String> returnFromList = ["Customer", "Branch", "Supplier"];
  @override
  void initState() {
    super.initState();
    _loadBranchIdAndFetch();
  }

  Future<void> _loadBranchIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    branchId = prefs.getInt("branch_id");
    if (branchId != null) {
      context.read<TrayReturnBloc>().add(
        FetchTrayReturnData(branchId: branchId!, date: currentDate),
      );
      context.read<TrayReturnBloc>().add(FetchWarehouses());
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.background1,
      body: BlocConsumer<TrayReturnBloc, TrayReturnState>(
        listener: (context, state) {
          if (state is TrayReturnError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error: ${state.message}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          print("TrayReturn State: $state");
          TrayReturnModel? model;
          if (state is TrayReturnLoaded) {
            model = state.model;
            print("TrayReturn Model Records Count: ${model.data.length}");
          }

          if (state is TrayReturnLoading && model == null) {
            return const TrayReturnShimmer();
          }

          // Define empty/default data if model is null (e.g. on error or initial load)
          final cards =
              model?.cards ??
              Cards(
                refundCredit: 0,
                damagedTrays: 0,
                totalReturnedThisMonth: 0,
                goodTrays: 0,
              );
          final dataList = model?.data ?? [];

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            "Tray Return",
                            style: AppTextStyles.headingText22,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              currentDate = DateFormat(
                                'yyyy-MM-dd',
                              ).format(pickedDate);
                            });
                            if (branchId != null) {
                              context.read<TrayReturnBloc>().add(
                                FetchTrayReturnData(
                                  branchId: branchId!,
                                  date: currentDate,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                currentDate ?? "All Time",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (state is TrayReturnLoading)
                    const LinearProgressIndicator(minHeight: 2),
                  SizedBox(height: size.height * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showFilteredModal(
                            context,
                            "Damaged",
                            dataList
                                .where((r) => r.condition == 'DAMAGED')
                                .toList(),
                          ),
                          child: Stockdetails(
                            title: "Damaged",
                            value: "${cards.damagedTrays} trays",
                            icon: Icons.dangerous_outlined,
                            iconBg: const Color(0xfffef2f2),
                            iconColor: Colors.red,
                            highlightUnit: true,
                          ),
                        ),
                      ),
                      SizedBox(width: getWidth(context, 6)),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showFilteredModal(
                            context,
                            "Returned This Month",
                            dataList,
                          ),
                          child: Stock(
                            title: "Returned This Month",
                            value: "${cards.totalReturnedThisMonth}",
                            percent: "MONTH",
                            subtitle: "Current Month",
                            icon: Icons.inventory,
                            iconBg: const Color(0xffeff6ff),
                            iconColor: Colors.blue,
                            highlightUnit: true,
                          ),
                        ),
                      ),
                      SizedBox(width: getWidth(context, 6)),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showFilteredModal(
                            context,
                            "Good Condition",
                            dataList
                                .where((r) => r.condition == 'GOOD')
                                .toList(),
                          ),
                          child: Stockdetails(
                            title: "Good Condition",
                            value: "${cards.goodTrays} trays",
                            icon: Icons.check_circle_outline,
                            iconBg: const Color(0xffecfdf5),
                            iconColor: Colors.green,
                            highlightUnit: true,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // SizedBox(height: size.height * 0.02),
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.all(16),

                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: Colors.grey.shade300),
                  //   ),

                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Center(
                  //         child: Text(
                  //           "Record Tray Return",
                  //           style: AppTextStyles.headingText20,
                  //         ),
                  //       ),

                  //       const SizedBox(height: 20),

                  //       Row(
                  //         children: [
                  //           SizedBox(
                  //             width: 100,
                  //             child: Text(
                  //               "Return From :",
                  //               style: AppTextStyles.bodyText14dark,
                  //             ),
                  //           ),

                  //           Expanded(
                  //             child: DropdownButtonFormField<String>(
                  //               value: selectedReturnFrom,

                  //               decoration: InputDecoration(
                  //                 contentPadding: const EdgeInsets.symmetric(
                  //                   horizontal: 12,
                  //                   vertical: 10,
                  //                 ),

                  //                 border: OutlineInputBorder(
                  //                   borderRadius: BorderRadius.circular(6),
                  //                 ),
                  //               ),

                  //               items: returnFromList.map((item) {
                  //                 return DropdownMenuItem(
                  //                   value: item,
                  //                   child: Text(item),
                  //                 );
                  //               }).toList(),

                  //               onChanged: (value) {
                  //                 setState(() {
                  //                   selectedReturnFrom = value!;
                  //                 });
                  //               },
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(height: size.height * 0.02),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TrayRecords()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.amber600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: AppColors.dark),
                          const SizedBox(width: 8),
                          Text(
                            "Tray Records",
                            style: AppTextStyles.headingText20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    "Recent Tray Returns",
                    style: AppTextStyles.headingText20,
                  ),
                  const SizedBox(height: 10),

                  dataList.isEmpty
                      ? Container(
                          height: 120,
                          alignment: Alignment.center,
                          child: Text(
                            "No Data Available",
                            style: AppTextStyles.bodyText14.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: width >= 600
                                ? ((width * 0.9 - 320) / 5).clamp(20.0, 150.0)
                                : 20,
                            headingRowColor: MaterialStateProperty.all(
                              Colors.grey.shade100,
                            ),
                            columns: const [
                              DataColumn(label: Text("Date")),
                              DataColumn(label: Text("From")),
                              DataColumn(label: Text("Tray Type")),
                              DataColumn(label: Text("Qty")),
                              DataColumn(label: Text("Condition")),
                              DataColumn(label: Text("Price")),
                            ],
                            rows: dataList.map((item) {
                              return buildSummaryRow(
                                item.date,
                                item.from,
                                item.trayType,
                                item.qty,
                                item.condition,
                                "₹${item.price}",
                              );
                            }).toList(),
                          ),
                        ),
                  // Text(
                  //   "Recent Tray Returns",
                  //   style: AppTextStyles.headingText20,
                  // ),
                  // const SizedBox(height: 10),
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: DataTable(
                  //     columnSpacing: width >= 600
                  //         ? ((width * 0.9 - 320) / 5).clamp(
                  //             20.0,
                  //             150.0,
                  //           ) // Distribute equally on tablets
                  //         : 20, // Mobile
                  //     // ignore: deprecated_member_use
                  //     headingRowColor: MaterialStateProperty.all(
                  //       Colors.grey.shade100,
                  //     ),
                  //     columns: const [
                  //       DataColumn(label: Text("Date")),
                  //       DataColumn(label: Text("From")),
                  //       DataColumn(label: Text("Tray Type")),
                  //       DataColumn(label: Text("Qty")),
                  //       DataColumn(label: Text("Condition")),
                  //       DataColumn(label: Text("Price")),
                  //     ],
                  //     rows: dataList.isEmpty
                  //         ? [
                  //             const DataRow(
                  //               cells: [
                  //                 DataCell(Text("No Data")),
                  //                 DataCell(Text("")),
                  //                 DataCell(Text("")),
                  //                 DataCell(Text("")),
                  //                 DataCell(Text("")),
                  //                 DataCell(Text("")),
                  //               ],
                  //             ),
                  //           ]
                  //         : dataList.map((item) {
                  //             return buildSummaryRow(
                  //               item.date,
                  //               item.from,
                  //               item.trayType,
                  //               item.qty,
                  //               item.condition,
                  //               "₹${item.price}",
                  //             );
                  //           }).toList(),
                  //   ),
                  // ),

                  // SizedBox(height: size.height * 0.02),
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: Colors.grey.shade300),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         "Refund/Credit Summary",
                  //         style: AppTextStyles.headingText20,
                  //       ),
                  //       SizedBox(height: size.height * 0.02),
                  //       summaryBox(
                  //         title: "Total Refund",
                  //         value: "₹${refundSummary.totalRefund}",
                  //         bgColor: AppColors.border2,
                  //       ),
                  //       SizedBox(height: size.height * 0.01),
                  //       summaryBox(
                  //         title: "Pending Refund",
                  //         value: "₹${refundSummary.pendingRefund}",
                  //         bgColor: Colors.grey.shade100,
                  //       ),
                  //       SizedBox(height: size.height * 0.01),
                  //       summaryBox(
                  //         title: "Total Credit",
                  //         value: "₹${refundSummary.totalCredit}",
                  //         bgColor: AppColors.border2,
                  //       ),
                  //       SizedBox(height: size.height * 0.01),
                  //       summaryBox(
                  //         title: "Pending Credit",
                  //         value: "₹${refundSummary.pendingCredit}",
                  //         bgColor: Colors.grey.shade100,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget summaryBox({
    required String title,
    required String value,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.bodyText14dark),
          Text(value, style: AppTextStyles.headingText20),
        ],
      ),
    );
  }

  DataRow buildSummaryRow(
    String date,
    String from,
    String tray,
    String qty,
    String condition,
    String price,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(date, style: const TextStyle(fontSize: 11))),
        DataCell(Text(from, style: const TextStyle(fontSize: 11))),
        DataCell(Text(tray, style: const TextStyle(fontSize: 11))),
        DataCell(Text(qty, style: const TextStyle(fontSize: 11))),
        DataCell(conditionWidget(condition)),
        DataCell(
          Text(
            price,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _showFilteredModal(
    BuildContext context,
    String title,
    List<TrayData> records,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$title Details", style: AppTextStyles.headingText20),
                    const Text(
                      "View comprehensive records",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: records.isEmpty
                  ? const Center(child: Text("No records found"))
                  : ListView.separated(
                      itemCount: records.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final r = records[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            r.from,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("${r.date} • ${r.trayType}"),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "₹${r.price}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                "${r.qty} Trays",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          leading: conditionWidget(r.condition),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget conditionWidget(String condition) {
    Color color;
    switch (condition.toUpperCase()) {
      case "GOOD":
        color = Colors.green;
        break;
      case "DAMAGED":
        color = Colors.red;
        break;
      case "SCRAP":
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        condition,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
