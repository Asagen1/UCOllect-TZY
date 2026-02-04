import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Make sure this import points to where you actually saved the widget
import '../../widgets/station_selector.dart'; 
import 'survey_page.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  double _liters = 5.0;
  bool _isLoading = false;

  Map<String, dynamic>? _selectedStation;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // FIX 1: Defined 'getter' here so the whole class can see it
  bool get _isFormValid => _selectedStation != null && _selectedDate != null && _selectedTime != null;

  // Helper to format date nicely
  String _getFormattedDate() {
    if (_selectedDate == null) return "Select Date";
    return "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}";
  }

  // Helper to format time nicely
  String _getFormattedTime() {
    if (_selectedTime == null) return "Select Time";
    return _selectedTime!.format(context);
  }

  Future<void> _handleConfirmPickup(double currentPrice) async {
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final double totalPrice = _liters * currentPrice;
      // Adjusted CO2 calculation (approx 3kg per liter)
      final double co2 = _liters * 3.0; 

      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final transactionRef = userRef.collection('transactions').doc();

      final batch = FirebaseFirestore.instance.batch();

      // FIX 2: We must SAVE the station and date/time to Firestore!
      batch.set(transactionRef, {
        'type': 'sold',
        'liters': _liters,
        'amount': totalPrice,
        'date': FieldValue.serverTimestamp(),
        'status': 'pending_pickup',
        // NEW FIELDS ADDED:
        'station_id': _selectedStation!['id'], // Assumes your picker returns an 'id'
        'station_name': _selectedStation!['name'],
        'station_address': _selectedStation!['address'],
        'pickup_date': _selectedDate, 
        'pickup_time': "${_selectedTime!.hour}:${_selectedTime!.minute}",
      });

      batch.update(userRef, {
        'total_liters': FieldValue.increment(_liters),
        'total_earnings': FieldValue.increment(totalPrice),
        'co2_saved': FieldValue.increment(co2),
      });

      await batch.commit();

      if (mounted) {
        // Move to survey
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SurveyPage()),
        );

        // Success Message
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
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('settings').doc('global_config').snapshots(),
      builder: (context, snapshot) {

        double livePrice = 12.50; //if no data, use default

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          livePrice = (data['price_per_liter'] ?? 12.50).toDouble();
        }

        double totalPrice = _liters * livePrice;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
          ),
          
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Oil Barrel)
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

                // Slider Section
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

                // Price Summary
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Rate: ₱${livePrice.toStringAsFixed(2)} per liter", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Text("Drop-off Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // STATION CARD
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
                            // FIX 3: Display dynamic text!
                            Text(_selectedStation != null ? _selectedStation!['name'] : "Select Station", 
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_selectedStation != null ? _selectedStation!['address'] : "No station selected", 
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final result = await showModalBottomSheet<Map<String, dynamic>>(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                  // Make sure this class name matches your widget file
                                  builder: (context) => const StationPickerSheet(), 
                                );
                                
                                if (result != null) {
                                  setState(() {
                                    _selectedStation = result;
                                  });
                                }
                              },
                              child: Text(
                                _selectedStation == null ? "Choose Station" : "Change Station",
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // DATE/TIME CARD
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
                            // FIX 4: Display dynamic date!
                            Text(
                              _selectedDate == null ? "Select a date" : "${_getFormattedDate()} • ${_getFormattedTime()}", 
                              style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(), // Fixed: Don't add Duration(0) needed
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 30)),
                                );
                                
                                if (date != null) {
                                  if (!mounted) return;
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: const TimeOfDay(hour: 9, minute: 0),
                                  );

                                  if (time != null) {
                                    setState(() {
                                      _selectedDate = date;
                                      _selectedTime = time;
                                    });
                                  }
                                }
                              },
                              child: Text(
                                _selectedDate == null ? "Set Schedule" : "Change Schedule",
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
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
                    // FIX 5: Corrected Syntax for ternary operator
                    onPressed: (_isLoading || !_isFormValid) ? null : () => _handleConfirmPickup(livePrice),

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
    );    
  }
}