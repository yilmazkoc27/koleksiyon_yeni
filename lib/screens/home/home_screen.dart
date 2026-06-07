// ==========================================
// 📄 DOSYA: lib/home/home_screen.dart
// ==========================================

// 📦 KÜTÜPHANE VE DOSYA BAĞLANTILARI
// Projede zaman zaman tekrarlanan görevler (Timer) için Dart'ın asenkron kütüphanesi yüklenir.
import 'dart:async';
import 'package:flutter/material.dart';

// 📂 DİĞER EKRANLARIN VE MODÜLLERİN DOSYA BAĞLANTILARI
// Ana sayfadan yönlendirme yapılacak olan alt koleksiyon ekranları,
// premium renk paleti (AppColors) ve rol tabanlı yetkilendirme servisi projeye dahil edilir.
import 'package:koleksiyon_yeni/screens/gems/gems_screen.dart';
import '../../core/theme/app_colors.dart';
import '../coins/coin_screen.dart';
import '../stamps/stamp_screen.dart';
import '../statistics/statistics_screen.dart';
import '../favorites/favorites_screen.dart';
import '../statistics/bids_list_screen.dart';
import '../../core/services/user_role.dart';

// 📈 VERİ SERVİSİ: FİNANSAL VERİLER
// Uygulamanın üst kısmında akan borsa şeridi için anlık döviz ve altın fiyatlarını
// asenkron bir şekilde getiren (simüle eden) statik servis sınıfıdır.
class FinanceService {
  static Future<Map<String, double>> fetchLiveRates() async {
    return {'USD': 46.50, 'EUR': 54.20, 'GOLD': 6650.0};
  }
}

