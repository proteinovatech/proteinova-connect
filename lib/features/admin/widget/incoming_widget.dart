import 'package:flutter/material.dart';
import '../inventory/models/inventory_model.dart';

/// OVERVIEW CARD
Widget buildOverviewCard({
  required String title,
  required String value,
  required String subtitle,
  required IconData icon,
  required Color iconBg,
  Color iconColor = Colors.black,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
        ],
      ),
    ),
  );
}

/// FILTER BOX
Widget buildFilterBox({
  required IconData icon,
  required String text,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    ),
  );
}

/// TABLE HEADER
Widget buildTableHeader() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      color: Color(0xffF9FAFB),
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    child: Row(
      children: [
        _headerCell("Purchase Record", 3),
        _headerCell("Supplier Details", 3),
        _headerCell("Product & Quantity", 3),
        _headerCell("Status", 3),
      ],
    ),
  );
}

Widget _headerCell(String text, int flex) {
  return Expanded(
    flex: flex,
    child: Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Color(0xff4B5563),
      ),
    ),
  );
}

/// TABLE ROW
Widget buildTableRow({
  required String po,
  required String date,
  required String supplier,
  required String location,
  required String quantity,
  required String type,
  required String purchaseStatus,
  required String movementStatus,
  VoidCallback? onReceive,
  VoidCallback? onMarkArrival,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// PURCHASE RECORD
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                po,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xff111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 11, color: Color(0xff6B7280)),
              ),
            ],
          ),
        ),

        /// SUPPLIER DETAILS
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                supplier,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xff111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: const TextStyle(fontSize: 11, color: Color(0xff6B7280)),
              ),
            ],
          ),
        ),

        /// PRODUCT & QUANTITY
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quantity,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xff111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                type,
                style: const TextStyle(fontSize: 11, color: Color(0xff6B7280)),
              ),
            ],
          ),
        ),

        /// STATUS
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _buildStatusColumn(
              purchaseStatus: purchaseStatus,
              movementStatus: movementStatus,
              onReceive: onReceive,
              onMarkArrival: onMarkArrival,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatusColumn({
  required String purchaseStatus,
  required String movementStatus,
  VoidCallback? onReceive,
  VoidCallback? onMarkArrival,
}) {
  final pStatus = purchaseStatus.toUpperCase();
  final mStatus = movementStatus.toUpperCase();

  if (pStatus == "PURCHASED" && mStatus == "RECEIVED") {
    return InkWell(
      onTap: onReceive,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xffFEF3C7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          "Receive Stock",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: Color(0xff92400E),
          ),
        ),
      ),
    );
  } else if (pStatus == "PURCHASED" && mStatus == "ARRIVAL") {
    return InkWell(
      onTap: onReceive,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xff10B981),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          "Receive Stock",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: Colors.white,
          ),
        ),
      ),
    );
  } else if (pStatus == "PURCHASED" &&
      (mStatus == "IN_TRANSIT" || mStatus == "PENDING" || mStatus.isEmpty)) {
    return InkWell(
      onTap: onMarkArrival,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xff2563EB),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          "Mark as Arrival",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: Colors.white,
          ),
        ),
      ),
    );
  } else {
    // Default fallback status chip
    Color bgColor = const Color(0xffF3F4F6);
    Color textColor = const Color(0xff374151);
    String label = purchaseStatus.toUpperCase();

    if (label == "RECEIVED") {
      bgColor = const Color(0xffDCFCE7);
      textColor = const Color(0xff166534);
    } else if (label == "ARRIVAL" || label == "PURCHASED") {
      bgColor = const Color(0xffDBEAFE);
      textColor = const Color(0xff1E40AF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: textColor,
        ),
      ),
    );
  }
}

class ShipmentCardWidget extends StatefulWidget {
  final String title;
  final String totalTitle;
  final String totalValue;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final List<PurchaseModel> shipments;

  const ShipmentCardWidget({
    Key? key,
    required this.title,
    required this.totalTitle,
    required this.totalValue,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.shipments,
  }) : super(key: key);

  @override
  _ShipmentCardWidgetState createState() => _ShipmentCardWidgetState();
}

class _ShipmentCardWidgetState extends State<ShipmentCardWidget> {
  bool showMore = false;

  @override
  Widget build(BuildContext context) {
    final displayData = showMore ? widget.shipments : widget.shipments.take(3).toList();
    final hasMore = widget.shipments.length > 3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        text: "${widget.shipments.length} ",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                        children: const [
                          TextSpan(
                            text: "Shipments",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              text: "${widget.totalTitle}: ",
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
              ),
              children: [
                TextSpan(
                  text: widget.totalValue,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            constraints: BoxConstraints(
              maxHeight: showMore ? 250 : 180,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    color: const Color(0xFFF9FAFB),
                    child: Row(
                      children: const [
                        Expanded(
                          child: Text(
                            "LOCATION NAME",
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "CATEGORY",
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...displayData.map((row) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              row.location.isNotEmpty ? row.location : 'N/A',
                              style: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              row.productName.isNotEmpty ? row.productName : 'N/A',
                              style: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  if (widget.shipments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Center(
                        child: Text(
                          "No shipments found",
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (hasMore)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: TextButton(
                  onPressed: () => setState(() => showMore = !showMore),
                  child: Text(
                    showMore ? "Show Less" : "Show More (${widget.shipments.length - 3} left)",
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class VehicleCardWidget extends StatefulWidget {
  final String title;
  final String totalTitle;
  final String totalValue;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final List<PurchaseModel> transactions;

  const VehicleCardWidget({
    Key? key,
    required this.title,
    required this.totalTitle,
    required this.totalValue,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.transactions,
  }) : super(key: key);

  @override
  _VehicleCardWidgetState createState() => _VehicleCardWidgetState();
}

class _VehicleCardWidgetState extends State<VehicleCardWidget> {
  bool showMore = false;

  @override
  Widget build(BuildContext context) {
    final displayData = showMore ? widget.transactions : widget.transactions.take(3).toList();
    final hasMore = widget.transactions.length > 3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        text: "${widget.transactions.length} ",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                        children: const [
                          TextSpan(
                            text: "Transactions",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              text: "${widget.totalTitle}: ",
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
              ),
              children: [
                TextSpan(
                  text: widget.totalValue,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            constraints: BoxConstraints(
              maxHeight: showMore ? 250 : 180,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    color: const Color(0xFFF9FAFB),
                    child: Row(
                      children: const [
                        Expanded(
                          child: Text(
                            "VEHICLE & DRIVER",
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "LOCATION",
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...displayData.map((row) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.vehicleNumber.isNotEmpty ? row.vehicleNumber : 'N/A',
                                  style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  row.driverName.isNotEmpty ? row.driverName : 'N/A',
                                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              row.location.isNotEmpty ? row.location : 'N/A',
                              style: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  if (widget.transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Center(
                        child: Text(
                          "No vehicles available",
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (hasMore)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: TextButton(
                  onPressed: () => setState(() => showMore = !showMore),
                  child: Text(
                    showMore ? "Show Less" : "Show More (${widget.transactions.length - 3} left)",
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
