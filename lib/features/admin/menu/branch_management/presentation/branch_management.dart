import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/bloc/branch_bloc/branch_bloc.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/bloc/branch_form_bloc/branch_form_bloc.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/data/services/branch_service.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/presentation/add_branch_details.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/widget/info_cards.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_branch_management_skeleton_loader.dart';

class BranchManagement extends StatefulWidget {
  const BranchManagement({super.key});

  @override
  State<BranchManagement> createState() => _BranchManagementState();
}

class _BranchManagementState extends State<BranchManagement> {
  
  
  final ScrollController _scrollController = ScrollController();

 
  String selectedRegionFilter = "All Regions";
  String selectedStatusFilter = "All Statuses";
  String searchQuery = "";
  int? selectedBranchId;

  @override
  Widget build(BuildContext context) {
    final blocState = context.watch<BranchBloc>().state;

final branches =
    blocState is BranchLoaded
        ? blocState.branches
        : [];
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

        titleSpacing: 16,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },

              child: const Padding(
                padding: EdgeInsets.only(top: 6),

                child: Icon(Icons.arrow_back, size: 22, color: Colors.black),
              ),
            ),

            SizedBox(width: getWidth(context, 12)),

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

                  SizedBox(height: getHeight(context, 8)),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(context, 10),
                      vertical: getHeight(context, 5),
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xffFFF7D6),

                      borderRadius: BorderRadius.circular(30),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 14,
                          color: Colors.black,
                        ),

                        SizedBox(width: getWidth(context, 6)),
                        const Flexible(
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
            padding: EdgeInsets.symmetric(horizontal: getWidth(context, 12)),
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

      body:  BlocBuilder<BranchBloc, BranchState>(
  builder: (context, state) {

    if (state is BranchLoading) {
      return const Center(
        child: AdminBranchManagementSkeletonLoader(),
      );
    }

    if (state is BranchError) {
      return Center(
        child: Text(state.message),
      );
    }

    if (state is BranchLoaded) {

      final branches = state.branches;
      final filteredBranches = branches.where((branch) {

  final matchesBranch =
      selectedBranchId == null ||
      branch.id == selectedBranchId;

  final matchesRegion =
      selectedRegionFilter == "All Regions" ||
      branch.region == selectedRegionFilter;

  final matchesStatus =
      selectedStatusFilter == "All Statuses" ||
      branch.status == selectedStatusFilter;

  final matchesSearch =
      searchQuery.isEmpty ||
      branch.branchName
          .toLowerCase()
          .contains(searchQuery.toLowerCase()) ||
      branch.city
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

  return matchesBranch &&
      matchesRegion &&
      matchesStatus &&
      matchesSearch;

}).toList();
final activeBranchesCount =
    branches.where((b) => b.status == "Active").length;

final totalEggStock =
    branches.fold(0, (sum, b) => sum + b.currentStock);

final totalSales =
    branches.fold(0.0, (sum, b) => sum + b.totalSales);

final totalRevenue =
    branches.fold(0.0, (sum, b) => sum + b.totalRevenue);

      return RefreshIndicator(
        onRefresh: () async {
          context.read<BranchBloc>()
              .add(RefreshBranchesEvent());
        },

              child: SingleChildScrollView(
                controller: _scrollController,

                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getWidth(context, 16),
                  ),

                  child: Column(
                    children: [
                      SizedBox(height: getHeight(context, 20)),
                      Row(
                        children: [
                          Expanded(
                            child: InfoCards(
                              title: "Total Active Branches",
                              value: "$activeBranchesCount",
                              percent: "+ 1",
                              subtitle: "new branch this year",
                              icon: Icons.trending_up,
                              topIcon: Icons.store_outlined,
                              topIconColor: AppColors.blueAccent,
                              iconColor: AppColors.green,
                            ),
                          ),
                          SizedBox(width: getWidth(context, 10)),
                          Expanded(
                            child: InfoCards(
                              title: "Total Egg Stock",
                              value: "$totalEggStock",
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
                      SizedBox(height: getHeight(context, 10)),
                      Row(
                        children: [
                          Expanded(
                            child: InfoCards(
                              title: "Total Sales Today",
                              value: "₹${totalSales.toStringAsFixed(0)}",
                              percent: "+5.4%",
                              subtitle: "vs yesterday",
                              icon: Icons.trending_up,
                              topIcon: Icons.currency_rupee,
                              topIconColor: Colors.deepPurple,
                              iconColor: AppColors.green,
                            ),
                          ),
                          SizedBox(width: getWidth(context, 10)),
                          Expanded(
                            child: InfoCards(
                              title: "Branch Revenue (MTD)",
                              value: "₹${totalRevenue.toStringAsFixed(0)}",
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
                      SizedBox(height: getHeight(context, 10)),
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
      builder: (context) => BlocProvider(
        create: (_) => BranchFormBloc(
          BranchService(),
        )..add(
            LoadBranchFormDataEvent(),
          ),

        child: const AddBranchDetails(),
      ),
    ),
  ).then((value) {
    context.read<BranchBloc>().add(
      LoadBranchesEvent(),
    );
  });
},
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: getWidth(context, 12),
                                            vertical: getHeight(context, 10),
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
                                              SizedBox(
                                                width: getWidth(context, 8),
                                              ),
                                              Text(
                                                "Add New Branch",
                                                style: AppTextStyles
                                                    .buttonText16
                                                    .copyWith(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: getHeight(context, 20)),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: getWidth(context, 12),
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

                                  SizedBox(height: getHeight(context, 10)),

                                  /// FILTER ROW
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: getWidth(context, 12),
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
                                                    selectedRegionFilter =
                                                        value;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: getWidth(context, 12)),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: getWidth(context, 12),
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
                                                    selectedStatusFilter =
                                                        value;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: getHeight(context, 12)),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,

                                    child: SizedBox(
                                      width: getWidth(context, 470),

                                      child: Column(
                                        children: [
                                          /// TABLE HEADER
                                          Container(
                                            width: double.infinity,

                                            padding: EdgeInsets.symmetric(
                                              horizontal: getWidth(context, 16),
                                              vertical: getHeight(context, 14),
                                            ),

                                            decoration: BoxDecoration(
                                              color: AppColors.background1,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),

                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,

                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                        Alignment.centerLeft,

                                                    child: Text(
                                                      "BRANCH\nDETAILS",
                                                      style: AppTextStyles
                                                          .bodyText9dark,
                                                    ),
                                                  ),
                                                ),

                                                Expanded(
                                                  flex: 5,

                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,

                                                    child: Text(
                                                      "BRANCH\nMANAGER",
                                                      style: AppTextStyles
                                                          .bodyText9dark,
                                                    ),
                                                  ),
                                                ),

                                                Expanded(
                                                  flex: 3,

                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,

                                                    child: Text(
                                                      "STATUS",
                                                      style: AppTextStyles
                                                          .bodyText9dark,
                                                    ),
                                                  ),
                                                ),

                                                Expanded(
                                                  flex: 3,

                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,

                                                    child: Text(
                                                      "CURRENT\nSTOCK",
                                                      style: AppTextStyles
                                                          .bodyText9dark,
                                                    ),
                                                  ),
                                                ),

                                                Expanded(
                                                  flex: 3,

                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,

                                                    child: Text(
                                                      "SALES(MTD)",
                                                      style: AppTextStyles
                                                          .bodyText9dark,
                                                    ),
                                                  ),
                                                ),

                                                Expanded(
                                                  flex: 2,

                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,

                                                    child: Text(
                                                      "ACTIONS",
                                                      style: AppTextStyles
                                                          .bodyText9dark,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          SizedBox(
                                            height: getHeight(context, 20),
                                          ),

                                          /// EMPTY
                                          filteredBranches.isEmpty
                                              ? Align(
                                                  alignment: Alignment.center,

                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: getHeight(
                                                          context,
                                                          10,
                                                        ),
                                                      ),

                                                      Text(
                                                        "No branches found",
                                                        style: AppTextStyles
                                                            .bodyText14dark,
                                                      ),

                                                      Text(
                                                        "Add a new branch to get started",
                                                        style: AppTextStyles
                                                            .bodyText14,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              /// LIST
                                              : ListView.separated(
                                                  shrinkWrap: true,

                                                  physics:
                                                      const NeverScrollableScrollPhysics(),

                                                  itemCount:
                                                      filteredBranches.length,

                                                  separatorBuilder: (_, __) =>
                                                      SizedBox(
                                                        height: getHeight(
                                                          context,
                                                          10,
                                                        ),
                                                      ),

                                                  itemBuilder: (context, index) {
                                                    final branch =
                                                        filteredBranches[index];

                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            14,
                                                          ),

                                                      decoration: BoxDecoration(
                                                        color: Colors.white,

                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),

                                                        border: Border.all(
                                                          color: Colors
                                                              .grey
                                                              .shade300,
                                                        ),
                                                      ),

                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,

                                                        children: [
                                                          /// BRANCH DETAILS
                                                          Expanded(
                                                            flex: 2,

                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,

                                                              children: [
                                                                Text(
                                                                  branch
                                                                      .branchName,

                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,

                                                                  style: AppTextStyles
                                                                      .bodyText12dark,
                                                                ),

                                                                const SizedBox(
                                                                  height: 2,
                                                                ),

                                                                Text(
                                                                  branch.city,

                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,

                                                                  style: AppTextStyles
                                                                      .bodyText10,
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          /// MANAGER
                                                          Expanded(
                                                            flex: 5,

                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        4,
                                                                  ),

                                                              child: Text(
                                                                branch
                                                                    .managerEmail,

                                                                textAlign:
                                                                    TextAlign
                                                                        .center,

                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,

                                                                style: AppTextStyles
                                                                    .bodyText10,
                                                              ),
                                                            ),
                                                          ),

                                                          /// STATUS
                                                          Expanded(
                                                            flex: 3,

                                                            child: Center(
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          5,
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

                                                                  style: TextStyle(
                                                                    color:
                                                                        branch.status ==
                                                                            "Active"
                                                                        ? Colors
                                                                              .green
                                                                        : Colors
                                                                              .red,

                                                                    fontSize: 9,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),

                                                          /// STOCK
                                                          Expanded(
                                                            flex: 3,

                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,

                                                              children: [
                                                                Text(
                                                                  "${branch.currentStock}",

                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,

                                                                  style: AppTextStyles
                                                                      .bodyText10dark,
                                                                ),

                                                                Text(
                                                                  "trays",

                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,

                                                                  style: AppTextStyles
                                                                      .bodyText10,
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          /// SALES
                                                          Expanded(
                                                            flex: 3,

                                                            child: Text(
                                                              "₹ ${branch.totalSales.toStringAsFixed(2)}",

                                                              textAlign:
                                                                  TextAlign
                                                                      .center,

                                                              style: AppTextStyles
                                                                  .bodyText10,
                                                            ),
                                                          ),

                                                          /// ACTIONS
                                                          Expanded(
                                                            flex: 2,

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
                                                                        builder:
                                                                            (
                                                                              context,
                                                                            ) => AddBranchDetails(
                                                                              branch: branch,
                                                                            ),
                                                                      ),
                                                                    ).then((
                                                                      value,
                                                                    ) {
                                                                      if (value ==
                                                                          true) {
                                                                       context.read<BranchBloc>().add(
                                                                          LoadBranchesEvent(),);
                                                                      }
                                                                    });
                                                                  },

                                                                  child: const Icon(
                                                                    Icons
                                                                        .edit_outlined,
                                                                    size: 14,
                                                                  ),
                                                                ),

                                                                const SizedBox(
                                                                  width: 6,
                                                                ),

                                                                GestureDetector(
                                                                  onTap: () async {
                                                                    final confirm = await showDialog<bool>(
                                                                      context:
                                                                          context,

                                                                      builder: (context) => AlertDialog(
                                                                        title: const Text(
                                                                          "Delete Branch",
                                                                        ),

                                                                        content:
                                                                            const Text(
                                                                              "Are you sure you want to delete this branch?",
                                                                            ),

                                                                        actions: [
                                                                          TextButton(
                                                                            onPressed: () => Navigator.pop(
                                                                              context,
                                                                              false,
                                                                            ),

                                                                            child: const Text(
                                                                              "Cancel",
                                                                            ),
                                                                          ),

                                                                          TextButton(
                                                                            onPressed: () => Navigator.pop(
                                                                              context,
                                                                              true,
                                                                            ),

                                                                            child: const Text(
                                                                              "Delete",

                                                                              style: TextStyle(
                                                                                color: Colors.red,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );

                                                                    if (confirm ==
                                                                        true) {
                                                                      try {
                                                                      context.read<BranchBloc>().add(
                                                                         DeleteBranchEvent(branch.id),);
                                                                      } catch (
                                                                        e
                                                                      ) {
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
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),

                                          SizedBox(
                                            height: getHeight(context, 10),
                                          ),
                                        ],
                                      ),
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
                ),
              ),
            );
    }
     return const SizedBox();
  }));

  
}
}