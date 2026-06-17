import 'package:flutter/material.dart';

class BranchSettingsScreen extends StatefulWidget {
  const BranchSettingsScreen({super.key});

  @override
  State<BranchSettingsScreen> createState() => _BranchSettingsScreenState();
}

class _BranchSettingsScreenState extends State<BranchSettingsScreen> {
   bool isAutoApprove = true;
   
  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          " Settings",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Admin",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
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
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Divider(
                    color: Colors.grey.shade300,
                  ),

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
Container(
  margin: const EdgeInsets.all(16),
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.amber,
      width: 1.5,
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// Header
      Row(
        children: [
          const Expanded(
            child: Text(
              "Configure:\nkrpuram",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001B44),
              ),
            ),
          ),

          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              value: "Active",
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE8F5E9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Active",
                  child: Text(
                    "Active",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: "Inactive",
                  child: Text("Inactive"),
                ),
              ],
              onChanged: (value) {},
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),
      const Divider(),
      const SizedBox(height: 30),

      /// Branch Name
      const Text(
        "Branch Name",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.store_mall_directory_outlined,
        hint: "gunjur",
      ),

      const SizedBox(height: 30),

      /// Branch Code
      const Text(
        "Branch Code",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.tag,
        hint: "BR 03",
      ),

      const SizedBox(height: 30),

      /// Max Capacity
      const Text(
        "Max Capacity (Eggs)",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.inventory_2_outlined,
        hint: "2500",
      ),
    const Padding(
  padding: EdgeInsets.symmetric(vertical: 20),
  child: Text(
    "LOCATION & CONTACT",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF334E68),
      letterSpacing: 0.5,
    ),
  ),
),
const Divider(),
const SizedBox(height: 25),

const Text(
  "Phone",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.phone_outlined,
  hint: "+91 9876543210",
),
const SizedBox(height: 30),

const Text(
  "Address",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.location_on_outlined,
  hint: "Enter address",
),
const SizedBox(height: 30),

const Text(
  "City",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.location_on_outlined,
  hint: "Enter city",
),
const SizedBox(height: 10),
const Text(
  "OPERATIONAL THRESHOLDS",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF334E68),
    letterSpacing: 0.5,
  ),
),

const SizedBox(height: 20),
const Divider(),
const SizedBox(height: 25),  
const Text(
  "Tray Capacity Limit per Order",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.inventory_2_outlined,
  hint: "Enter tray capacity",
),

const SizedBox(height: 8),

const Row(
  children: [
    Icon(
      Icons.warning_amber_rounded,
      color: Colors.red,
      size: 18,
    ),
    SizedBox(width: 6),
    Text(
      "Limit (6000 eggs) exceeds max capacity!",
      style: TextStyle(
        color: Colors.red,
        fontSize: 11,
      ),
    ),
  ],
),
const SizedBox(height: 30),

const Text(
  "Delivery Radius Threshold (km)",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.my_location_outlined,
  hint: "Enter delivery radius",
),
const SizedBox(height: 30),

const Text(
  "Operating Hours",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.access_time_outlined,
  hint: "Enter operating hours",
), 
const SizedBox(height: 30),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Expanded(
      child: Text(
        "Auto-approve closing daily logs",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF334E68),
        ),
      ),
    ),

    Switch(
      value: isAutoApprove,
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFFF4C20D),
      onChanged: (value) {
        setState(() {
          isAutoApprove = value;
        });
      },
    ),
  ],
),
     const SizedBox(height: 32),

                 SizedBox(
  width: double.infinity,
  height: 48,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF4C20D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Settings Saved"),
          content: const Text(
            "Your branch settings have been saved successfully.",
          ),
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
    },
    child: const Text(
      "Save Settings",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
    ],
  ),
)
              
             , Container(
  margin: const EdgeInsets.all(16),
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.amber,
      width: 1.5,
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// Header
      Row(
        children: [
          const Expanded(
            child: Text(
              "Configure:\nPURCHASE",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001B44),
              ),
            ),
          ),

          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              value: "Active",
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE8F5E9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Active",
                  child: Text(
                    "Active",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: "Inactive",
                  child: Text("Inactive"),
                ),
              ],
              onChanged: (value) {},
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),
      const Divider(),
      const SizedBox(height: 30),

      /// Branch Name
      const Text(
        "Branch Name",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.store_mall_directory_outlined,
        hint: "gunjur",
      ),

      const SizedBox(height: 30),

      /// Branch Code
      const Text(
        "Branch Code",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.tag,
        hint: "BR 03",
      ),

      const SizedBox(height: 30),

      /// Max Capacity
      const Text(
        "Max Capacity (Eggs)",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.inventory_2_outlined,
        hint: "2500",
      ),
    const Padding(
  padding: EdgeInsets.symmetric(vertical: 20),
  child: Text(
    "LOCATION & CONTACT",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF334E68),
      letterSpacing: 0.5,
    ),
  ),
),
const Divider(),
const SizedBox(height: 25),

