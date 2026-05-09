import 'package:flutter/material.dart';

Widget buildLabel(String text) {
  return RichText(
    text: TextSpan(
      text: text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xff374151),
      ),
      children: const [
        TextSpan(
          text: " *",
          style: TextStyle(color: Colors.red),
        ),
      ],
    ),
  );
}

Widget buildTextField({required String hint}) {
  return TextField(
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xff9CA3AF), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff2563EB), width: 1.4),
      ),
    ),
  );
}

Widget buildDropdown({
  required String value,
  required List<String> items,
  required Function(String?) onChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xffD1D5DB)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 20,
          color: Color(0xff111827),
        ),
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xff111827),
          fontWeight: FontWeight.w500,
        ),
        items: items.map((e) {
          return DropdownMenuItem<String>(value: e, child: Text(e));
        }).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

Widget buildDateField() {
  return TextField(
    readOnly: true,
    decoration: InputDecoration(
      hintText: "dd-mm-yyyy",
      hintStyle: const TextStyle(fontSize: 14, color: Color(0xff9CA3AF)),
      prefixIcon: const Icon(
        Icons.calendar_today_outlined,
        size: 18,
        color: Color(0xff111827),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffD1D5DB)),
      ),
    ),
  );
}
