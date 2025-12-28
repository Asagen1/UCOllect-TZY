import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  double _liters = 5.0;
  final double _pricePerLiter = 12.50;

  bool _isLoading = false;

  Future<void> _handleConfirmPickup() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final double totalPrice = _liters * _pricePerLiter;
      final double co2 = _liters * 3.0;

      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final transactionRef = userRef.collection('transactions').doc();

      final batch = FirebaseFirestore.instance.batch();

      batch.set(transactionRef, {
        'type': 'sold',
        'liters': _liters,
        'amount': totalPrice,
        'date': FieldValue.serverTimestamp(),
        'status': 'pending_pickup',
      });

      batch.update(userRef, {
        'total_liters': FieldValue.increment(_liters),
        'total_earnings': FieldValue.increment(totalPrice),
        'co2_saved': FieldValue.increment(co2),
      });

      await batch.commit();

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Pickup Confirmed! Dashboard updated."), backgroundColor: Colors.green),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    double totalPrice = _liters * _pricePerLiter;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Sell Page", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.oil_barrel, color: Colors.orange.shade700, size: 32),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Used Cooking Oil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Ready for collection", style: TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 32),

            const Text("Quantity (Liters)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.blue,
                inactiveTrackColor: Colors.grey.shade200,
                thumbColor: Colors.blue,
                overlayColor: Colors.blue.withOpacity(0.2),
                trackHeight: 6.0,
              ),
              child: Slider(
                value: _liters,
                min: 1,
                max: 20,
                divisions: 19,
                label: "${_liters.toInt()}L",
                onChanged: (value) {
                  setState(() {
                    _liters = value;
                  });
                },
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("1L", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text("10L", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text("20L", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Selected Quantity:", style: TextStyle(color: Colors.grey)),
                      Text("${_liters.toInt()} Liters", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Price:", style: TextStyle(color: Colors.grey)),
                      Text("₱${totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0EB052))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Rate: ₱12.50 per liter", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text("Drop-off Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: const Icon(Icons.location_on, color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Station Address", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        const Text("123 Main Street, Barangay San Jose", style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text("Manila, Metro Manila, 1000", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {},
                          child: const Text("Edit Station", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                    child: const Icon(Icons.calendar_today, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Drop-off Date", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        const Text("Tomorrow, Dec 23, 2025", style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text("Between 9:00 AM - 12:00 PM", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {},
                          child: const Text("Change Schedule", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("You'll receive", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text("₱${totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleConfirmPickup,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.orange.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Confirm Pickup", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}