import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';

import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/addexpense/presentation/addexpense.dart';
import 'package:proteinova_connect/features/addexpense/presentation/expense_management/widget/expense_category.dart';
import 'package:proteinova_connect/features/addexpense/presentation/expense_management/widget/expensecard.dart';
import 'package:proteinova_connect/features/addexpense/presentation/expense_management/widget/expenses.dart';

class ExpenseManagement extends StatefulWidget {
  const ExpenseManagement({super.key});

  @override
  State<ExpenseManagement> createState() => _ExpenseManagementState();
}

class _ExpenseManagementState extends State<ExpenseManagement> {
  bool isExpanded = true;

  bool isLoading = true;

  List<Map<String, dynamic>> expenses = [];

    @override
  void initState() {
    super.initState();
    fetchExpense();
  }

  Future<void> fetchExpense() async {
    try {
       final response = await http.get(
      Uri.parse(ApiConstants.dashboard),
      headers: {
        "Accept": "application/json",
      },
    );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data = jsonDecode(response.body);

        setState(() {
                 expenses = [
            {
              "id": data["expense"]["id"],
              "branch_id": data["expense"]["branch_id"],
              "expense_date":
                  data["expense"]["expense_date"],
              "category":
                  data["expense"]["category"],
              "amount": data["expense"]["amount"],
              "payment_method":
                  data["expense"]["payment_method"],
              "description":
                  data["expense"]["description"],
              "status": data["expense"]["status"],
              "attachment_url":
                  data["expense"]["attachment_url"],
              "created_by":
                  data["expense"]["created_by"],
              "created_at":
                  data["expense"]["created_at"],
            }
          ];

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        debugPrint(
          "Failed : ${response.statusCode}",
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint("Error : $e");
    }
  }

  double getTotalExpense() {
    double total = 0;

    for (var item in expenses) {
      total +=
          double.tryParse(item["amount"].toString()) ??
              0;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background1,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.07),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    "Expense Management",
                    style:
                        AppTextStyles.headingText22,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Divider(),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Expenses(
                      title: "Total Expense(MTD)",
                      value:
                          "₹${getTotalExpense().toStringAsFixed(2)}",
                      icon: Icons.currency_pound,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Expenses(
                      title: "Salary Payroll",
                      value:
                          expenses.isNotEmpty
                              ? "₹${expenses[0]["amount"]}"
                              : "₹0.00",
                      icon: Icons.person,
                      subtitle: "- Unchanged",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Expenses(
                      title: "Rent & Facilities",
                      value:
                          expenses.isNotEmpty
                              ? expenses[0]["category"]
                                  .toString()
                              : "No Data",
                      icon: Icons.inventory,
                      subtitle: "- Unchanged",
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Expenses(
                      title: "Transport & Fuel",
                      value:
                          expenses.isNotEmpty
                              ? expenses[0]
                                      ["payment_method"]
                                  .toString()
                              : "No Data",
                      icon: Icons.local_shipping,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const Addexpense(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.amber600,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: AppColors.dark,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Add Expense",
                        style:
                            AppTextStyles.headingText20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Expense Category",
                      style:
                          AppTextStyles.headingText22,
                    ),

                    const SizedBox(height: 10),

                    const Divider(),

                    const SizedBox(height: 10),

                    Column(
                      children: [
                        Row(
                          children: const [
                            Expanded(
                              child:
                                  ExpenseCategory(
                                icon: Icons.person,
                                title: "Salary",
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child:
                                  ExpenseCategory(
                                icon: Icons
                                    .shopping_cart,
                                title: "Purchase",
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child:
                                  ExpenseCategory(
                                icon: Icons
                                    .local_shipping,
                                title: "Transport",
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        Row(
                          children: const [
                            Expanded(
                              child:
                                  ExpenseCategory(
                                icon: Icons.people,
                                title:
                                    "Maintanace",
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child:
                                  ExpenseCategory(
                                icon: Icons.home,
                                title: "Rent",
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child:
                                  ExpenseCategory(
                                icon: Icons.people,
                                title: "Packing",
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        Row(
                          children: const [
                            Spacer(),
                            Expanded(
                              child:
                                  ExpenseCategory(
                                icon: Icons.people,
                                title: "General",
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child:
                                  ExpenseCategory(
                                icon: Icons
                                    .miscellaneous_services,
                                title: "Others",
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Expenses",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  Text(
                    "View All",
                    style:
                        AppTextStyles.blueText2,
                  ),
                ],
              ),

              const SizedBox(height: 10),
isLoading
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : expenses.isEmpty
        ? const Center(
            child: Text("No Expenses Found"),
          )
        : ListView.builder(
            itemCount: expenses.length,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = expenses[index];

              return Card(
                margin:
                    const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          Text(
                            item["category"] ?? "",
                            style:
                                const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₹${item["amount"]}",
                            style:
                                const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        item["description"] ?? "",
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item["expense_date"] ??
                                "",
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors.orange
                                  .shade100,
                              borderRadius:
                                  BorderRadius.circular(
                                8,
                              ),
                            ),
                            child: Text(
                              item["payment_method"] ??
                                  "",
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors.green
                                  .shade100,
                              borderRadius:
                                  BorderRadius.circular(
                                8,
                              ),
                            ),
                            child: Text(
                              item["status"] ?? "",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}