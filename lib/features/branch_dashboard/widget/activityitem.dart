import 'package:flutter/material.dart';

class ActivityItem extends StatefulWidget {
  final Widget leading; // Avatar or Icon
  final String title;
  final Widget subtitle; // Row or Text
  final String time;
  final String tag;

  const ActivityItem({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.tag,
  });

  @override
  State<ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<ActivityItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔹 LEADING (Avatar / Icon)
        widget.leading,

        const SizedBox(width: 12),

        /// 🔹 CONTENT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// TITLE
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 4),

              /// SUBTITLE
              widget.subtitle,

              const SizedBox(height: 4),

              /// TIME ROW
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(widget.time,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(width: 6),
                  const Text("•",
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 6),
                  Text(widget.tag,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}