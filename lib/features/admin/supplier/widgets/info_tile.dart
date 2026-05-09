import 'package:flutter/material.dart';

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoTile({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xff9CA3AF)),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
