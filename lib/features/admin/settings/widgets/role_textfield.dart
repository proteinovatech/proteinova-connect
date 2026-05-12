import 'package:flutter/material.dart';

class RoleTextField extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;

  const RoleTextField({
    super.key,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        TextFormField(
          maxLines: maxLines,

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: const TextStyle(
              color: Color(0xff9CA3AF),
            ),

            filled: true,
            fillColor: Colors.white,

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),

              borderSide: const BorderSide(
                color: Color(0xffE5E7EB),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),

              borderSide: const BorderSide(
                color: Color(0xffE5E7EB),
              ),
            ),
          ),
        ),
      ],
    );
  }
}