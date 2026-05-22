import 'package:flutter/material.dart';

class ReceivingBranchScreen extends StatelessWidget {
  const ReceivingBranchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8FA),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                /// HEADER
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(
                        Icons.arrow_back,
                        size: 28,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Expanded(
                      child: Text(
                        "Distribution Dashboard",

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField(
                  value: "Sarjapura",

                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  items: ["Sarjapura"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),

                  onChanged: (_) {},
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,

                    vertical: 14,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.yellow,

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Icon(Icons.local_shipping_outlined),

                      SizedBox(width: 10),

                      Text(
                        "Receiving",

                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// CARDS
                GridView.count(
                  shrinkWrap: true,

                  physics: NeverScrollableScrollPhysics(),

                  crossAxisCount: 2,

                  childAspectRatio: 1,

                  crossAxisSpacing: 14,

                  mainAxisSpacing: 14,

                  children: [
                    _card("Expected Today", "0", Icons.local_shipping_outlined),

                    _card("Ready for\nUnloading", "0", Icons.send_outlined),

                    _card("Delayed", "1", Icons.calendar_month),

                    _card(
                      "Total Transit",
                      "1\nShipments",
                      Icons.inventory_2_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Incoming Dispatches",

                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                /// TABLE
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width + 220,
                    ),

                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: DataTable(
                        headingRowHeight: 56,

                        dataRowMinHeight: 90,
                        dataRowMaxHeight: 110,

                        columnSpacing: 40,

                        horizontalMargin: 20,

                        columns: const [
                          DataColumn(
                            label: SizedBox(
                              width: 90,
                              child: Text("Dispatch ID"),
                            ),
                          ),

                          DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text("Expected Arrival"),
                            ),
                          ),

                          DataColumn(
                            label: SizedBox(
                              width: 140,
                              child: Text("Vehicle & Driver"),
                            ),
                          ),

                          DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text("Total Qty"),
                            ),
                          ),

                          DataColumn(
                            label: SizedBox(width: 100, child: Text("Status")),
                          ),

                          DataColumn(
                            label: SizedBox(width: 140, child: Text("Actions")),
                          ),
                        ],

                        rows: [
                          DataRow(
                            cells: [
                              DataCell(
                                SizedBox(width: 90, child: Text("#DS-3")),
                              ),

                              DataCell(
                                SizedBox(width: 120, child: Text("19/5/2026")),
                              ),

                              DataCell(
                                SizedBox(
                                  width: 140,

                                  child: Text("TN88M5818\n(viji)"),
                                ),
                              ),

                              DataCell(
                                SizedBox(
                                  width: 120,

                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text("1000 Trays"),

                                      SizedBox(height: 4),

                                      Text("30000 Eggs"),
                                    ],
                                  ),
                                ),
                              ),

                              DataCell(
                                SizedBox(
                                  width: 100,

                                  child: Chip(
                                    label: Text("DELAYED"),

                                    backgroundColor: Colors.red.shade50,
                                  ),
                                ),
                              ),

                              DataCell(
                                SizedBox(
                                  width: 130,

                                  child: ElevatedButton(
                                    onPressed: () {},

                                    child: const Text("Mark Arrival"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Expanded(child: Text(title)),

              Icon(icon),
            ],
          ),

          const Spacer(),

          Text(
            value,

            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
