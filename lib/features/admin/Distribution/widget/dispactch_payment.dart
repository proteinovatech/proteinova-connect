import 'package:flutter/material.dart';

class DispactchPayment extends StatefulWidget {
  const DispactchPayment({super.key});

  @override
  State<DispactchPayment> createState() => _DispactchPaymentState();
}

class _DispactchPaymentState extends State<DispactchPayment>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String selectedUpi = "";

  final amountController = TextEditingController();
  final debtController = TextEditingController();
  final refController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),

          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: const [
                  Icon(Icons.currency_rupee, size: 22),

                  SizedBox(width: 8),

                  Text(
                    "Choose Payment",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                "Select payment method for this sale",
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 20),

              Divider(),

              TabBar(
                controller: _tabController,
                indicatorColor: Colors.blue,

                labelColor: Colors.blue,

                unselectedLabelColor: Colors.black54,

                tabs: const [
                  Tab(text: "UPI Payment"),
                  Tab(text: "COD"),
                  Tab(text: "RTGS/NEFT"),
                ],
              ),

              SizedBox(
                height: 420,

                child: TabBarView(
                  controller: _tabController,

                  children: [
                    _upiView(),

                    _codView(),

                    _bankView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _upiView() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Select UPI App",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 10,
            runSpacing: 10,

            children: [
              _upi("Google Pay"),
              _upi("PhonePe"),
              _upi("Paytm"),
              _upi("Other"),
            ],
          ),

          const SizedBox(height: 22),

          _field(
            "Reference / ID",
            "UPI ID or Ref No",
            refController,
          ),

          const SizedBox(height: 18),

          _field(
            "Enter Amount",
            "₹ 0.00",
            amountController,
          ),

          const SizedBox(height: 18),

          _field(
            "Debt (Optional)",
            "₹ 0.00",
            debtController,
          ),
        ],
      ),
    );
  }

  Widget _codView() {
    return _card(
      child: Column(
        children: [

          const Align(
            alignment: Alignment.centerLeft,

            child: Text(
              "Cash on Delivery",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            "Pay when order arrives.",
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 30),

          _field(
            "Enter Amount",
            "₹ 0.00",
            amountController,
          ),

          const SizedBox(height: 18),

          _field(
            "Debt (Optional)",
            "₹ 0.00",
            debtController,
          ),
        ],
      ),
    );
  }

  Widget _bankView() {
    return _card(
      child: Column(
        children: [

          const Align(
            alignment: Alignment.centerLeft,

            child: Text(
              "RTGS/NEFT Transfer",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            "Bank transfer via RTGS or NEFT.",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 28),

          _field(
            "Transaction Reference",
            "Enter Reference ID",
            refController,
          ),

          const SizedBox(height: 18),

          _field(
            "Enter Amount",
            "₹ 0.00",
            amountController,
          ),

          const SizedBox(height: 18),

          _field(
            "Debt (Optional)",
            "₹ 0.00",
            debtController,
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 18),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),

      child: child,
    );
  }

  Widget _upi(String name) {
    bool active = selectedUpi == name;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor:
            active ? Colors.blue.shade50 : Colors.white,
      ),

      onPressed: () {
        setState(() {
          selectedUpi = name;
        });
      },

      child: Text(name),
    );
  }

  Widget _field(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: controller,

          decoration: InputDecoration(
            hintText: hint,

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}