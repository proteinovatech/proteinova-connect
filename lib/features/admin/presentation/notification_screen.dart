import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Map<String, String> filterMapping = {
    'All Alerts': 'all',
    'Unread': 'unread',
    'Approvals': 'approvals',
    'Dispatches': 'dispatches',
    'Stock': 'stock',
  };

  String activeFilter = 'All Alerts';

  List<Map<String, dynamic>> notifications = <Map<String, dynamic>>[];

  Map<String, dynamic> counts = <String, dynamic>{
    "all": 0,
    "unread": 0,
    "approvals": 0,
    "dispatches": 0,
    "stock": 0,
  };

  bool loading = true;
  bool isFetching = true;

  Map<String, dynamic>? user;

  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      // Replace with SharedPreferences user data

      user = {"id": 1, "role": "Inventory & Ops Admin"};
    } catch (e) {
      debugPrint("User parse error $e");
    } finally {
      setState(() {
        isFetching = false;
      });

      fetchNotifications();
    }
  }

  Future<void> fetchNotifications() async {
    try {
      setState(() {
        loading = true;
      });

      final tab = filterMapping[activeFilter] ?? 'all';

      final userId = user?["id"] ?? 0;

      final url = "$baseUrl/api/admin/notifications?tab=$tab&user_id=$userId";

      debugPrint("API URL => $url");

      final response = await http.get(Uri.parse(url));

      debugPrint("NOTIFICATION STATUS => ${response.statusCode}");

      debugPrint("NOTIFICATION RESPONSE => ${response.body}");

      // Prevent HTML response parsing
      if (response.body.startsWith("<!DOCTYPE")) {
        throw Exception("API returned HTML instead of JSON.\nCheck BASE_URL");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          notifications = data["items"] ?? [];

          counts =
              data["tabs"] ??
              {
                "all": 0,
                "unread": 0,
                "approvals": 0,
                "dispatches": 0,
                "stock": 0,
              };
        });
      } else {
        throw Exception("Failed to load notifications");
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/admin/notifications/$id/read"),

        headers: {"Content-Type": "application/json"},

        body: jsonEncode({"user_id": user?["id"]}),
      );

      debugPrint("MARK READ STATUS => ${response.statusCode}");

      debugPrint("MARK READ RESPONSE => ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          notifications = notifications.map((n) {
            if (n["id"] == id) {
              n["is_read"] = true;
            }

            return n;
          }).toList();

          counts["unread"] = (counts["unread"] - 1).clamp(0, 999999);
        });
      }
    } catch (e) {
      debugPrint("Error marking as read: $e");
    }
  }

  IconData getIcon(String type) {
    switch (type) {
      case 'approval':
        return Icons.warning_amber_rounded;

      case 'dispatch':
        return Icons.local_shipping;

      case 'stock':
        return Icons.inventory_2_outlined;

      default:
        return Icons.notifications_none;
    }
  }

  Color getStatusColor(String type, String priority) {
    if (priority == 'high') {
      return Colors.red;
    }

    switch (type) {
      case 'approval':
        return Colors.orange;

      case 'dispatch':
        return Colors.red;

      case 'stock':
        return Colors.green;

      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

        // actions: [
        //   IconButton(
        //     onPressed: () {},

        //     icon: const Icon(Icons.notifications_none, color: Colors.black),
        //   ),
        // ],
      ),

      body: isFetching
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),

                  // child: Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,

                  //   children: [
                  //     Text(
                  //       "Role: ${user?["role"] ?? "Admin"}",

                  //       style: const TextStyle(
                  //         fontSize: 14,
                  //         color: Colors.grey,
                  //       ),
                  //     ),

                  //     const SizedBox(height: 15),

                  //     TextField(
                  //       decoration: InputDecoration(
                  //         hintText: "Search notifications...",

                  //         prefixIcon: const Icon(Icons.search),

                  //         filled: true,

                  //         fillColor: const Color(0xfff1f5f9),

                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(12),

                  //           borderSide: BorderSide.none,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: const [
                                Text(
                                  "Inbox",

                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 5),

                                Text(
                                  "Review system alerts and approvals",

                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),

                            TextButton.icon(
                              onPressed: fetchNotifications,

                              icon: loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,

                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.refresh),

                              label: const Text("Refresh"),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          height: 45,

                          child: ListView(
                            scrollDirection: Axis.horizontal,

                            children: [
                              filterButton("All Alerts", counts["all"]),

                              filterButton("Unread", counts["unread"]),

                              filterButton("Approvals", counts["approvals"]),

                              filterButton("Dispatches", counts["dispatches"]),

                              filterButton("Stock", counts["stock"]),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Expanded(
                          child: loading
                              ? const Center(child: CircularProgressIndicator())
                              : notifications.isEmpty
                              ? emptyWidget()
                              : ListView.builder(
                                  itemCount: notifications.length,

                                  itemBuilder: (context, index) {
                                    final n = notifications[index];

                                    final Color statusColor = getStatusColor(
                                      n["type"] ?? "",

                                      n["priority"] ?? "",
                                    );

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),

                                      decoration: BoxDecoration(
                                        color: Colors.white,

                                        borderRadius: BorderRadius.circular(16),

                                        border: Border.all(
                                          color: const Color(0xffe2e8f0),
                                        ),
                                      ),

                                      child: Row(
                                        children: [
                                          Container(
                                            width: 6,

                                            height: 170,

                                            decoration: BoxDecoration(
                                              color: statusColor,

                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      16,
                                                    ),

                                                    bottomLeft: Radius.circular(
                                                      16,
                                                    ),
                                                  ),
                                            ),
                                          ),

                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),

                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,

                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 45,

                                                        height: 45,

                                                        decoration: BoxDecoration(
                                                          color: statusColor
                                                              .withOpacity(
                                                                0.15,
                                                              ),

                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),

                                                        child: Icon(
                                                          getIcon(
                                                            n["type"] ?? "",
                                                          ),

                                                          color: statusColor,
                                                        ),
                                                      ),

                                                      const SizedBox(width: 12),

                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,

                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    n["title"] ??
                                                                        "",

                                                                    style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,

                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                                  ),
                                                                ),

                                                                Text(
                                                                  n["time_ago"] ??
                                                                      "",

                                                                  style: const TextStyle(
                                                                    color: Colors
                                                                        .grey,

                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                            const SizedBox(
                                                              height: 5,
                                                            ),

                                                            if (!(n["is_read"] ??
                                                                false))
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          8,

                                                                      vertical:
                                                                          3,
                                                                    ),

                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .blue,

                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        5,
                                                                      ),
                                                                ),

                                                                child: const Text(
                                                                  "NEW",

                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,

                                                                    fontSize:
                                                                        10,

                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 16),

                                                  Text(
                                                    n["message"] ?? "",

                                                    style: const TextStyle(
                                                      color: Colors.grey,

                                                      height: 1.5,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 16),

                                                  Wrap(
                                                    spacing: 8,

                                                    runSpacing: 8,

                                                    children: [
                                                      badge(
                                                        n["action_label"] ?? "",

                                                        const Color(0xfff1f5f9),

                                                        const Color(0xff475569),
                                                      ),

                                                      if (n["priority"] ==
                                                          "high")
                                                        badge(
                                                          "High Priority",

                                                          const Color(
                                                            0xfffee2e2,
                                                          ),

                                                          Colors.red,
                                                        ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 16),

                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,

                                                    children: [
                                                      !(n["is_read"] ?? false)
                                                          ? ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                foregroundColor:
                                                                    Colors
                                                                        .black,
                                                                elevation: 0,

                                                                side: const BorderSide(
                                                                  color: Color(
                                                                    0xffe2e8f0,
                                                                  ),
                                                                ),

                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                              ),

                                                              onPressed: () {
                                                                markAsRead(
                                                                  n["id"],
                                                                );
                                                              },

                                                              child: const Text(
                                                                "Mark as Read",
                                                              ),
                                                            )
                                                          : Row(
                                                              children: const [
                                                                Icon(
                                                                  Icons.check,

                                                                  size: 18,

                                                                  color: Colors
                                                                      .grey,
                                                                ),

                                                                SizedBox(
                                                                  width: 4,
                                                                ),

                                                                Text(
                                                                  "Read",

                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                      ElevatedButton.icon(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.white,
                                                          foregroundColor:
                                                              Colors.black,
                                                          elevation: 0,

                                                          side:
                                                              const BorderSide(
                                                                color: Color(
                                                                  0xffe2e8f0,
                                                                ),
                                                              ),

                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                        ),

                                                        onPressed: () {},

                                                        icon: const Icon(
                                                          Icons.arrow_forward,
                                                        ),

                                                        label: const Text(
                                                          "View",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget filterButton(String title, int count) {
    final bool isActive = activeFilter == title;

    return Padding(
      padding: const EdgeInsets.only(right: 10),

      child: GestureDetector(
        onTap: () {
          setState(() {
            activeFilter = title;
          });

          fetchNotifications();
        },

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(
              color: isActive ? Colors.blue : const Color(0xffe2e8f0),
            ),
          ),

          child: Center(
            child: Text(
              count > 0 ? "$title ($count)" : title,

              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,

                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget badge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

      decoration: BoxDecoration(
        color: bg,

        borderRadius: BorderRadius.circular(8),
      ),

      child: Text(
        text,

        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget emptyWidget() {
    return Center(
      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(40),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(16),

          border: Border.all(color: const Color(0xffe2e8f0)),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: const [
            Icon(Icons.notifications_none, size: 60, color: Colors.grey),

            SizedBox(height: 16),

            Text(
              "No Notifications Found",

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(
              "Everything looks clear! We'll notify you when something needs your attention.",

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
