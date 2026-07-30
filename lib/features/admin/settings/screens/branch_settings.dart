import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/features/admin/settings/model/branch_model.dart';
import 'package:shimmer/shimmer.dart';

class BranchSettingsScreen extends StatefulWidget {
  const BranchSettingsScreen({super.key});

  @override
  State<BranchSettingsScreen> createState() => _BranchSettingsScreenState();
}

class _BranchSettingsScreenState extends State<BranchSettingsScreen> {
  bool isAutoApprove = true;
  List<BranchModel> branches = [];
  bool isLoading = true;
  Future<void> fetchBranches() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['VITE_BACKEND_URL'] ?? dotenv.env['BASE_URL'] ?? ''}/api/branches'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        branches = (data['data'] as List)
            .map((e) => BranchModel.fromJson(e))
            .toList();

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBranches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          " Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Admin Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user_outlined, size: 18),
                  SizedBox(width: 8),
                  Text("Admin", style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Company Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Branch Settings",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Configure thresholds and operational settings for all active branches.",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                  ),

                  const SizedBox(height: 24),

                  Divider(color: Colors.grey.shade300),

                  const SizedBox(height: 32),
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search branch name, code, or city...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (isLoading)
                    Column(
                      children: List.generate(
                        5,
                        (index) => _buildShimmerCard(),
                      ),
                    )
                  else
                    Column(
                      children: branches.map((branch) {
                        return _branchCard(branch);
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _branchCard(BranchModel branch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Configure:\n${branch.branchName}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001B44),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: branch.status == "Active"
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(branch.status),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildInputField(icon: Icons.store, hint: branch.branchName),

          const SizedBox(height: 15),

          _buildInputField(icon: Icons.tag, hint: branch.branchCode),

          const SizedBox(height: 15),

          _buildInputField(
            icon: Icons.inventory_2_outlined,
            hint: branch.maxStockCapacity.toString(),
          ),

          const SizedBox(height: 15),

          _buildInputField(icon: Icons.phone, hint: branch.contactNumber),

          const SizedBox(height: 15),

          _buildInputField(
            icon: Icons.location_on_outlined,
            hint: branch.addressLine1,
          ),

          const SizedBox(height: 15),

          _buildInputField(icon: Icons.location_city, hint: branch.city),

          const SizedBox(height: 15),

          _buildInputField(
            icon: Icons.inventory,
            hint: branch.trayCapacityLimit.toString(),
          ),

          const SizedBox(height: 15),

          _buildInputField(
            icon: Icons.my_location,
            hint: branch.deliveryRadius.toString(),
          ),

          const SizedBox(height: 15),

          _buildInputField(
            icon: Icons.access_time,
            hint: branch.operatingHours,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({required IconData icon, required String hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDE3EA)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        initialValue: hint,
        decoration: InputDecoration(
          icon: Icon(icon, size: 18, color: Colors.blueGrey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 20, width: 180, color: Colors.white),
            const SizedBox(height: 12),
            Container(height: 14, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 14, width: 250, color: Colors.white),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container(height: 40, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 40, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
