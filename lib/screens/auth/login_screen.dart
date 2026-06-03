import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../../core/services/user_role.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextField verilerini okumak için Controller'larımızı tanımlıyoruz
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Giriş yaparken ekranda yüklenme çarkı göstermek için durum değişkeni
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    // 1. Alanların doluluk kontrolü
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnackBar("Lütfen tüm alanları doldurunuz!", Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Firebase Auth ile giriş yapılıyor
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Kullanıcı başarıyla giriş yaptıysa e-postasını alıyoruz
      String? loggedInEmail = userCredential.user?.email;

      if (loggedInEmail != null) {
        // 3. Firestore'dan rol sorgulanıyor
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Kullanicilar')
            .where('email', isEqualTo: loggedInEmail)
            .get();

        // Eğer veritabanında bu e-posta varsa rolüne bakıyoruz
        if (querySnapshot.docs.isNotEmpty) {
          var userData =
              querySnapshot.docs.first.data() as Map<String, dynamic>;
          String role = userData['rol'] ?? 'user';

          // Rol atamasını yapıyoruz
          if (role == 'admin') {
            UserRole.isAdmin = true;
          } else {
            UserRole.isAdmin = false;
          }
        } else {
          // Eğer Firestore'da rolü elinle eklemeyi unuttuysan sunumda kilitlenmesin diye varsayılan olarak user yapalım
          UserRole.isAdmin = false;
          print(
            "⚠️ Firestore'da bu e-postaya ait rol bulunamadı, varsayılan 'user' yapıldı.",
          );
        }

        // 🔥 KRİTİK DÜZELTME: Navigator tetiklenmeden önce sayfanın hala ekranda (mounted) olduğundan emin oluyoruz.
        // Bu, Pointer/Gesture kilitlenmesini tamamen çözer.
        if (!mounted) return;

        _showSnackBar(
          UserRole.isAdmin
              ? "Yönetici Girişi Başarılı!"
              : "Kullanıcı Girişi Başarılı!",
          Colors.green,
        );

        // Sayfa geçişini tetikliyoruz
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Giriş başarısız oldu.";
      if (e.code == 'user-not-found') {
        errorMessage = "Bu e-posta adresine ait kullanıcı bulunamadı.";
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = "E-posta veya şifre hatalı.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Geçersiz bir e-posta formatı.";
      }

      if (mounted) _showSnackBar(errorMessage, Colors.red);
    } catch (e) {
      // Başka bir sistemsel hata olursa uygulamayı dondurma, hatayı ekrana bas
      if (mounted) _showSnackBar("Sistemsel Hata: $e", Colors.orange);
      print("Arayüzü Kilitleyen Hata: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Ortak Snackbar fonksiyonu
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için controller'ları kapatıyoruz
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            colors: [Colors.black, Color(0xFF121212)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: SingleChildScrollView(
              // Klavye açılınca ekran taşmasın diye ekledik
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
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
                  const Text(
                    "Koleksiyonlarına Değer Kat",
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                  const SizedBox(height: 50),

                  // E-mail Giriş Kutusu
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "E-mail",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(
                        Icons.email,
                        color: AppColors.gold,
                      ),
                      filled: true,
                      fillColor: AppColors.cardBlack,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Şifre Giriş Kutusu
                  TextField(
                    controller: _passwordController,
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

                  // Giriş Buton Alanı
                  _isLoading
                      ? const CircularProgressIndicator(color: AppColors.gold)
                      : SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              "Sisteme Giriş Yap",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
      ),
    );
  }
}
