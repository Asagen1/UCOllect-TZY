import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ucollect/widgets/custom_appbar.dart';
import '../../widgets/recent_activity_list.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.white,
      body: user == null
          ? const Center(child: Text("Please log in"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                   Text(
                    "All Transactions",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  
                  RecentActivityList(
                    userId: user.uid, 
                    limit: 50,
                  ),
                ],
              ),
            ),
    );
  }
}