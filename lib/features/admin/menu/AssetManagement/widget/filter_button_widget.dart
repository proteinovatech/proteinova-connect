import 'package:flutter/material.dart';

class FilterButtonWidget extends StatelessWidget {
  const FilterButtonWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,

          isScrollControlled: true,

          backgroundColor: Colors.transparent,

          builder: (context) {
            return DraggableScrollableSheet(
              initialChildSize: 0.60,
              minChildSize: 0.45,
              maxChildSize: 0.90,

              builder: (
                context,
                scrollController,
              ) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
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

                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        /// HEADER
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 22,
                          ),

                          child: Row(
                            children: [

                              const Icon(
                                Icons.tune,
                                size: 24,
                              ),

                              const SizedBox(width: 10),

                              const Expanded(
                                child: Text(
                                  "Advanced Filters",

                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(
                                    context,
                                  );
                                },

                                child: const Icon(
                                  Icons.close,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        Divider(
                          color: Colors.grey.shade300,
                          height: 1,
                        ),

                        /// BODY
                        Padding(
                          padding:
                              const EdgeInsets.all(22),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              /// BRANCH
                              buildFilterLabel(
                                "Branch Location",
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              buildFilterDropdown(
                                "All Branches",
                              ),

                              const SizedBox(
                                height: 24,
                              ),

                              /// CATEGORY
                              buildFilterLabel(
                                "Asset Category",
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              buildFilterDropdown(
                                "All Categories",
                              ),

                              const SizedBox(
                                height: 24,
                              ),

                              /// STATUS
                              buildFilterLabel(
                                "Status",
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              buildFilterDropdown(
                                "All Statuses",
                              ),

                              const SizedBox(
                                height: 40,
                              ),

                              /// BUTTONS
                              Row(
                                children: [

                                  Expanded(
                                    child: Container(
                                      height: 50,

                                      decoration:
                                          BoxDecoration(
                                        color:
                                            const Color(
                                          0xffF5F5F7,
                                        ),

                                        borderRadius:
                                            BorderRadius.circular(
                                          14,
                                        ),
                                      ),

                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,

                                        children: [

                                          Icon(
                                            Icons
                                                .filter_alt_off_outlined,
                                            size: 18,
                                          ),

                                          SizedBox(
                                            width: 6,
                                          ),

                                          Text(
                                            "Clear All",

                                            style:
                                                TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 12,
                                  ),

                                  Expanded(
                                    child: Container(
                                      height: 50,

                                      decoration:
                                          BoxDecoration(
                                        color:
                                            Colors.white,

                                        borderRadius:
                                            BorderRadius.circular(
                                          14,
                                        ),

                                        border:
                                            Border.all(
                                          color: Colors
                                              .grey
                                              .shade300,
                                        ),
                                      ),

                                      child:
                                          const Center(
                                        child: Text(
                                          "Cancel",

                                          style:
                                              TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 12,
                                  ),

                                  Expanded(
                                    child: Container(
                                      height: 50,

                                      decoration:
                                          BoxDecoration(
                                        color:
                                            const Color(
                                          0xffFFD600,
                                        ),

                                        borderRadius:
                                            BorderRadius.circular(
                                          14,
                                        ),
                                      ),

                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,

                                        children: [

                                          Icon(
                                            Icons.tune,
                                            size: 18,
                                            color:
                                                Colors.black,
                                          ),

                                          SizedBox(
                                            width: 6,
                                          ),

                                          Text(
                                            "Apply Filters",

                                            style:
                                                TextStyle(
                                              color: Colors
                                                  .black,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ],
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
          },
        );
      },

      child: Container(
        height: 52,
        width: 90,

        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(14),

          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),

        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              Icons.tune,
              size: 18,
            ),

            SizedBox(width: 6),

            Text(
              "Filters",

              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// FILTER LABEL
Widget buildFilterLabel(String text) {
  return Text(
    text,

    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );
}

/// FILTER DROPDOWN
Widget buildFilterDropdown(
  String text,
) {
  return Container(
    height: 56,

    padding:
        const EdgeInsets.symmetric(
      horizontal: 16,
    ),

    decoration: BoxDecoration(
      borderRadius:
          BorderRadius.circular(14),

      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),

    child: Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [

        Text(
          text,

          style: const TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.w500,
          ),
        ),

        const Icon(
          Icons.keyboard_arrow_down,
        ),
      ],
    ),
  );
}