const Text(
  "Phone",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.phone_outlined,
  hint: "+91 9876543210",
),
const SizedBox(height: 30),

const Text(
  "Address",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.location_on_outlined,
  hint: "Enter address",
),
const SizedBox(height: 30),

const Text(
  "City",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.location_on_outlined,
  hint: "Enter city",
),
const SizedBox(height: 10),
const Text(
  "OPERATIONAL THRESHOLDS",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF334E68),
    letterSpacing: 0.5,
  ),
),

const SizedBox(height: 20),
const Divider(),
const SizedBox(height: 25),  
const Text(
  "Tray Capacity Limit per Order",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.inventory_2_outlined,
  hint: "Enter tray capacity",
),

const SizedBox(height: 8),

const Row(
  children: [
    Icon(
      Icons.warning_amber_rounded,
      color: Colors.red,
      size: 18,
    ),
    SizedBox(width: 6),
    Text(
      "Limit (6000 eggs) exceeds max capacity!",
      style: TextStyle(
        color: Colors.red,
        fontSize: 11,
      ),
    ),
  ],
),
const SizedBox(height: 30),

const Text(
  "Delivery Radius Threshold (km)",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.my_location_outlined,
  hint: "Enter delivery radius",
),
const SizedBox(height: 30),

const Text(
  "Operating Hours",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.access_time_outlined,
  hint: "Enter operating hours",
), 
const SizedBox(height: 30),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Expanded(
      child: Text(
        "Auto-approve closing daily logs",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF334E68),
        ),
      ),
    ),

    Switch(
      value: isAutoApprove,
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFFF4C20D),
      onChanged: (value) {
        setState(() {
          isAutoApprove = value;
        });
      },
    ),
  ],
),
     const SizedBox(height: 32),

               SizedBox(
  width: double.infinity,
  height: 48,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF4C20D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Settings Saved"),
          content: const Text(
            "Your branch settings have been saved successfully.",
          ),
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
    },
    child: const Text(
      "Save Settings",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
    ],
  ),
)
        
        ,Container(
  margin: const EdgeInsets.all(16),
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.amber,
      width: 1.5,
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// Header
      Row(
        children: [
          const Expanded(
            child: Text(
              "Configure:\nSARJAPURA",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001B44),
              ),
            ),
          ),

          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              value: "Active",
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE8F5E9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Active",
                  child: Text(
                    "Active",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: "Inactive",
                  child: Text("Inactive"),
                ),
              ],
              onChanged: (value) {},
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),
      const Divider(),
      const SizedBox(height: 30),

      /// Branch Name
      const Text(
        "Branch Name",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.store_mall_directory_outlined,
        hint: "SARJAPURA",
      ),

      const SizedBox(height: 30),

      /// Branch Code
      const Text(
        "Branch Code",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.tag,
        hint: "BR 03",
      ),

      const SizedBox(height: 30),

      /// Max Capacity
      const Text(
        "Max Capacity (Eggs)",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.inventory_2_outlined,
        hint: "2500",
      ),
    const Padding(
  padding: EdgeInsets.symmetric(vertical: 20),
  child: Text(
    "LOCATION & CONTACT",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF334E68),
      letterSpacing: 0.5,
    ),
  ),
),
const Divider(),
const SizedBox(height: 25),