// 🏠 ANA EKRAN YAPISI (StatefulWidget)
// Borsa şeridindeki kaydırma efektleri ve dinamik arayüz güncellemeleri için
// durumu (state) kendi içinde yönetebilen ana görünüm bileşenidir.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// 🧠 ANA EKRANIN DURUM (STATE) YÖNETİM MERKEZİ
class _HomeScreenState extends State<HomeScreen> {
  // 🕹️ Otomatik kaydırma mekanizmasını ve zamanlayıcıyı kontrol eden yerel değişkenler.
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  // 🏁 EKRAN BAŞLATILIRKEN ÇALIŞAN KISIM (initState)
  // Ekran belleğe yüklendiği an ilk kare çizildikten sonra otomatik kaydırma motorunu tetikler.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  // 🔄 OTOMATİK KAYDIRMA MOTORU (Borsa Şeridi İçin)
  // Her 30 milisaniyede bir borsa şeridini 1 piksel sağa kaydırır.
  // Şerit sona ulaştığında pürüzsüz bir şekilde başa (`0` konumuna) sarar.
  void _startScrolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;

        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(currentScroll + 1.0);
        }
      }
    });
  }

  // 🛑 BELLEK TEMİZLEME MERKEZİ (dispose)
  // Sayfa kapatıldığında arka planda çalışan zamanlayıcıyı (Timer) durdurur ve
  // kaydırma kontrolcüsünü bellekten silerek "Memory Leak" (Bellek Sızıntısı) oluşmasını engeller.
  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // 🎨 GÖRSEL ARAYÜZÜN İNŞA ALANI (build)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Uygulama arka plan rengi
      // 📌 ÜST BAŞLIK ÇUBUĞU (AppBar)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "AntikAdam",
          style: TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.w900,
            fontSize: 26,
            letterSpacing: 1.2,
            fontStyle: FontStyle.italic,
            fontFamily: 'Palatino',
          ),
        ),
        actions: [
          // 👤 KULLANICI PROFİL İKONU VE GÖRSEL DEKORASYONU
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withAlpha(150),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(40),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const CircleAvatar(
                backgroundColor: AppColors.surface,
                child: Icon(Icons.person, color: AppColors.gold),
              ),
            ),
          ),
        ],
      ),

      // 🌌 ANA GÖVDE KATMANLARI (Stack)
      // Arka plana dairesel premium ışık süzmeleri (ambient light effect) eklemek
      // ve üzerine ana elementleri dizmek için üst üste binen katman yapısı kurulmuştur.
      body: Stack(
        children: [
          // 🟡 Sol Üst Işık Efekti
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withAlpha(25),
                backgroundBlendMode: BlendMode.screen,
              ),
            ),
          ),
          // 🟡 Sağ Alt Işık Efekti
          Positioned(
            bottom: 150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withAlpha(15),
              ),
            ),
          ),

          // 🗂️ ANA İÇERİK SÜTUNU (Döviz şeridi ve Koleksiyon Kartları)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📊 GELECEK TABANLI VERİ İNŞAATÇISI (FutureBuilder — BORSA ŞERİDİ)
              // Finans servisinden canlı verileri asenkron bekler. Veri yüklenene kadar
              // veya hata durumunda varsayılan (safeguard) borsa kurlarını ekrana basar.
              FutureBuilder<Map<String, double>>(
                future: FinanceService.fetchLiveRates(),
                builder: (context, snapshot) {
                  Map<String, double> rates =
                      snapshot.data ??
                      {'USD': 46.5, 'EUR': 54.2, 'GOLD': 6650.0};

                  // Döviz metin şeridinin hazırlanması
                  String tickerText =
                      "🇺🇸 USD: ${rates['USD']!.toStringAsFixed(2)} TL    •    "
                      "🇪🇺 EUR: ${rates['EUR']!.toStringAsFixed(2)} TL    •    "
                      "🟡 GRAM ALTIN: ${rates['GOLD']!.toStringAsFixed(0)} TL    •    ";

                  // Şeridin sonsuz döngüde gibi görünmesi için metin 12 kere yan yana çoğaltılır.
                  String repeatedText = tickerText * 12;

                  return Container(
                    width: double.infinity,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: AppColors.gold.withAlpha(40),
                          width: 0.5,
                        ),
                      ),
                    ),
                    // Kullanıcı parmağıyla kaydıramasın diye fizikleri kapatılmış yatay kaydırma çubuğu
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        child: Text(
                          repeatedText,
                          textWidthBasis: TextWidthBasis.parent,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 🎴 MENÜ KARTLARI VE BANNER ALANI
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 👋 Karşılama Başlığı (Akademik Palatino Fontu ile)
                      Row(
                        children: [
                          Text(
                            "Hoş Geldiniz...",
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w100,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Palatino',
                                ),
                          ),
                        ],
                      ),
                      const Text(
                        "Koleksiyon Dünyasına Giriş Yaptınız....",
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          letterSpacing: 0.5,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🎫 PREMİUM ÜST BANNER (Görsel Marka Kimliği alanı)
                      Container(
                        width: double.infinity,
                        height: 125,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.gold.withAlpha(100),
                            width: 1.2,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.surfaceVariant.withAlpha(200),
                              AppColors.surface.withAlpha(240),
                              AppColors.surfaceVariant.withAlpha(150),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withAlpha(35),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Icon(
                                Icons.blur_on,
                                size: 150,
                                color: AppColors.gold.withAlpha(15),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withAlpha(40),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.gold.withAlpha(100),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: const Text(
                                      "PREMİUM KOLEKSİYON DÜNYASI",
                                      style: TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "KOÇ KOLEKSİYON",
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontFamily: 'Times New Roman',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const Text(
                                    "HATIRA PARA • PUL • DEĞERLİ TAŞLAR",
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 🏷️ Altı Çizili Bölüm Başlığı
                      const Text(
                        "Koleksiyon Galerisi",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          height: 1.5,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.gold,
                          decorationThickness: 2,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // IZGARA PANELİ (GridView — MENÜ KARTLARI)
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio:
                              1.12, // Kartların en-boy oranı dengesi
                          children: [
                            buildCard(
                              context,
                              "Hatıra Para",
                              Icons.monetization_on_rounded,
                            ),
                            buildCard(context, "Pul", Icons.mail_rounded),
                            buildCard(
                              context,
                              "Değerli Taşlar",
                              Icons.diamond_rounded,
                            ),

                            //ADMİN / YÖNETİCİ KONTROL SORGUSU
                            UserRole.isAdmin
                                ? buildCard(
                                    context,
                                    "Yönetici Paneli",
                                    Icons.admin_panel_settings_rounded,
                                    isAdminCard: true,
                                  )
                                : buildCard(
                                    context,
                                    "İstatistik",
                                    Icons.analytics_rounded,
                                  ),

                            buildCard(
                              context,
                              "Teklifler",
                              Icons.gavel_rounded,
                            ),
                            buildCard(
                              context,
                              "Favoriler",
                              Icons.stars_rounded,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //YARDIMCI METOT: DİNAMİK KART OLUŞTURUCU (buildCard)

  Widget buildCard(
    BuildContext context,
    String title,
    IconData icon, {
    bool isAdminCard = false,
  }) {
    return GestureDetector(
      //  DİNAMİK SAYFA YÖNLENDİRME MERKEZİ (Navigation Map)
      onTap: () {
        if (title == "Hatıra Para") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CoinScreen()),
          );
        } else if (title == "Pul") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StampScreen()),
          );
        } else if (title == "Değerli Taşlar") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GemsScreen()),
          );
        } else if (title == "İstatistik") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StatisticsScreen()),
          );
        } else if (title == "Favoriler") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavoritesScreen()),
          );
        } else if (title == "Teklifler") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BidsListScreen()),
          );
        } else if (title == "Yönetici Paneli") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StatisticsScreen()),
          );
        }
      },
      // KARTIN GÖRSEL KUTU TASARIMI (BoxDecoration)
      child: Container(
        decoration: BoxDecoration(
          color: isAdminCard
              ? AppColors.surfaceVariant.withAlpha(220)
              : AppColors.surface.withAlpha(200),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isAdminCard ? AppColors.gold : AppColors.gold.withAlpha(50),
            width: isAdminCard ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isAdminCard
                  ? AppColors.gold.withAlpha(50)
                  : Colors.black.withAlpha(80),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        // KART İÇERİĞİ
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isAdminCard
                    ? AppColors.gold.withAlpha(30)
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isAdminCard
                      ? AppColors.gold.withAlpha(100)
                      : Colors.white.withAlpha(10),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: AppColors.gold, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: isAdminCard ? AppColors.gold : AppColors.textPrimary,
                fontWeight: isAdminCard ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
