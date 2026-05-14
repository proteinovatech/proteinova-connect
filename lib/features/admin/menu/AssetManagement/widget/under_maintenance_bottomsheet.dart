import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import '../models/asset_model.dart';

class UnderMaintenanceBottomSheet extends StatelessWidget {
  final List<AssetModel> assets;
  const UnderMaintenanceBottomSheet({
    super.key,
    required this.assets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: Column(
        children: [
          SizedBox(height: getHeight(context, 12)),
          Container(
            width: getWidth(context, 70),
            height: getHeight(context, 5),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          SizedBox(height: getHeight(context, 26)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: getWidth(context, 24)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.build_outlined,
                    color: Colors.purple,
                    size: 28,
                  ),
                ),
                SizedBox(width: getWidth(context, 16)),
                const Expanded(
                  child: Text(
                    "Under Maintenance",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 30),
                ),
              ],
            ),
          ),
          SizedBox(height: getHeight(context, 24)),
          Divider(color: Colors.grey.shade300, height: 1),
          _buildTableHeader(context),
          if (assets.isEmpty) ...[
            const Spacer(),
            Icon(
              Icons.inventory_2_outlined,
              size: 120,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: getHeight(context, 28)),
            const Text(
              "No assets under maintenance.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: getHeight(context, 80)),
          ] else
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: getWidth(context, 20), vertical: getHeight(context, 10)),
                itemCount: assets.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  return _buildAssetRow(asset,context);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: getWidth(context, 20), vertical: getHeight(context, 18),),
      color: const Color(0xffFAFAFA),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text("ASSET DETAILS", style: _headerStyle)),
          Expanded(flex: 2, child: Text("CATEGORY", style: _headerStyle)),
          Expanded(flex: 2, child: Text("LOCATION", style: _headerStyle)),
          Expanded(flex: 2, child: Text("STATUS", style: _headerStyle)),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 11,
    color: Colors.grey,
    fontWeight: FontWeight.bold,
  );

  Widget _buildAssetRow(AssetModel asset,BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: getWidth(context, 20), vertical: getHeight(context, 8)),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  asset.assetId,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(asset.category, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Text(asset.location, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusTag(asset.status,context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status,BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: getWidth(context, 8), vertical: getHeight(context, 4)),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.purple,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
