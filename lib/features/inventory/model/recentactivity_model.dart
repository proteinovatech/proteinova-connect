class RecentActivity {

  final String actorName;

  final String activityType;

  final String activity;

  final String createdAt;

  RecentActivity({

    required this.actorName,

    required this.activityType,

    required this.activity,

    required this.createdAt,
  });

  factory RecentActivity.fromJson(
    Map<String, dynamic> json,
  ) {

    return RecentActivity(

      actorName:
          json["actor_name"] ?? "",

      activityType:
          json["activity_type"] ?? "",

      activity:
          json["activity"] ?? "",

      createdAt:
          json["created_at"] ?? "",
    );
  }
}