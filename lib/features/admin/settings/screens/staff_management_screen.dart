import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/admin/settings/bloc/user/user_bloc.dart';
import 'package:proteinova_connect/features/admin/settings/screens/profile_screen.dart';
import '../widgets/role_textfield.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  
  bool showAddForm = false;
  int? editingUserId;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? selectedRole;
  String? selectedBranch;
  String? selectedWarehouse;

  @override
  void initState() {
    super.initState();
     context.read<UserBloc>().add(
    FetchUsersEvent(),
  );
  }

 
  void _resetForm() {
    nameController.clear();
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
      nameController.text = user['name'] ?? '';
      emailController.text = user['email'] ?? '';
      passwordController.clear();
      selectedRole = user['role'];
      selectedBranch = user['branch_id']?.toString();
      selectedWarehouse = user['warehouse_id']?.toString();
      showAddForm = true;
    });
  }

 Future<void> _handleSaveUser() async {
  if (nameController.text.isEmpty ||
      emailController.text.isEmpty ||
      (editingUserId == null && passwordController.text.isEmpty) ||
      selectedRole == null) {
    _showSnackBar(
      "Name, Email, Password and Role are required",
      isError: true,
    );
    return;
  }

  final normalizedRole = selectedRole!.toLowerCase();

  if (normalizedRole == "branch" && selectedBranch == null) {
    _showSnackBar(
      "Please select a branch for this user",
      isError: true,
    );
    return;
  }

  if ((normalizedRole == "admin" ||
          normalizedRole == "ware house" ||
          normalizedRole == "purchase") &&
      selectedWarehouse == null) {
    _showSnackBar(
      "Please select a warehouse for this user",
      isError: true,
    );
    return;
  }

  final userData = {
    "name": nameController.text,
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

  context.read<UserBloc>().add(
    SaveUserEvent(
      userData: userData,
      userId: editingUserId,
    ),
  );

  setState(() {
    showAddForm = false;
  });

  _resetForm();
}
 
 Future<void> _handleDelete(int userId) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Text(
        "Delete Staff Member?",
        style: TextStyle(color: Colors.red),
      ),
      content: const Text(
        "This action cannot be undone. This user will lose access to the system.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text("Delete"),
        ),
      ],
    ),
  );

  if (confirm == true) {
    context.read<UserBloc>().add(
      DeleteUserEvent(userId),
    );
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
    final isWide = MediaQuery.of(context).size.width > 900;
    return BlocConsumer<UserBloc, UserState>(
    listener: (context, state) {

      /// SUCCESS
      if (state is UserActionSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.green,
          ),
        );
      }

      /// ERROR
      if (state is UserError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    },

    builder: (context, state) {

      /// DATA
      List<dynamic> users = [];
      Map<String, dynamic> formOptions = {};

      if (state is UserLoaded) {
        users = state.users;
        formOptions = state.formOptions;
      }

    return Scaffold(
      backgroundColor:AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            /// GLOBAL HEADER
            _buildHeader(),
            const Divider(height: 1),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// SIDEBAR (Only if wide or persistent)
                  if (isWide) _buildSidebar(),

                  /// MAIN CONTENT
                  Expanded(
                    child: state is UserLoading
                         ? const Center(child: CircularProgressIndicator(),)
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: _buildMainContent( 
                              isWide,
                              users,
                              formOptions,),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      );}
    );
  }


  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          const SizedBox(width: 8),
          const Text(
            "Settings",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xffFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user, size: 16, color: Colors.amber),
                SizedBox(width: 6),
                Text(
                  "Admin",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xffE5E7EB))),
      ),
      child: Column(
        children: [
          _sidebarItem(Icons.person_outline, "My Profile", false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }),
          _sidebarItem(Icons.group_outlined, "Staff Management", true, () {}),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    IconData icon,
    String title,
    bool active,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xffFEF3C7) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: active ? Colors.amber.shade700 : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: active ? Colors.amber.shade900 : Colors.grey.shade700,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isWide,
  List<dynamic> users,
  Map<String, dynamic> formOptions,) {
    if (showAddForm) return _buildAddForm(isWide,formOptions);
    return _buildStaffList(isWide,users);
  }

  Widget _buildStaffList(bool isWide, List<dynamic> users,) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Staff List",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _resetForm();
                setState(() => showAddForm = true);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add New Staff"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber600,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
       isWide
    ? _buildStaffTable(users)
    : _buildStaffListView(users),
      ],
    );
  }

  Widget _buildStaffTable( List<dynamic> users,) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(const Color(0xffF9FAFB)),
        columns: const [
          DataColumn(
            label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text("Role", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              "Location",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "Created",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "Actions",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: users.map((user) {
          return DataRow(
            cells: [
              DataCell(Text(user['name'] ?? "-")),
              DataCell(Text(user['email'] ?? "-")),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user['role']?.toString().toUpperCase() ?? "-",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              DataCell(
                Text(user['branch_name'] ?? user['warehouse_name'] ?? "N/A"),
              ),
              DataCell(
                Text(user['created_at']?.toString().split('T')[0] ?? "-"),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed: () => _handleEdit(user),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => _handleDelete(user['id']),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStaffListView( List<dynamic> users,) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    user['name'] ?? "N/A",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.blue,
                          size: 18,
                        ),
                        onPressed: () => _handleEdit(user),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        onPressed: () => _handleDelete(user['id']),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                user['email'] ?? "N/A",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user['role']?.toString().toUpperCase() ?? "N/A",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user['branch_name'] ??
                          user['warehouse_name'] ??
                          "No Location",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddForm(bool isWide,Map<String, dynamic> formOptions,) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 700) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => showAddForm = false),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 18),

                SizedBox(width: 8),

                Text(
                  "Back to List",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      setState(() => showAddForm = false),

                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSaveUser,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.amber600,
                    foregroundColor: Colors.black,
                  ),

                  child: Text(
                    editingUserId != null
                        ? "Update Member"
                        : "Save Member",
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        InkWell(
          onTap: () => setState(() => showAddForm = false),

          child: const Row(
            children: [
              Icon(Icons.arrow_back, size: 18),

              SizedBox(width: 8),

              Text(
                "Back to List",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        OutlinedButton(
          onPressed: () =>
              setState(() => showAddForm = false),

          child: const Text(
            "Cancel",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),

        const SizedBox(width: 12),

        ElevatedButton(
          onPressed: _handleSaveUser,

          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.amber600,
            foregroundColor: Colors.black,
          ),

          child: Text(
            editingUserId != null
                ? "Update Member"
                : "Save Member",
          ),
        ),
      ],
    );
  },
),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xffE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                editingUserId != null
                    ? "Edit Staff Member"
                    : "Add New Staff Member",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 40),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWide ? 2 : 1,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: isWide ? 3.5 : 3.2,
                children: [
                  RoleTextField(
                    label: "Full Name",
                    hint: "e.g. Santhosh",
                    controller: nameController,
                  ),
                  RoleTextField(
                    label: "Email Address",
                    hint: "e.g. manager@proteinova.com",
                    controller: emailController,
                  ),
                  RoleTextField(
                    label: editingUserId != null
                        ? "Password (Leave blank)"
                        : "Password",
                    hint: "Min 6 characters",
                    controller: passwordController,
                    isPassword: true,
                  ),
                  _buildDropdown(
                    "Role",
                    selectedRole,
                    (formOptions['roles'] as List)
                        .map((r) => r.toString())
                        .toList(),
                    (val) {
                      setState(() {
                        selectedRole = val;
                        selectedBranch = null;
                        selectedWarehouse = null;
                      });
                    },
                  ),

                  if (selectedRole?.toLowerCase() == "branch")
                    _buildDropdown(
                      "Assigned Branch",
                      selectedBranch,
                      (formOptions['branches'] as List)
                          .map((b) => b['id'].toString())
                          .toList(),
                      (val) {
                        setState(() => selectedBranch = val);
                      },
                      itemLabels: (formOptions['branches'] as List)
                          .map((b) => b['branch_name'].toString())
                          .toList(),
                    ),

                  if ([
                    "admin",
                    "ware house",
                    "purchase",
                  ].contains(selectedRole?.toLowerCase()))
                    _buildDropdown(
                      "Assigned Warehouse",
                      selectedWarehouse,
                      (formOptions['warehouses'] as List)
                          .map((w) => w['id'].toString())
                          .toList(),
                      (val) {
                        setState(() => selectedWarehouse = val);
                      },
                      itemLabels: (formOptions['warehouses'] as List)
                          .map((w) => w['warehouse_name'].toString())
                          .toList(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    List<String>? itemLabels,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : null,
          items: List.generate(items.length, (index) {
            return DropdownMenuItem(
              value: items[index],
              child: Text(
                itemLabels != null
                    ? itemLabels[index]
                    : items[index].toUpperCase(),
                style: const TextStyle(fontSize: 14),
              ),
            );
          }),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffE5E7EB)),
            ),
          ),
        ),
      ],
    );
  }
}
