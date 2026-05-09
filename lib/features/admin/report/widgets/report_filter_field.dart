import 'package:flutter/material.dart';

class ReportFilterField extends StatelessWidget {
  final String hint;
  final IconData? prefix;
  final bool dropdown;

  const ReportFilterField({
    super.key,
    required this.hint,
    this.prefix,
    this.dropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffE5E7EB),
        ),
      ),

      child: Row(
        children: [

          if (prefix != null)
            Icon(prefix),

          if (prefix != null)
            const SizedBox(width: 10),

          Expanded(
            child: Text(
              hint,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          if (dropdown)
            const Icon(
              Icons.keyboard_arrow_down,
            ),
        ],
      ),
    );
  }
}