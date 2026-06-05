import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/user_role.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  Future<void> _handleRegister() async {
    // 1. Form alanlarının doğruluğunu kontrol ediyoruz
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Firebase Auth ile yeni kullanıcı kaydı oluşturuluyor
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 3. Kullanıcı başarıyla oluştuktan sonra Firestore kaydı yapılıyor
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;

        // Doküman ID'sini doğrudan kullanıcının benzersiz UID'si yapıyoruz
        await FirebaseFirestore.instance.collection('Kullanicilar').doc(uid).set({
          'uid': uid,
          'email': _emailController.text.trim(),
          'rol': 'user', // Yeni kayıt olan herkes standart kullanıcıdır
          'durum':
              'beklemede', // ⏳ KRİTİK: Giriş yapabilmek için admin onayı gerekecek
          'kayitTarihi': FieldValue.serverTimestamp(),
        });

        // Yeni kayıt olan kullanıcı direkt içeri alınmayacağı için rolünü güvenceye alıyoruz
        UserRole.isAdmin = false;

        if (!mounted) return;

        // Kullanıcıya bilgi veriyoruz
        _showSnackBar(
          "🎉 Kayıt başarılı! Hesabınız yönetici onayından sonra aktif olacaktır.",
          Colors.orange,
        );

        // Otomatik girişi engellemek için Firebase Auth oturumunu hemen kapatıyoruz
        await FirebaseAuth.instance.signOut();

        // Kullanıcıyı bir önceki ekran olan Giriş (Login) ekranına geri yönlendiriyoruz
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Kayıt işlemi başarısız oldu.";
      if (e.code == 'weak-password') {
        errorMessage =
            "Şifre çok zayıf. En az 6 karakterli daha güçlü bir şifre deneyin.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage =
            "Bu e-posta adresi zaten başka bir hesap tarafından kullanılıyor.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Geçersiz bir e-posta formatı girdiniz.";
      }

      if (mounted) _showSnackBar(errorMessage, Colors.red);
    } catch (e) {
      if (mounted) _showSnackBar("Sistemsel bir hata oluştu: $e", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tasarımdaki input border stillerini ortaklaştırıyoruz
    final inputBorderDecoration = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: Colors.white.withAlpha(20)),
    );

    final focusedBorderDecoration = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.gold,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey, // Validasyon takibi
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Başlık Alanı
                      const Text(
                        "Yeni Hesap Oluştur",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Collectify dünyasına katılın ve onay bekleyin",
                        style: TextStyle(color: Colors.white38, fontSize: 14),
                      ),
                      const SizedBox(height: 40),

                      // E-mail Input
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Lütfen bir e-posta adresi giriniz.";
                          }
                          if (!value.contains('@')) {
                            return "Geçersiz e-posta formatı.";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "E-mail",
                          hintStyle: const TextStyle(color: Colors.grey),
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

                      // Şifre Input
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isPasswordObscure,
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Lütfen şifrenizi belirleyin.";
                          }
                          if (value.length < 6) {
                            return "Şifre en az 6 karakter olmalıdır.";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Şifre",
                          hintStyle: const TextStyle(color: Colors.grey),
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
                      const SizedBox(height: 20),

                      // Şifre Tekrar Input
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _isConfirmPasswordObscure,
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Lütfen şifrenizi tekrar giriniz.";
                          }
                          if (value != _passwordController.text) {
                            return "Şifreler birbiriyle uyuşmuyor!";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Şifre Tekrar",
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(
                            Icons.lock_clock_outlined,
                            color: AppColors.gold,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordObscure =
                                    !_isConfirmPasswordObscure;
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

                      // Kayıt Ol Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
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
                                  "Kayıt Talebi Gönder",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
