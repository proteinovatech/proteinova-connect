import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/presentation/active_offer_details_bottom_sheet.dart';
import 'package:proteinova_connect/features/admin/presentation/add_offer_bottom_sheet.dart';
import 'package:proteinova_connect/features/admin/widget/offer_price_widget.dart';

class OfferPrice extends StatelessWidget {
  const OfferPrice({super.key});

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
                    onTap: () {
                      AddOfferBottomSheet.show(context);
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

              /// CARDS
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                ActiveOffersDetailsBottomSheet.show(context);
                              },
                              child: offerCard(
                                title: "Active Offers",
                                value: "0",
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
                              value: "0",
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
                              value: "0",
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
                              value: "0",
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

                                const Text(
                                  "View All",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff6B7280),
                                  ),
                                ),

                                const SizedBox(width: 6),

                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Color(0xff6B7280),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xffE5E7EB),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 18,
                                    ),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color(0xffE5E7EB),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "OFFER NAME",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff6B7280),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          flex: 2,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "PRODUCT",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff6B7280),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          flex: 3,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "OFFER DETAILS",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff6B7280),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          flex: 3,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "VALID DATES",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff6B7280),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          flex: 2,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "STATUS",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff6B7280),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    height: 250,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 70,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            color: const Color(0xffF4F4F5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.inbox_outlined,
                                            size: 32,
                                            color: Color(0xff94A3B8),
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        const Text(
                                          "No offers available",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xff64748B),
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

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
