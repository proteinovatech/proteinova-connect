import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

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

  Widget item(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xff374151),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(context, 18),
        vertical: getHeight(context, 22),
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          item(approval.requestId, 2),

          item(approval.type, 2),

          item(approval.customer, 2),

          item(approval.details, 2),

          Expanded(
            flex: 3,
            child: Text(
              "${approval.date}\n${approval.requester}",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context, 12),
                  vertical: getHeight(context, 6),
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
                  child: const Icon(Icons.remove_red_eye_outlined, size: 20),
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
    );
  }
}
