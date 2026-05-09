import 'package:flutter/material.dart';

Widget addAssetButton(BuildContext context) {
  return GestureDetector(
    onTap: () {
      showModalBottomSheet(
        context: context,

        isScrollControlled: true,

        backgroundColor: Colors.transparent,

        builder: (context) {
          return const AddAssetBottomSheet();
        },
      );
    },

    child: Container(
      width: double.infinity,
      height: 56,

      decoration: BoxDecoration(
        color: const Color(0xffFFD600),

        borderRadius: BorderRadius.circular(18),
      ),

      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(Icons.add, color: Colors.black),

          SizedBox(width: 8),

          Text(
            "Add New Asset",

            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

/// ================================
/// ADD ASSET BOTTOM SHEET
/// ================================

class AddAssetBottomSheet extends StatelessWidget {
  const AddAssetBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.60,
      maxChildSize: 0.95,

      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),

          child: SingleChildScrollView(
            controller: scrollController,

            child: Column(
              children: [
                /// TOP LINE
                const SizedBox(height: 10),

                Container(
                  width: 70,
                  height: 5,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,

                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 22),

                /// HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),

                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 28),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          "Add New Asset",

                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },

                        child: const Icon(Icons.close, size: 28),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Divider(color: Colors.grey.shade300, height: 1),

                /// BODY
                Padding(
                  padding: const EdgeInsets.all(22),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      /// ASSET NAME
                      buildLabel("Asset Name"),

                      const SizedBox(height: 10),

                      buildField(hint: "Enter asset name"),

                      const SizedBox(height: 22),

                      /// ASSET ID
                      buildLabel("Asset ID"),

                      const SizedBox(height: 10),

                      Container(
                        height: 56,

                        width: double.infinity,

                        padding: const EdgeInsets.symmetric(horizontal: 16),

                        alignment: Alignment.centerLeft,

                        decoration: BoxDecoration(
                          color: const Color(0xffF5F5F7),

                          borderRadius: BorderRadius.circular(14),

                          border: Border.all(color: Colors.grey.shade300),
                        ),

                        child: Text(
                          "AST-2037",

                          style: TextStyle(
                            fontSize: 16,

                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      /// CATEGORY + QUANTITY
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                buildLabel("Category"),

                                const SizedBox(height: 10),

                                buildDropdown("Equipment"),
                              ],
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                buildLabel("Quantity"),

                                const SizedBox(height: 10),

                                buildField(hint: "Enter quantity"),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      /// LOCATION + STATUS
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                buildLabel("Location"),

                                const SizedBox(height: 10),

                                buildDropdown("Main Warehouse"),
                              ],
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                buildLabel("Status"),

                                const SizedBox(height: 10),

                                buildDropdown("Available"),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      /// BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 54,

                              decoration: BoxDecoration(
                                color: Colors.white,

                                borderRadius: BorderRadius.circular(14),

                                border: Border.all(color: Colors.grey.shade300),
                              ),

                              child: const Center(
                                child: Text(
                                  "Cancel",

                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Container(
                              height: 54,

                              decoration: BoxDecoration(
                                color: const Color(0xffFFD600),

                                borderRadius: BorderRadius.circular(14),
                              ),

                              child: const Center(
                                child: Text(
                                  "Add Asset",

                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildLabel(String text) {
    return Text(
      text,

      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  Widget buildField({required String hint}) {
    return Container(
      height: 56,

      padding: const EdgeInsets.symmetric(horizontal: 16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.grey.shade300),
      ),

      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,

          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
      ),
    );
  }

  Widget buildDropdown(String text) {
    return Container(
      height: 56,

      padding: const EdgeInsets.symmetric(horizontal: 16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Expanded(
            child: Text(
              text,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}
