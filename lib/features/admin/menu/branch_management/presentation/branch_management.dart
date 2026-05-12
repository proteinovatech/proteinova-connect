import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/data/services/branch_service.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/presentation/add_branch_details.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/widget/info_cards.dart';

class BranchManagement extends StatefulWidget {
  const BranchManagement({super.key});

  @override
  State<BranchManagement> createState() => _BranchManagementState();
}

class _BranchManagementState extends State<BranchManagement> {
  List<BranchModel> branches = [];
  bool isLoading = true;

  String selectedRegionFilter = "All Regions";
  String selectedStatusFilter = "All Statuses";
  String searchQuery = "";
  int? selectedBranchId;

  List<BranchModel> get filteredBranches {
    return branches.where((branch) {
      final matchesBranch =
          selectedBranchId == null || branch.id == selectedBranchId;
      final matchesRegion =
          selectedRegionFilter == "All Regions" ||
          branch.region == selectedRegionFilter;
      final matchesStatus =
          selectedStatusFilter == "All Statuses" ||
          branch.status == selectedStatusFilter;
      final matchesSearch =
          searchQuery.isEmpty ||
          branch.branchName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          branch.city.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesBranch && matchesRegion && matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadBranches();
  }

  int get _activeBranchesCount {
    if (selectedBranchId != null) {
      return branches
          .where((b) => b.id == selectedBranchId && b.status == "Active")
          .length;
    }
    return branches.where((b) => b.status == "Active").length;
  }

  int get _totalEggStock {
    if (selectedBranchId != null) {
      return branches
          .where((b) => b.id == selectedBranchId)
          .fold(0, (sum, b) => sum + b.currentStock);
    }
    return branches.fold(0, (sum, b) => sum + b.currentStock);
  }

  double get _totalSales {
    if (selectedBranchId != null) {
      return branches
          .where((b) => b.id == selectedBranchId)
          .fold(0.0, (sum, b) => sum + b.totalSales);
    }
    return branches.fold(0.0, (sum, b) => sum + b.totalSales);
  }

  double get _totalRevenue {
    if (selectedBranchId != null) {
      return branches
          .where((b) => b.id == selectedBranchId)
          .fold(0.0, (sum, b) => sum + b.totalRevenue);
    }
    return branches.fold(0.0, (sum, b) => sum + b.totalRevenue);
  }

  Future<void> loadBranches() async {
    try {
      final data = await BranchService().fetchBranches();

      setState(() {
        branches = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xffF7F7F7),
        elevation: 0,

        titleSpacing: 16,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },

              child: const Padding(
                padding: EdgeInsets.only(top: 2),

                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xffFFF7D6),

                      borderRadius: BorderRadius.circular(30),
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

                        Flexible(
                          child: Text(
                            "Role: Inventory & Ops Admin",

                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: selectedBranchId,
                hint: const Text(
                  "All Branches",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                icon: const Icon(Icons.arrow_drop_down_outlined),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text("All Branches", style: TextStyle(fontSize: 13)),
                  ),
                  ...branches.map((branch) {
                    return DropdownMenuItem<int?>(
                      value: branch.id,
                      child: Text(
                        branch.branchName,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedBranchId = value;
                  });
                },
              ),
            ),
          ),

          // Icon(
          //   Icons.notifications_none_outlined,
          //   size: 20,
          //   color: Colors.black,
          // ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InfoCards(
                            title: "Total Active Branches",
                            value: "$_activeBranchesCount",
                            percent: "+ 1",
                            subtitle: "new branch this year",
                            icon: Icons.trending_up,
                            topIcon: Icons.store_outlined,
                            topIconColor: AppColors.blueAccent,
                            iconColor: AppColors.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InfoCards(
                            title: "Total Egg Stock",
                            value: "$_totalEggStock",
                            percent: "Live",
                            subtitle: "across all grades",
                            icon: Icons.trending_up,
                            topIcon: Icons.stacked_bar_chart,
                            topIconColor: AppColors.deepOrange,
                            iconColor: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InfoCards(
                            title: "Total Sales Today",
                            value: "₹${_totalSales.toStringAsFixed(0)}",
                            percent: "+5.4%",
                            subtitle: "vs yesterday",
                            icon: Icons.trending_up,
                            topIcon: Icons.currency_rupee,
                            topIconColor: Colors.deepPurple,
                            iconColor: AppColors.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InfoCards(
                            title: "Branch Revenue (MTD)",
                            value: "₹${_totalRevenue.toStringAsFixed(0)}",
                            percent: "+0%",
                            subtitle: "vs last month",
                            icon: Icons.trending_up,
                            topIcon: Icons.currency_rupee,
                            topIconColor: AppColors.green,
                            iconColor: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(color: Colors.grey.shade300),
                      ),

                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                            builder: (context) =>
                                                const AddBranchDetails(),
                                          ),
                                        ).then((value) {
                                          loadBranches();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.amber50,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.add, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Add New Branch",
                                              style: AppTextStyles.buttonText16
                                                  .copyWith(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),

                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),

                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Filter name or location...",
                                      icon: Icon(Icons.search, size: 20),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                /// FILTER ROW
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),

                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),

                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),

                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: selectedRegionFilter,
                                            isExpanded: true,
                                            items: const [
                                              DropdownMenuItem(
                                                value: "All Regions",
                                                child: Text("All Regions"),
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
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  selectedRegionFilter = value;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),

                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),

                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),

                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: selectedStatusFilter,
                                            isExpanded: true,
                                            items: const [
                                              DropdownMenuItem(
                                                value: "All Statuses",
                                                child: Text("All Statuses"),
                                              ),

                                              DropdownMenuItem(
                                                value: "Active",
                                                child: Text("Active"),
                                              ),

                                              DropdownMenuItem(
                                                value: "Inactive",
                                                child: Text("Inactive"),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  selectedStatusFilter = value;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background1,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "BRANCH\nDETAILS",
                                            style: AppTextStyles.bodyText10dark,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "BRANCH\nMANAGER",
                                            style: AppTextStyles.bodyText10dark,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "STATUS",
                                            style: AppTextStyles.bodyText10dark,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "CURRENT\nSTOCK",
                                            style: AppTextStyles.bodyText10dark,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "SALES(MTD)",
                                            style: AppTextStyles.bodyText10dark,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            "ACTIONS",
                                            style: AppTextStyles.bodyText10dark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                filteredBranches.isEmpty
                                    ? Align(
                                        alignment: Alignment.center,
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 10),
                                            Text(
                                              "No branches found",
                                              style:
                                                  AppTextStyles.bodyText14dark,
                                            ),
                                            Text(
                                              "Add a new branch to get started",
                                              style: AppTextStyles.bodyText14,
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),

                                        itemCount: filteredBranches.length,

                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 10),

                                        itemBuilder: (context, index) {
                                          final branch =
                                              filteredBranches[index];

                                          return Container(
                                            padding: const EdgeInsets.all(14),

                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),

                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),

                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        branch.branchName,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: AppTextStyles
                                                            .bodyText12dark,
                                                      ),
                                                      Text(
                                                        branch.city,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: AppTextStyles
                                                            .bodyText10,
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    branch.managerEmail,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTextStyles
                                                        .bodyText10,
                                                  ),
                                                ),

