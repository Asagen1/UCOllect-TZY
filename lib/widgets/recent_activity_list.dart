import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/dashboard/transactionDetails_page.dart';

class RecentActivityList extends StatelessWidget {
  final String userId;
  final int limit;

  const RecentActivityList({
    super.key,
    required this.userId,
    this.limit = 3,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .limit(limit)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.history, size: 40, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text(
                  "No recent activity",
                  style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Sell oil to see your history here",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final double amount = (data['amount'] ?? 0).toDouble();
            final double liters = (data['liters'] ?? 0).toDouble();
            
            // Format the Timestamp to a readable string (simplified)
            // You can add 'intl' package later for better formatting
            final Timestamp? timestamp = data['date'] as Timestamp?;
            final String dateStr = timestamp != null 
                ? "${timestamp.toDate().month}/${timestamp.toDate().day}" 
                : "Recent";

              return GestureDetector(
              // ADDED THIS ONTAP
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionDetailsPage(
                      transactionId: doc.id, // Passes the ID
                      data: data,           // Passes the rest of the info
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Color(0xFFF17416), size: 20),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Oil Collected", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("$liters L • $dateStr", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    Text("+P${amount.toStringAsFixed(0)}", 
                      style: const TextStyle(color: Color(0xFFF17416), fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(width: 8),
                    // Added a small arrow to hint it is clickable
                    const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}