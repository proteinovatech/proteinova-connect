import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/presentation/active_offer_details_bottom_sheet.dart';
import 'package:proteinova_connect/features/admin/presentation/add_offer_bottom_sheet.dart';
import 'package:proteinova_connect/features/admin/widget/offer_price_widget.dart';
import 'package:proteinova_connect/services/offer_service.dart';

class OfferPrice extends StatefulWidget {
  const OfferPrice({super.key});

  @override
  State<OfferPrice> createState() => _OfferPriceState();
}

class _OfferPriceState extends State<OfferPrice> {
  bool isLoading = true;
  Map<String, dynamic>? cardData;
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
        cardData = result['data']['card'];
        offers = result['data']['offers_list'];
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
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const SizedBox(height: 18),

              /// TOP BAR
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: Color(0xff111827),
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Text(
                      "Offers & Prices",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff0F172A),
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () async {
                      final result = await AddOfferBottomSheet.show(context);
                      if (result == true) {
                        _fetchData();
                      }
                    },
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xff0B1742),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            "Add Offers",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// CONTENT
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              /// CARDS
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        ActiveOffersDetailsBottomSheet.show(context);
                                      },
                                      child: offerCard(
                                        title: "Active Offers",
                                        value: (cardData?['active_offers'] ?? 0).toString(),
                                        subtitle: "Running Now",
                                        icon: Icons.attach_money,
                                        iconBg: const Color(0xffE7F7EE),
                                        iconColor: const Color(0xff22C55E),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: offerCard(
                                      title: "Product on Offers",
                                      value: (cardData?['products_on_offer'] ?? 0).toString(),
                                      subtitle: "Products",
                                      icon: Icons.gps_fixed,
                                      iconBg: const Color(0xffF5ECFF),
                                      iconColor: const Color(0xffA855F7),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: offerCard(
                                      title: "Expiring Soon",
                                      value: (cardData?['expiring_soon'] ?? 0).toString(),
                                      subtitle: "Within 7 days",
                                      icon: Icons.calendar_today_outlined,
                                      iconBg: const Color(0xffFFF2E9),
                                      iconColor: const Color(0xffF97316),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: offerCard(
                                      title: "Deactive Offers",
                                      value: (cardData?['deactive_offers'] ?? 0).toString(),
                                      subtitle: "Currently paused",
                                      icon: Icons.sync,
                                      iconBg: const Color(0xffFFF4E8),
                                      iconColor: const Color(0xffB45309),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              /// ACTIVE OFFERS TABLE
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          "Active offers",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xff0F172A),
                                          ),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () {
                                            ActiveOffersDetailsBottomSheet.show(context);
                                          },
                                          child: const Row(
                                            children: [
                                              Text(
                                                "View All",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xff6B7280),
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: Color(0xff6B7280),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 18),

                                    Scrollbar(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SizedBox(
                                          width: 600, // Fixed width for horizontal scrolling
                                          child: Column(
                                            children: [
                                              /// TABLE HEADER
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xffF9FAFB),
                                                  border: Border(bottom: BorderSide(color: Color(0xffE5E7EB))),
                                                ),
                                                child: Row(
                                                  children: [
                                                    _headerCell("OFFER NAME", 150),
                                                    _headerCell("PRODUCT", 100),
                                                    _headerCell("OFFER DETAILS", 120),
                                                    _headerCell("VALID DATES", 130),
                                                    _headerCell("STATUS", 80),
                                                  ],
                                                ),
                                              ),

                                              /// TABLE BODY
                                              offers.isEmpty
                                                  ? _emptyState()
                                                  : ListView.separated(
                                                      shrinkWrap: true,
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      itemCount: offers.length > 5 ? 5 : offers.length,
                                                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xffE5E7EB)),
                                                      itemBuilder: (context, index) {
                                                        final offer = offers[index];
                                                        return Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                                          child: Row(
                                                            children: [
                                                              _bodyCell(offer['offer_name'] ?? "-", 150, isBold: true),
                                                              _bodyCell((offer['product_name'] == null || offer['product_name'].toString().isEmpty) ? "All" : offer['product_name'], 100),
                                                              _bodyCell(_formatOfferDetails(offer), 120),
                                                              _bodyCell("${offer['start_date']} to ${offer['end_date']}", 130),
                                                              _statusCell(offer['status'] ?? "inactive", 80),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Text(
          text,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xff6B7280)),
        ),
      ),
    );
  }

  Widget _bodyCell(String text, double width, {bool isBold = false}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: const Color(0xff374151),
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xffDCFCE7) : const Color(0xffFEE2E2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xff166534) : const Color(0xff991B1B),
          ),
        ),
      ),
    );
  }

  String _formatOfferDetails(Map<String, dynamic> offer) {
    final type = offer['offer_type']?.toString().toLowerCase() ?? '';
    final unit = (offer['discount_unit']?.toString() ?? '').replaceAll('_', ' ');

    if (type == 'fixed_amount' || type == 'fixed amount') {
      final val = offer['discount_value']?.toString() ?? '0';
      return "₹$val off $unit".trim();
    } else if (type == 'percentage') {
      final val = offer['discount_value']?.toString() ?? '0';
      return "$val% off $unit".trim();
    } else if (type == 'buy_x_get_y' || type == 'buy x get y') {
      final buy = offer['buy_qty']?.toString() ?? '0';
      final free = offer['free_qty']?.toString() ?? '0';
      return "Buy $buy Get $free";
    }
    return "-";
  }

  Widget _emptyState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(color: Color(0xffF4F4F5), shape: BoxShape.circle),
            child: const Icon(Icons.inbox_outlined, size: 28, color: Color(0xff94A3B8)),
          ),
          const SizedBox(height: 12),
          const Text(
            "No offers available",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff64748B)),
          ),
        ],
      ),
    );
  }
}
