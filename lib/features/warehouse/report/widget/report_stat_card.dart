import 'package:flutter/material.dart';

class ReportStatCard extends StatelessWidget {
  final String title;
  final String amount;
  final String growth;
  final IconData icon;
  final Color iconBg;
  final Color growthColor;
  final VoidCallback? onTap;

  const ReportStatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.growth,
    required this.icon,
    required this.iconBg,
    required this.growthColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNegative = growth.contains("-");

    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: const Color(0xffE5E7EB)),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Expanded(
                  child: Text(
                    title,

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xff6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: iconBg,

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Icon(icon, size: 22),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,

                child: FittedBox(
                  fit: BoxFit.scaleDown,

                  alignment: Alignment.centerLeft,

                  child: Text(
                    amount,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff111827),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,

              spacing: 6,

              runSpacing: 4,

              children: [
                Icon(
                  isNegative ? Icons.trending_down : Icons.trending_up,

                  size: 18,

                  color: growthColor,
                ),

                Text(
                  growth,

                  style: TextStyle(
                    color: growthColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const Text(
                  "last month",

                  style: TextStyle(color: Color(0xff6B7280), fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
