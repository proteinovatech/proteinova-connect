import 'package:flutter/material.dart';

class ActivityItem extends StatefulWidget {

  final Widget leading;

  final String title;

  final Widget subtitle;

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
  State<ActivityItem> createState() =>
      _ActivityItemState();
}

class _ActivityItemState
    extends State<ActivityItem> {

  @override
  Widget build(BuildContext context) {

    return Row(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        widget.leading,

        const SizedBox(width: 12),

        Expanded(

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(

                widget.title,

                maxLines: 1,

                overflow:
                    TextOverflow.ellipsis,

                style: const TextStyle(

                  fontWeight:
                      FontWeight.bold,

                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 4),

              widget.subtitle,

              const SizedBox(height: 4),

              Row(

                children: [

                  const Icon(

                    Icons.access_time,

                    size: 17,

                    color: Colors.grey,
                  ),

                  const SizedBox(width: 4),

                  Expanded(

                    child: Text(

                      widget.time,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  const Text(

                    "•",

                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Flexible(

                    child: Text(

                      widget.tag,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}