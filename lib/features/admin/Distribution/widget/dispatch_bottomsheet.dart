import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget dispatchBottomSheet(
  BuildContext context, {
  required String title,
  List<dynamic>? data,
}) {
  final List<dynamic> records = data ?? [];

  // Filter logic based on title
  List<dynamic> filteredRecords = [];
  if (title == "Active Vehicles") {
    // Show dispatches that are currently active (In Transit, Arrival, Loading)
    filteredRecords = records.where((r) {
      final status = r['status']?.toString().toUpperCase() ?? "";
      return status == 'IN_TRANSIT' ||
          status == 'ARRIVAL' ||
          status == 'LOADING';
    }).toList();
  } else if (title == "In Transit") {
    // Strictly In Transit
    filteredRecords = records.where((r) {
      final status = r['status']?.toString().toUpperCase() ?? "";
      return status == 'IN_TRANSIT';
    }).toList();
  } else if (title == "Today's Dispatches") {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    filteredRecords = records.where((r) {
      final date = r['date']?.toString().split('T').first;
      return date == today;
    }).toList();
  } else if (title == "In Transit") {
    filteredRecords = records
        .where(
          (r) =>
              r['status']?.toString().toUpperCase() == 'IN_TRANSIT' ||
              r['status']?.toString().toUpperCase() == 'ARRIVAL',
        )
        .toList();
  } else if (title == "Total Delivered Today") {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    filteredRecords = records.where((r) {
      final date = r['date']?.toString().split('T').first;
      return date == today &&
          r['status']?.toString().toUpperCase() == 'DELIVERED';
    }).toList();
  } else {
    filteredRecords = records;
  }

  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'LOADING':
        return Colors.blue;
      case 'IN_TRANSIT':
      case 'ARRIVAL':
        return Colors.blueAccent;
      case 'ACCEPTED':
        return Colors.teal;
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr.split('T').first;
    }
  }

  return Container(
    constraints: BoxConstraints(maxHeight: 600),
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        /// HANDLE
        Center(
          child: Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 20),

        /// HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$title (${filteredRecords.length})",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.grey),
            ),
          ],
        ),

        const SizedBox(height: 18),

        if (filteredRecords.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 60,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No records found",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: filteredRecords.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),

              itemBuilder: (context, index) {
                final r = filteredRecords[index];

                final String status = r['status']?.toString() ?? "PENDING";

                final String vehicleDriver =
                    r['vehicle_driver']?.toString() ?? "-";

                final String driver = vehicleDriver.contains('(')
                    ? vehicleDriver.split('(').last.replaceAll(')', '').trim()
                    : '-';

                final String vehicle = vehicleDriver.split('(').first.trim();

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TOP SECTION
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// RECORD ID
                          Expanded(
                            flex: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "RECORD ID",
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  r['dispatch_id']?.toString() ?? "-",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 11,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        formatDate(r['date']),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          /// DESTINATION
                          Expanded(
                            flex: 13,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "DESTINATION",
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  r['destination_branch']?.toString() ?? "-",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          /// VEHICLE & DRIVER
                          Expanded(
                            flex: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "VEHICLE & DRIVER",
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vehicle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  driver,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 12),

                      /// BOTTOM SECTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// QUANTITY
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "QUANTITY",
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${r['total_qty']} Eggs",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "${r['total_trays']} Trays",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// STATUS BUTTON
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: getStatusColor(status),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    ),
  );
}
