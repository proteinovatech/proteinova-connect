import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../bloc/ledger_bloc.dart';
import '../bloc/ledger_event.dart';
import '../bloc/ledger_state.dart';
import '../data/model/ledger_model.dart';

class LedgerScreen extends StatefulWidget {
  final int branchId;
  const LedgerScreen({super.key, required this.branchId});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final _formatter = NumberFormat('#,##0.00', 'en_IN');
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    print("Ledger Branch ID: ${widget.branchId}");

    context.read<LedgerBloc>().add(FetchLedgerEvent(widget.branchId));
  }

  List<LedgerEntry> _getFilteredEntries(List<LedgerEntry> entries) {
    if (_searchQuery.isEmpty) return entries;
    final q = _searchQuery.toLowerCase();
    return entries
        .where(
          (e) =>
              e.customerName.toLowerCase().contains(q) ||
              e.customerPhone.contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LedgerBloc, LedgerState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          Navigator.of(context).pop(); // close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment recorded successfully!'),
              backgroundColor: Color(0xFF22C55E),
            ),
          );
        } else if (state is PaymentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: BlocBuilder<LedgerBloc, LedgerState>(
            builder: (context, state) {
              if (state is LedgerLoading) return _buildShimmer();
              if (state is LedgerError) return _buildError(state.message);

              final entries = state is LedgerLoaded
                  ? state.entries
                  : state is PaymentSubmitting
                  ? state.entries
                  : state is PaymentSuccess
                  ? state.entries
                  : state is PaymentFailure
                  ? state.entries
                  : <LedgerEntry>[];

              final isSubmitting = state is PaymentSubmitting;
              final filtered = _getFilteredEntries(entries);

              final totalBilled = entries.fold<double>(
                0,
                (s, e) => s + e.totalBilled,
              );
              final totalPaid = entries.fold<double>(
                0,
                (s, e) => s + e.totalPaid,
              );
              final totalPending = entries.fold<double>(
                0,
                (s, e) => s + e.pendingAmount,
              );

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<LedgerBloc>().add(
                    FetchLedgerEvent(widget.branchId),
                  );
                },
                child: CustomScrollView(
                  slivers: [
                    // ── Header ──────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(
                                  Icons.arrow_back,
                                  size: 24,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ledger',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet_outlined,
                                        size: 14,
                                        color: Color(0xFF3B82F6),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Branch',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1D4ED8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                context.read<LedgerBloc>().add(
                                  FetchLedgerEvent(widget.branchId),
                                );
                              },
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Summary Cards ───────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: Row(
                          children: [
                            _buildSummaryCard(
                              label: 'Total Billed',
                              value: '₹${_formatter.format(totalBilled)}',
                              color: const Color(0xFF3B82F6),
                              bgColor: const Color(0xFFEFF6FF),
                              icon: Icons.receipt_long_outlined,
                            ),
                            const SizedBox(width: 10),
                            _buildSummaryCard(
                              label: 'Collected',
                              value: '₹${_formatter.format(totalPaid)}',
                              color: const Color(0xFF22C55E),
                              bgColor: const Color(0xFFF0FDF4),
                              icon: Icons.check_circle_outline,
                            ),
                            const SizedBox(width: 10),
                            _buildSummaryCard(
                              label: 'Pending',
                              value: '₹${_formatter.format(totalPending)}',
                              color: const Color(0xFFEF4444),
                              bgColor: const Color(0xFFFEF2F2),
                              icon: Icons.pending_outlined,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Search bar ──────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: InputDecoration(
                              hintText: 'Search customer by name or phone...',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: Color(0xFF94A3B8),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Section Title ────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Row(
                          children: [
                            const Text(
                              'Customer Balances',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${filtered.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Customer List ────────────────────────────────
                    if (filtered.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 60,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No ledger entries found'
                                    : 'No customers match "$_searchQuery"',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final entry = filtered[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildCustomerCard(
                                context,
                                entry,
                                isSubmitting: isSubmitting,
                              ),
                            );
                          }, childCount: filtered.length),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(
    BuildContext context,
    LedgerEntry entry, {
    bool isSubmitting = false,
  }) {
    final progress = entry.totalBilled > 0
        ? (entry.totalPaid / entry.totalBilled).clamp(0.0, 1.0)
        : 0.0;

    Color statusColor;
    Color statusBg;
    IconData statusIcon;
    if (entry.status == 'Paid') {
      statusColor = const Color(0xFF22C55E);
      statusBg = const Color(0xFFF0FDF4);
      statusIcon = Icons.check_circle_rounded;
    } else if (entry.status == 'Partial') {
      statusColor = const Color(0xFFF59E0B);
      statusBg = const Color(0xFFFFFBEB);
      statusIcon = Icons.timelapse_rounded;
    } else {
      statusColor = const Color(0xFFEF4444);
      statusBg = const Color(0xFFFEF2F2);
      statusIcon = Icons.warning_amber_rounded;
    }

    return GestureDetector(
      onTap: () =>
          _openPaymentSheet(context, entry, isSubmitting: isSubmitting),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: name + status badge
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: statusBg,
                  child: Text(
                    entry.customerName.isNotEmpty
                        ? entry.customerName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.customerName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        entry.customerPhone,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        entry.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFF1F5F9),
                color: statusColor,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 10),

            // Amounts row
            Row(
              children: [
                _buildAmountLabel(
                  'Billed',
                  '₹${_formatter.format(entry.totalBilled)}',
                  const Color(0xFF64748B),
                ),
                const Spacer(),
                _buildAmountLabel(
                  'Paid',
                  '₹${_formatter.format(entry.totalPaid)}',
                  const Color(0xFF22C55E),
                ),
                const Spacer(),
                _buildAmountLabel(
                  'Pending',
                  '₹${_formatter.format(entry.pendingAmount)}',
                  const Color(0xFFEF4444),
                ),
              ],
            ),

            if (entry.lastPaymentDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last payment: ${entry.lastPaymentDate}',
                style: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountLabel(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 2),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _openPaymentSheet(
    BuildContext context,
    LedgerEntry entry, {
    bool isSubmitting = false,
  }) {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: context.read<LedgerBloc>(),
          child: BlocBuilder<LedgerBloc, LedgerState>(
            builder: (ctx, state) {
              final submitting = state is PaymentSubmitting;
              return Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(ctx).viewInsets.bottom + 24,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Customer name
                    Text(
                      entry.customerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      entry.customerPhone,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 16),

                    // Balance breakdown
                    Row(
                      children: [
                        _balanceChip(
                          'Total Billed',
                          '₹${_formatter.format(entry.totalBilled)}',
                          const Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 10),
                        _balanceChip(
                          'Paid',
                          '₹${_formatter.format(entry.totalPaid)}',
                          const Color(0xFF22C55E),
                        ),
                        const SizedBox(width: 10),
                        _balanceChip(
                          'Pending',
                          '₹${_formatter.format(entry.pendingAmount)}',
                          const Color(0xFFEF4444),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Payment input
                    if (entry.pendingAmount > 0) ...[
                      const Text(
                        'Record Payment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter amount to record',
                            hintStyle: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.currency_rupee,
                              color: Color(0xFF64748B),
                              size: 18,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submitting
                              ? null
                              : () {
                                  final amt = double.tryParse(
                                    amountController.text.trim(),
                                  );
                                  if (amt == null || amt <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a valid amount',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  ctx.read<LedgerBloc>().add(
                                    RecordPaymentEvent(
                                      customerId: entry.id,
                                      amount: amt,
                                      branchId: widget.branchId,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: submitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Confirm Payment',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF22C55E),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'All payments are cleared!',
                              style: TextStyle(
                                color: Color(0xFF22C55E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _balanceChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Summary cards shimmer
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // List shimmer
          ...List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                direction: i % 2 == 0
                    ? ShimmerDirection.ltr
                    : ShimmerDirection.rtl,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load ledger',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.read<LedgerBloc>().add(
                FetchLedgerEvent(widget.branchId),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