const Text(
  "Phone",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.phone_outlined,
  hint: "+91 9876543210",
),
const SizedBox(height: 30),

const Text(
  "Address",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.location_on_outlined,
  hint: "Enter address",
),
const SizedBox(height: 30),

const Text(
  "City",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.location_on_outlined,
  hint: "Enter city",
),
const SizedBox(height: 10),
const Text(
  "OPERATIONAL THRESHOLDS",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF334E68),
    letterSpacing: 0.5,
  ),
),

const SizedBox(height: 20),
const Divider(),
const SizedBox(height: 25),  
const Text(
  "Tray Capacity Limit per Order",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.inventory_2_outlined,
  hint: "Enter tray capacity",
),

const SizedBox(height: 8),

const Row(
  children: [
    Icon(
      Icons.warning_amber_rounded,
      color: Colors.red,
      size: 18,
    ),
    SizedBox(width: 6),
    Text(
      "Limit (6000 eggs) exceeds max capacity!",
      style: TextStyle(
        color: Colors.red,
        fontSize: 11,
      ),
    ),
  ],
),
const SizedBox(height: 30),

const Text(
  "Delivery Radius Threshold (km)",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.my_location_outlined,
  hint: "Enter delivery radius",
),
const SizedBox(height: 30),

const Text(
  "Operating Hours",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.access_time_outlined,
  hint: "Enter operating hours",
), 
const SizedBox(height: 30),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Expanded(
      child: Text(
        "Auto-approve closing daily logs",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF334E68),
        ),
      ),
    ),

    Switch(
      value: isAutoApprove,
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFFF4C20D),
      onChanged: (value) {
        setState(() {
          isAutoApprove = value;
        });
      },
    ),
  ],
),
     const SizedBox(height: 32),

                 SizedBox(
  width: double.infinity,
  height: 48,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF4C20D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Settings Saved"),
          content: const Text(
            "Your branch settings have been saved successfully.",
          ),
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
    },
    child: const Text(
      "Save Settings",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
    ],
  ),
),Container(
  margin: const EdgeInsets.all(16),
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.amber,
      width: 1.5,
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// Header
      Row(
        children: [
          const Expanded(
            child: Text(
              "Configure:\ngunjur",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001B44),
              ),
            ),
          ),

          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              value: "Active",
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE8F5E9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Active",
                  child: Text(
                    "Active",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: "Inactive",
                  child: Text("Inactive"),
                ),
              ],
              onChanged: (value) {},
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),
      const Divider(),
      const SizedBox(height: 30),

      /// Branch Name
      const Text(
        "Branch Name",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.store_mall_directory_outlined,
        hint: "gunjur",
      ),

      const SizedBox(height: 30),

      /// Branch Code
      const Text(
        "Branch Code",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.tag,
        hint: "BR 03",
      ),

      const SizedBox(height: 30),

      /// Max Capacity
      const Text(
        "Max Capacity (Eggs)",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.inventory_2_outlined,
        hint: "2500",
      ),
    const Padding(
  padding: EdgeInsets.symmetric(vertical: 20),
  child: Text(
    "LOCATION & CONTACT",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF334E68),
      letterSpacing: 0.5,
    ),
  ),
),
const Divider(),
const SizedBox(height: 25),

const Text(
  "Phone",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.phone_outlined,
  hint: "+91 9876543210",
),
const SizedBox(height: 30),

const Text(
  "Address",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.location_on_outlined,
  hint: "Enter address",
),
const SizedBox(height: 30),

const Text(
  "City",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.location_on_outlined,
  hint: "Enter city",
),
const SizedBox(height: 10),
const Text(
  "OPERATIONAL THRESHOLDS",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF334E68),
    letterSpacing: 0.5,
  ),
),

const SizedBox(height: 20),
const Divider(),
const SizedBox(height: 25),  
const Text(
  "Tray Capacity Limit per Order",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.inventory_2_outlined,
  hint: "Enter tray capacity",
),

const SizedBox(height: 8),

