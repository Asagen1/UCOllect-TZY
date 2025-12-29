import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add 'intl' to pubspec.yaml if you haven't, or use manual formatting

class TransactionDetailsPage extends StatelessWidget {
  final String transactionId;
  final Map<String, dynamic> data;

  const TransactionDetailsPage({
    super.key,
    required this.transactionId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Extract and Format Data
    final double amount = (data['amount'] ?? 0).toDouble();
    final double liters = (data['liters'] ?? 0).toDouble();
    final String status = data['status'] ?? "Completed";
    
    // Date Formatting 
    final Timestamp? timestamp = data['date'] as Timestamp?;
    final DateTime date = timestamp?.toDate() ?? DateTime.now();
    final String dateString = DateFormat('MMMM dd, yyyy').format(date);
    final String timeString = DateFormat('hh:mm a').format(date);

    String stationName = data['station_name'] ?? "Unknown Station";
    String stationAddress = data['station_address'] ?? "";

    String place = stationName;
    if(stationAddress.isNotEmpty && stationAddress != stationName){
      place = "$stationName\n($stationAddress)";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Details", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, size: 60, color: Color(0xFF0EB052)),
            ),
            const SizedBox(height: 16),
            const Text("Transaction Successful", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(dateString, style: const TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  const Text("Total Earnings", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text("₱${amount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0EB052))),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  _buildDetailRow("Transaction ID", transactionId, isSmall: true),
                  const SizedBox(height: 16),
                  _buildDetailRow("Status", status, color: Colors.green),
                  const SizedBox(height: 16),
                  _buildDetailRow("Volume Sold", "$liters Liters"),
                  const SizedBox(height: 16),
                  _buildDetailRow("Time", timeString),
                  const SizedBox(height: 16),
                  _buildDetailRow("Place", place),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isSmall = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value, 
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: isSmall ? 12 : 14,
              color: color ?? Colors.black87
            ),
          ),
        ),
      ],
    );
  }
}