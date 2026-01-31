import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard/home_page.dart'; // Make sure this imports your HomePage correctly

class NameSetupPage extends StatefulWidget {
  const NameSetupPage({super.key});

  @override
  State<NameSetupPage> createState() => _NameSetupPageState();
}

class _NameSetupPageState extends State<NameSetupPage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submitName() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String name = _nameController.text.trim();

      // 1. Update Firebase Auth Profile (Local App Display)
      await user.updateDisplayName(name);

      // 2. Update Firestore User Document (Database Record)
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': name,
        'email': user.email,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // 'merge: true' creates it if it doesn't exist

      if (mounted) {
        // 3. Go to Home Page (Remove back button history)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFFFC882F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "What's your name?",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Let us know what to call you.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                
                const SizedBox(height: 40),

                TextFormField(
                  controller: _nameController,
                  autofocus: true, // Keyboard pops up automatically
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: "Your Name",
                    hintText: "e.g. Juan dela Cruz",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: brandColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitName,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Continue",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}