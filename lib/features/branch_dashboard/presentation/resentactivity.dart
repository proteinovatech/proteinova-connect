// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:proteinova_connect/core/theme/app_colors.dart';
// import 'package:proteinova_connect/features/branch_dashboard/widget/activityitem.dart';

// class Resentactivity extends StatefulWidget {
//   const Resentactivity({super.key});

//   @override
//   State<Resentactivity> createState() =>
//       _ResentactivityState();
// }

// class _ResentactivityState
//     extends State<Resentactivity> {

//   List recentActivity = [];

//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchRecentActivity();
//   }

//   Future<void> fetchRecentActivity() async {

//     try {

//       final response = await http.get(
//         Uri.parse(
//           "https://proteinova-system.onrender.com/api/branch/dashboard",
//         ),
//       );

//       if (response.statusCode == 200) {

//         final data = jsonDecode(response.body);

//         setState(() {

//   recentActivity =

//       (data["recent_activity"] as List)

//           .map(
//             (e) => {

//               "title":
//                   e["actor_name"],

//               "description":
//                   e["activity"],

//               "time":
//                   e["created_at"],

//               "tag":
//                   e["activity_type"],
//             },
//           )
//           .toList();

//   isLoading = false;
// });
//       } else {

//         setState(() {
//           isLoading = false;
//         });

//         print(
//           "Status Code : ${response.statusCode}",
//         );
//       }

//     } catch (e) {

//       setState(() {
//         isLoading = false;
//       });

//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(

//       backgroundColor:
//           AppColors.background1,

//       appBar: AppBar(

//         backgroundColor:
//             AppColors.background,

//         scrolledUnderElevation: 0,

//         title: const Text(
//           "Recent Activity",
//         ),
//       ),

//       body: isLoading

//           ? const Center(
//               child:
//                   CircularProgressIndicator(),
//             )

//           : recentActivity.isEmpty

//               ? const Center(
//                   child: Text(
//                     "No Recent Activity",
//                   ),
//                 )

//               : Padding(

//                   padding:
//                       const EdgeInsets.all(
//                     12,
//                   ),

//                   child: ListView.builder(

//                     itemCount:
//                         recentActivity.length,

//                     itemBuilder:
//                         (context, index) {

//                       final activity =
//                           recentActivity[index];

//                       return Column(

//                         children: [

//                           ActivityItem(

//                             leading:
//                                 CircleAvatar(

//                               radius: 25,

//                               backgroundColor:
//                                   Colors.grey,

//                               child: Icon(

//                                 getIcon(
//                                   activity["tag"]
//                                       .toString(),
//                                 ),

//                                 color:
//                                     Colors.white,
//                               ),
//                             ),

//                             title:
//                                 activity["title"]
//                                         ?.toString() ??
//                                     "No Title",

//                             subtitle: Text(

//                               activity["description"]
//                                       ?.toString() ??
//                                   "No Description",

//                               style:
//                                   const TextStyle(

//                                 fontWeight:
//                                     FontWeight
//                                         .bold,

//                                 fontSize: 12,
//                               ),
//                             ),

//                             time:
//                                 activity["time"]
//                                         ?.toString() ??
//                                     "",

//                             tag:
//                                 activity["tag"]
//                                         ?.toString() ??
//                                     "",
//                           ),

//                           const SizedBox(
//                             height: 15,
//                           ),

//                           const Divider(),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//     );
//   }

//   IconData getIcon(String tag) {

//     switch (tag.toLowerCase()) {

//       case "delivery":
//         return Icons.local_shipping;

//       case "error":
//         return Icons.error_outline;

//       case "procurement":
//         return Icons.shopping_cart;

//       default:
//         return Icons.person;
//     }
//   }
// }