const Row(
  children: [
    Icon(
      Icons.warning_amber_rounded,
      color: Colors.red,
      size: 18,
    ),
    SizedBox(width: 6),
    Text(
      "Limit (6000 eggs) exceeds max capacity!",
      style: TextStyle(
        color: Colors.red,
        fontSize: 11,
      ),
    ),
  ],
),
const SizedBox(height: 30),

const Text(
  "Delivery Radius Threshold (km)",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.my_location_outlined,
  hint: "Enter delivery radius",
),
const SizedBox(height: 30),

const Text(
  "Operating Hours",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.access_time_outlined,
  hint: "Enter operating hours",
), 
const SizedBox(height: 30),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Expanded(
      child: Text(
        "Auto-approve closing daily logs",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF334E68),
        ),
      ),
    ),

    Switch(
      value: isAutoApprove,
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFFF4C20D),
      onChanged: (value) {
        setState(() {
          isAutoApprove = value;
        });
      },
    ),
  ],
),
     const SizedBox(height: 32),

                  SizedBox(
  width: double.infinity,
  height: 48,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF4C20D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Settings Saved"),
          content: const Text(
            "Your branch settings have been saved successfully.",
          ),
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
    },
    child: const Text(
      "Save Settings",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
    ],
  ),
),Container(
  margin: const EdgeInsets.all(16),
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.amber,
      width: 1.5,
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// Header
      Row(
        children: [
          const Expanded(
            child: Text(
              "Configure:\nkrpuram",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001B44),
              ),
            ),
          ),

          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              value: "Active",
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE8F5E9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Active",
                  child: Text(
                    "Active",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: "Inactive",
                  child: Text("Inactive"),
                ),
              ],
              onChanged: (value) {},
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),
      const Divider(),
      const SizedBox(height: 30),

      /// Branch Name
      const Text(
        "Branch Name",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.store_mall_directory_outlined,
        hint: "krpuram",
      ),

      const SizedBox(height: 30),

      /// Branch Code
      const Text(
        "Branch Code",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.tag,
        hint: "BR 03",
      ),

      const SizedBox(height: 30),

      /// Max Capacity
      const Text(
        "Max Capacity (Eggs)",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.inventory_2_outlined,
        hint: "2500",
      ),
    const Padding(
  padding: EdgeInsets.symmetric(vertical: 20),
  child: Text(
    "LOCATION & CONTACT",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF334E68),
      letterSpacing: 0.5,
    ),
  ),
),
const Divider(),
const SizedBox(height: 25),

const Text(
  "Phone",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.phone_outlined,
  hint: "+91 9876543210",
),
const SizedBox(height: 30),

const Text(
  "Address",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.location_on_outlined,
  hint: "Enter address",
),
const SizedBox(height: 30),

const Text(
  "City",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.location_on_outlined,
  hint: "Enter city",
),
const SizedBox(height: 10),
const Text(
  "OPERATIONAL THRESHOLDS",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF334E68),
    letterSpacing: 0.5,
  ),
),

const SizedBox(height: 20),
const Divider(),
const SizedBox(height: 25),  
const Text(
  "Tray Capacity Limit per Order",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.inventory_2_outlined,
  hint: "Enter tray capacity",
),

const SizedBox(height: 8),

const Row(
  children: [
    Icon(
      Icons.warning_amber_rounded,
      color: Colors.red,
      size: 18,
    ),
    SizedBox(width: 6),
    Text(
      "Limit (6000 eggs) exceeds max capacity!",
      style: TextStyle(
        color: Colors.red,
        fontSize: 11,
      ),
    ),
  ],
),
const SizedBox(height: 30),

const Text(
  "Delivery Radius Threshold (km)",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.my_location_outlined,
  hint: "Enter delivery radius",
),
const SizedBox(height: 30),

