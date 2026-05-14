import 'package:flutter/material.dart';

import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/stock.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/stockdetails.dart';

// import 'package:proteinova_connect/features/branch_dashboard/widget/stock.dart';
// import 'package:proteinova_connect/features/branch_dashboard/widget/stockdetails.dart';
import 'package:proteinova_connect/features/tray_returns/presentation/model/tray_return_model.dart';
import 'package:proteinova_connect/features/tray_returns/presentation/repository/tray_return_repository.dart';

import 'package:proteinova_connect/features/tray_returns/presentation/tray_records.dart';

class TrayReturn extends StatefulWidget {
  const TrayReturn({super.key});

  @override
  State<TrayReturn> createState() =>
      _TrayReturnState();
}

class _TrayReturnState
    extends State<TrayReturn> {
  bool isLoading = true;

  TrayReturnModel? trayReturnModel;

  final TrayReturnRepository repository =
      TrayReturnRepository();

  @override
  void initState() {
    super.initState();

    fetchTrayReturnData();
  }

  Future<void> fetchTrayReturnData() async {
    try {
      final result =
          await repository
              .fetchTrayReturnData();

      setState(() {
        trayReturnModel = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size =
        MediaQuery.of(context).size;

    final cards =
        trayReturnModel?.cards;

    final refundSummary =
        trayReturnModel
            ?.refundCreditSummary;

    final dataList =
        trayReturnModel?.data ?? [];

    return Scaffold(
      backgroundColor:
          AppColors.background1,

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    size.width * 0.05,
              ),

              child:
                  SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    SizedBox(
                      height:
                          size.height *
                              0.05,
                    ),

                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons
                                .arrow_back,
                          ),

                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
                          },
                        ),

                        Text(
                          "Tray Return",

                          style:
                              AppTextStyles
                                  .headingText22,
                        ),
                      ],
                    ),

                    SizedBox(
                      height:
                          size.height *
                              0.02,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Stock(
                            title:
                                "Refund/Credit",

                            value:
                                "₹${refundSummary?.totalRefund ?? 0}",

                            percent:
                                "0%",

                            subtitle:
                                "Today",

                            icon: Icons
                                .attach_money,

                            iconBg:
                                const Color(
                              0xFFE6EBF0,
                            ),

                            iconColor:
                                Colors.grey,

                            highlightUnit:
                                true,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child:
                              Stockdetails(
                            title:
                                "Damaged",

                            value:
                                "${cards?.damagedTrays ?? 0} trays",

                            icon: Icons
                                .dangerous_outlined,

                            iconBg:
                                const Color(
                              0xFFE6EBF0,
                            ),

                            iconColor:
                                Colors.grey,

                            highlightUnit:
                                true,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height:
                          size.height *
                              0.02,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Stock(
                            title:
                                "Returned This\nMonth",

                            value:
                                "${cards?.totalReturnedThisMonth ?? 0}",

                            percent:
                                "0%",

                            subtitle:
                                "Month",

                            icon: Icons
                                .inventory,

                            iconBg:
                                const Color(
                              0xFFE6EBF0,
                            ),

                            iconColor:
                                Colors.grey,

                            highlightUnit:
                                true,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child:
                              Stockdetails(
                            title:
                                "Good Trays",

                            value:
                                "${cards?.goodTrays ?? 0} trays",

                            icon: Icons
                                .inventory_2_outlined,

                            iconBg:
                                const Color(
                              0xFFE6EBF0,
                            ),

                            iconColor:
                                Colors.grey,

                            highlightUnit:
                                true,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height:
                          size.height *
                              0.02,
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    const TrayRecords(),
                          ),
                        );
                      },

                      child: Container(
                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets.all(
                          12,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              AppColors
                                  .amber600,

                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),

                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: [
                            Icon(
                              Icons.add,

                              color:
                                  AppColors
                                      .dark,
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Text(
                              "Tray Records",

                              style:
                                  AppTextStyles
                                      .headingText20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height:
                          size.height *
                              0.02,
                    ),

                    Text(
                      "Recent Tray Returns",

                      style:
                          AppTextStyles
                              .headingText20,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal,

                      child: DataTable(
                        columnSpacing:
                            20,

                        headingRowColor:
                            MaterialStateProperty.all(
                          Colors.grey
                              .shade300,
                        ),

                        columns: const [
                          DataColumn(
                            label: Text(
                              "Date",
                            ),
                          ),

                          DataColumn(
                            label: Text(
                              "From",
                            ),
                          ),

                          DataColumn(
                            label: Text(
                              "Tray Type",
                            ),
                          ),

                          DataColumn(
                            label: Text(
                              "Qty",
                            ),
                          ),

                          DataColumn(
                            label: Text(
                              "Condition",
                            ),
                          ),

                          DataColumn(
                            label: Text(
                              "Reasons",
                            ),
                          ),

                          DataColumn(
                            label: Text(
                              "Price",
                            ),
                          ),
                        ],

                        rows:
                            dataList.isEmpty
                                ? [
                                    const DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            "No Data",
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            "",
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            "",
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            "",
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            "",
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            "",
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            "",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]
                                : dataList.map(
                                    (item) {
                                      return buildSummaryRow(
                                        item.date,

                                        item.from,

                                        item
                                            .trayType,

                                        item.qty,

                                        item
                                            .condition,

                                        item.reason,

                                        "₹${item.price}",
                                      );
                                    },
                                  ).toList(),
                      ),
                    ),

                    SizedBox(
                      height:
                          size.height *
                              0.02,
                    ),

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets.all(
                        16,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),

                        border:
                            Border.all(
                          color: Colors
                              .grey
                              .shade300,
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Text(
                            "Refund/Credit Summary",

                            style:
                                AppTextStyles
                                    .headingText20,
                          ),

                          SizedBox(
                            height:
                                size.height *
                                    0.02,
                          ),

                          summaryBox(
                            title:
                                "Total Refund",

                            value:
                                "₹${refundSummary?.totalRefund ?? 0}",

                            bgColor:
                                AppColors
                                    .border2,
                          ),

                          SizedBox(
                            height:
                                size.height *
                                    0.01,
                          ),

                          summaryBox(
                            title:
                                "Pending Refund",

                            value:
                                "₹${refundSummary?.pendingRefund ?? 0}",

                            bgColor:
                                Colors.grey
                                    .shade100,
                          ),

                          SizedBox(
                            height:
                                size.height *
                                    0.01,
                          ),

                          summaryBox(
                            title:
                                "Total Credit",

                            value:
                                "₹${refundSummary?.totalCredit ?? 0}",

                            bgColor:
                                AppColors
                                    .border2,
                          ),

                          SizedBox(
                            height:
                                size.height *
                                    0.01,
                          ),

                          summaryBox(
                            title:
                                "Pending Credit",

                            value:
                                "₹${refundSummary?.pendingCredit ?? 0}",

                            bgColor:
                                Colors.grey
                                    .shade100,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height:
                          size.height *
                              0.02,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget summaryBox({
    required String title,
    required String value,
    required Color bgColor,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),

      decoration: BoxDecoration(
        color: bgColor,

        borderRadius:
            BorderRadius.circular(
          10,
        ),

        border: Border.all(
          color:
              Colors.grey.shade300,
        ),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [
          Text(
            title,

            style: AppTextStyles
                .bodyText14dark,
          ),

          Text(
            value,

            style: AppTextStyles
                .headingText20,
          ),
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
    String reason,
    String price,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(date)),

        DataCell(Text(from)),

        DataCell(Text(tray)),

        DataCell(Text(qty)),

        DataCell(
          conditionWidget(
            condition,
          ),
        ),

        DataCell(Text(reason)),

        DataCell(Text(price)),
      ],
    );
  }

  Widget conditionWidget(
    String condition,
  ) {
    Color color;

    switch (condition) {
      case "Good":
        color = Colors.green;
        break;

      case "Damaged":
        color = Colors.red;
        break;

      case "Scrap":
        color = Colors.orange;
        break;

      default:
        color = Colors.grey;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color:
            color.withOpacity(0.1),

        borderRadius:
            BorderRadius.circular(
          8,
        ),

        border: Border.all(
          color: color,
        ),
      ),

      child: Text(
        condition,

        style: TextStyle(
          color: color,

          fontWeight:
              FontWeight.w500,
        ),
      ),
    );
  }
}