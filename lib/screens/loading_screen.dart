import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // 🚀 Performance: Reduced loading time from 3s to 1.5s for faster app startup
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) { // 🛡️ Safety: Check if widget is still mounted
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🚀 Performance: Optimized logo loading with caching
            Image.asset(
              'assets/CC-Penta-3.png',
              width: 120, // Reduced size for faster loading
              height: 120,
              cacheWidth: 120, // Cache at display size
              cacheHeight: 120,
              filterQuality: FilterQuality.medium, // Balance quality vs performance
            ),
            const SizedBox(height: 24),

            // Animated Spinner
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.deepOrange,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(
                    color: Colors.deepOrange,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
