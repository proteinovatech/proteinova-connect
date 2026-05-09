import 'package:flutter/material.dart';

class ApprovalFilterDropdown extends StatelessWidget {
  final String value;
  final Function(String?) onChanged;

  const ApprovalFilterDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xffE5E7EB),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [
            DropdownMenuItem(
              value: "Pending Review",
              child: Text("Pending Review"),
            ),
            DropdownMenuItem(
              value: "Approved",
              child: Text("Approved"),
            ),
            DropdownMenuItem(
              value: "Rejected",
              child: Text("Rejected"),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}