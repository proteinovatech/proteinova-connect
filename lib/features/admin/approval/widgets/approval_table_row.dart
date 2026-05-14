import 'package:flutter/material.dart';

import '../models/approval_model.dart';

class ApprovalTableRow extends StatelessWidget {
  final ApprovalModel approval;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onView;

  const ApprovalTableRow({
    super.key,
    required this.approval,
    required this.onApprove,
    required this.onReject,
    required this.onView,
  });
  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
    Color iconBg = const Color(0xffF3F4F6),
    Color iconColor = const Color(0xff6B7280),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xff9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff111827),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isApproved = approval.status.toLowerCase() == "approved";

    final bool isRejected = approval.status.toLowerCase() == "rejected";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: Colors.grey.shade200),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP SECTION
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// LEFT ICON
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: const Color(0xffDBEAFE),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xff3B82F6),
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              /// RIGHT CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      approval.requestId,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff111827),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// GRID INFO
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: infoCard(
                                icon: Icons.calendar_today_outlined,
                                title: "Date",
                                value: approval.date,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: infoCard(
                                icon: Icons.inventory_2_outlined,
                                title: "Details",
                                value: approval.details,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: infoCard(
                                icon: Icons.person_outline,
                                title: "Customer",
                                value: approval.customer,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: approval.status == "Approved"
                                        ? Colors.green.shade100
                                        : approval.status == "Rejected"
                                        ? Colors.red.shade100
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    approval.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: approval.status == "Approved"
                                          ? Colors.green
                                          : approval.status == "Rejected"
                                          ? Colors.red
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: onView,
                                    child: const Icon(
                                      Icons.remove_red_eye_outlined,
                                      size: 20,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  InkWell(
                                    onTap: onApprove,
                                    child: const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  InkWell(
                                    onTap: onReject,
                                    child: const Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
