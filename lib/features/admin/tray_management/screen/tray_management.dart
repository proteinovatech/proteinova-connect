import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/tray_management_bloc.dart';
import '../bloc/tray_management_event.dart';
import '../bloc/tray_management_state.dart';
import '../services/tray_management_service.dart';
import '../models/tray_inventory_model.dart';

class TrayManagementScreen extends StatelessWidget {
  const TrayManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TrayManagementBloc(TrayManagementService())
            ..add(FetchInventoryEvent()),
      child: const TrayManagementView(),
    );
  }
}

class TrayManagementView extends StatefulWidget {
  const TrayManagementView({Key? key}) : super(key: key);

  @override
  State<TrayManagementView> createState() => _TrayManagementViewState();
}

class _TrayManagementViewState extends State<TrayManagementView> {
  final _plasticTraysController = TextEditingController();
  final _paperTraysController = TextEditingController();

  @override
  void dispose() {
    _plasticTraysController.dispose();
    _paperTraysController.dispose();
    super.dispose();
  }

  void _showAddTraysDialog(BuildContext context) {
    _plasticTraysController.clear();
    _paperTraysController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<TrayManagementBloc>(),
          child: BlocConsumer<TrayManagementBloc, TrayManagementState>(
            listener: (context, state) {
              if (state.addSuccess) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trays added successfully!')),
                );
              }
              if (state.error != null &&
                  state.error!.isNotEmpty &&
                  state.isAdding == false) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error!)));
              }
            },
            builder: (context, state) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                child: Container(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Add Trays to Namakkal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Plastic Trays',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _plasticTraysController,
                              decoration: InputDecoration(
                                hintText: 'Enter count',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Paper Trays',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _paperTraysController,
                              decoration: InputDecoration(
                                hintText: 'Enter count',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),

                      // Actions
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: state.isAdding
                                    ? null
                                    : () {
                                        final plastic =
                                            int.tryParse(
                                              _plasticTraysController.text,
                                            ) ??
                                            0;
                                        final paper =
                                            int.tryParse(
                                              _paperTraysController.text,
                                            ) ??
                                            0;
                                        context.read<TrayManagementBloc>().add(
                                          AddTraysEvent(
                                            plasticTrays: plastic,
                                            paperTrays: paper,
                                          ),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFACC15),
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: state.isAdding
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black,
                                        ),
                                      )
                                    : const Text(
                                        'Submit',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showReturnTrayDialog(BuildContext context) {
    String? selectedWarehouse;

    _plasticTraysController.clear();
    _paperTraysController.clear();

    showDialog(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              child: Container(
                width: 400,

                padding: const EdgeInsets.all(24),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Center(
                      child: Text(
                        "Return Trays to Namakkal",

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Divider(),

                    const SizedBox(height: 20),

                    /// Warehouse
                    const Text(
                      "Warehouse",

                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: selectedWarehouse,

                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      hint: const Text("Select Warehouse"),

                      items: ["Bangalore", "Chennai", "Salem"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),

                      onChanged: (v) {
                        setLocal(() {
                          selectedWarehouse = v;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    /// Plastic
                    const Text("Plastic Trays"),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _plasticTraysController,

                      keyboardType: TextInputType.number,

                      decoration: InputDecoration(
                        hintText: "Enter count",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Paper
                    const Text("Paper Trays"),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _paperTraysController,

                      keyboardType: TextInputType.number,

                      decoration: InputDecoration(
                        hintText: "Enter count",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      color: const Color(0xffF1F5F9),

                      padding: const EdgeInsets.all(12),

                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },

                              child: const Text("Cancel"),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,
                              ),

                              onPressed: () {
                                final plastic =
                                    int.tryParse(
                                      _plasticTraysController.text,
                                    ) ??
                                    0;

                                final paper =
                                    int.tryParse(_paperTraysController.text) ??
                                    0;

                                context.read<TrayManagementBloc>().add(
                                  AddTraysEvent(
                                    plasticTrays: plastic,
                                    paperTrays: paper,
                                  ),
                                );

                                Navigator.pop(dialogContext);
                              },

                              child: const Text(
                                "Submit",

                                style: TextStyle(color: Colors.black),
                              ),
                            ),
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
  }

  @override
  Widget build(BuildContext context) {
    // In Flutter Web / Desktop we could use Row but on Mobile Row will overflow.
    // We should make it responsive or use Wrap/ListView. Let's use Wrap.
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Tray Management',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocConsumer<TrayManagementBloc, TrayManagementState>(
        listener: (context, state) {
          if (state.error != null &&
              state.error!.isNotEmpty &&
              !state.isAdding) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.inventory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final inventory = state.inventory;
          final namakkal = inventory.firstWhere(
            (item) => item.locationName == 'Namakkal',
            orElse: () => TrayInventoryModel(
              id: 0,
              locationName: 'Namakkal',
              locationType: '',
              plasticTrayCount: 0,
              paperTrayCount: 0,
              updatedAt: DateTime.now(),
            ),
          );

          final warehouses = inventory
              .where((item) => item.locationType == 'WAREHOUSE')
              .toList();
          final branches = inventory
              .where((item) => item.locationType == 'BRANCH')
              .toList();

          final totalWarehousePlastic = warehouses.fold<int>(
            0,
            (sum, item) => sum + item.plasticTrayCount,
          );
          final totalBranchPlastic = branches.fold<int>(
            0,
            (sum, item) => sum + item.plasticTrayCount,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    /// Return Tray
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),

                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),

                        onPressed: () => _showReturnTrayDialog(context),

                        icon: const Icon(Icons.undo, size: 18),

                        label: const Text(
                          "Return Trays to\nNamakkal",

                          textAlign: TextAlign.center,

                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Add Tray
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD600),

                          foregroundColor: Colors.black,

                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),

                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),

                        onPressed: () => _showAddTraysDialog(context),

                        icon: const Icon(Icons.add, size: 18),

                        label: const Text(
                          "Add Trays to\nNamakkal",

                          textAlign: TextAlign.center,

                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // Cards
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    SizedBox(
                      width: isDesktop ? 300 : double.infinity,
                      child: _buildCard(
                        title: 'NAMAKKAL STOCK',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStockText(
                              'Plastic:',
                              namakkal.plasticTrayCount.toString(),
                            ),
                            const SizedBox(height: 4),
                            _buildStockText(
                              'Paper:',
                              namakkal.paperTrayCount.toString(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isDesktop ? 300 : double.infinity,
                      child: _buildCard(
                        title: 'WAREHOUSE STOCK',
                        child: _buildStockText(
                          'Plastic:',
                          totalWarehousePlastic.toString(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isDesktop ? 300 : double.infinity,
                      child: _buildCard(
                        title: 'BRANCH STOCK',
                        child: _buildStockText(
                          'Plastic:',
                          totalBranchPlastic.toString(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Table
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Inventory Details',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      if (state.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('Loading inventory...'),
                        )
                      else if (inventory.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No inventory data found.'),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: inventory.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            color: Color(0xFFF3F4F6),
                          ),
                          itemBuilder: (context, index) {
                            final item = inventory[index];
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.locationName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE9EDF3),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          item.locationType,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Plastic Trays',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.plasticTrayCount.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Paper Trays',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.paperTrayCount.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'Last Updated',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat(
                                              'M/d/yyyy, h:mm a',
                                            ).format(item.updatedAt.toLocal()),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
        border: const Border(
          left: BorderSide(color: Color(0xFFFFD600), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildStockText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF111827),
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
