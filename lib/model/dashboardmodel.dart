class DashboardModel {
  final Map<String, dynamic> cards;

  DashboardModel({required this.cards});

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      cards: json['cards'] ?? {},
    );
  }

  get dailySalesVolume => null;
}