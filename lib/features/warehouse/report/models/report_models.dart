class ReportStatModel {
  final String title;
  final String amount;
  final String growth;

  ReportStatModel({
    required this.title,
    required this.amount,
    required this.growth,
  });
}

class TopBranchModel {
  final String branch;
  final String amount;
  final double progress;

  TopBranchModel({
    required this.branch,
    required this.amount,
    required this.progress,
  });
}