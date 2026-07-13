import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';
import 'package:proteinova_connect/features/admin/add%20branch/bloc/add_branch_bloc.dart';
import 'package:proteinova_connect/features/admin/add%20branch/bloc/add_branch_event.dart';
import 'package:proteinova_connect/features/admin/add%20branch/bloc/add_branch_state.dart';
import 'package:proteinova_connect/features/admin/add%20branch/data/repository/add_branch_repository.dart';
import 'package:proteinova_connect/features/admin/add%20branch/data/models/branch_manager_model.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/add_branch_shimmer.dart';

class AddBranchPage extends StatelessWidget {
  final BranchModel? branch;
  const AddBranchPage({super.key, this.branch});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddBranchBloc(AddBranchRepository())..add(LoadFormOptionsEvent()),
      child: AddBranch(branch: branch),
    );
  }
}

class AddBranch extends StatefulWidget {
  final BranchModel? branch;
  const AddBranch({super.key, this.branch});

  @override
  State<AddBranch> createState() => _AddBranchState();
}

class _AddBranchState extends State<AddBranch> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _branchNameController = TextEditingController();
  final _branchCodeController = TextEditingController();
  final _regionController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalZipCodeController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailAddressController = TextEditingController();
  final _maxStockCapacityController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  // Dropdown states
  String _selectedStatus = "Active";
  int? _selectedManagerId;

  // Options populated from Bloc
  List<BranchManagerModel> _managersList = [];
  List<String> _statusesList = ["Active", "Inactive"];

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.branch != null;
    if (_isEditing) {
      final b = widget.branch!;
      _branchNameController.text = b.branchName;
      _branchCodeController.text = b.branchCode;
      _regionController.text = b.region;
      _addressLine1Controller.text = b.addressLine1;
      _cityController.text = b.city;
      _postalZipCodeController.text = b.postalZipCode;
      _contactNumberController.text = b.contactNumber;
      _emailAddressController.text = b.emailAddress;
      _maxStockCapacityController.text = b.maxStockCapacity?.toString() ?? "";
      _additionalNotesController.text = b.additionalNotes ?? "";
      _selectedStatus = b.status.isNotEmpty ? b.status : "Active";
      _selectedManagerId = b.branchManagerId;
    }
  }

  @override
  void dispose() {
    _branchNameController.dispose();
    _branchCodeController.dispose();
    _regionController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _postalZipCodeController.dispose();
    _contactNumberController.dispose();
    _emailAddressController.dispose();
    _maxStockCapacityController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  void _handleClearForm() {
    setState(() {
      _branchNameController.clear();
      _branchCodeController.clear();
      _regionController.clear();
      _addressLine1Controller.clear();
      _cityController.clear();
      _postalZipCodeController.clear();
      _contactNumberController.clear();
      _emailAddressController.clear();
      _maxStockCapacityController.clear();
      _additionalNotesController.clear();
      _selectedStatus = "Active";
      _selectedManagerId = null;
    });
  }

  void _handleSave(BuildContext context) {
    // Basic validation
    if (_branchNameController.text.trim().isEmpty ||
        _branchCodeController.text.trim().isEmpty ||
        _addressLine1Controller.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _contactNumberController.text.trim().isEmpty) {
      _showCustomPopup(
        context: context,
        type: "error",
        title: "Error",
        message: "Please fill in all required fields marked with *",
      );
      return;
    }

    final payload = {
      "branch_name": _branchNameController.text.trim(),
      "branch_code": _branchCodeController.text.trim().toUpperCase(),
      "region": _regionController.text.trim(),
      "status": _selectedStatus,
      "address_line1": _addressLine1Controller.text.trim(),
      "city": _cityController.text.trim(),
      "postal_zip_code": _postalZipCodeController.text.trim().isEmpty ? null : _postalZipCodeController.text.trim(),
      "contact_number": _contactNumberController.text.trim(),
      "email_address": _emailAddressController.text.trim().isEmpty ? null : _emailAddressController.text.trim(),
      "branch_manager_id": _selectedManagerId,
      "max_stock_capacity": _maxStockCapacityController.text.trim().isEmpty 
          ? null 
          : int.tryParse(_maxStockCapacityController.text.trim()),
      "additional_notes": _additionalNotesController.text.trim().isEmpty ? null : _additionalNotesController.text.trim(),
      "created_by": 1,
      "login_user_id": 1
    };

    context.read<AddBranchBloc>().add(
      SaveBranchEvent(
        isEditing: _isEditing,
        branchId: widget.branch?.id,
        payload: payload,
      ),
    );
  }

  void _showCustomPopup({
    required BuildContext context,
    required String type,
    required String title,
    required String message,
    VoidCallback? onClose,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isSuccess = type == "success";
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(context, 24),
              vertical: getHeight(context, 32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success / Error circular icon
                Container(
                  width: getWidth(context, 80),
                  height: getWidth(context, 80),
                  decoration: BoxDecoration(
                    color: isSuccess ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isSuccess ? Icons.check_rounded : Icons.priority_high_rounded,
                      color: isSuccess ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                      size: getWidth(context, 40),
                    ),
                  ),
                ),
                SizedBox(height: getHeight(context, 20)),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: getHeight(context, 10)),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: getHeight(context, 24)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (onClose != null) {
                        onClose();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: getHeight(context, 14),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddBranchBloc, AddBranchState>(
      listener: (context, state) {
        if (state is AddBranchSuccess) {
          _showCustomPopup(
            context: context,
            type: "success",
            title: "Success",
            message: state.message,
            onClose: () {
              Navigator.pop(context, true);
            },
          );
        } else if (state is AddBranchFailure) {
          _showCustomPopup(
            context: context,
            type: "error",
            title: "Error",
            message: state.error,
          );
        }
      },
      child: BlocBuilder<AddBranchBloc, AddBranchState>(
        builder: (context, state) {
          if (state is AddBranchFormLoaded) {
            _managersList = state.options.managers;
            _statusesList = state.options.statuses;
          }

          final isLoading = state is AddBranchSubmitting || state is AddBranchFormLoading;

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: SafeArea(
              child: Column(
                children: [
                  // Premium App Bar header
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(context, 16),
                      vertical: getHeight(context, 14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 18,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            SizedBox(width: getWidth(context, 16)),
                            Text(
                              _isEditing ? "Edit Branch Details" : "Branch Details",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    color: const Color(0xFFE2E8F0),
                  ),

                  // Main Scrollable form
                  Expanded(
                    child: state is AddBranchFormLoading
                        ? const AddBranchShimmer()
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(context, 16),
                              vertical: getHeight(context, 16),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // SECTION 1: Basic Information
                                  _buildCard(
                                    title: "Basic Information",
                                    children: [
                                      _buildTextField(
                                        label: "Branch Name",
                                        isRequired: true,
                                        controller: _branchNameController,
                                        placeholder: "e.g. Branch 06 - Central",
                                      ),
                                      SizedBox(height: getHeight(context, 14)),
                                      _buildTextField(
                                        label: "Branch Code",
                                        isRequired: true,
                                        controller: _branchCodeController,
                                        placeholder: "e.g. BR-006",
                                        textCapitalization: TextCapitalization.characters,
                                      ),
                                      SizedBox(height: getHeight(context, 14)),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              label: "Region",
                                              controller: _regionController,
                                              placeholder: "e.g. North Region",
                                            ),
                                          ),
                                          SizedBox(width: getWidth(context, 12)),
                                          Expanded(
                                            child: _buildDropdown(
                                              label: "Status",
                                              value: _selectedStatus,
                                              items: _statusesList,
                                              onChanged: (val) {
                                                if (val != null) {
                                                  setState(() {
                                                    _selectedStatus = val;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: getHeight(context, 16)),

                                  // SECTION 2: Location & Contact
                                  _buildCard(
                                    title: "Location & Contact",
                                    children: [
                                      _buildTextField(
                                        label: "Address Line 1",
                                        isRequired: true,
                                        controller: _addressLine1Controller,
                                        placeholder: "Street address, P.O. box, company name, c/o",
                                      ),
                                      SizedBox(height: getHeight(context, 14)),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              label: "City",
                                              isRequired: true,
                                              controller: _cityController,
                                              placeholder: "City",
                                            ),
                                          ),
                                          SizedBox(width: getWidth(context, 12)),
                                          Expanded(
                                            child: _buildTextField(
                                              label: "Postal / Zip Code",
                                              controller: _postalZipCodeController,
                                              placeholder: "ZIP Code",
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: getHeight(context, 14)),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              label: "Contact Number",
                                              isRequired: true,
                                              controller: _contactNumberController,
                                              placeholder: "+1 (555) 000-0000",
                                              keyboardType: TextInputType.phone,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                                LengthLimitingTextInputFormatter(10),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: getWidth(context, 12)),
                                          Expanded(
                                            child: _buildTextField(
                                              label: "Email Address",
                                              controller: _emailAddressController,
                                              placeholder: "branch@example.com",
                                              keyboardType: TextInputType.emailAddress,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: getHeight(context, 16)),

                                  // SECTION 3: Management & Operations
                                  _buildCard(
                                    title: "Management & Operations",
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _buildDropdown(
                                              label: "Branch Manager",
                                              value: _selectedManagerId?.toString(),
                                              placeholder: "Assign Manager",
                                              items: _managersList.map((m) => m.id.toString()).toList(),
                                              itemLabelBuilder: (val) {
                                                final idVal = int.tryParse(val ?? '');
                                                if (idVal != null) {
                                                  final match = _managersList.firstWhere(
                                                    (m) => m.id == idVal,
                                                    orElse: () => BranchManagerModel(id: 0, email: '', role: ''),
                                                  );
                                                  if (match.id != 0) {
                                                    return "${match.email} (${match.role})";
                                                  }
                                                }
                                                return val ?? '';
                                              },
                                              onChanged: (val) {
                                                setState(() {
                                                  _selectedManagerId = val != null ? int.tryParse(val) : null;
                                                });
                                              },
                                            ),
                                          ),
                                          SizedBox(width: getWidth(context, 12)),
                                          Expanded(
                                            child: _buildTextField(
                                              label: "Max Stock Capacity (Units)",
                                              controller: _maxStockCapacityController,
                                              placeholder: "e.g. 5000",
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: getHeight(context, 14)),
                                      _buildTextField(
                                        label: "Additional Notes",
                                        controller: _additionalNotesController,
                                        placeholder: "Any specific operational details for this branch...",
                                        maxLines: 4,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: getHeight(context, 24)),

                                  // BOTTOM BUTTONS Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: isLoading ? null : _handleClearForm,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFF1F5F9),
                                            foregroundColor: const Color(0xFF475569),
                                            elevation: 0,
                                            padding: EdgeInsets.symmetric(
                                              vertical: getHeight(context, 16),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              side: const BorderSide(
                                                color: Color(0xFFE2E8F0),
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            "Clear Form",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: getWidth(context, 12)),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: isLoading ? null : () => _handleSave(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFFFC107),
                                            foregroundColor: const Color(0xFF1E293B),
                                            elevation: 0,
                                            padding: EdgeInsets.symmetric(
                                              vertical: getHeight(context, 16),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child: CircularProgressIndicator(
                                                    color: Color(0xFF1E293B),
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.check_rounded,
                                                      size: 18,
                                                      color: Color(0xFF1E293B),
                                                    ),
                                                    SizedBox(width: getWidth(context, 6)),
                                                    Text(
                                                      _isEditing ? "Update Branch" : "Save Branch",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: getHeight(context, 20)),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper builder for premium white container cards
  Widget _buildCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(context, 16),
        vertical: getHeight(context, 18),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: getHeight(context, 10)),
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
          ),
          SizedBox(height: getHeight(context, 14)),
          ...children,
        ],
      ),
    );
  }

  // Helper builder for premium input fields
  Widget _buildTextField({
    required String label,
    bool isRequired = false,
    required TextEditingController controller,
    required String placeholder,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              if (isRequired)
                const TextSpan(
                  text: " *",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: getHeight(context, 6)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFCBD5E1),
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: getWidth(context, 14),
                vertical: getHeight(context, maxLines > 1 ? 12 : 14),
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  // Helper builder for custom dropdown inputs
  Widget _buildDropdown({
    required String label,
    bool isRequired = false,
    String? value,
    String? placeholder,
    required List<String> items,
    String Function(String?)? itemLabelBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    final labelBuilder = itemLabelBuilder ?? (v) => v ?? '';
    final resolvedValue = (value != null && items.contains(value)) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              if (isRequired)
                const TextSpan(
                  text: " *",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: getHeight(context, 6)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: getWidth(context, 14),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFCBD5E1),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: resolvedValue,
              hint: Text(
                placeholder ?? "Select",
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF64748B),
                size: 20,
              ),
              items: [
                if (placeholder != null)
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      placeholder,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ...items.map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      labelBuilder(item),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
