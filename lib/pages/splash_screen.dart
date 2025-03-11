import 'package:flutter/material.dart';
import 'dart:async';
import 'package:local_event/pages/signin.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Auto navigate after 3 seconds
    Timer(const Duration(seconds: 30), () {
      _navigateToLogin();
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfcf3cf), // Soft warm background
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: FadeTransition(
                opacity: _animation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120, // Fixed width for circular shape
                      height: 120, // Fixed height for circular shape
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.jpg',
                          fit: BoxFit.cover, // Ensures the image covers the circular area
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Event",
                      style: TextStyle(

                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Skip Button
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: TextButton(
              onPressed: _navigateToLogin,
              child: const Text(
                "Skip",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Change color as needed
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