const Text(
  "Operating Hours",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.access_time_outlined,
  hint: "Enter operating hours",
), 
const SizedBox(height: 30),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Expanded(
      child: Text(
        "Auto-approve closing daily logs",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF334E68),
        ),
      ),
    ),

    Switch(
      value: isAutoApprove,
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFFF4C20D),
      onChanged: (value) {
        setState(() {
          isAutoApprove = value;
        });
      },
    ),
  ],
),
     const SizedBox(height: 32),

                 SizedBox(
  width: double.infinity,
  height: 48,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF4C20D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Settings Saved"),
          content: const Text(
            "Your branch settings have been saved successfully.",
          ),
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
    },
    child: const Text(
      "Save Settings",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
    ],
  ),
)
        ,Container(
  margin: const EdgeInsets.all(16),
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.amber,
      width: 1.5,
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// Header
      Row(
        children: [
          const Expanded(
            child: Text(
              "Configure:\nSALEM",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001B44),
              ),
            ),
          ),

          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              value: "Active",
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE8F5E9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Active",
                  child: Text(
                    "Active",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: "Inactive",
                  child: Text("Inactive"),
                ),
              ],
              onChanged: (value) {},
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),
      const Divider(),
      const SizedBox(height: 30),

      /// Branch Name
      const Text(
        "Branch Name",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.store_mall_directory_outlined,
        hint: "SALEM",
      ),

      const SizedBox(height: 30),

      /// Branch Code
      const Text(
        "Branch Code",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.tag,
        hint: "BR 03",
      ),

      const SizedBox(height: 30),

      /// Max Capacity
      const Text(
        "Max Capacity (Eggs)",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),

      const SizedBox(height: 10),

      _buildInputField(
        icon: Icons.inventory_2_outlined,
        hint: "2500",
      ),
    const Padding(
  padding: EdgeInsets.symmetric(vertical: 20),
  child: Text(
    "LOCATION & CONTACT",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF334E68),
      letterSpacing: 0.5,
    ),
  ),
),
const Divider(),
const SizedBox(height: 25),

const Text(
  "Phone",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.phone_outlined,
  hint: "+91 9876543210",
),
const SizedBox(height: 30),

const Text(
  "Address",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.location_on_outlined,
  hint: "Enter address",
),
const SizedBox(height: 30),

const Text(
  "City",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.location_on_outlined,
  hint: "Enter city",
),
const SizedBox(height: 10),
const Text(
  "OPERATIONAL THRESHOLDS",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF334E68),
    letterSpacing: 0.5,
  ),
),

const SizedBox(height: 20),
const Divider(),
const SizedBox(height: 25),  
const Text(
  "Tray Capacity Limit per Order",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.inventory_2_outlined,
  hint: "Enter tray capacity",
),

const SizedBox(height: 8),

const Row(
  children: [
    Icon(
      Icons.warning_amber_rounded,
      color: Colors.red,
      size: 18,
    ),
    SizedBox(width: 6),
    Text(
      "Limit (6000 eggs) exceeds max capacity!",
      style: TextStyle(
        color: Colors.red,
        fontSize: 11,
      ),
    ),
  ],
),
const SizedBox(height: 30),

const Text(
  "Delivery Radius Threshold (km)",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.my_location_outlined,
  hint: "Enter delivery radius",
),
const SizedBox(height: 30),

const Text(
  "Operating Hours",
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334E68),
  ),
),

const SizedBox(height: 10),

_buildInputField(
  icon: Icons.access_time_outlined,
  hint: "Enter operating hours",
), 
const SizedBox(height: 30),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Expanded(
      child: Text(
        "Auto-approve closing daily logs",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF334E68),
        ),
      ),
    ),

    Switch(
      value: isAutoApprove,
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFFF4C20D),
      onChanged: (value) {
        setState(() {
          isAutoApprove = value;
        });
      },
    ),
  ],
),
     const SizedBox(height: 32),

                  SizedBox(
  width: double.infinity,
  height: 48,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF4C20D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Settings Saved"),
          content: const Text(
            "Your branch settings have been saved successfully.",
          ),
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
    },
    child: const Text(
      "Save Settings",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
    ],
  ),
)
        ,
        
         ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
  required IconData icon,
  required String hint,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 4,
    ),
    decoration: BoxDecoration(
      border: Border.all(
        color: const Color(0xFFDDE3EA),
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextField(
      decoration: InputDecoration(
        icon: Icon(
          icon,
          size: 18,
          color: Colors.blueGrey,
        ),
        hintText: hint,
        border: InputBorder.none,
      ),
    ),
  );
}
}