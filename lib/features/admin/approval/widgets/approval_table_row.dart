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
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(16),

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
                              child: infoCard(
                                icon: Icons.local_shipping_outlined,
                                title: "Requester",
                                value:
                                    "${approval.type}\n${approval.requester}",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// STATUS + VIEW
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color: isApproved
                                ? Colors.green.shade100
                                : isRejected
                                ? Colors.red.shade100
                                : Colors.orange.shade100,

                            borderRadius: BorderRadius.circular(30),
                          ),

                          child: Text(
                            approval.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isApproved
                                  ? Colors.green
                                  : isRejected
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                          ),
                        ),

                        const Spacer(),

                        InkWell(
                          onTap: onView,
                          child: const Row(
                            children: [
                              Text(
                                "View",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff374151),
                                ),
                              ),

                              SizedBox(width: 4),

                              Icon(
                                Icons.chevron_right,
                                color: Color(0xff9CA3AF),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: onReject,

                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade200),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    child: const Text(
                      "Reject",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onApprove,

                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.green,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    child: const Text(
                      "Approve",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
