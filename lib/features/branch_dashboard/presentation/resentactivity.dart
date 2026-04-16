import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/activityitem.dart';

class Resentactivity extends StatelessWidget {
  const Resentactivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent Activity"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [

                   ActivityItem(
      leading: const CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: "Sarah jenzkin generated purchase order",
      subtitle: Row(
        children: const [
          Text("#PO-4092",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(width: 5),
          Text("for 500x wireless headset",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
      time: "10 min ago",
      tag: "procurement",
    ),

    const SizedBox(height: 15),
    const Divider(),
               const SizedBox(height: 12),

                      ActivityItem(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.local_shipping_outlined,
            color: Colors.green),
      ),
      title: "Dispatch DS-110 marked as in transit to",
      subtitle: const Text(
        "Branch (Downtown)",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      time: "10 min ago",
      tag: "procurement",
    ),
    const SizedBox(height: 15),
    const Divider(),
    const SizedBox(height: 10),
        ActivityItem(
     leading: const CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: "Marcus Doe recorded anew bulk sales",
      subtitle: const Text(
        "entry #NV",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
      ),
      time: "5 min ago",
      tag: "delivery",
    ),
    const SizedBox(height: 15),
    const Divider(),
    const SizedBox(height: 10),
      ActivityItem(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.error_outline,
            color: Colors.red),
      ),
      title: "Dispatch DS-110 marked as in transit to",
      subtitle: const Text(
        "Branch (Downtown)",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      time: "10 min ago",
      tag: "procurement",
    ),
    const SizedBox(height: 15),
    const Divider(),
    const SizedBox(height: 10),
        ActivityItem(
     leading: const CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: "Marcus Doe recorded anew bulk sales",
      subtitle: const Text(
        "entry #NV",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
      ),
      time: "5 min ago",
      tag: "delivery",
    ),
 
          ],
        ),
      ),
    );
  }
}