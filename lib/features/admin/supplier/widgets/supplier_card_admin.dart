import 'package:flutter/material.dart';
import '../models/supplier_model.dart';
import 'info_tile.dart';

class SupplierCardAdmin extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onEdit;
  final VoidCallback onMore;

  const SupplierCardAdmin({
    super.key,
    required this.supplier,
    required this.onEdit,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffECECEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// LEFT SIDE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// NAME
                    Text(
                      supplier.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff111827),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// ID
                    Text(
                      supplier.id,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              /// ACTIVE TAG
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: supplier.active ? const Color(0xffE8F8EA) : const Color(0xffFEE2E2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  supplier.active ? "ACTIVE" : "INACTIVE",
                  style: TextStyle(
                    color: supplier.active ? const Color(0xff1BA34A) : const Color(0xffDC2626),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              /// EDIT ICON
              InkWell(
                onTap: onEdit,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Color(0xff4B5563),
                ),
              ),

              const SizedBox(width: 12),

              /// MORE ICON
              InkWell(
                onTap: onMore,
                child: const Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Color(0xff4B5563),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          /// DETAILS ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// LEFT SIDE
              Expanded(
                child: Column(
                  children: [
                    InfoTile(
                      icon: Icons.location_on_outlined,
                      text: supplier.location,
                    ),

                    const SizedBox(height: 20),

                    InfoTile(icon: Icons.person_outline, text: supplier.owner),
                  ],
                ),
              ),

              const SizedBox(width: 30),

              /// RIGHT SIDE
              Expanded(
                child: Column(
                  children: [
                    InfoTile(icon: Icons.phone_outlined, text: supplier.phone),

                    const SizedBox(height: 20),

                    InfoTile(icon: Icons.mail_outline, text: supplier.email),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
