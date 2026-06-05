import 'package:flutter/material.dart';

class AppColors {
  // 🔥 Arka Plan Derinliği (Pure Luxury Black)
  // Eski 0xFF0D0D0D yerine biraz daha lacivert/füme kırılımlı ultra premium siyah
  static const Color background = Color(0xFF080808);

  // 📦 Kartlar ve Katmanlar (Sleek Surface Hiyerarşisi)
  // Birbirinin üstüne binen listeler ve kartlar için derinlik hissi
  static const Color surface = Color(
    0xFF121212,
  ); // Ana kartlar (Eski cardBlack yerine)
  static const Color surfaceVariant = Color(
    0xFF1A1A1A,
  ); // Açılır paneller veya iç kartlar
  static const Color cardBlack = Color(
    0xFF121212,
  ); // Geriye dönük uyumluluk bozulmasın diye

  // 👑 İmza Altın Tonları (The Royal Gold Palette)
  // Uygulamanın mücevher gibi parlamasını sağlayan, gözü yormayan asil tonlar
  static const Color gold = Color(
    0xFFD4AF37,
  ); // Saf Metalik Altın (Daha asil bir ton)
  static const Color goldClick = Color(
    0xFFFFC107,
  ); // Tıklama efekti ve vurgular için parlak altın
  static const Color amber = Color(0xFFFFB300); // Mevcut yapın için korundu
  static const Color softGold = Color(
    0xFFF3E5AB,
  ); // İpeksi Şampanya/Krem Altın (Yazılar için mükemmel)
  static const Color darkGold = Color(
    0xFF8C6D23,
  ); // Pasif butonlar ve ince kontürler için mat altın

  // 📝 Metin ve Tipografi Renkleri
  // Saf beyaz gözü yorar, bu yüzden hafif matlaştırılmış lüks kontrastlar
  static const Color textPrimary = Color(
    0xFFF5F5F7,
  ); // Ana başlıklar (Apple tarzı kırık beyaz)
  static const Color textSecondary = Color(
    0xFF9E9E9E,
  ); // Açıklamalar ve alt başlıklar
  static const Color textMuted = Color(
    0xFF616161,
  ); // Pasif tarihler ve ipuçları

  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Colors.grey;

  // 🚥 Durum Renkleri (Sistem Geri Bildirimleri)
  // Altın temayı bozmayacak şekilde soft seçilmiş durum renkleri
  static const Color success = Color(
    0xFF2E7D32,
  ); // Başarılı teklifler (Zümrüt Yeşili)
  static const Color error = Color(
    0xFFC62828,
  ); // Hatalar ve uyarılar (Yakup Kırmızı)
  static const Color info = Color(0xFF1565C0); // Bilgilendirmeler (Safir Mavi)

  // 🌟 Premium Degrade (Gradient) Geçişleri
  // Butonların ve büyük alanların arkasına koyabileceğin muazzam bir lüks geçişi
  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      Color(0xFFBF953F),
      Color(0xFFFCF6BA),
      Color(0xFFB38728),
      Color(0xFFFBF5B7),
      Color(0xFFAA771C),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
