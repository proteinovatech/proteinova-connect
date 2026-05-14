<<<<<<< HEAD
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:proteinova_connect/core/theme/app_colors.dart';
// import 'package:proteinova_connect/features/branch_dashboard/widget/activityitem.dart';
=======
// import 'package:flutter/material.dart';
// import 'package:proteinova_connect/core/network/dio_client.dart';
// import 'package:proteinova_connect/core/theme/app_colors.dart';
// import 'package:proteinova_connect/features/branch/branch_dashboard/data/model/dashboard_model.dart';
// import 'package:proteinova_connect/features/branch/branch_dashboard/data/repository/dashboard_repository.dart';
// import 'package:proteinova_connect/features/branch/branch_dashboard/widget/activityitem.dart';
>>>>>>> 985535f3db39fce19bb7ce2ac31180ddc2961dc9

// class Resentactivity extends StatefulWidget {
//   const Resentactivity({super.key});

//   @override
<<<<<<< HEAD
//   State<Resentactivity> createState() =>
//       _ResentactivityState();
// }

// class _ResentactivityState
//     extends State<Resentactivity> {

//   List recentActivity = [];

//   bool isLoading = true;
=======
//   State<Resentactivity> createState() => _ResentactivityState();
// }

// class _ResentactivityState extends State<Resentactivity> {
//   DashboardModel? dashboardModel;
//   bool isLoading = true;
//   late final DashboardRepository repository;
>>>>>>> 985535f3db39fce19bb7ce2ac31180ddc2961dc9

//   @override
//   void initState() {
//     super.initState();
<<<<<<< HEAD
=======
//     repository = DashboardRepository(DioClient().dio);
>>>>>>> 985535f3db39fce19bb7ce2ac31180ddc2961dc9
//     fetchRecentActivity();
//   }

//   Future<void> fetchRecentActivity() async {
<<<<<<< HEAD

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

=======
//     try {
//       final result = await repository.fetchDashboardData();

//       setState(() {
//         dashboardModel = result;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
>>>>>>> 985535f3db39fce19bb7ce2ac31180ddc2961dc9
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
<<<<<<< HEAD

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

=======
//     return Scaffold(
//       backgroundColor: AppColors.background1,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         scrolledUnderElevation: 0,
//         title: const Text("Recent Activity"),
//       ),
//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(),
//             )
//           : (dashboardModel?.recentActivity.isEmpty ?? true)
//               ? const Center(
//                   child: Text("No Recent Activity"),
//                 )
//               : Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: ListView.builder(
//                     itemCount: dashboardModel!.recentActivity.length,
//                     itemBuilder: (context, index) {
//                       final activity = dashboardModel!.recentActivity[index];

//                       return Column(
//                         children: [
//                           ActivityItem(
//                             leading: CircleAvatar(
//                               radius: 25,
//                               backgroundColor: Colors.grey,
//                               child: Icon(
//                                 getIcon(activity.tag),
//                                 color: Colors.white,
//                               ),
//                             ),
//                             title: activity.title,
//                             subtitle: Text(
//                               activity.description,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             ),
//                             time: activity.time,
//                             tag: activity.tag,
//                           ),
//                           const SizedBox(height: 15),
>>>>>>> 985535f3db39fce19bb7ce2ac31180ddc2961dc9
//                           const Divider(),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//     );
//   }

//   IconData getIcon(String tag) {
<<<<<<< HEAD

//     switch (tag.toLowerCase()) {

//       case "delivery":
//         return Icons.local_shipping;

//       case "error":
//         return Icons.error_outline;

//       case "procurement":
//         return Icons.shopping_cart;

=======
//     switch (tag.toLowerCase()) {
//       case "delivery":
//         return Icons.local_shipping;
//       case "error":
//         return Icons.error_outline;
//       case "procurement":
//         return Icons.shopping_cart;
>>>>>>> 985535f3db39fce19bb7ce2ac31180ddc2961dc9
//       default:
//         return Icons.person;
//     }
//   }
<<<<<<< HEAD
// }
=======
// }
>>>>>>> 985535f3db39fce19bb7ce2ac31180ddc2961dc9
