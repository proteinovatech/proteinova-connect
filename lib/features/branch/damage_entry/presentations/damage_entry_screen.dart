import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/damage_entry/bloc/damage_bloc.dart';
import 'package:proteinova_connect/features/branch/damage_entry/bloc/damage_event.dart';
import 'package:proteinova_connect/features/branch/damage_entry/bloc/damage_state.dart';
import 'package:proteinova_connect/features/branch/damage_entry/data/model/damage_category_model.dart';

class DamageEntryScreen extends StatefulWidget {
  const DamageEntryScreen({super.key});

  @override
  State<DamageEntryScreen> createState() => _DamageEntryScreenState();
}

class _DamageEntryScreenState extends State<DamageEntryScreen> {
  final TextEditingController eggController = TextEditingController();
  int branchId = 0;

  @override
  void initState() {
    super.initState();
    _loadBranchId();
  }

  Future<void> _loadBranchId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      branchId = prefs.getInt('branch_id') ?? 0;
    });
    if (mounted && branchId > 0) {
      final bloc = context.read<DamageBloc>();
      bloc.add(FetchDamageCategoriesEvent(branchId: branchId));
      bloc.add(FetchDamageHistoryEvent(branchId: branchId));
    }
  }

  @override
  void dispose() {
    eggController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocListener<DamageBloc, DamageState>(
          listenWhen: (previous, current) {
            return previous.isSubmitting && !current.isSubmitting;
          },
          listener: (context, state) {
            if (!state.isSubmitting && state.error == null) {
              if (eggController.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Damage reported successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
                eggController.clear();
                // Refresh categories to update available stock count
                context.read<DamageBloc>().add(
                  FetchDamageCategoriesEvent(branchId: branchId),
                );
              }
            }

            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: ${state.error}"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<DamageBloc, DamageState>(
            builder: (context, state) {
              final selectedCatData = state.categories.firstWhere(
                (c) => c.eggCategoryGrade == state.selectedCategory,
                orElse: () => DamageCategoryModel(
                  eggCategoryGrade: '',
                  eggsAvailable: 0,
                  traysAvailable: 0,
                ),
              );

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button / Header
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Color(0xFF6B7280),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Back to Dashboard",
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title Section
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFEF4444),
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Manual Damage Entry",
                          style: AppTextStyles.headingText22.copyWith(
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Report eggs that were damaged while in branch storage. This will deduct from your available sales stock.",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Main sections
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // FORM SECTION
                        Container(
                          padding: const EdgeInsets.all(24),
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
                              const Text(
                                "Report New Damage",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(color: Color(0xFFE2E8F0)),
                              const SizedBox(height: 16),

                              // Category dropdown
                              const Text(
                                "Egg Category *",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 8),
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
                                child: state.isLoadingCategories
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      )
                                    : DropdownButton<String>(
                                        isExpanded: true,
                                        underline: const SizedBox(),
                                        value: state.selectedCategory,
                                        hint: const Text(
                                          "-- Select Available Category --",
                                        ),
                                        items: state.categories.map((category) {
                                          return DropdownMenuItem<String>(
                                            value: category.eggCategoryGrade,
                                            child: Text(
                                              "${category.eggCategoryGrade} (${category.eggsAvailable} eggs available)",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            context.read<DamageBloc>().add(
                                              SelectCategoryEvent(value),
                                            );
                                          }
                                        },
                                      ),
                              ),
                              const SizedBox(height: 20),

                              // Damaged eggs count input
                              const Text(
                                "Number of Damaged Eggs *",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: eggController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1E293B),
                                ),
                                decoration: InputDecoration(
                                  hintText: "e.g. 5",
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3B82F6),
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {});
                                },
                              ),
                              if (selectedCatData
                                  .eggCategoryGrade
                                  .isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  "Maximum limit: ${selectedCatData.eggsAvailable} eggs",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),

                              // Submit button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444),
                                    disabledBackgroundColor: const Color(
                                      0xFF94A3B8,
                                    ),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed:
                                      state.isSubmitting ||
                                          state.selectedCategory == null ||
                                          eggController.text.isEmpty
                                      ? null
                                      : () {
                                          final enteredEggs =
                                              int.tryParse(
                                                eggController.text,
                                              ) ??
                                              0;
                                          if (enteredEggs <= 0) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Please enter a valid number of eggs",
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          if (selectedCatData
                                                  .eggCategoryGrade
                                                  .isNotEmpty &&
                                              enteredEggs >
                                                  selectedCatData
                                                      .eggsAvailable) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Cannot report more than ${selectedCatData.eggsAvailable} damaged eggs",
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          context.read<DamageBloc>().add(
                                            ReportDamageEvent(
                                              branchId: branchId,
                                              category: state.selectedCategory!,
                                              damagedEggs: eggController.text,
                                            ),
                                          );
                                        },
                                  child: state.isSubmitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "Report Damage",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // HISTORY SECTION
                        Container(
                          padding: const EdgeInsets.all(24),
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
                              const Text(
                                "Damage History",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(color: Color(0xFFE2E8F0)),
                              const SizedBox(height: 16),
                              state.isLoadingHistory
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 40,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : state.history.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 40,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "No manual damage reports found.",
                                          style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                  : LayoutBuilder(
                                      builder: (context, constraints) {
                                        final bool useScroll =
                                            constraints.maxWidth < 500;
                                        final Table tableWidget = Table(
                                          columnWidths: useScroll
                                              ? null
                                              : const {
                                                  0: FlexColumnWidth(
                                                    1.2,
                                                  ), // Date
                                                  1: FlexColumnWidth(
                                                    1.5,
                                                  ), // Category
                                                  2: FlexColumnWidth(
                                                    1.0,
                                                  ), // Damaged Eggs
                                                  3: FlexColumnWidth(
                                                    1.3,
                                                  ), // Trays Marked Damaged
                                                },
                                          defaultColumnWidth: useScroll
                                              ? const FixedColumnWidth(110)
                                              : const FlexColumnWidth(),
                                          border: TableBorder(
                                            horizontalInside: BorderSide(
                                              color: Colors.grey.shade100,
                                              width: 1,
                                            ),
                                          ),
                                          children: [
                                            TableRow(
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Color(0xFFE2E8F0),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              children: const [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                                  child: Text(
                                                    "Date",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF475569),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                                  child: Text(
                                                    "Category",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF475569),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 4,
                                                  ),
                                                  child: Text(
                                                    "Damaged Eggs",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF475569),
                                                      fontSize: 13,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                                  child: Text(
                                                    "Trays Marked Damaged",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF475569),
                                                      fontSize: 13,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ...state.history.map((log) {
                                              return TableRow(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    child: Text(
                                                      log.date,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Color(
                                                          0xFF334155,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    child: Text(
                                                      log.category,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color(
                                                          0xFF1E293B,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                          horizontal: 4,
                                                        ),
                                                    child: Text(
                                                      log.damagedEggs
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                          0xFFEF4444,
                                                        ),
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 10,
                                                        ),
                                                    child: Center(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFFFEE2E2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          "${log.trays} Trays",
                                                          style:
                                                              const TextStyle(
                                                                color: Color(
                                                                  0xFF991B1B,
                                                                ),
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                          ],
                                        );

                                        if (useScroll) {
                                          return SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: tableWidget,
                                          );
                                        }
                                        return tableWidget;
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
