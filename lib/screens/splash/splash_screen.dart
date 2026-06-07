import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            colors: [Colors.black, Color(0xFF1A1A1A)],
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              height: 150,
              width: 150,

              decoration: BoxDecoration(
                color: AppColors.cardBlack,

                shape: BoxShape.circle,

                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withRed(4),

                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),

              child: const Icon(
                Icons.workspace_premium,

                color: AppColors.gold,

                size: 90,
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              "ANTİKADAM",

              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                fontStyle: FontStyle.italic,
                fontFamily: 'Palatino',
              ),
            ),

            const SizedBox(height: 15),

            Text(
              "Koleksiyon için,\nİyi bir başlangıç...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontFamily: 'Palatino',
              ),
            ),
            const SizedBox(height: 60),
            CircularProgressIndicator(color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}
