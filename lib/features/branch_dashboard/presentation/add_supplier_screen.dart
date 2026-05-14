<<<<<<< HEAD
// import 'package:flutter/material.dart';

// class AddSupplierScreen extends StatelessWidget {
//   const AddSupplierScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff5f6fa),

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,

//         title: const Text(
//           "Add New Supplier",
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),

//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: const Icon(Icons.close, color: Colors.grey),
//           ),
//         ],
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// SUPPLIER NAME
//                 const Text(
//                   "Supplier Company Name",
//                   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//                 ),

//                 const SizedBox(height: 8),

//                 TextField(
//                   decoration: InputDecoration(
//                     hintText: "e.g. Apex Farms",
//                     hintStyle: TextStyle(
//                       color: Colors.grey.shade500,
//                       fontSize: 13,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 14,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(color: Color(0xfffacc15)),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 /// LOCATION + STATUS
//                 Row(
//                   children: [
//                     /// LOCATION
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Location / Region",
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),

//                           const SizedBox(height: 8),

//                           DropdownButtonFormField<String>(
//                             value: "Select region...",
//                             decoration: InputDecoration(
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 14,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                             ),
//                             items: const [
//                               DropdownMenuItem(
//                                 value: "Select region...",
//                                 child: Text("Select region.."),
//                               ),
//                               DropdownMenuItem(
//                                 value: "North Region",
//                                 child: Text("North Region"),
//                               ),
//                               DropdownMenuItem(
//                                 value: "South Region",
//                                 child: Text("South Region"),
//                               ),
//                             ],
//                             onChanged: (value) {},
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(width: 12),

//                     /// STATUS
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Status",
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),

//                           const SizedBox(height: 8),

//                           DropdownButtonFormField<String>(
//                             value: "Active",
//                             decoration: InputDecoration(
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 14,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                             ),
//                             items: const [
//                               DropdownMenuItem(
//                                 value: "Active",
//                                 child: Text("Active"),
//                               ),
//                               DropdownMenuItem(
//                                 value: "Inactive",
//                                 child: Text("Inactive"),
//                               ),
//                             ],
//                             onChanged: (value) {},
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 18),

//                 /// PRIMARY CONTACT
//                 const Text(
//                   "Primary Contact Name",
//                   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//                 ),

//                 const SizedBox(height: 8),

//                 TextField(
//                   decoration: InputDecoration(
//                     hintText: "e.g. Jane Doe",
//                     hintStyle: TextStyle(
//                       color: Colors.grey.shade500,
//                       fontSize: 13,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 14,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 /// EMAIL + PHONE
//                 Row(
//                   children: [
//                     /// EMAIL
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Email Address",
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),

//                           const SizedBox(height: 8),

//                           TextField(
//                             decoration: InputDecoration(
//                               hintText: "name@company.com",
//                               hintStyle: TextStyle(
//                                 color: Colors.grey.shade500,
//                                 fontSize: 13,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 14,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(width: 12),

//                     /// PHONE
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Phone Number",
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),

//                           const SizedBox(height: 8),

//                           TextField(
//                             decoration: InputDecoration(
//                               hintText: "+1 (555) 000-0000",
//                               hintStyle: TextStyle(
//                                 color: Colors.grey.shade500,
//                                 fontSize: 13,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 14,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 28),

//                 /// BUTTONS
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     /// CANCEL
//                     OutlinedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Colors.black87,
//                         side: BorderSide(color: Colors.grey.shade300),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 18,
//                           vertical: 14,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text("Cancel"),
//                     ),

//                     const SizedBox(width: 12),

//                     /// SAVE
//                     // ElevatedButton(
//                     //   onPressed: () {},
//                     //   style: ElevatedButton.styleFrom(
//                     //     backgroundColor: const Color(0xfffacc15),
//                     //     foregroundColor: Colors.black,
//                     //     elevation: 0,
//                     //     padding: const EdgeInsets.symmetric(
//                     //       horizontal: 18,
//                     //       vertical: 14,
//                     //     ),
//                     //     shape: RoundedRectangleBorder(
//                     //       borderRadius: BorderRadius.circular(10),
//                     //     ),
//                     //   ),
//                     //   child: const Text(
//                     //     "Save Supplier",
//                     //     style: TextStyle(fontWeight: FontWeight.w600),
//                     //   ),
//                     // ),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context, {
//                           "supplier": "Apex Farms",
//                           "contactperson": "Robert",
//                           "contactnumber": "+91 1234567890",
//                           "status": "Active",
//                         });
//                       },
=======
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:proteinova_connect/core/network/dio_client.dart';

// class AddSupplierScreen extends StatefulWidget {
//   const AddSupplierScreen({super.key});

//   @override
//   State<AddSupplierScreen> createState() => _AddSupplierScreenState();
// }

// class _AddSupplierScreenState extends State<AddSupplierScreen> {
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _contactNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
  
