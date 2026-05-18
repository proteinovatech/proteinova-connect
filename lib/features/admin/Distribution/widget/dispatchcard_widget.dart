import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

Widget dispatchCard({
  required String id,
  required String date,
  required String branch,
  required String vehicle,
  required String driver,
  required String qty,
  required String status,
  required Color statusColor,
  required BuildContext context,
}) {

  ValueNotifier<bool> showLocation =
      ValueNotifier(false);

  ValueNotifier<bool> showVehicle =
      ValueNotifier(false);

  return Container(

    width: double.infinity,

    margin: EdgeInsets.only(
      bottom: getHeight(context, 14),
    ),

    padding: EdgeInsets.all(
      getWidth(context, 14),
    ),

    decoration: BoxDecoration(

      color: Colors.white,

      borderRadius:
          BorderRadius.circular(18),

      border: Border.all(
        color: Colors.grey.shade200,
      ),

      boxShadow: [

        BoxShadow(

          color:
              // ignore: deprecated_member_use
              Colors.black.withOpacity(0.04),

          blurRadius: 10,

          offset: const Offset(0, 4),
        ),
      ],
    ),

    child: Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        /// TOP ROW
        Row(

          children: [

            Container(

              padding:
                  const EdgeInsets.all(10),

              decoration: BoxDecoration(

                color:
                    // ignore: deprecated_member_use
                    Colors.blue.withOpacity(
                  0.10,
                ),

                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),

              child: const Icon(

                Icons.local_shipping_outlined,

                color: Colors.blue,

                size: 20,
              ),
            ),

            SizedBox(
              width:
                  getWidth(context, 10),
            ),

            /// ID & DATE
            Expanded(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(

                    id,

                    style: TextStyle(

                      fontSize:
                          getWidth(context, 14),

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(
                    height:
                        getHeight(context, 4),
                  ),

                  Text(

                    date,

                    style: TextStyle(

                      color:
                          Colors.grey.shade600,

                      fontSize:
                          getWidth(context, 11),
                    ),
                  ),
                ],
              ),
            ),

            /// QTY
           /// QUANTITY
Container(

  padding: EdgeInsets.symmetric(
    horizontal: getWidth(context, 10),
    vertical: getHeight(context, 6),
  ),

  decoration: BoxDecoration(

    color:
        // ignore: deprecated_member_use
        Colors.orange.withOpacity(
      0.10,
    ),

    borderRadius:
        BorderRadius.circular(10),
  ),

  child: Row(

    mainAxisSize: MainAxisSize.min,

    crossAxisAlignment:
        CrossAxisAlignment.start,

    children: [

      Icon(
        Icons.inventory_2_outlined,
        size: 16,
        color: Colors.orange,
      ),

      SizedBox(
        width: getWidth(context, 6),
      ),

      Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(

            "Qty",

            style: TextStyle(

              color: Colors.orange,

              fontSize:
                  getWidth(context, 9),

              fontWeight:
                  FontWeight.w600,
            ),
          ),

          SizedBox(
            height: getHeight(context, 2),
          ),

          Text(
            qty,textAlign: TextAlign.center,
            style: TextStyle(

              color: Colors.orange,

              fontWeight:
                  FontWeight.bold,

              fontSize:
                  getWidth(context, 11),
            ),
          ),
        ],
      ),
    ],
  ),
), ],
        ),

        SizedBox(
          height:
              getHeight(context, 14),
        ),

        /// STATUS + ICONS
        Row(

          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

          children: [

            Container(

              padding:
                  EdgeInsets.symmetric(

                horizontal:
                    getWidth(context, 12),

                vertical:
                    getHeight(context, 7),
              ),

              decoration: BoxDecoration(

                color:
                    // ignore: deprecated_member_use
                    statusColor.withOpacity(
                  0.12,
                ),

                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),

              child: Row(

                children: [

                  Icon(

                    Icons.circle,

                    size: 10,

                    color: statusColor,
                  ),

                  SizedBox(
                    width:
                        getWidth(context, 6),
                  ),

                  Text(

                    status,

                    style: TextStyle(

                      color: statusColor,

                      fontWeight:
                          FontWeight.bold,

                      fontSize:
                          getWidth(context, 11),
                    ),
                  ),
                ],
              ),
            ),

            /// ICONS
            Row(

              children: [

                /// LOCATION ICON
                ValueListenableBuilder(

                  valueListenable:
                      showLocation,

                  builder:
                      (
                        context,
                        locationOpen,
                        _,
                      ) {

                    return GestureDetector(

                      onTap: () {

                        showLocation.value =
                            !showLocation
                                .value;

                        if (showLocation
                            .value) {

                          showVehicle.value =
                              false;
                        }
                      },

                      child: Container(

                        padding:
                            const EdgeInsets
                                .all(8),

                        decoration:
                            BoxDecoration(

                          color:
                              locationOpen
                                  ? Colors.blue
                                      // ignore: deprecated_member_use
                                      .withOpacity(
                                      0.12,
                                    )
                                  : Colors.grey
                                      .shade100,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),

                        child: Icon(

                          Icons
                              .location_on_outlined,

                          size: 18,

                          color:
                              locationOpen
                                  ? Colors
                                      .blue
                                  : Colors
                                      .black87,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(
                  width:
                      getWidth(context, 8),
                ),

                /// VEHICLE ICON
                ValueListenableBuilder(

                  valueListenable:
                      showVehicle,

                  builder:
                      (
                        context,
                        vehicleOpen,
                        _,
                      ) {

                    return GestureDetector(

                      onTap: () {

                        showVehicle.value =
                            !showVehicle
                                .value;

                        if (showVehicle
                            .value) {

                          showLocation.value =
                              false;
                        }
                      },

                      child: Container(

                        padding:
                            const EdgeInsets
                                .all(8),

                        decoration:
                            BoxDecoration(

                          color:
                              vehicleOpen
                                  ? Colors
                                      .orange
                                      // ignore: deprecated_member_use
                                      .withOpacity(
                                      0.12,
                                    )
                                  : Colors.grey
                                      .shade100,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),

                        child: Icon(

                          Icons
                              .local_shipping_outlined,

                          size: 18,

                          color:
                              vehicleOpen
                                  ? Colors
                                      .orange
                                  : Colors
                                      .black87,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        /// LOCATION DETAILS
        ValueListenableBuilder(

          valueListenable:
              showLocation,

          builder:
              (
                context,
                locationOpen,
                _,
              ) {

            if (!locationOpen) {

              return const SizedBox();
            }

            return Padding(

              padding: EdgeInsets.only(
                top:
                    getHeight(context, 14),
              ),

              child:
                  buildExpandableTile(

                context: context,

                icon: Icons
                    .location_on_outlined,

                title:
                    "Destination Branch",

                value: branch,
              ),
            );
          },
        ),

        /// VEHICLE DETAILS
        ValueListenableBuilder(

          valueListenable:
              showVehicle,

          builder:
              (
                context,
                vehicleOpen,
                _,
              ) {

            if (!vehicleOpen) {

              return const SizedBox();
            }

            return Padding(

              padding: EdgeInsets.only(
                top:
                    getHeight(context, 14),
              ),

              child:
                  buildExpandableTile(

                context: context,

                icon: Icons
                    .local_shipping_outlined,

                title: "Vehicle",

                value: vehicle,

                subtitle:
                    "Driver : $driver",
              ),
            );
          },
        ),
      ],
    ),
  );
}

Widget buildExpandableTile({

  required BuildContext context,

  required IconData icon,

  required String title,

  required String value,

  String? subtitle,
}) {

  return Container(

    padding:
        EdgeInsets.all(
      getWidth(context, 12),
    ),

    decoration: BoxDecoration(

      color: Colors.grey.shade50,

      borderRadius:
          BorderRadius.circular(14),

      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),

    child: Row(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Container(

          padding:
              const EdgeInsets.all(9),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(10),
          ),

          child: Icon(

            icon,

            size: 18,

            color: Colors.black87,
          ),
        ),

        SizedBox(
          width:
              getWidth(context, 10),
        ),

        Expanded(

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(

                title,

                style: TextStyle(

                  color:
                      Colors.grey.shade600,

                  fontSize:
                      getWidth(context, 11),
                ),
              ),

              SizedBox(
                height:
                    getHeight(context, 4),
              ),

              Text(

                value,

                style: TextStyle(

                  fontWeight:
                      FontWeight.bold,

                  fontSize:
                      getWidth(context, 13),
                ),
              ),

              if (subtitle != null) ...[

                SizedBox(
                  height:
                      getHeight(context, 4),
                ),

                Text(

                  subtitle,

                  style: TextStyle(

                    color:
                        Colors.grey.shade700,

                    fontSize:
                        getWidth(context, 11),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}