import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

import '../data/asset_repository.dart';
import '../models/asset_model.dart';

class AssetTableWidget extends StatelessWidget {
  final List<AssetModel> assets;
  final VoidCallback? onStatusChanged;

  const AssetTableWidget({
    super.key,
    required this.assets,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: getWidth(context, 600),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.09),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            /// TABLE HEADER
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: getWidth(context, 100),
                  child: const Text(
                    'ASSET DETAILS',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: getWidth(context, 80),
                  child: const Text(
                    'CATEGORY',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: getWidth(context, 80),
                  child: const Text(
                    'QTY',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: getWidth(context, 80),
                  child: const Text(
                    'LOCATION',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: getWidth(context, 80),
                  child: const Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: getWidth(context, 50),
                  child: const Text(
                    'ACTION',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            Divider(
              height: getHeight(context, 30),
              color: Colors.grey.shade200,
            ),

            if (assets.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: assets.length,
                separatorBuilder: (context, index) => Divider(
                  height: getHeight(context, 20),
                  color: Colors.grey.shade100,
                ),
                itemBuilder: (context, index) {
                  return _buildRow(context, assets[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, AssetModel asset) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: getWidth(context, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                asset.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                asset.assetId,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        SizedBox(
          width: getWidth(context, 80),
          child: Text(asset.category, style: const TextStyle(fontSize: 12)),
        ),
        SizedBox(
          width: getWidth(context, 80),
          child: Text(
            asset.quantity.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        SizedBox(
          width: getWidth(context, 80),
          child: Text(
            asset.location,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: getWidth(context, 80),
          child: _buildStatus(asset.status),
        ),
        SizedBox(
          width: getWidth(context, 50),
          child: GestureDetector(
            onTap: () => _showActionSheet(context, asset),
            child: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
          ),
        ),
      ],
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
        // ignore: deprecated_member_use
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

  void _showActionSheet(BuildContext context, AssetModel asset) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _AssetActionSheet(asset: asset, onStatusChanged: onStatusChanged),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.assignment_outlined, size: 110, color: Colors.grey.shade300),
        const SizedBox(height: 24),
        const Text(
          'No assets found',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Get started by adding your first asset.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

/// ── Action Bottom Sheet ────────────────────────────────────────────────────

class _AssetActionSheet extends StatefulWidget {
  final AssetModel asset;
  final VoidCallback? onStatusChanged;

  const _AssetActionSheet({required this.asset, this.onStatusChanged});

  @override
  State<_AssetActionSheet> createState() => _AssetActionSheetState();
}

class _AssetActionSheetState extends State<_AssetActionSheet> {
  final AssetRepository _repository = AssetRepository();
  bool _isLoading = false;

  static const _statuses = ['Available', 'In Use', 'Maintenance', 'Damaged'];

  static Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'in use':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'damaged':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (widget.asset.id == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Asset ID not found')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _repository.updateAssetStatus(widget.asset.id, newStatus);
      if (mounted) {
        Navigator.pop(context);
        widget.onStatusChanged?.call();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: getWidth(context, 40),
              height: getHeight(context, 4),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Asset name + id
          Text(
            widget.asset.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.asset.assetId,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 20),
          const Text(
            'Update Status',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _statuses.map((status) {
                final isCurrent = widget.asset.status == status;
                final color = _statusColor(status);
                return GestureDetector(
                  onTap: isCurrent ? null : () => _updateStatus(status),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: isCurrent ? color : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      // ignore: deprecated_member_use
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isCurrent ? Colors.white : color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
