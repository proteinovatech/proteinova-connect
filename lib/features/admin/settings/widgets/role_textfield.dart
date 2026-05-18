import 'package:flutter/material.dart';

class RoleTextField extends StatefulWidget {
  final String label;
  final String hint;
  final int maxLines;
  final TextEditingController? controller;
  final bool isPassword;
  final bool enabled;

  const RoleTextField({
    super.key,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.controller,
    this.isPassword = false,
    this.enabled = true,
  });

  @override
  State<RoleTextField> createState() => _RoleTextFieldState();
}

class _RoleTextFieldState extends State<RoleTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: widget.controller,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          obscureText: _obscureText,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              color: Color(0xff9CA3AF),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: widget.enabled ? Colors.white : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xffE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xffE5E7EB),
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
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