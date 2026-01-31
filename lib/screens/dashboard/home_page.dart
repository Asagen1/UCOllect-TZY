import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ucollect/screens/dashboard/sell_page.dart'; 

import '../../widgets/recent_activity_list.dart';
import '../../widgets/custom_appBar.dart';
import 'rate_page.dart';
import 'cashout_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'station_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFFFC882F);

    return Scaffold(
      backgroundColor: Colors.white,
      
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          DashboardTab(),
          RatePage(),
          CashOutPage(),
          HistoryPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        backgroundColor: Colors.white,
        selectedItemColor: brandGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Rate"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Cash Out"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFFFC882F);
    const Color lightOrangeBg = Color.fromARGB(255, 252, 246, 242);
    const Color lightYellowBg = Color(0xFFFFFDE7);
    const Color textDark = Color(0xFF1F2937);

    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        double earnings = 0.0;
        double liters = 0.0;
        double co2 = 0.0;
        String name = "MantiCollector";

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          earnings = (data['total_earnings'] ?? 0).toDouble();
          liters = (data['total_liters'] ?? 0).toDouble();
          co2 = (data['co2_saved'] ?? 0).toDouble();
          name = data['displayName'] ?? "MantiCollector";
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const CustomAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                const SizedBox(height: 24),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: brandColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: brandColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Impact",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: lightOrangeBg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.water_drop, color: Color(0xFFFC882F), size: 28),
                                  const SizedBox(height: 8),
                                  Text(
                                    liters.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark),
                                  ),
                                  const Text("Liters Sold", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: lightYellowBg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.currency_ruble, color: Color(0xFFFBC02D), size: 28),
                                  const SizedBox(height: 8),
                                  Text(
                                    earnings.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark),
                                  ),
                                  const Text("Total Earnings", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("CO2 Saved", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text("$co2 kg", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2962FF))),
                              ],
                            ),
                            const Icon(Icons.eco, color: Color(0xFF2962FF)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SellPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Sell Cooking Oil", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("Convert your oil to cash", style: TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const StationsListPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
                        child: const Icon(Icons.local_shipping, color: Colors.black54),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Drop-off Stations", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                          Text("See collection status", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                RecentActivityList(userId: user!.uid, limit: 3),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}