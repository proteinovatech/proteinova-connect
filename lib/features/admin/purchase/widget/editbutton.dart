import 'package:flutter/material.dart';


class EditButton extends StatelessWidget {
  final VoidCallback? onTap;

  const EditButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, 
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit, size: 16),
            const SizedBox(width: 6),
            Text("Edit"),
          ],
        ),
      ),
    );
  }
}