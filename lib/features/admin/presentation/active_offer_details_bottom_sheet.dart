import 'package:flutter/material.dart';
import 'package:proteinova_connect/services/offer_service.dart';

class ActiveOffersDetailsBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const ActiveOffersDetailsScreen();
      },
    );
  }
}

class ActiveOffersDetailsScreen extends StatefulWidget {
  const ActiveOffersDetailsScreen({super.key});

  @override
  State<ActiveOffersDetailsScreen> createState() => _ActiveOffersDetailsScreenState();
}

class _ActiveOffersDetailsScreenState extends State<ActiveOffersDetailsScreen> {
  bool isLoading = true;
  List<dynamic> offers = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    final result = await OfferService.fetchOffers();
    if (result != null && result['success'] == true) {
      setState(() {
        offers = result['data']['offers_list'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .84,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          /// HANDLE
          const SizedBox(height: 10),

          Container(
            height: 6,
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xffD1D5DB),
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          const SizedBox(height: 22),

          /// TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Active Offers Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff0F172A),
                    ),
                  ),
                ),

                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffF3F4F6),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xff6B7280),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Divider(color: Colors.grey.shade300, height: 1),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// TABLE
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xffE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          /// BODY
                          Expanded(
                            child: isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : offers.isEmpty
                                    ? _buildEmptyState()
                                    : Scrollbar(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: SizedBox(
                                            width: 500,
                                            child: Column(
                                              children: [
                                                /// HEADER
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xffFAFAFA),
                                                    border: Border(bottom: BorderSide(color: Color(0xffE5E7EB))),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      _cell("Offer Name", 150, isHeader: true),
                                                      _cell("Product", 100, isHeader: true),
                                                      _cell("Status", 80, isHeader: true),
                                                      _cell("Dates", 100, isHeader: true),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: ListView.separated(
                                                    padding: EdgeInsets.zero,
                                                    itemCount: offers.length,
                                                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xffE5E7EB)),
                                                    itemBuilder: (context, index) {
                                                      final offer = offers[index];
                                                      return Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                        child: Row(
                                                          children: [
                                                            _cell(offer['offer_name'] ?? "-", 150, isBold: true),
                                                            _cell(offer['product_name'] ?? "All", 100),
                                                            _statusCell(offer['status'] ?? "inactive", 80),
                                                            _cell("${offer['start_date']}\n${offer['end_date']}", 100, fontSize: 10),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  /// CLOSE BUTTON
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffD1D5DB)),
                      ),
                      child: const Center(
                        child: Text(
                          "Close",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff111827),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String text, double width, {bool isHeader = false, bool isBold = false, double fontSize = 12}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isHeader
              ? FontWeight.w700
              : isBold
                  ? FontWeight.w600
                  : FontWeight.normal,
          color: isHeader ? const Color(0xff111827) : const Color(0xff374151),
        ),
      ),
    );
  }

  Widget _statusCell(String status, double width) {
    final isActive = status.toLowerCase() == 'active';
    return SizedBox(
      width: width,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xffDCFCE7) : const Color(0xffFEE2E2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          status.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xff166534) : const Color(0xff991B1B),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffF5F5F5)),
            child: const Icon(Icons.inbox_outlined, size: 38, color: Color(0xff94A3B8)),
          ),
          const SizedBox(height: 20),
          const Text(
            "No records found",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xff0F172A)),
          ),
          const SizedBox(height: 12),
          const Text(
            "There are no active offers\navailable at the moment.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xff6B7280)),
          ),
        ],
      ),
    );
  }
}
