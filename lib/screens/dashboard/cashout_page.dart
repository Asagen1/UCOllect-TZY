import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ai cash out page

class CashOutPage extends StatefulWidget {
  const CashOutPage({super.key});

  @override
  State<CashOutPage> createState() => _CashOutPageState();
}

class _CashOutPageState extends State<CashOutPage> {
  final _amountController = TextEditingController();
  final _numberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    // Safety: Hide keyboard
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final double amountToWithdraw = double.parse(_amountController.text);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // 1. Get User Data
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        
        if (!userSnapshot.exists) throw Exception("User not found");

        double currentBalance = (userSnapshot.get('total_earnings') ?? 0).toDouble();

        // 2. Check Balance
        if (currentBalance < amountToWithdraw) {
          throw Exception("Insufficient Balance"); // This triggers the snackbar below
        }

        // 3. Deduct Money
        double newBalance = currentBalance - amountToWithdraw;
        transaction.update(userRef, {'total_earnings': newBalance});

        // 4. Create Withdrawal Ticket
        DocumentReference newRequestRef = FirebaseFirestore.instance.collection('withdrawals').doc();
        transaction.set(newRequestRef, {
          'userId': user.uid,
          'userEmail': user.email,
          'amount': amountToWithdraw,
          'gcash_number': _numberController.text,
          'status': 'PENDING',
          'timestamp': FieldValue.serverTimestamp(),
          'method': 'GCash',
        });
      });

      if (mounted) {
        _amountController.clear();
        _numberController.clear();
        // Show Success Dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Request Sent!"),
            content: const Text("Your funds will be sent to your GCash within 24 hours."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 60),
              // Header Image or Icon
              const Icon(Icons.account_balance_wallet, size: 80, color: Color(0xFFFC882F)),
              const SizedBox(height: 20),
              const Text(
                "Withdraw Earnings",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text("Transfer directly to GCash", style: TextStyle(color: Colors.grey)),
              
              const SizedBox(height: 30),

              // GCash Number
              TextFormField(
                controller: _numberController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: InputDecoration(
                  labelText: "GCash Number (09...)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.phone_android),
                  counterText: "", // Hides the character counter
                ),
                validator: (value) {
                  if (value == null || value.length != 11 || !value.startsWith('09')) {
                    return "Enter a valid 11-digit GCash number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount (₱)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter amount";
                  if (double.tryParse(value) == null) return "Invalid number";
                  if (double.parse(value) < 50) return "Minimum withdrawal is ₱50";
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Main Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFC882F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _submitRequest,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("WITHDRAW NOW", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}