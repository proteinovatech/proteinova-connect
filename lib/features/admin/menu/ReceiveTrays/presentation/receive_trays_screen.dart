import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/config/api_config.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';

class ReceiveTraysScreen extends StatefulWidget {
  const ReceiveTraysScreen({super.key});

  @override
  State<ReceiveTraysScreen> createState() => _ReceiveTraysScreenState();
}

class _ReceiveTraysScreenState extends State<ReceiveTraysScreen> {
  List<dynamic> recentReturns = [];
  dynamic selectedRecord;
  bool loading = true;
  bool saving = false;
  bool isFetching = true;
  final TextEditingController receiveNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchReturns();
  }

  @override
  void dispose() {
    receiveNotesController.dispose();
    super.dispose();
  }

  Future<void> fetchReturns() async {
    try {
      setState(() {
        isFetching = true;
        loading = true;
      });

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/admin/tray-returns?limit=50"),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            recentReturns = data['data'] ?? [];
          });
        }
      } else {
        debugPrint("Failed to fetch returns: ${response.statusCode}");
      }
    } catch (err) {
      debugPrint("Error fetching tray returns: $err");
    } finally {
      if (mounted) {
        setState(() {
          isFetching = false;
          loading = false;
        });
      }
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat('dd MMM yy').format(d);
    } catch (_) {
      return "-";
    }
  }

  Future<void> handleViewReceived(dynamic row) async {
    try {
      setState(() {
        isFetching = true;
      });

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/admin/tray-receive?tray_return_id=${row['id']}"),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> receiveNotesList = data['data'] ?? [];
        if (mounted) {
          _showReceiveDetailsPopup(row, receiveNotesList);
        }
      } else {
        _showErrorSnackBar("Error fetching receive details: ${response.statusCode}");
      }
    } catch (err) {
      _showErrorSnackBar("Error fetching receive details: $err");
    } finally {
      if (mounted) {
        setState(() {
          isFetching = false;
        });
      }
    }
  }

  Future<void> handleSave() async {
    if (selectedRecord == null) {
      _showErrorSnackBar("Please select a tray return record first.");
      return;
    }
    final notes = receiveNotesController.text.trim();
    if (notes.isEmpty) {
      _showErrorSnackBar("Please enter notes before saving.");
      return;
    }

    try {
      setState(() {
        saving = true;
      });

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/admin/tray-receive"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tray_return_id": selectedRecord['id'],
          "received_qty": selectedRecord['quantity'],
          "received_condition": selectedRecord['condition'] ?? "GOOD",
          "notes": notes,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessSnackBar("Tray receive record saved successfully!");
        setState(() {
          receiveNotesController.clear();
          selectedRecord = null;
        });
        fetchReturns();
      } else {
        final errBody = jsonDecode(response.body);
        _showErrorSnackBar("Error saving: ${errBody['error'] ?? 'Server error'}");
      }
    } catch (err) {
      _showErrorSnackBar("Error saving: $err");
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showReceiveDetailsPopup(dynamic trayReturn, List<dynamic> receiveNotesList) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 520,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Receive Details",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),

                // Tray Return info header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tray Return Record",
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 8),
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 8,
                          childAspectRatio: 3.5,
                        ),
                        children: [
                          _buildPopupMetaItem("From", trayReturn['return_from_name']?.toString() ?? '-'),
                          _buildPopupMetaItem("Date", formatDate(trayReturn['return_date'])),
                          _buildPopupMetaItem("Tray Type", trayReturn['tray_type']?.toString() ?? '-'),
                          _buildPopupMetaItem("Claimed Qty", trayReturn['quantity']?.toString() ?? '0'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Receive Records",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 8),

                // Receive Notes List
                Expanded(
                  child: receiveNotesList.isEmpty
                      ? const Center(
                          child: Text(
                            "No receive records found.",
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          ),
                        )
                      : ListView.separated(
                          itemCount: receiveNotesList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final note = receiveNotesList[idx];
                            String receivedAtFormatted = "-";
                            if (note['received_at'] != null) {
                              try {
                                final dt = DateTime.parse(note['received_at']);
                                receivedAtFormatted = DateFormat('dd/MM/yyyy, hh:mm a').format(dt);
                              } catch (_) {}
                            }

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GridView(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 3.2,
                                    ),
                                    children: [
                                      _buildPopupMetaItem("Received Qty", note['received_qty']?.toString() ?? '0'),
                                      _buildPopupMetaItem("Condition", note['received_condition']?.toString() ?? '-'),
                                      _buildPopupMetaItem("Received At", receivedAtFormatted),
                                      _buildPopupMetaItem("Received By", note['received_by_name']?.toString() ?? '-'),
                                    ],
                                  ),
                                  if (note['notes'] != null && note['notes'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "📝 ${note['notes']}",
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Receive Trays:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              "Manage and receive incoming Trays from Branch to update inventory",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 768;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _buildLeftColumn(),
                      ),
                    ),
                    const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildRightColumn(isWide: true),
                      ),
                    ),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildLeftColumn(),
                      const SizedBox(height: 24),
                      _buildRightColumn(isWide: false),
                    ],
                  ),
                );
              }
            },
          ),
          if (isFetching)
            Container(
              color: Colors.black.withOpacity(0.15),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.amber600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Received Info Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.02),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Received Info",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              if (selectedRecord != null) ...[
                Row(
                  children: [
                    Expanded(child: _buildInfoItem("Return ID", "RTN-${selectedRecord['id'].toString().padLeft(4, '0')}")),
                    Expanded(child: _buildInfoItem("Return Date", formatDate(selectedRecord['return_date']))),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildInfoItem("Branch Name", selectedRecord['branch_name']?.toString() ?? "-")),
                    Expanded(child: _buildInfoItem("From", selectedRecord['return_from_name']?.toString() ?? "-")),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildInfoItem("Tray Type", selectedRecord['tray_type']?.toString() ?? "-")),
                    Expanded(child: _buildInfoItem("Quantity", selectedRecord['quantity']?.toString() ?? "-")),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildInfoItem("Condition", selectedRecord['condition']?.toString() ?? "-")),
                    Expanded(child: _buildInfoItem("Settlement", selectedRecord['settlement_type']?.toString() ?? "-")),
                  ],
                ),
                const Divider(height: 24),
                const Text(
                  "Warehouse Notes",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: receiveNotesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter receiving notes, discrepancies, or observations...",
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.amber600),
                    ),
                  ),
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: Center(
                    child: Text(
                      "Click View on any record to see its details here.",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    selectedRecord = null;
                    receiveNotesController.clear();
                  });
                },
                icon: const Icon(Icons.refresh, size: 16, color: Colors.black),
                label: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFFEEF2F7),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: saving ? null : handleSave,
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
                      )
                    : const Icon(Icons.check_circle_outline, size: 16, color: Colors.black),
                label: Text(
                  saving ? "Saving..." : "Save",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xffFFC107),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildRightColumn({required bool isWide}) {
    final DataTable dataTable = DataTable(
      columns: const [
        DataColumn(label: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text("From", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text("Tray Type", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text("Condition", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text("Reasons", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: recentReturns.map((row) {
        return DataRow(
          cells: [
            DataCell(Text(formatDate(row['return_date']))),
            DataCell(Text(row['return_from_name']?.toString() ?? "-")),
            DataCell(Text(row['tray_type']?.toString() ?? "-")),
            DataCell(Text(row['quantity']?.toString() ?? "0")),
            DataCell(_buildConditionBadge(row['condition']?.toString() ?? "")),
            DataCell(Text(row['remarks']?.toString() ?? "-")),
            DataCell(_buildActionCell(row)),
          ],
        );
      }).toList(),
    );

    final Widget content = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: loading
          ? const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.amber600),
                ),
              ),
            )
          : recentReturns.isEmpty
              ? const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      "No records found",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: isWide
                      ? SingleChildScrollView(
                          child: dataTable,
                        )
                      : dataTable,
                ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: isWide ? MainAxisSize.max : MainAxisSize.min,
      children: [
        const Text(
          "Recent Tray Returns",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        isWide ? Expanded(child: content) : content,
      ],
    );
  }

  Widget _buildConditionBadge(String condition) {
    final condUpper = condition.toUpperCase();
    Color bg;
    Color text;
    IconData icon;

    if (condUpper == 'GOOD') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF15803D);
      icon = Icons.check_circle_outline;
    } else if (condUpper == 'DAMAGED') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFB91C1C);
      icon = Icons.error_outline;
    } else {
      bg = const Color(0xFFF1F5F9);
      text = const Color(0xFF475569);
      icon = Icons.refresh;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            condition.isNotEmpty ? "${condition[0].toUpperCase()}${condition.substring(1).toLowerCase()}" : "-",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCell(dynamic row) {
    final status = row['receive_status']?.toString().toUpperCase();
    if (status == 'RECEIVED' || status == 'PARTIAL') {
      final isReceived = status == 'RECEIVED';
      final bg = isReceived ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C3);
      final text = isReceived ? const Color(0xFF166534) : const Color(0xFF854D0E);
      final label = isReceived ? '✓ Received' : '⚠ Partial';

      return OutlinedButton(
        onPressed: () => handleViewReceived(row),
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: text),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            selectedRecord = row;
            receiveNotesController.clear();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: const Text("View", style: TextStyle(fontSize: 11)),
      );
    }
  }
}
