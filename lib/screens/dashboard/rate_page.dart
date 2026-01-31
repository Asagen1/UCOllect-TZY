import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ucollect/widgets/custom_appBar.dart';

// ai rate page

class RatePage extends StatefulWidget {
  const RatePage({super.key});

  @override
  State<RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  // Simple calculator variables
  final TextEditingController _calcController = TextEditingController();
  double _estimatedEarnings = 0.0;
  double _currentPrice = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('settings').doc('global_config').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading rates"));
          // Default 
          _currentPrice = 35.0; 
          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            _currentPrice = (data['price_per_liter'] ?? 35).toDouble();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // --- THE BIG PRICE CARD ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFC882F), Color(0xFFFFAB73)], // MantiCol Orange
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text("BUYING PRICE", style: TextStyle(color: Colors.white, letterSpacing: 1.5)),
                      const SizedBox(height: 10),
                      Text(
                        "₱ ${_currentPrice.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const Text("per Liter", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- "FAKE" GRAPH (Visuals only) ---
                const Text("Price Trend (7 Days)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  height: 150,
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  // This is a placeholder graph. 
                  // In a real app, you'd use the 'fl_chart' package.
                  child: CustomPaint(
                    painter: _SimpleGraphPainter(), // See class below
                  ),
                ),

                const SizedBox(height: 30),

                // --- CALCULATOR (Interactive part) ---
                const Text("Profit Calculator", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _calcController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "If I collect (Liters)...",
                            border: OutlineInputBorder(),
                            suffixText: "L",
                          ),
                          onChanged: (value) {
                            setState(() {
                              double liters = double.tryParse(value) ?? 0;
                              _estimatedEarnings = liters * _currentPrice;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("You will earn:", style: TextStyle(fontSize: 16, color: Colors.grey)),
                            Text(
                              "₱ ${_estimatedEarnings.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Just draws a simple squiggly line to look like a graph
class _SimpleGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.9, size.width, size.height * 0.2); // Ends high (good trend)

    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}