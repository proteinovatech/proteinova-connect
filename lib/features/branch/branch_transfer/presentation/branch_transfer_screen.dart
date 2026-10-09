import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import '../bloc/branch_transfer_bloc.dart';
import '../bloc/branch_transfer_event.dart';
import '../bloc/branch_transfer_state.dart';
import '../data/datasource/branch_transfer_remote_datasource.dart';

class BranchTransferScreen extends StatefulWidget {
  const BranchTransferScreen({super.key});

  @override
  State<BranchTransferScreen> createState() => _BranchTransferScreenState();
}

class _BranchTransferScreenState extends State<BranchTransferScreen> {
  late BranchTransferBloc _bloc;
  
  String? shopName;
  String dispatchDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String arrivalDate = "";
  final TextEditingController _vehicleNoCtrl = TextEditingController();
  final TextEditingController _driverNameCtrl = TextEditingController();
  final TextEditingController _driverPhoneCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  
  int plasticTrays = 0;
  int paperTrays = 0;

  List<Map<String, dynamic>> items = [
    { 'id': DateTime.now().millisecondsSinceEpoch, 'egg_category_grade': null, 'trays': 0, 'eggs': 0 }
  ];

  int? loginUserId;
  String? branchName;
  int? branchId;

  @override
  void initState() {
    super.initState();
    _bloc = BranchTransferBloc(BranchTransferRemoteDatasource());
    _loadUserAndData();
  }

  Future<void> _loadUserAndData() async {
    final prefs = await SharedPreferences.getInstance();
    loginUserId = prefs.getInt('user_id');
    branchName = prefs.getString('branch_name') ?? '';
    branchId = prefs.getInt('branch_id');
    
    _bloc.add(LoadInitialDataEvent(loginUserId: loginUserId ?? 0, branchName: branchName ?? '', branchId: branchId ?? 0));
  }

