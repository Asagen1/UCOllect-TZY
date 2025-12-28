import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/widgets/social_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _handleSignup() async {
    String email = _emailController.text.trim();
    String password = _passController.text.trim();
    String confirmPassword = _confirmPassController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    if(!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showError("Please enter a valid email address");
      return;
    }

    if(password.length < 8) {
      _showError("Password must be at least 8 characters long");
      return;
    }

    if (password != confirmPassword) {
      _showError("Passwords do not match");
      return;
    }
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'total_earnings': 0.0, // Start with 0
          'total_liters': 0.0,
          'co2_saved': 0.0,
          'displayName': email.split('@')[0],
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      Navigator.of(context).pop();

      print("User Created: $email");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created! Please Sign In."), backgroundColor: Colors.green),
      );
      
      Navigator.pop(context); 

    } on FirebaseAuthException catch (e) {
      // Hide loading circle
      Navigator.of(context).pop();

      String message = "An error occurred";
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
      _showError(message);
    } catch (e) {
      Navigator.of(context).pop();
      _showError("Error: ${e.toString()}");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  SvgPicture.asset(
                    'assets/icons/ucollect_logo.svg',
                    colorFilter: const ColorFilter.mode(Color(0xFF07D55D), BlendMode.srcIn),
                    height: 50, 
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ucollect',
                    style: TextStyle(
                      color: Color(0xFF07D55D),
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(24),         
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Let's Get Started",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 30),

                    const Text("Email address", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "juandelacruz@gmail.com",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passController,  
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: "• • • • • • • •",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text("Re-enter Password", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmPassController,  
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: "• • • • • • • •",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          height: 24, 
                          width: 24,
                          child: Checkbox(
                            value: _isPasswordVisible,
                            activeColor: const Color(0xFF00C853),
                            onChanged: (value) => setState(() => _isPasswordVisible = value!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text("Show password", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Center(
                      child: SizedBox(
                        width: 150, 
                        child: ElevatedButton(
                          onPressed: _handleSignup,
                          
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text("Sign up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  // 1. Left Line
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                  
                  // 2. The Text in the middle
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "or",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  
                  // 3. Right Line
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SocialButton(
                text: "Continue with Google",
                svgPath: 'assets/icons/google_logo.svg',  
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              SocialButton(
                text: "Continue with Apple",
                icon: Icons.apple,
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              SocialButton(
                text: "Continue with Facebook",
                icon: Icons.facebook,
                iconColor: Colors.blue, 
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}