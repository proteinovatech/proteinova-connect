import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_distribution_skeleton_loader.dart';

import '../models/approval_model.dart';
import '../widgets/approval_empty_widget.dart';
import '../widgets/approval_filter_dropdown.dart';
import '../widgets/approval_search_field.dart';
import '../widgets/approval_table_header.dart';
import '../widgets/approval_table_row.dart';
import 'dart:async';

class ApprovalsQueueScreen extends StatefulWidget {
  const ApprovalsQueueScreen({super.key});

  @override
  State<ApprovalsQueueScreen> createState() => _ApprovalsQueueScreenState();
}

class _ApprovalsQueueScreenState extends State<ApprovalsQueueScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedStatus = "Pending Review";

  List<ApprovalModel> approvals = [];
  List<ApprovalModel> filteredApprovals = [];

  bool isLoading = false;
  String? errorText;
  Timer? _debounce;
  

  bool isRefreshing = false;
  Future<void> refreshDashboard() async {
    setState(() {
      isRefreshing = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    await _fetchApprovals();

    setState(() {
      isRefreshing = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _fetchApprovals();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  String _apiStatusFromUi(String uiStatus) {
    switch (uiStatus) {
      case "Approved":
        return "APPROVED";
      case "Rejected":
        return "REJECTED";
      case "Pending Review":
      default:
        return "PENDING_REVIEW";
    }
  }

  String _uiStatusFromApi(String apiStatus) {
    switch (apiStatus.toUpperCase()) {
      case "APPROVED":
        return "Approved";
      case "REJECTED":
        return "Rejected";
      case "PENDING_REVIEW":
      default:
        return "Pending Review";
    }
  }

  int? _extractApprovalId(String requestId) {
    // Supports "#APR-12", "APR-12", "12", etc.
    final match = RegExp(r'(\d+)').firstMatch(requestId);
    if (match == null) return null;
    final n = int.tryParse(match.group(1) ?? "");
    return (n != null && n > 0) ? n : null;
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return "";
    try {
      final dt = DateTime.tryParse(dateValue.toString());
      if (dt == null) return dateValue.toString();
      return DateFormat('dd MMM yyyy').format(dt.toLocal());
    } catch (_) {
      return dateValue.toString();
    }
  }

  String _buildDetails(Map<String, dynamic> details) {
    final branchName = (details["branch_name"] ?? "").toString().trim();
    final totalTrays = details["total_trays"];
    final totalEggs = details["total_eggs"];
    final totalAmount = details["total_amount"];

    final parts = <String>[];
    if (branchName.isNotEmpty) parts.add(branchName);
    if (totalTrays != null) parts.add("${totalTrays.toString()} trays");
    if (totalEggs != null) parts.add("${totalEggs.toString()} eggs");
    if (totalAmount != null) parts.add("₹${totalAmount.toString()}");

    return parts.isEmpty ? "-" : parts.join(" • ");
  }

  String _pickCustomer(Map<String, dynamic> details) {
    final customerName = (details["customer_name"] ?? "").toString().trim();
    if (customerName.isNotEmpty) return customerName;
    final branchName = (details["branch_name"] ?? "").toString().trim();
    if (branchName.isNotEmpty) return branchName;
    return "N/A";
  }

  Future<void> _fetchApprovals() async {
    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      final q = searchController.text.trim();
      final apiStatus = _apiStatusFromUi(selectedStatus);

      final response = await DioClient().dio.get(
        '/api/admin/approvals',
        queryParameters: {'status': apiStatus, if (q.isNotEmpty) 'q': q},
      );

      final data = response.data;
      final approvalsList = (data is Map<String, dynamic>)
          ? (data['approvals'] as List? ?? [])
          : <dynamic>[];

      final mapped = approvalsList.map((row) {
        final map = (row is Map)
            ? Map<String, dynamic>.from(row)
            : <String, dynamic>{};
        final detailsRaw = map['details'];
        final details = (detailsRaw is Map)
            ? Map<String, dynamic>.from(detailsRaw)
            : <String, dynamic>{};

        return ApprovalModel(
          requestId: (map['request_id'] ?? '').toString(),
          type: (map['type'] ?? '-').toString(),
          customer: _pickCustomer(details),
          details: _buildDetails(details),
          date: _formatDate(map['date_time']),
          requester: (map['requester'] ?? '-').toString(),
          status: _uiStatusFromApi((map['status'] ?? '').toString()),
        );
      }).toList();

      setState(() {
        approvals = mapped;
        filteredApprovals = mapped;
      });
    } catch (e) {
      setState(() {
        errorText = "Failed to load approvals";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> approveRequest(ApprovalModel approval) async {
    final id = _extractApprovalId(approval.requestId);
    if (id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid approval id")));
      return;
    }

    try {
      await DioClient().dio.post('/api/admin/approvals/$id/approve', data: {});
      await _fetchApprovals();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${approval.requestId} Approved")));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to approve request")),
      );
    }
  }

  Future<void> rejectRequest(ApprovalModel approval) async {
    final id = _extractApprovalId(approval.requestId);
    if (id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid approval id")));
      return;
    }

    try {
      await DioClient().dio.post('/api/admin/approvals/$id/reject', data: {});
      await _fetchApprovals();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${approval.requestId} Rejected")));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to reject request")));
    }
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

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 60,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,

          children: const [
            Text("Approvals Queue", style: AppTextStyles.headingText21),
          ],
        ),
      ),

      body: SafeArea(
        child: isLoading
            ? const Center(child: AdminDistributionSkeletonLoader())
            : RefreshIndicator(
                onRefresh: _fetchApprovals,

                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),

                  padding: const EdgeInsets.all(16),

                  children: [
                    /// SEARCH + FILTER
                    Row(
                      children: [
                        Expanded(
                          child: ApprovalSearchField(
                            controller: searchController,

                            onChanged: (value) {
                              _debounce?.cancel();

                              _debounce = Timer(
                                const Duration(milliseconds: 400),
                                () {
                                  if (mounted) {
                                    _fetchApprovals();
                                  }
                                },
                              );
                            },
                          ),
                        ),

                        SizedBox(width: getWidth(context, 18)),
                        Expanded(
                          child: ApprovalFilterDropdown(
                            value: selectedStatus,

                            onChanged: (value) {
                              selectedStatus = value!;
                              _fetchApprovals();
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: getHeight(context, 24)),

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
                        //  child: const ApprovalTableHeader(),
                        ),

                        /// EMPTY
                        if (isLoading)
                          const Expanded(
                            child: Center(child: CircularProgressIndicator()),
                          ),

                        if (!isLoading && errorText != null)
                          Expanded(
                            child: Center(
                              child: Text(
                                errorText!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),

                        if (!isLoading &&
                            errorText == null &&
                            filteredApprovals.isEmpty)
                        Expanded(
  child: Center(
    child: SingleChildScrollView(
      child: ApprovalEmptyWidget(),
    ),
  ),
),

                        /// TABLE DATA
                        if (!isLoading &&
                            errorText == null &&
                            filteredApprovals.isNotEmpty)
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
