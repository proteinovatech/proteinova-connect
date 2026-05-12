import 'package:flutter/material.dart';

class FilterButtonWidget extends StatefulWidget {
  final String selectedBranch;
  final String selectedCategory;
  final String selectedStatus;
  final List<String> availableBranches;
  final List<String> availableCategories;
  final Function(String branch, String category, String status) onFilterChanged;

  const FilterButtonWidget({
    super.key,
    required this.selectedBranch,
    required this.selectedCategory,
    required this.selectedStatus,
    required this.availableBranches,
    required this.availableCategories,
    required this.onFilterChanged,
  });

  @override
  State<FilterButtonWidget> createState() => _FilterButtonWidgetState();
}

class _FilterButtonWidgetState extends State<FilterButtonWidget> {
  late String localBranch;
  late String localCategory;
  late String localStatus;

  final List<String> statuses = ["All Statuses", "Available", "In Use", "Maintenance", "Damaged"];

  @override
  void initState() {
    super.initState();
    localBranch = widget.selectedBranch;
    localCategory = widget.selectedCategory;
    localStatus = widget.selectedStatus;
  }

  void _showSelectionDialog(String title, List<String> options, String currentSelection, Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select $title"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return ListTile(
                title: Text(option),
                trailing: option == currentSelection ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  onSelected(option);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.65,
                  minChildSize: 0.45,
                  maxChildSize: 0.90,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              width: 70,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              child: Row(
                                children: [
                                  const Icon(Icons.tune, size: 24),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      "Advanced Filters",
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: const Icon(Icons.close, size: 28),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            Divider(color: Colors.grey.shade300, height: 1),
                            Padding(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildFilterLabel("Branch Location"),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () => _showSelectionDialog("Branch", widget.availableBranches, localBranch, (val) {
                                      setModalState(() => localBranch = val);
                                    }),
                                    child: buildFilterDropdown(localBranch),
                                  ),
                                  const SizedBox(height: 24),
                                  buildFilterLabel("Asset Category"),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () => _showSelectionDialog("Category", widget.availableCategories, localCategory, (val) {
                                      setModalState(() => localCategory = val);
                                    }),
                                    child: buildFilterDropdown(localCategory),
                                  ),
                                  const SizedBox(height: 24),
                                  buildFilterLabel("Status"),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () => _showSelectionDialog("Status", statuses, localStatus, (val) {
                                      setModalState(() => localStatus = val);
                                    }),
                                    child: buildFilterDropdown(localStatus),
                                  ),
                                  const SizedBox(height: 40),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setModalState(() {
                                              localBranch = "All Branches";
                                              localCategory = "All Categories";
                                              localStatus = "All Statuses";
                                            });
                                          },
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: const Color(0xffF5F5F7),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.filter_alt_off_outlined, size: 18),
                                                SizedBox(width: 6),
                                                Text("Clear", style: TextStyle(fontWeight: FontWeight.w600)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            widget.onFilterChanged(localBranch, localCategory, localStatus);
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: const Color(0xffFFD600),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                "Apply",
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                      ),
                    );
                  },
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tune, size: 18),
            SizedBox(width: 6),
            Text("Filters", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget buildFilterLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  Widget buildFilterDropdown(String text) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}