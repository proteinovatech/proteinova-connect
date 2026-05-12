import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool enabled;
  final TextEditingController? controller;

  const ProfileTextField({
    super.key,
    required this.label,
    required this.hint,
    this.enabled = true,
    this.controller,
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
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        TextFormField(
          controller: controller,
          enabled: enabled,
          initialValue: controller == null ? hint : null,

          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? Colors.white
                : const Color(0xffF3F4F6),

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),

              borderSide: const BorderSide(
                color: Color(0xffE5E7EB),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),

              borderSide: const BorderSide(
                color: Color(0xffE5E7EB),
              ),
            ),

            disabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),

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