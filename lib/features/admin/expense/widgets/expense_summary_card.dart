import 'package:flutter/material.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color iconBg;
  final VoidCallback onTap;

  const ExpenseSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xffE5E7EB),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xff6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Icon(icon),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                amount,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}