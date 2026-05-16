import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/settings/data/services/settings_service.dart';
import '../widgets/role_textfield.dart';

class RolePermissionScreen extends StatefulWidget {
  const RolePermissionScreen({super.key});

  @override
  State<RolePermissionScreen> createState() => _RolePermissionScreenState();
}

class _RolePermissionScreenState extends State<RolePermissionScreen> {
  final SettingsService _settingsService = SettingsService();

  List<dynamic> users = [];
  bool isLoading = true;
  bool showAddForm = false;
  int? editingUserId;

  Map<String, dynamic> formOptions = {
    "roles": [],
    "branches": [],
    "warehouses": [],
  };

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? selectedRole;
  String? selectedBranch;
  String? selectedWarehouse;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    final usersList = await _settingsService.fetchUsersList();
    final formData = await _settingsService.fetchUserFormData();
    setState(() {
      users = usersList;
      formOptions = formData;
      isLoading = false;
    });
  }

  void _resetForm() {
    emailController.clear();
    passwordController.clear();
    selectedRole = null;
    selectedBranch = null;
    selectedWarehouse = null;
    editingUserId = null;
  }

  void _handleEdit(dynamic user) {
    setState(() {
      editingUserId = user['id'];
      emailController.text = user['email'] ?? '';
      passwordController.clear();
      selectedRole = user['role'];
      selectedBranch = user['branch_id']?.toString();
      selectedWarehouse = user['warehouse_id']?.toString();
      showAddForm = true;
    });
  }

  Future<void> _handleDelete(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Staff Member?"),
        content: const Text(
          "This action cannot be undone. This user will lose access to the system.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _settingsService.deleteUser(userId);
      if (success) {
        _fetchData();
        _showSnackBar("Staff member deleted successfully");
      } else {
        _showSnackBar("Failed to delete user", isError: true);
      }
    }
  }

  Future<void> _handleSaveUser() async {
    if (emailController.text.isEmpty ||
        (editingUserId == null && passwordController.text.isEmpty) ||
        selectedRole == null) {
      _showSnackBar("Email, Password and Role are required", isError: true);
      return;
    }

    final normalizedRole = selectedRole!.toLowerCase();
    if (normalizedRole == "branch" && selectedBranch == null) {
      _showSnackBar("Please select a branch for this user", isError: true);
      return;
    }
    if ((normalizedRole == "admin" ||
            normalizedRole == "ware house" ||
            normalizedRole == "purchase") &&
        selectedWarehouse == null) {
      _showSnackBar("Please select a warehouse for this user", isError: true);
      return;
    }

    final userData = {
      "email": emailController.text,
      "password": passwordController.text,
      "role": selectedRole,
      "branch_id": selectedBranch != null
          ? int.tryParse(selectedBranch!)
          : null,
      "warehouse_id": selectedWarehouse != null
          ? int.tryParse(selectedWarehouse!)
          : null,
    };

    final success = await _settingsService.saveUser(
      userData,
      userId: editingUserId,
    );
    if (success) {
      _showSnackBar(
        "Staff member ${editingUserId != null ? "updated" : "added"} successfully",
      );
      setState(() => showAddForm = false);
      _resetForm();
      _fetchData();
    } else {
      _showSnackBar("Failed to save user", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Settings",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.shield_outlined, size: 18),
                              SizedBox(width: 6),
                              Text(
                                "Admin",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (!showAddForm) ...[
                      /// STAFF LIST VIEW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Staff List",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.amber600,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              _resetForm();
                              setState(() => showAddForm = true);
                            },
                            icon: const Icon(Icons.add, color: Colors.black),
                            label: const Text(
                              "Add New Staff",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xffE5E7EB)),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: users.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: Colors.grey.shade200),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text(
                                user['email'] ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          user['role']
                                                  ?.toString()
                                                  .toUpperCase() ??
                                              'N/A',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          user['branch_name'] ??
                                              user['warehouse_name'] ??
                                              'N/A',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        user['created_at'] != null
                                            ? user['created_at']
                                                  .toString()
                                                  .split('T')[0]
                                            : 'N/A',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _handleEdit(user),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _handleDelete(user['id']),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      /// ADD/EDIT FORM
                      // InkWell(
                      //   onTap: () => setState(() => showAddForm = false),
                      //   child: const Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(Icons.arrow_back_ios_new, size: 16),
                      //       SizedBox(width: 8),
                      //       Text("Back to List", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              editingUserId != null
                                  ? "Edit Staff Member"
                                  : "Add New Staff Member",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () =>
                                setState(() => showAddForm = false),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.amber600,
                            ),
                            onPressed: _handleSaveUser,
                            child: Text(
                              editingUserId != null
                                  ? "Update Member"
                                  : "Save Member",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xffE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RoleTextField(
                              label: "Email Address",
                              hint: "e.g. manager@proteinova.com",
                              controller: emailController,
                            ),
                            const SizedBox(height: 20),
                            RoleTextField(
                              label: editingUserId != null
                                  ? "Password (Leave blank to keep current)"
                                  : "Password",
                              hint: "Min 6 characters",
                              controller: passwordController,
                              isPassword: true,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Role",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: selectedRole,
                              items: (formOptions['roles'] as List)
                                  .map(
                                    (role) => DropdownMenuItem(
                                      value: role.toString(),
                                      child: Text(
                                        role.toString().toUpperCase(),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => selectedRole = val),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xffE5E7EB),
                                  ),
                                ),
                              ),
                            ),
                            if (selectedRole?.toLowerCase() == "branch") ...[
                              const SizedBox(height: 20),
                              const Text(
                                "Assigned Branch",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: selectedBranch,
                                items: (formOptions['branches'] as List)
                                    .map(
                                      (b) => DropdownMenuItem(
                                        value: b['id'].toString(),
                                        child: Text(
                                          b['branch_name'].toString(),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => selectedBranch = val),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xffE5E7EB),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if ([
                              "admin",
                              "ware house",
                              "purchase",
                            ].contains(selectedRole?.toLowerCase())) ...[
                              const SizedBox(height: 20),
                              const Text(
                                "Assigned Warehouse",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: selectedWarehouse,
                                items: (formOptions['warehouses'] as List)
                                    .map(
                                      (w) => DropdownMenuItem(
                                        value: w['id'].toString(),
                                        child: Text(
                                          w['warehouse_name'].toString(),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => selectedWarehouse = val),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xffE5E7EB),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
