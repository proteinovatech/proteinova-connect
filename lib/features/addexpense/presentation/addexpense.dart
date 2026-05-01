import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  bool isLoading = false;

  // API URL
  final String apiUrl = "YOUR_API_URL";

  // CONTROLLERS
  final TextEditingController dateController =
      TextEditingController(
    text: "2026-04-11",
  );

  final TextEditingController amountController =
      TextEditingController(
    text: "500",
  );

  final TextEditingController descriptionController =
      TextEditingController(
    text:
        "Transport for stock from warehouse",
  );

  final List<String> transportList = [
    "SALARY",
    "PURCHASE",
    "TRANSPORT",
    "MAINTANANCE",
    "RENT",
    "PACKING",
    "GENERAL",
  ];

  Future<void> pickFile() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'png',
        ],
      );

      if (result != null) {
        final file = result.files.first;

        if (file.size <= 5 * 1024 * 1024) {
          setState(() {
            fileName = file.name;
          });
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                "File must be less than 5MB",
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  Future<void> saveExpense() async {
    if (selectedTransport == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please select category",
          ),
        ),
      );
      return;
    }

    if (selectedPayment.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please select payment method",
          ),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type":
              "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "branch_id": 1,
          "expense_date":
              dateController.text,
          "category":
              selectedTransport,
          "amount":
              amountController.text,
          "payment_method":
              selectedPayment.toUpperCase(),
          "description":
              descriptionController.text,
        }),
      );

      debugPrint(
        "STATUS : ${response.statusCode}",
      );

      debugPrint(
        "BODY : ${response.body}",
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data =
            jsonDecode(response.body);

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              data["message"]
                  .toString(),
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Failed to save expense",
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("ERROR : $e");

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size =
        MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          AppColors.background1,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * 0.05,
              ),

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
                    "Add Expense",
                    style:
                        AppTextStyles.headingText22,
                  ),
                ],
              ),

              SizedBox(
                height: size.height * 0.01,
              ),

              const Divider(),

              SizedBox(
                height: size.height * 0.01,
              ),

              Text(
                "Expanse Date*",
                style:
                    AppTextStyles.headingText20,
              ),

              SizedBox(
                height: size.height * 0.01,
              ),

              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: size.height * 0.02,
              ),

              Text(
                "Expanse Category*",
                style:
                    AppTextStyles.headingText20,
              ),

              SizedBox(
                height: size.height * 0.01,
              ),

              DropdownButtonFormField<
                  String>(
                value: selectedTransport,
                hint:
                    const Text("Transport"),
                decoration:
                    InputDecoration(
                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 12,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                ),
                items:
                    transportList.map(
                  (item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTransport =
                        value;
                  });
                },
              ),

              SizedBox(
                height: size.height * 0.02,
              ),

              Text(
                "Amount(₹)*",
                style:
                    AppTextStyles.bodyText16,
              ),

              SizedBox(
                height: size.height * 0.01,
              ),

              TextField(
                controller:
                    amountController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    InputDecoration(
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: size.height * 0.02,
              ),

              Text(
                "Payment Method*",
                style:
                    AppTextStyles.headingText20,
              ),

              SizedBox(
                height: size.height * 0.01,
              ),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPayment =
                              "CASH";
                        });
                      },
                      child: Container(
                        height: 45,
                        decoration:
                            BoxDecoration(
                          border: Border.all(
                            color:
                                selectedPayment ==
                                        "CASH"
                                    ? Colors.blue
                                    : AppColors
                                        .border2,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            8,
                          ),
                          color:
                              selectedPayment ==
                                      "CASH"
                                  ? Colors.blue
                                      .withOpacity(
                                      0.1,
                                    )
                                  : Colors
                                      .transparent,
                        ),
                        child: const Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(Icons.money),
                            SizedBox(
                                width: 6),
                            Text("Cash"),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPayment =
                              "UPI";
                        });
                      },
                      child: Container(
                        height: 45,
                        decoration:
                            BoxDecoration(
                          border: Border.all(
                            color:
                                selectedPayment ==
                                        "UPI"
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            8,
                          ),
                          color:
                              selectedPayment ==
                                      "UPI"
                                  ? Colors.blue
                                      .withOpacity(
                                      0.1,
                                    )
                                  : Colors
                                      .transparent,
                        ),
                        child: const Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(Icons
                                .account_balance_wallet),
                            SizedBox(
                                width: 6),
                            Text("UPI"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: size.height * 0.02,
              ),

              Text(
                "Description*",
                style:
                    AppTextStyles.bodyText16,
              ),

              SizedBox(
                height: size.height * 0.01,
              ),

              TextField(
                controller:
                    descriptionController,
                maxLines: 3,
                decoration:
                    InputDecoration(
                  hintText:
                      "Transport for stock from Warehouse",
                 contentPadding: const EdgeInsets.symmetric(
  horizontal: 12,
  vertical: 10,
),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: size.height * 0.02,
              ),

              RichText(
                text: const TextSpan(
                  text: "Attachment ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      text: "(Optional)",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: size.height * 0.01,
              ),

              InkWell(
                onTap: () async {
                  await pickFile();
                },
                child: Container(
                  height: 100,
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration:
                      BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .center,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          const Icon(
                            Icons
                                .upload_file,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Flexible(
                            child: Text(
                              fileName,
                              textAlign:
                                  TextAlign
                                      .center,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        "PDF, JPG, PNG (Max 5MB)",
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color:
                              Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Divider(),

              SizedBox(
                height: size.height * 0.02,
              ),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTransport =
                              null;
                          selectedPayment =
                              "";
                          fileName =
                              "Choose File";

                          amountController
                              .clear();

                          descriptionController
                              .clear();
                        });
                      },
                      child: Container(
                        height: 45,
                        alignment:
                            Alignment.center,
                        decoration:
                            BoxDecoration(
                          border: Border.all(
                            color:
                                Colors.grey,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            8,
                          ),
                        ),
                        child: const Text(
                          "Reset",
                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) {
                            return AlertDialog(
                              title: const Text(
                                "Confirm",
                              ),
                              content:
                                  const Text(
                                "Are you sure you want to save expenses?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () {
                                    Navigator.pop(
                                      context,
                                    );
                                  },
                                  child:
                                      const Text(
                                    "No",
                                  ),
                                ),
                                TextButton(
                                  onPressed:
                                      () async {
                                    Navigator.pop(
                                      context,
                                    );

                                    await saveExpense();
                                  },
                                  child:
                                      isLoading
                                          ? const CircularProgressIndicator()
                                          : const Text(
                                              "Yes",
                                            ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 45,
                        alignment:
                            Alignment.center,
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .blueAccent,
                          borderRadius:
                              BorderRadius.circular(
                            8,
                          ),
                        ),
                        child: const Text(
                          "Save Expenses",
                          style: TextStyle(
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: size.height * 0.02,
              ),
            ],
          ),
        ),
      ),
    );
  }
}