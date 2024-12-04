import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged; // Accept the onThemeChanged callback

  const SplashScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Animation duration of 2 seconds
    );

    // Define fade animation
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Start the animation
    _animationController.forward();

    // Delay and navigate to home screen after the animation (4 seconds)
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(onThemeChanged: widget.onThemeChanged), // Pass the onThemeChanged callback
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color of the splash screen
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation, // Apply fade-in animation to the logo
          child: Image.asset(
            'assets/app_icon.png', // Path to your app icon
            width: 150, // Size of the logo
            height: 150,
          ),
        ),
      ),
    );
  }
}
