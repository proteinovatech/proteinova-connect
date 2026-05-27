import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/admin/admin customertrays/data/models/admin_customer_tray_model.dart';
import 'package:proteinova_connect/features/admin/admin customertrays/data/repository/admin_customer_tray_service.dart';

class AdminCustomerTrays extends StatefulWidget {
  final bool isBranch;
  final String branchName;

  const AdminCustomerTrays({
    super.key,
    this.isBranch = false,
    this.branchName = "",
  });

  @override
  State<AdminCustomerTrays> createState() => _AdminCustomerTraysState();
}

class _AdminCustomerTraysState extends State<AdminCustomerTrays> {
  final TextEditingController _searchController = TextEditingController();
  List<AdminCustomerTray> _salesData = [];
  bool _isLoading = true;
  String _searchTerm = "";
  Timer? _debounce;

  // Stats
  int _totalGiven = 0;
  int _totalReturned = 0;
  int _totalBalance = 0;

  @override
  void initState() {
    super.initState();
    _fetchCustomerTrays();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchCustomerTrays() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      final data = await AdminCustomerTrayService.getCustomerTrays(
        search: _searchTerm,
        isBranch: widget.isBranch,
        branchName: widget.branchName,
      );

      if (!mounted) return;

      int given = 0;
      int returned = 0;
      int balance = 0;

      for (var item in data) {
        given += item.traysGiven;
        returned += item.traysReturned;
        balance += item.balance;
      }

      setState(() {
        _salesData = data;
        _totalGiven = given;
        _totalReturned = returned;
        _totalBalance = balance;
        _isLoading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch customer trays: $err"),
          backgroundColor: AppColors.redAccent,
        ),
      );
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchTerm = query;
      });
      _fetchCustomerTrays();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customer Trays Ledger",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.isBranch
                  ? "Tracking trays given to customers in ${widget.branchName}"
                  : "Track empty trays given to customers during sales",
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569)),
            onPressed: _fetchCustomerTrays,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: "Search by customer name or number...",
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
              ),
            ),
          ),

          // Mini Stats Section
          if (!_isLoading) _buildStatsCards(),

          // Main list content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.amber600),
                    ),
                  )
                : _salesData.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchCustomerTrays,
                        color: AppColors.amber600,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _salesData.length,
                          itemBuilder: (context, index) {
                            final item = _salesData[index];
                            return _buildLedgerCard(item, index);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      height: 76,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildStatCard(
            title: "Given",
            value: _totalGiven.toString(),
            icon: Icons.unarchive_outlined,
            color: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFEFF6FF),
          ),
          _buildStatCard(
            title: "Returned",
            value: _totalReturned.toString(),
            icon: Icons.archive_outlined,
            color: const Color(0xFF10B981),
            bgColor: const Color(0xFFECFDF5),
          ),
          _buildStatCard(
            title: "Balance",
            value: _totalBalance.toString(),
            icon: Icons.account_balance_wallet_outlined,
            color: _totalBalance > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
            bgColor: _totalBalance > 0 ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Color(0xFFD97706),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No tray records found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "No records match your search or filters at this time.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLedgerCard(AdminCustomerTray item, int index) {
    // Determine balance color details
    final bool hasBalance = item.balance > 0;
    final Color balanceBg = hasBalance ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7);
    final Color balanceText = hasBalance ? const Color(0xFFB91C1C) : const Color(0xFF15803D);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 50).clamp(0, 300)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0.0, (1.0 - value) * 15),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Customer header row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.customerName.isEmpty ? 'Walk-in' : item.customerName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone_android, size: 12, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              item.customerNumber.isEmpty ? '-' : item.customerNumber,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!widget.isBranch)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.soldLocation.isEmpty ? 'Admin' : item.soldLocation,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            // Bottom stats detail grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "TRAY TYPE",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.trayType,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "GIVEN",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.traysGiven.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "RETURNED",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.traysReturned.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "BALANCE",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: balanceBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.balance.toString(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: balanceText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
