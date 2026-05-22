import 'package:proteinova_connect/features/warehouse/approval/models/approval_models.dart';

/// lib/features/admin/approvals/data/approval_dummy_data.dart



List<ApprovalModel> approvalDummyData = [
  ApprovalModel(
    requestId: "REQ-1001",
    type: "Purchase",
    customer: "Apex Farms",
    details: "500 Egg Trays",
    date: "08 May 2026",
    requester: "Robert",
    status: "Pending Review",
  ),

  ApprovalModel(
    requestId: "REQ-1002",
    type: "Bulk Sale",
    customer: "ProteinOva",
    details: "1200 Eggs",
    date: "07 May 2026",
    requester: "John",
    status: "Approved",
  ),

  ApprovalModel(
    requestId: "REQ-1003",
    type: "Purchase",
    customer: "Farm Fresh",
    details: "250 Trays",
    date: "06 May 2026",
    requester: "Alex",
    status: "Rejected",
  ),
];