  void _submitTransfer() {
    if (shopName == null || shopName!.isEmpty) {
      _showError("Please select a destination branch");
      return;
    }
    if (_vehicleNoCtrl.text.isEmpty || _driverNameCtrl.text.isEmpty || _driverPhoneCtrl.text.isEmpty) {
      _showError("Please fill vehicle and driver details");
      return;
    }
    if (arrivalDate.isEmpty) {
      _showError("Please select an arrival date");
      return;
    }
    
    final validItems = items.where((i) => i['egg_category_grade'] != null && i['trays'] > 0).toList();
    if (validItems.isEmpty && plasticTrays == 0 && paperTrays == 0) {
      _showError("Please add at least one item or empty trays to transfer");
      return;
    }

    final currentState = _bloc.state;
    int? toBranchId;
    if (currentState is BranchTransferDataLoaded) {
      int index = currentState.branches.indexWhere(
        (b) => b['branch_name'] == shopName
      );
      if (index != -1) {
        toBranchId = currentState.branches[index]['id'];
      }
    }

    final payload = {
        "shop_name": shopName,
        "dispatch_type": "branch",
        "dispatch_source": "BRANCH",
        "from_branch_id": branchId,
        "from_branch_name": branchName,
        "to_branch_id": toBranchId,
        "dispatch_date": dispatchDate,
        "arrival_date": arrivalDate,
        "vehicle_number": _vehicleNoCtrl.text,
        "driver_name": _driverNameCtrl.text,
        "driver_phone": _driverPhoneCtrl.text,
        "notes": _notesCtrl.text,
        "plastic_trays": plasticTrays,
        "paper_trays": paperTrays,
        "plastic_tray_price": 0,
        "paper_tray_price": 0,
        "items": validItems,
        "login_user_id": loginUserId
    };

    _bloc.add(SubmitTransferEvent(payload));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
  
  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  int _getCapacity(String? grade) {
    if (grade == null) return 30;
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(grade);
    if (match != null) return int.parse(match.group(0)!);
    if (grade.toLowerCase().contains('export')) return 360;
    return 30;
  }

  Map<String, dynamic> _getAvailableStock(String? grade, BranchTransferDataLoaded state) {
    if (grade == null) return {"trays": 0, "eggs": 0};
    int index = state.inventoryStock.indexWhere(
      (s) => s['egg_category_grade']?.toString().toLowerCase() == grade.toLowerCase(),
    );
    if (index != -1) {
      final stockItem = state.inventoryStock[index];
      return {
        "trays": stockItem['total_trays'] ?? 0,
        "eggs": stockItem['total_eggs'] ?? 0
      };
    }
    return {"trays": 0, "eggs": 0};
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _bloc,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("Initiate Branch Transfer", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: BlocConsumer<BranchTransferBloc, BranchTransferState>(
          listener: (context, state) {
            if (state is BranchTransferError) {
              _showError(state.message);
            } else if (state is BranchTransferSubmitError) {
              _showError(state.message);
            } else if (state is BranchTransferSubmitSuccess) {
              _showSuccess("Transfer Initiated Successfully!");
              Navigator.pop(context, true); // return true to refresh dashboard
            }
          },
          builder: (context, state) {
            if (state is BranchTransferInitial || state is BranchTransferLoading) {
              return _buildShimmer();
            }
            
            BranchTransferDataLoaded? data;
            bool isSubmitting = false;
            
            if (state is BranchTransferDataLoaded) {
              data = state;
            } else if (state is BranchTransferSubmitting) {
              data = state.previousData;
              isSubmitting = true;
            } else if (state is BranchTransferSubmitError) {
              data = state.previousData;
            }
            
            if (data == null) {
              return const Center(child: Text("Failed to load data"));
            }

            return _buildForm(data, isSubmitting);
          },
        ),
      ),
      ),
    );
  }

  Widget _buildForm(BranchTransferDataLoaded data, bool isSubmitting) {
    int totalTrays = items.fold(0, (sum, i) => sum + (i['trays'] as int)) + plasticTrays + paperTrays;
    int totalEggs = items.fold(0, (sum, i) => sum + (i['eggs'] as int));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Transfer Details", "Select destination and assign transport"),
                const SizedBox(height: 12),
                _buildCard([
                  _buildDropdown("Destination Branch *", shopName, data.branches.where((b)=> b['id'] != branchId).map((b) => b['branch_name'].toString()).toList(), (val) {
                    setState(() => shopName = val);
                  }),
                  const SizedBox(height: 12),
                  _buildTextField("Vehicle Number *", _vehicleNoCtrl, "e.g. TN 38 XX 1234"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("Driver Name *", _driverNameCtrl, "Name")),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField("Driver Phone *", _driverPhoneCtrl, "Phone", TextInputType.phone)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildDateField("Dispatch Date *", dispatchDate, (val) => setState(() => dispatchDate = val))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDateField("Expected Arrival *", arrivalDate, (val) => setState(() => arrivalDate = val))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField("Notes (Optional)", _notesCtrl, "Any additional instructions..."),
                ]),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Transfer Items", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Select categories & quantities", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          items.add({ 'id': DateTime.now().millisecondsSinceEpoch, 'egg_category_grade': null, 'trays': 0, 'eggs': 0 });
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text("Add Item"),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        foregroundColor: Colors.blue,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                ...items.map((item) => _buildItemRow(item, data)).toList(),
                
                const SizedBox(height: 20),
                _buildSectionTitle("Transfer Empty Trays", "Include empty trays in transfer"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildEmptyTrayCard("Plastic Trays", data.emptyPlasticTrays, plasticTrays, (val) => setState(()=> plasticTrays = val))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildEmptyTrayCard("Paper Trays", data.emptyPaperTrays, paperTrays, (val) => setState(()=> paperTrays = val))),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0,-4), blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Total Eggs: $totalEggs", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text("Total Trays: $totalTrays", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue)),
                ],
              ),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submitTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B74FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Initiate Transfer", style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item, BranchTransferDataLoaded data) {
    final available = _getAvailableStock(item['egg_category_grade'], data);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text("Select Category"),
                  value: item['egg_category_grade'],
                  items: data.eggCategories.map((c) {
                    final catName = c['category_name'].toString();
                    final stock = _getAvailableStock(catName, data);
                    return DropdownMenuItem<String>(
                      value: catName,
                      enabled: stock['eggs'] > 0,
                      child: Text("$catName (${stock['eggs']})", style: TextStyle(color: stock['eggs'] > 0 ? Colors.black : Colors.grey)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      item['egg_category_grade'] = val;
                      item['trays'] = 0;
                      item['eggs'] = 0;
                    });
                  },
                ),
              ),
              if (items.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    setState(() => items.remove(item));
                  },
                )
            ],
          ),
          if (item['egg_category_grade'] != null) ...[
            const SizedBox(height: 8),
            Text("Available: ${available['trays']} Trays (${available['eggs']} Eggs)", style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item['trays'] == 0 ? "" : item['trays'].toString(),
                    decoration: const InputDecoration(labelText: "Trays to send", isDense: true, border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      setState(() {
                        int trays = int.tryParse(val) ?? 0;
                        item['trays'] = trays;
                        item['eggs'] = trays * _getCapacity(item['egg_category_grade']);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: ValueKey(item['eggs']),
                    initialValue: item['eggs'] == 0 ? "" : item['eggs'].toString(),
                    decoration: const InputDecoration(labelText: "Total Eggs", isDense: true, border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      int eggs = int.tryParse(val) ?? 0;
                      item['eggs'] = eggs;
                      item['trays'] = (eggs / _getCapacity(item['egg_category_grade'])).ceil();
                    },
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildEmptyTrayCard(String title, int available, int current, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("Available: $available", style: TextStyle(fontSize: 12, color: available > 0 ? Colors.green : Colors.red)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: current == 0 ? "" : current.toString(),
            decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            keyboardType: TextInputType.number,
            onChanged: (val) => onChanged(int.tryParse(val) ?? 0),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, String hint, [TextInputType type = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        )
      ],
    );
  }

  Widget _buildDropdown(String label, String? val, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: val,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        )
      ],
    );
  }

  Widget _buildDateField(String label, String val, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            DateTime? dt = await showDatePicker(
              context: context,
              initialDate: val.isEmpty ? DateTime.now() : DateTime.parse(val),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (dt != null) {
              onChanged(DateFormat('yyyy-MM-dd').format(dt));
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(val.isEmpty ? "YYYY-MM-DD" : val, style: TextStyle(color: val.isEmpty ? Colors.grey : Colors.black)),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: index == 0 ? 200 : 100,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
