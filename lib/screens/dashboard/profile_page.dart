import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ucollect/widgets/custom_appBar.dart';
import '../welcome_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  void _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Log Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomePage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const Color brandColor = Color(0xFFFC882F);

    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          
          String displayName = "MantiCollector";
          String email = user?.email ?? "";
          
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            displayName = data['displayName'] ?? "MantiCollector";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: brandColor.withOpacity(0.1),
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : "U",
                          style: const TextStyle(fontSize: 40, color: brandColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(email, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                _buildProfileOption(icon: Icons.person_outline, title: "Edit Personal Details", onTap: () {}),
                _buildProfileOption(icon: Icons.notifications_none, title: "Notifications", onTap: () {}),
                _buildProfileOption(icon: Icons.security, title: "Privacy & Security", onTap: () {}),
                
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),

                _buildProfileOption(icon: Icons.help_outline, title: "Help & Support", onTap: () {}),
                
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.logout, color: Colors.red.shade400, size: 20),
                  ),
                  title: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                  onTap: _handleLogout,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileOption({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}