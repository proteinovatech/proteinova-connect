class ApprovalModel {
  final String requestId;
  final String type;
  final String customer;
  final String details;
  final String date;
  final String requester;
  String status;

  ApprovalModel({
    required this.requestId,
    required this.type,
    required this.customer,
    required this.details,
    required this.date,
    required this.requester,
    required this.status,
  });
}