//   String _selectedRegion = "Select region...";
//   String _selectedStatus = "Active";
//   bool _isSaving = false;

//   @override
//   void dispose() {
//     _companyNameController.dispose();
//     _contactNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   Future<void> _saveSupplier() async {
//     if (_companyNameController.text.isEmpty || _contactNameController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill all required fields")),
//       );
//       return;
//     }

//     setState(() => _isSaving = true);

//     try {
//       final dio = DioClient().dio;
//       final response = await dio.post("/api/addSupplier", data: {
//         "supplier_company_name": _companyNameController.text,
//         "supplier_name": _contactNameController.text,
//         "email": _emailController.text,
//         "phone_number": _phoneController.text,
//         "supplier_location": _selectedRegion,
//         "status": _selectedStatus,
//       });

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         if (mounted) {
//           Navigator.pop(context, true);
//         }
//       } else {
//         throw Exception("Failed to save supplier");
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error: $e")),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isSaving = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff5f6fa),

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,

//         title: const Text(
//           "Add New Supplier",
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),

//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: const Icon(Icons.close, color: Colors.grey),
//           ),
//         ],
//       ),

//       body: _isSaving 
//         ? const Center(child: CircularProgressIndicator())
//         : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// SUPPLIER NAME
//                 const Text(
//                   "Supplier Company Name",
//                   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//                 ),

//                 const SizedBox(height: 8),

//                 TextField(
//                   controller: _companyNameController,
//                   decoration: InputDecoration(
//                     hintText: "e.g. Apex Farms",
//                     hintStyle: TextStyle(
//                       color: Colors.grey.shade500,
//                       fontSize: 13,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 14,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(color: Color(0xfffacc15)),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 /// LOCATION + STATUS
//                 Row(
//                   children: [
//                     /// LOCATION
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Location / Region",
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),

//                           const SizedBox(height: 8),

//                           DropdownButtonFormField<String>(
//                             value: _selectedRegion,
//                             decoration: InputDecoration(
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 14,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                             ),
//                             items: const [
//                               DropdownMenuItem(
//                                 value: "Select region...",
//                                 child: Text("Select region.."),
//                               ),
//                               DropdownMenuItem(
//                                 value: "North Region",
//                                 child: Text("North Region"),
//                               ),
//                               DropdownMenuItem(
//                                 value: "South Region",
//                                 child: Text("South Region"),
//                               ),
//                             ],
//                             onChanged: (value) {
//                               if (value != null) setState(() => _selectedRegion = value);
//                             },
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(width: 12),

//                     /// STATUS
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Status",
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),

//                           const SizedBox(height: 8),

//                           DropdownButtonFormField<String>(
//                             value: _selectedStatus,
//                             decoration: InputDecoration(
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 14,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                             ),
//                             items: const [
//                               DropdownMenuItem(
//                                 value: "Active",
//                                 child: Text("Active"),
//                               ),
//                               DropdownMenuItem(
//                                 value: "Inactive",
//                                 child: Text("Inactive"),
//                               ),
//                             ],
//                             onChanged: (value) {
//                               if (value != null) setState(() => _selectedStatus = value);
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 18),

//                 /// PRIMARY CONTACT
//                 const Text(
//                   "Primary Contact Name",
//                   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//                 ),

//                 const SizedBox(height: 8),

//                 TextField(
//                   controller: _contactNameController,
//                   decoration: InputDecoration(
//                     hintText: "e.g. Jane Doe",
//                     hintStyle: TextStyle(
//                       color: Colors.grey.shade500,
//                       fontSize: 13,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 14,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 /// EMAIL + PHONE
//                 Row(
//                   children: [
//                     /// EMAIL
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Email Address",
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),

//                           const SizedBox(height: 8),

//                           TextField(
//                             controller: _emailController,
//                             decoration: InputDecoration(
//                               hintText: "name@company.com",
//                               hintStyle: TextStyle(
//                                 color: Colors.grey.shade500,
//                                 fontSize: 13,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 14,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(width: 12),

//                     /// PHONE
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Phone Number",
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),

//                           const SizedBox(height: 8),

//                           TextField(
//                             controller: _phoneController,
//                             decoration: InputDecoration(
//                               hintText: "+1 (555) 000-0000",
//                               hintStyle: TextStyle(
//                                 color: Colors.grey.shade500,
//                                 fontSize: 13,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 14,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 28),

//                 /// BUTTONS
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     /// CANCEL
//                     OutlinedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Colors.black87,
//                         side: BorderSide(color: Colors.grey.shade300),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 18,
//                           vertical: 14,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text("Cancel"),
//                     ),

//                     const SizedBox(width: 12),

//                     /// SAVE
//                     ElevatedButton(
//                       onPressed: _saveSupplier,
>>>>>>> 985535f3db39fce19bb7ce2ac31180ddc2961dc9
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xfffacc15),
//                         foregroundColor: Colors.black,
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 18,
//                           vertical: 14,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text(
//                         "Save Supplier",
//                         style: TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
