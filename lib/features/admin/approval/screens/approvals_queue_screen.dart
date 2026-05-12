import 'package:flutter/material.dart';

import '../data/approval_dummy_data.dart';
import '../models/approval_model.dart';
import '../widgets/approval_empty_widget.dart';
import '../widgets/approval_filter_dropdown.dart';
import '../widgets/approval_search_field.dart';
import '../widgets/approval_table_header.dart';
import '../widgets/approval_table_row.dart';

class ApprovalsQueueScreen extends StatefulWidget {
  const ApprovalsQueueScreen({super.key});

  @override
  State<ApprovalsQueueScreen> createState() => _ApprovalsQueueScreenState();
}

class _ApprovalsQueueScreenState extends State<ApprovalsQueueScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedStatus = "Pending Review";

  List<ApprovalModel> approvals = approvalDummyData;

  List<ApprovalModel> filteredApprovals = [];

  @override
  void initState() {
    super.initState();

    filterApprovals();
  }

  void filterApprovals() {
    setState(() {
      filteredApprovals = approvals.where((approval) {
        final matchesSearch =
            approval.customer.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ) ||
            approval.requestId.toLowerCase().contains(
              searchController.text.toLowerCase(),
            );

        final matchesStatus = approval.status == selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void approveRequest(ApprovalModel approval) {
    setState(() {
      approval.status = "Approved";
    });

    filterApprovals();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("${approval.requestId} Approved")));
  }

  void rejectRequest(ApprovalModel approval) {
    setState(() {
      approval.status = "Rejected";
    });

    filterApprovals();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("${approval.requestId} Rejected")));
  }

  void viewRequest(ApprovalModel approval) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(approval.requestId),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Customer : ${approval.customer}"),

              const SizedBox(height: 10),

              Text("Details : ${approval.details}"),

              const SizedBox(height: 10),

              Text("Requester : ${approval.requester}"),

              const SizedBox(height: 10),

              Text("Status : ${approval.status}"),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 10),

              /// HEADER
              Row(
                children: [
                  // InkWell(
                  //   // borderRadius: BorderRadius.circular(40),
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  //   child: const Icon(Icons.arrow_back),
                  // ),
                  const SizedBox(width: 18),

                  const Text(
                    "Approvals Queue",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// DESCRIPTION
              const Text(
                "Review and manage pending system requests,\nbulk sales, and purchase orders.",
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xff6B7280),
                ),
              ),

              const SizedBox(height: 28),

              /// SEARCH + FILTER
              Row(
                children: [
                  ApprovalSearchField(
                    controller: searchController,
                    onChanged: (value) {
                      filterApprovals();
                    },
                  ),

                  const SizedBox(width: 18),

                  ApprovalFilterDropdown(
                    value: selectedStatus,
                    onChanged: (value) {
                      selectedStatus = value!;

                      filterApprovals();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// TABLE
              /// TABLE
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: Container(
                    width: 1050,
                    margin: const EdgeInsets.only(bottom: 10),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xffE5E7EB)),
                    ),

                    child: Column(
                      children: [
                        /// HEADER
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: const ApprovalTableHeader(),
                        ),

                        /// EMPTY
                        if (filteredApprovals.isEmpty)
                          const Expanded(child: ApprovalEmptyWidget()),

                        /// TABLE DATA
                        if (filteredApprovals.isNotEmpty)
                          Expanded(
                            child: ListView.builder(
                              itemCount: filteredApprovals.length,

                              itemBuilder: (context, index) {
                                final approval = filteredApprovals[index];

                                return ApprovalTableRow(
                                  approval: approval,

                                  onApprove: () => approveRequest(approval),

                                  onReject: () => rejectRequest(approval),

                                  onView: () => viewRequest(approval),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
