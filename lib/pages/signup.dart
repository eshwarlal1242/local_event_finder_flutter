import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_event/pages/signin.dart';
import '../services/auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  void signup() async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text.trim() == confirmPasswordController.text.trim()) {
        try {
          final userCredential = await _authService.signUp(
            emailController.text.trim(),
            passwordController.text.trim(),
          );

          // Save user details in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'createdAt': Timestamp.now(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup Successful!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add, size: 80, color: Colors.orange),
                const SizedBox(height: 10),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Sign up to get started",
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name Field
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon: const Icon(Icons.person, color: Colors.orange),
                            filled: true,
                            fillColor: Colors.orange.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                        ),
                        const SizedBox(height: 15),

                        // Email Field
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email, color: Colors.orange),
                            filled: true,
                            fillColor: Colors.orange.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Enter your email' : null,
                        ),
                        const SizedBox(height: 15),

                        // Password Field
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                            filled: true,
                            fillColor: Colors.orange.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) => value!.isEmpty ? 'Enter your password' : null,
                        ),
                        const SizedBox(height: 15),

                        // Confirm Password Field
                        TextFormField(
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.orange),
                            filled: true,
                            fillColor: Colors.orange.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) => value!.isEmpty ? 'Confirm your password' : null,
                        ),
                        const SizedBox(height: 20),

                        // Signup Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: signup,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.orange.shade600,
                              foregroundColor: Colors.white,
                              elevation: 5,
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Already have an account? Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
