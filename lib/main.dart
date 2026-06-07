import 'package:flutter/material.dart';
import 'package:koleksiyon_yeni/screens/splash/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android klasörüne koyduğumuz google-services.json dosyasını okuyarak Firebase'i uyandırıyoruz
  await Firebase.initializeApp();
  runApp(const Collectify());
}

class Collectify extends StatelessWidget {
  const Collectify({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.darkTheme,

      home: const SplashScreen(),
    );
  }
}
