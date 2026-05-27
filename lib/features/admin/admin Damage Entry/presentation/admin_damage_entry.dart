import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/admin/admin Damage Entry/bloc/damage_entry_bloc.dart';
import 'package:proteinova_connect/features/admin/admin Damage Entry/data/models/damage_location_model.dart';
import 'package:proteinova_connect/features/admin/admin Damage Entry/data/models/damage_category_model.dart';
import 'package:proteinova_connect/features/admin/admin Damage Entry/data/models/damage_history_model.dart';

class AdminDamageEntryPage extends StatelessWidget {
  const AdminDamageEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DamageEntryBloc>(
      create: (context) => DamageEntryBloc()..add(FetchLocationsEvent()),
      child: const DamageEntryBody(),
    );
  }
}

class DamageEntryBody extends StatefulWidget {
  const DamageEntryBody({super.key});

  @override
  State<DamageEntryBody> createState() => _DamageEntryBodyState();
}

class _DamageEntryBodyState extends State<DamageEntryBody> {
  DamageLocation? _selectedLocation;
  String? _selectedCategory;
  final TextEditingController _eggsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _eggsController.dispose();
    super.dispose();
  }

  void _onLocationChanged(DamageLocation? location, BuildContext context) {
    setState(() {
      _selectedLocation = location;
      _selectedCategory = null;
      _eggsController.clear();
    });
    context.read<DamageEntryBloc>().add(LocationSelectedEvent(location));
  }

  void _submitReport(
    BuildContext context,
    DamageLocation location,
    List<DamageCategory> categories,
  ) {
    if (_formKey.currentState?.validate() ?? false) {
      final category = _selectedCategory;
      final eggsCount = int.tryParse(_eggsController.text);

      if (category != null && eggsCount != null) {
        context.read<DamageEntryBloc>().add(
          SubmitDamageReportEvent(
            location: location,
            category: category,
            damagedEggs: eggsCount,
          ),
        );
      }
    }
  }

  String _formatDateTime(String dateIso) {
    try {
      final date = DateTime.parse(dateIso).toLocal();

      return "${DateFormat('dd MMM yyyy').format(date)}\n"
          "${DateFormat('hh:mm a').format(date)}";
    } catch (_) {
      return dateIso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocListener<DamageEntryBloc, DamageEntryState>(
          listener: (context, state) {
            if (state is DamageReportingSuccess) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text("Success"),
                    ],
                  ),
                  content: Text(state.message),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedCategory = null;
                          _eggsController.clear();
                        });
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            } else if (state is DamageEntryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.redAccent,
                ),
              );
            }
          },
          child: BlocBuilder<DamageEntryBloc, DamageEntryState>(
            builder: (context, state) {
              List<DamageLocation> locations = [];
              List<DamageCategory> categories = [];
              List<DamageHistory> history = [];
              bool isLoadingLocations = false;
              bool isLoadingData = false;
              bool isSubmitting = false;

              if (state is DamageLocationsLoading) {
                isLoadingLocations = true;
              } else if (state is DamageLocationsLoaded) {
                locations = state.locations;
              } else if (state is DamageDataLoading) {
                locations = state.locations;
                isLoadingData = true;
              } else if (state is DamageDataLoaded) {
                locations = state.locations;
                categories = state.categories;
                history = state.history;
              } else if (state is DamageReportingProgress) {
                locations = state.locations;
                categories = state.categories;
                history = state.history;
                isSubmitting = true;
              } else if (state is DamageReportingSuccess) {
                locations = state.locations;
                categories = state.categories;
                history = state.history;
              } else if (state is DamageEntryError) {
                locations = state.locations;
                categories = state.categories;
                history = state.history;
              }

              final DamageCategory? selectedCatData = categories.firstWhere(
                (c) => c.eggCategoryGrade == _selectedCategory,
                orElse: () => DamageCategory(
                  eggCategoryGrade: '',
                  traysAvailable: 0,
                  eggsAvailable: 0,
                ),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Nav Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.arrow_back, color: Colors.black, size: 28),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFEF4444),
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Global Damage Entry",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              SizedBox(height: 4),
                              Text(
                                "Report eggs that were damaged at the warehouse or specific branches.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Target Location Selector Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF334155),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Select Target Location",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (isLoadingLocations)
                            const SizedBox(
                              height: 45,
                              child: Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<DamageLocation>(
                                  value: _selectedLocation == null
                                      ? null
                                      : locations.firstWhere(
                                          (l) => l.id == _selectedLocation!.id,
                                          orElse: () => _selectedLocation!,
                                        ),
                                  isExpanded: true,
                                  hint: const Text(
                                    "-- Choose Location --",
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  onChanged: (loc) =>
                                      _onLocationChanged(loc, context),
                                  items: locations.map((loc) {
                                    final bool isWarehouse =
                                        loc.type == "WAREHOUSE";
                                    return DropdownMenuItem<DamageLocation>(
                                      value: loc,
                                      child: Row(
                                        children: [
                                          Text(
                                            isWarehouse ? "🏢 " : "🏪 ",
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            loc.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Active report form & history
                    if (_selectedLocation != null) ...[
                      if (isLoadingData)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.amber600,
                              ),
                            ),
                          ),
                        )
                      else ...[
                        // Report form Card
                        _buildFormCard(
                          context,
                          categories,
                          selectedCatData,
                          isSubmitting,
                        ),
                        const SizedBox(height: 20),

                        // History logs Card
                        _buildHistoryCard(history),
                      ],
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    List<DamageCategory> categories,
    DamageCategory? selectedCatData,
    bool isSubmitting,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Report Damage for ${_selectedLocation!.name}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 12),

            // Category select field
            const Text(
              "Egg Category *",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Category is required' : null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  hint: const Text(
                    "-- Select Available Category --",
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                  onChanged: (cat) {
                    setState(() {
                      _selectedCategory = cat;
                      _eggsController.clear();
                    });
                  },
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat.eggCategoryGrade,
                      child: Text(
                        "${cat.eggCategoryGrade} (${cat.eggsAvailable} eggs available)",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Number of eggs damaged
            const Text(
              "Number of Damaged Eggs *",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _eggsController,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Egg count is required';
                final count = int.tryParse(v);
                if (count == null || count <= 0)
                  return 'Enter a valid positive number';
                if (selectedCatData != null &&
                    selectedCatData.eggCategoryGrade.isNotEmpty) {
                  if (count > selectedCatData.eggsAvailable) {
                    return 'Cannot exceed available eggs (${selectedCatData.eggsAvailable})';
                  }
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: "e.g. 5",
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
            ),
            if (selectedCatData != null &&
                selectedCatData.eggCategoryGrade.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                "Maximum limit: ${selectedCatData.eggsAvailable} eggs",
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: isSubmitting || _selectedCategory == null
                    ? null
                    : () => _submitReport(
                        context,
                        _selectedLocation!,
                        categories,
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  disabledBackgroundColor: const Color(0xFF94A3B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isSubmitting ? "Processing..." : "Report Damage",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(List<DamageHistory> history) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Damage History (${_selectedLocation!.name})",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          if (history.isEmpty)
            _buildEmptyHistory()
          else
            _buildHistoryTable(history),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: const [
          Icon(Icons.description_outlined, color: Color(0xFF94A3B8), size: 48),
          SizedBox(height: 12),
          Text(
            "No manual damage reports found for this location.",
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTable(List<DamageHistory> history) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 15,
        headingRowHeight: 40,
        dataRowHeight: 52,
        horizontalMargin: 0,
        columns: const [
          DataColumn(
            label: Text(
              "Date",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF475569),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              "Category",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF475569),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              "Damaged \nEggs",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF475569),
              ),
            ),
            numeric: true,
          ),
          DataColumn(
            label: Text(
              "Trays Marked\n Damaged",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
        rows: history.map((log) {
          return DataRow(
            cells: [
              DataCell(
                SizedBox(
                  width: 120,
                  child: Text(
                    _formatDateTime(log.createdAt),
                    maxLines: 2,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  log.eggCategoryGrade,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              DataCell(
                Text(
                  log.damagedEggs.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${log.damagedTrays} Trays",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
