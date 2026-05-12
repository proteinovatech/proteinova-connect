import 'package:flutter/material.dart';

Widget dispatchBottomSheet({
  required String title,
}) {
  /// TODAY DISPATCH EMPTY UI
  if (title == "Today's Dispatches") {
    return Container(
      height: 430,

      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        20,
      ),

      decoration: const BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),

      child: Column(
        children: [

          /// HANDLE
          Center(
            child: Container(
              width: 50,
              height: 5,

              decoration: BoxDecoration(
                color: Colors.grey.shade300,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// HEADER
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const Icon(
                Icons.close,
                color: Colors.grey,
              ),
            ],
          ),

          const Spacer(),

          Icon(
            Icons.inventory_2_outlined,
            size: 90,
            color: Colors.grey.shade300,
          ),

          const SizedBox(height: 18),

          const Text(
            "No records found",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "No dispatches found for today.",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 24),

          Container(
            height: 46,
            width: double.infinity,

            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),

              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),

            child: const Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                Icon(Icons.tune, size: 18),

                SizedBox(width: 8),

                Text(
                  "Change Filter",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  /// COMMON UI
  return Container(
    height: 430,

    padding: const EdgeInsets.fromLTRB(
      16,
      10,
      16,
      20,
    ),

    decoration: const BoxDecoration(
      color: Colors.white,

      borderRadius: BorderRadius.vertical(
        top: Radius.circular(28),
      ),
    ),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        /// HANDLE
        Center(
          child: Container(
            width: 50,
            height: 5,

            decoration: BoxDecoration(
              color: Colors.grey.shade300,

              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// HEADER
        Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,

          children: [

            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const Icon(
              Icons.close,
              color: Colors.grey,
            ),
          ],
        ),

        const SizedBox(height: 18),

        /// MAIN CONTAINER
        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),

            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),

          child: Column(
            children: [

              /// TABLE HEADER
              Row(
                children: const [

                  Expanded(
                    flex: 2,
                    child: Text(
                      "DISPATCH RECORD",
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      "DESTINATION",
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      "VEHICLE & DRIVER",
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      "QUANTITY\nTOTAL EGGS",

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        fontSize: 7,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      "STATUS",

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        fontSize: 7,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              /// DATA ROW
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  /// DISPATCH
                  Expanded(
                    flex: 2,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        const Text(
                          "DSP-1",

                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,

                            fontSize: 10,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: const [

                            Icon(
                              Icons
                                  .calendar_today,

                              size: 10,

                              color:
                                  Colors.grey,
                            ),

                            SizedBox(width: 4),

                            Text(
                              "30/4/2026",

                              style: TextStyle(
                                fontSize: 9,

                                color: Colors
                                    .grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// DESTINATION
                  const Expanded(
                    flex: 2,

                    child: Text(
                      "Branch 034",

                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,

                        fontSize: 10,
                      ),
                    ),
                  ),

                  /// VEHICLE
                  Expanded(
                    flex: 2,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: const [

                        Text(
                          "TN 32 B 2134",

                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,

                            fontSize: 10,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          "Mani",

                          style: TextStyle(
                            color:
                                Colors.grey,

                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// QUANTITY
                  Expanded(
                    flex: 2,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .center,

                      children: const [

                        Text(
                          "1,530 Eggs",

                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,

                            fontSize: 10,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          "51 Trays",

                          style: TextStyle(
                            color:
                                Colors.grey,

                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// STATUS
                  Expanded(
                    flex: 2,

                    child: Center(
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xffE8F3FF,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),
                        ),

                        child: const Text(
                          "IN TRANSIT",

                          textAlign:
                              TextAlign.center,

                          style: TextStyle(
                            color:
                                Colors.blue,

                            fontWeight:
                                FontWeight
                                    .bold,

                            fontSize: 8,
                          ),
                        ),
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
  );
}