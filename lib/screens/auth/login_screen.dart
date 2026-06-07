// 1. KÜTÜPHANELERİ YÜKLEME

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../../core/services/user_role.dart';
import 'register_screen.dart';

// LOGIN SCREEN STATEFUL WIDGET TANIMLAMASI

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// EKRAN DURUMU VE KONTROL DEĞİŞKENLERİ

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordObscure = true;

  // KULLANICI GİRİŞ İŞLEMLERİ FONKSİYONU

  Future<void> _handleLogin() async {
    // Form Validasyon Kontrolü
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase Auth ile Oturum Açma
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      String? loggedInEmail = userCredential.user?.email;

      if (loggedInEmail != null) {
        // Firestore Kullanıcı Bilgileri ve Rol Sorgulama
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Kullanicilar')
            .where('email', isEqualTo: loggedInEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userData =
              querySnapshot.docs.first.data() as Map<String, dynamic>;
          String role = userData['rol'] ?? 'user';
          String durum = userData['durum'] ?? 'onaylandi';

          //  Yönetici Onay Durumu Kontrolü
          if (role != 'admin' && durum == 'beklemede') {
            await FirebaseAuth.instance.signOut();

            if (!mounted) return;
            _showSnackBar(
              "⏳ Hesabınız henüz yönetici tarafından onaylanmamıştır.",
              Colors.orange,
            );
            return;
          }

          //  Global Rol Ataması
          UserRole.isAdmin = (role == 'admin');
        } else {
          UserRole.isAdmin = false;
          print(
            "⚠️ Firestore'da bu e-postaya ait rol bulunamadı, varsayılan 'user' yapıldı.",
          );
        }

        if (!mounted) return;

        // Başarılı Giriş Bildirimi
        _showSnackBar(
          UserRole.isAdmin
              ? "👑 Yönetici Girişi Başarılı!"
              : "👋 Kullanıcı Girişi Başarılı!",
          Colors.green,
        );

        // Ana Sayfaya Yönlendirme ve Geçmişi Temizleme
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Firebase Hata Yönetimi
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
      // Genel Sistem Hatalarının Yakalanması
      if (mounted) _showSnackBar("Sistemsel Hata: $e", Colors.orange);
    } finally {
      // İşlem Bitiminde Yükleniyor Durumunun Kapatılması
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // BİLDİRİM MESAJI (SNACKBAR) FONKSİYONU

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // BELLEK TEMİZLİĞİ (DISPOSE)FONKSİYONU

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ARAYÜZ TASARIMI (BUILD METODU)

  @override
  Widget build(BuildContext context) {
    //  Ortak Giriş Kutusu Kenarlıkları (Dekorasyon Tanımları)
    final inputBorderDecoration = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: Colors.white.withAlpha(20)),
    );

    final focusedBorderDecoration = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
    );

    return Scaffold(
      //  Arka Plan Gradyan Konteyneri
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFF0F0F0F), Color(0xFF151515)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Center(
              //  Klavye Açıldığında Taşmayı Önleyen Kaydırılabilir Alan
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E1E1E),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withAlpha(30),
                              blurRadius: 40,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          size: 60,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      // 7e. Uygulama Başlığı ve Alt Slogan
                      const Text(
                        "AntikAdam",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Palatino',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Koleksiyonlarına Değer Kat",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 50),

                      // E-posta Giriş Alanı
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Lütfen e-posta adresinizi giriniz.";
                          }
                          if (!value.contains('@')) {
                            return "Geçersiz e-posta formatı.";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "E-mail",
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.gold,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF181818),
                          enabledBorder: inputBorderDecoration,
                          focusedBorder: focusedBorderDecoration,
                          errorBorder: inputBorderDecoration,
                          focusedErrorBorder: focusedBorderDecoration,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Şifre Giriş Alanı ve Gizle/Göster Butonu
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isPasswordObscure,
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Lütfen şifrenizi giriniz.";
                          }
                          if (value.length < 6) {
                            return "Şifre en az 6 karakter olmalıdır.";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Şifre",
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.gold,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordObscure = !_isPasswordObscure;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFF181818),
                          enabledBorder: inputBorderDecoration,
                          focusedBorder: focusedBorderDecoration,
                          errorBorder: inputBorderDecoration,
                          focusedErrorBorder: focusedBorderDecoration,
                        ),
                      ),
                      const SizedBox(height: 40),

                      //  Giriş Butonu ve Yükleniyor Simgesi
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: AppColors.gold.withAlpha(
                              100,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 5,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  "Sisteme Giriş Yap",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Kayıt Ekranına Geçiş Butonu
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Henüz bir hesabın yok mu? Hesap Oluştur",
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
