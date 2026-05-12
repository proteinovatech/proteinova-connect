/// ==========================================
/// asset_bottomsheet_widget.dart
/// ==========================================

import 'package:flutter/material.dart';

import '../models/asset_model.dart';

class TotalTrackedBottomsheetWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<AssetModel> assets;

  const TotalTrackedBottomsheetWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.assets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.vertical(
          top: Radius.circular(34),
        ),
      ),

      child: Column(
        children: [

          /// TOP LINE
          const SizedBox(height: 12),

          Container(
            width: 70,
            height: 5,

            decoration: BoxDecoration(
              color: Colors.grey.shade300,

              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 26),

          /// HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Row(
              children: [

                /// ICON
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                /// TITLE
                Expanded(
                  child: Text(
                    title,

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                /// CLOSE
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },

                  child: const Icon(
                    Icons.close,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Divider(
            color: Colors.grey.shade300,
            height: 1,
          ),

          /// TABLE HEADER
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),

            color: const Color(0xffFAFAFA),

            child: const Row(
              children: [

                Expanded(
                  flex: 3,

                  child: Text(
                    "ASSET DETAILS",

                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,

                  child: Text(
                    "CATEGORY",

                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,

                  child: Text(
                    "LOCATION",

                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,

                  child: Text(
                    "STATUS",

                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (assets.isEmpty) ...[
            const Spacer(),
            Icon(
              Icons.inventory_2_outlined,
              size: 120,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 28),
            const Text(
              "No assets found.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 80),
          ] else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: assets.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asset.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                asset.assetId,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            asset.category,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            asset.location,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildStatus(asset.status),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatus(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'available':
        color = Colors.green;
        break;
      case 'in use':
        color = Colors.blue;
        break;
      case 'maintenance':
        color = Colors.orange;
        break;
      case 'damaged':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}


