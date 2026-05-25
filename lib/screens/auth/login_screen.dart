import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../../core/services/user_role.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            colors: [Colors.black, Color(0xFF121212)],
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Container(
                  height: 110,
                  width: 110,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: AppColors.cardBlack,

                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withAlpha(5),

                        blurRadius: 30,
                        spreadRadius: 3,
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.workspace_premium,

                    size: 60,

                    color: AppColors.gold,
                  ),
                ),

                const SizedBox(height: 35),

                const Text(
                  "Collectify",

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 30,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Koleksiyonlarına Değer Kat",

                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),

                const SizedBox(height: 50),

                TextField(
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    hintText: "E-mail",

                    hintStyle: const TextStyle(color: Colors.grey),

                    prefixIcon: const Icon(Icons.email, color: AppColors.gold),

                    filled: true,

                    fillColor: AppColors.cardBlack,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  obscureText: true,

                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    hintText: "Şifre",

                    hintStyle: const TextStyle(color: Colors.grey),

                    prefixIcon: const Icon(Icons.lock, color: AppColors.gold),

                    filled: true,

                    fillColor: AppColors.cardBlack,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 60,

                      child: ElevatedButton(
                        onPressed: () {
                          UserRole.isAdmin = true;

                          Navigator.pushReplacement(
                            context,

                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        },

                        child: const Text(
                          "Yönetici Girişi",

                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 60,

                      child: OutlinedButton(
                        onPressed: () {
                          UserRole.isAdmin = false;

                          Navigator.pushReplacement(
                            context,

                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        },

                        child: const Text(
                          "Kullanıcı Girişi",

                          style: TextStyle(fontSize: 18, color: AppColors.gold),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {},

                  child: const Text(
                    "Hesap Oluştur",

                    style: TextStyle(color: AppColors.gold),
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
