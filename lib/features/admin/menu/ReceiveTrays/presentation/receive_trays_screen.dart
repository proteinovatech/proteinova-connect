import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/menu/ReceiveTrays/services/tray_receive_service.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_expense_management_skeleton_loader.dart';

class ReceiveTraysScreen extends StatefulWidget {
  const ReceiveTraysScreen({super.key});

  @override
  State<ReceiveTraysScreen> createState() => _ReceiveTraysScreenState();
}

class _ReceiveTraysScreenState extends State<ReceiveTraysScreen> {
  final TrayReceiveService _trayReceiveService = TrayReceiveService();
  List<dynamic> receiveNotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReceiveNotes();
  }

  Future<void> _fetchReceiveNotes() async {
    setState(() {
      isLoading = true;
    });
    try {
      final notes = await _trayReceiveService.getTrayReceiveNotes();
      setState(() {
        receiveNotes = notes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading records: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isSmall = width < 380;

    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xffF6F7FB),
        elevation: 0,
        scrolledUnderElevation: 0,

        leadingWidth: getWidth(context, 70),

        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),

          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },

            child: const Center(
              child: Icon(
                Icons.arrow_back_outlined,
                size: 28,
                color: Colors.black,
              ),
            ),
          ),
        ),

        titleSpacing: 0,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Receive Trays",

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: isSmall ? 22 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xff0B132B),
              ),
            ),

            const SizedBox(height: 2),

            Text(
              "Manage and receive incoming trays",

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: isSmall ? 12 : 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      body: isLoading
          ? const AdminExpenseManagementSkeletonLoader()
          : RefreshIndicator(
              onRefresh: _fetchReceiveNotes,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 16 : 20,
                    vertical: 16,
                  ),

                  child: Column(
                    children: [
                      /// APP BAR
                      SizedBox(height: getHeight(context, 14)),

                      /// RECEIVED INFO CARD
                      Container(
                        width: double.infinity,

                        padding: EdgeInsets.all(isSmall ? 16 : 20),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(22),

                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black.withValues(alpha: 0.04),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Row(
                          children: [
                            /// ICON
                            SizedBox(width: getWidth(context, 12)),

                            /// TEXT
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "Received Info",

                                    style: TextStyle(
                                      fontSize: isSmall ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff0B132B),
                                    ),
                                  ),

                                  SizedBox(height: getHeight(context, 6)),

                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Click ",

                                          style: TextStyle(
                                            fontSize: isSmall ? 13 : 15,
                                            color: Colors.grey.shade700,
                                            height: 1.5,
                                          ),
                                        ),

                                        TextSpan(
                                          text: "View",

                                          style: TextStyle(
                                            fontSize: isSmall ? 13 : 15,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xff3B82F6),
                                          ),
                                        ),

                                        TextSpan(
                                          text:
                                              " on any record to see details.",

                                          style: TextStyle(
                                            fontSize: isSmall ? 13 : 15,
                                            color: Colors.grey.shade700,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: getHeight(context, 20)),

                      /// BUTTON ROW
                      Row(
                        children: [
                          /// CANCEL BUTTON
                          Expanded(
                            child: Container(
                              height: getHeight(context, 58),

                              decoration: BoxDecoration(
                                color: const Color(0xffEEF2F7),

                                borderRadius: BorderRadius.circular(18),

                                border: Border.all(color: Colors.grey.shade300),
                              ),

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  const Icon(
                                    Icons.refresh,
                                    color: Colors.black,
                                    size: 22,
                                  ),

                                  SizedBox(width: getWidth(context, 10)),

                                  Text(
                                    "Cancel",

                                    style: TextStyle(
                                      fontSize: isSmall ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(width: getWidth(context, 14)),

                          /// SAVE BUTTON
                          Expanded(
                            child: Container(
                              height: getHeight(context, 58),

                              decoration: BoxDecoration(
                                color: const Color(0xffFFC107),

                                borderRadius: BorderRadius.circular(18),

                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    color: Colors.orange.withValues(
                                      alpha: 0.25,
                                    ),
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Container(
                                    width: getWidth(context, 28),
                                    height: getHeight(context, 28),

                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,

                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2,
                                      ),
                                    ),

                                    child: const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                  ),

                                  SizedBox(width: getWidth(context, 12)),

                                  Text(
                                    "Save",

                                    style: TextStyle(
                                      fontSize: isSmall ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: getHeight(context, 22)),

                      /// TABLE CARD
                      Container(
                        width: double.infinity,

                        padding: EdgeInsets.all(isSmall ? 16 : 20),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(22),

                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black.withValues(alpha: 0.04),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            /// TITLE
                            Text(
                              "Recent Tray Returns",

                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff0B132B),
                              ),
                            ),

                            SizedBox(height: getHeight(context, 18)),

                            /// TABLE
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,

                              child: Container(
                                width: getWidth(context, 720),

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),

                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),

                                child: Column(
                                  children: [
                                    /// HEADER
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getWidth(context, 10),
                                        vertical: getHeight(context, 16),
                                      ),

                                      decoration: const BoxDecoration(
                                        color: Color(0xffF8FAFC),

                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(18),
                                          topRight: Radius.circular(18),
                                        ),
                                      ),

                                      child: Row(
                                        children: [
                                          tableHeader("Date"),
                                          tableHeader("From"),
                                          tableHeader("Tray Type"),
                                          tableHeader("Qty"),
                                          tableHeader("Condition"),
                                          tableHeader("Reasons"),
                                          tableHeader("Action"),
                                        ],
                                      ),
                                    ),

                                    Divider(
                                      height: 1,
                                      color: Colors.grey.shade300,
                                    ),

                                    /// ROWS OR EMPTY
                                    if (isLoading)
                                      const Padding(
                                        padding: EdgeInsets.all(50),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    else if (receiveNotes.isEmpty)
                                      Container(
                                        width: double.infinity,

                                        padding: EdgeInsets.symmetric(
                                          vertical: getHeight(context, 50),
                                        ),

                                        child: Column(
                                          children: [
                                            Container(
                                              width: getWidth(context, 120),
                                              height: getHeight(context, 120),

                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xffF8FAFC),
                                              ),

                                              child: const Icon(
                                                Icons.inventory_2_outlined,
                                                size: 58,
                                                color: Color(0xff94A3B8),
                                              ),
                                            ),

                                            SizedBox(
                                              height: getHeight(context, 18),
                                            ),

                                            Text(
                                              "No records found",

                                              style: TextStyle(
                                                fontSize: isSmall ? 22 : 26,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xff0B132B),
                                              ),
                                            ),

                                            SizedBox(
                                              height: getHeight(context, 8),
                                            ),

                                            Text(
                                              "No tray receive notes yet.",

                                              style: TextStyle(
                                                fontSize: isSmall ? 14 : 16,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: receiveNotes.length,
                                        separatorBuilder: (context, index) =>
                                            Divider(
                                              height: getHeight(context, 1),
                                              color: Colors.grey.shade300,
                                            ),
                                        itemBuilder: (context, index) {
                                          final note = receiveNotes[index];
                                          final dateStr =
                                              note['received_at'] != null
                                              ? DateFormat(
                                                  'dd MMM yyyy',
                                                ).format(
                                                  DateTime.parse(
                                                    note['received_at'],
                                                  ),
                                                )
                                              : 'N/A';

                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: getHeight(context, 12),
                                              horizontal: getWidth(context, 10),
                                            ),
                                            child: Row(
                                              children: [
                                                tableCell(dateStr),
                                                tableCell(
                                                  note['warehouse_name'] ?? '-',
                                                ),
                                                tableCell(
                                                  "Tray Return #${note['tray_return_id']}",
                                                ),
                                                tableCell(
                                                  note['received_qty']
                                                          ?.toString() ??
                                                      '0',
                                                ),
                                                tableCell(
                                                  note['received_condition'] ??
                                                      '-',
                                                ),
                                                tableCell(note['notes'] ?? '-'),
                                                tableCellAction(note),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: getHeight(context, 20)),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// TABLE HEADER
  Widget tableHeader(String title) {
    return Expanded(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  /// TABLE CELL
  Widget tableCell(String text) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: Color(0xff0B132B)),
      ),
    );
  }

  /// TABLE CELL ACTION
  Widget tableCellAction(dynamic note) {
    return Expanded(
      child: Center(
        child: InkWell(
          onTap: () {
            // View action
          },
          child: const Text(
            "View",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}
