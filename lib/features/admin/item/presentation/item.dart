import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';

class TrayData {
  String? type;
  TextEditingController color = TextEditingController();
  TextEditingController qty = TextEditingController();
}

class CoverData {
  String? type;
  TextEditingController color = TextEditingController();
  TextEditingController qty = TextEditingController();
}

class EggData {
  String? category;
  TextEditingController qty = TextEditingController();
}

class Items extends StatefulWidget {
  const Items({super.key});

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  final List<String> locations = ["Warehouse", "Branch"];
  final List<String> trayTypes = ["Plastic Tray", "Paper Tray"];
  final List<String> coverTypes = ["plastic", "paper"];
  final List<String> eggCategories = [
    "quil Egg",
    "white large",
    "brown Egg",
    "white correct size",
    "white export",
    "white medium",
  ];

  Future<void> saveItems() async {
    try {
     final url = Uri.parse(ApiConstants.itemsInventoryAdd);

      final body = {
        "tray": {
          "location": trayLocation,
          "type": trayType,
          "quantity": trayQtyController.text,
          "color": trayColorController.text,
        },
        "cover": {
          "location": coverLocation,
          "type": coverType,
          "quantity": coverQtyController.text,
          "color": coverColorController.text,
        },
        "egg": {
          "location": eggLocation,
          "category": eggCategory,
          "quantity": eggQtyController.text,
        },
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("Status Code: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Items saved successfully"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      print(e);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  String? trayLocation = "Warehouse";
  String? trayType;

  String? coverLocation = "Warehouse";
  String? coverType;

  String? eggLocation = "Warehouse";
  String? eggCategory;
  bool showTrayNewType = false;
  bool showCoverNewType = false;
  bool showEggNewTypeCategory = false;

  final trayColorController = TextEditingController();
  final trayQtyController = TextEditingController();

  final coverColorController = TextEditingController();
  final coverQtyController = TextEditingController();

  final eggQtyController = TextEditingController();
  int trayCount = 1;
  int coverCount = 1;
  int eggCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),

      appBar: AppBar(
        backgroundColor: const Color(0xffF3F4F6),
        elevation: 0,
        title: const Text(
          "Add Items",
          style: TextStyle(
            color: Color(0xff111827),
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTrayCard(),
            const SizedBox(height: 20),

            _buildCoverCard(),
            const SizedBox(height: 20),

            _buildEggCard(),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color(0xff374151),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await saveItems();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFACC15),
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(52),
                      elevation: 3,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    child: const Text(
                      "Save Items",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrayCard() {
    return _sectionCard(
      title: "Add Tray",
      newButtonText: "+ New Type",
      addMoreText: "+ Add More",
      child: Column(
        children: [
          _topRow(
            value: trayLocation,
            items: locations,
            onChanged: (v) => setState(() => trayLocation = v),
            newButtonText: "+ New Type",
          ),
          if (showTrayNewType) ...[
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: _inputDecoration(
                      hint: "Enter new tray type...",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: _inputDecoration(hint: "Tray color"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: _inputDecoration(hint: "Quantity / Capacity"),
                  ),
                ),
                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () {
                    // save type
                  },
                  child: const Text("Save Type"),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],

          const SizedBox(height: 24),

          Column(
            children: List.generate(
              trayCount,
              (index) => Column(
                children: [
                  _dropdownField(
                    title: "Tray Type",
                    hint: "Select Type",
                    value: trayType,
                    items: trayTypes,
                    onChanged: (v) => setState(() => trayType = v),
                  ),

                  const SizedBox(height: 20),

                  _textField(
                    title: "Color",
                    controller: TextEditingController(),
                    hint: "Enter details...",
                  ),

                  const SizedBox(height: 20),

                  _textField(
                    title: "Quantity",
                    controller: TextEditingController(),
                    hint: "Enter quantity...",
                  ),

                  const SizedBox(height: 20),
                  if (index > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            trayCount--;
                          });
                        },
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

  Widget _buildCoverCard() {
    return _sectionCard(
      title: "Add Cover",
      newButtonText: "+ New Type",
      addMoreText: "+ Add More",
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 12),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showCoverNewType = !showCoverNewType;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffE5E7EB),
                  foregroundColor: const Color(0xff374151),
                  elevation: 0,
                ),
                child: Text(showCoverNewType ? "Close" : "+ New Type"),
              ),

              const SizedBox(width: 12),

              InkWell(
                onTap: () {
                  setState(() {
                    coverCount++;
                  });
                },
                child: const Text(
                  "+ Add More",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (showCoverNewType) ...[
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: _inputDecoration(
                      hint: "Enter new cover type...",
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Save cover type
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5BC8A8),
                    ),
                    child: const Text(
                      "Save Type",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
          const SizedBox(height: 24),
          Column(
            children: List.generate(
              coverCount,
              (index) => Column(
                children: [
                  _dropdownField(
                    title: "Cover Type",
                    hint: "Select Type",
                    value: coverType,
                    items: coverTypes,
                    onChanged: (v) => setState(() => coverType = v),
                  ),

                  const SizedBox(height: 20),

                  _textField(
                    title: "Color",
                    controller: TextEditingController(),
                    hint: "Enter details...",
                  ),

                  const SizedBox(height: 20),

                  _textField(
                    title: "Quantity",
                    controller: TextEditingController(),
                    hint: "Enter quantity...",
                  ),

                  const SizedBox(height: 20),
                  if (index > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            coverCount--;
                          });
                        },
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

  Widget _buildEggCard() {
    return _sectionCard(
      title: "Add Eggs",
      newButtonText: "+ New Category",
      addMoreText: "+ Add More",
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 12),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showEggNewTypeCategory = !showEggNewTypeCategory;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffE5E7EB),
                  foregroundColor: const Color(0xff374151),
                  elevation: 0,
                ),
                child: Text(
                  showEggNewTypeCategory ? "Close" : "+ New Category",
                ),
              ),

              const SizedBox(width: 12),

              InkWell(
                onTap: () {
                  setState(() {
                    eggCount++;
                  });
                },
                child: const Text(
                  "+ Add More",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (showEggNewTypeCategory) ...[
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: _inputDecoration(
                      hint: "Enter new egg category...",
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5BC8A8),
                    ),
                    child: const Text(
                      "Save Type",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
          const SizedBox(height: 24),

          Column(
            children: List.generate(
              eggCount,
              (index) => Column(
                children: [
                  _dropdownField(
                    title: "Category",
                    hint: "Select Egg Category",
                    value: eggCategory,
                    items: eggCategories,
                    onChanged: (v) => setState(() => eggCategory = v),
                  ),

                  const SizedBox(height: 20),

                  _textField(
                    title: "Quantity",
                    controller: TextEditingController(),
                    hint: "Enter quantity...",
                  ),

                  const SizedBox(height: 20),
                  if (index > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            eggCount--;
                          });
                        },
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

  Widget _sectionCard({
    required String title,
    required String newButtonText,
    required String addMoreText,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff374151),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  value: "Warehouse",
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(
                      value: "Warehouse",
                      child: Text("Warehouse"),
                    ),
                    DropdownMenuItem(value: "Branch", child: Text("Branch")),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }

  Widget _topRow({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String newButtonText,
  }) {
    return Row(
      children: [
        const SizedBox(width: 12),

        ElevatedButton(
          onPressed: () {
            if (newButtonText == "+ New Type") {
              setState(() {
                showTrayNewType = !showTrayNewType;
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffE5E7EB),
            foregroundColor: const Color(0xff374151),
            elevation: 0,
          ),
          child: Text(showTrayNewType ? "Close" : "+ New Type"),
        ),
        const SizedBox(width: 12),

        InkWell(
          onTap: () {
            setState(() {
              trayCount++;
            });
          },
          child: const Text(
            "+ Add More",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String title,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),

        const SizedBox(height: 10),

        DropdownButtonFormField<String>(
          value: value,
          decoration: _inputDecoration(),
          hint: Text(hint),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _textField({
    required String title,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),

        const SizedBox(height: 10),

        TextField(
          controller: controller,
          decoration: _inputDecoration(hint: hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