                                                Expanded(
                                                  flex: 2,
                                                  child: Center(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 5,
                                                          ),

                                                      decoration: BoxDecoration(
                                                        color:
                                                            branch.status ==
                                                                "Active"
                                                            ? Colors
                                                                  .green
                                                                  .shade100
                                                            : Colors
                                                                  .red
                                                                  .shade100,

                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),

                                                      child: Text(
                                                        branch.status,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color:
                                                              branch.status ==
                                                                  "Active"
                                                              ? Colors.green
                                                              : Colors.red,
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "${branch.currentStock}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: AppTextStyles
                                                            .bodyText10dark,
                                                      ),
                                                      Text(
                                                        "trays",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: AppTextStyles
                                                            .bodyText10,
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    "₹ ${branch.totalSales.toStringAsFixed(2)}",
                                                    textAlign: TextAlign.center,
                                                    style: AppTextStyles
                                                        .bodyText10,
                                                  ),
                                                ),

                                                Expanded(
                                                  flex: 3,
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    AddBranchDetails(
                                                                      branch:
                                                                          branch,
                                                                    ),
                                                              ),
                                                            ).then((value) {
                                                              if (value ==
                                                                  true) {
                                                                loadBranches();
                                                              }
                                                            });
                                                          },
                                                          child: const Icon(
                                                            Icons.edit_outlined,
                                                            size: 14,
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          width: 4,
                                                        ),

                                                        GestureDetector(
                                                          onTap: () async {
                                                            final confirm = await showDialog<bool>(
                                                              context: context,
                                                              builder: (context) => AlertDialog(
                                                                title: const Text(
                                                                  "Delete Branch",
                                                                ),
                                                                content: const Text(
                                                                  "Are you sure you want to delete this branch?",
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                          context,
                                                                          false,
                                                                        ),
                                                                    child: const Text(
                                                                      "Cancel",
                                                                    ),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                          context,
                                                                          true,
                                                                        ),
                                                                    child: const Text(
                                                                      "Delete",
                                                                      style: TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );

                                                            if (confirm ==
                                                                true) {
                                                              try {
                                                                await BranchService()
                                                                    .deleteBranch(
                                                                      branch.id,
                                                                    );
                                                                loadBranches();
                                                              } catch (e) {
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      "Error: $e",
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            }
                                                          },
                                                          child: const Icon(
                                                            Icons
                                                                .delete_outline,
                                                            size: 16,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
