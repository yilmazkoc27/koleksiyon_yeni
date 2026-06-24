import 'dart:async';
import 'package:flutter/material.dart';
import 'package:koleksiyon_yeni/screens/gems/gems_screen.dart';
import '../../core/theme/app_colors.dart';
import '../coins/coin_screen.dart';
import '../stamps/stamp_screen.dart';
import '../statistics/statistics_screen.dart';
import '../favorites/favorites_screen.dart';
import '../statistics/bids_list_screen.dart';
import '../../core/services/user_role.dart';

class FinanceService {
  static Future<Map<String, double>> fetchLiveRates() async {
    return {'USD': 46.50, 'EUR': 54.20, 'GOLD': 6650.0};
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

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

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "AntikAdam",
          style: TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.w900,
            fontSize: 36,
            letterSpacing: 1.2,
            fontStyle: FontStyle.italic,
            fontFamily: 'Palatino',
          ),
        ),
        actions: [
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
              // child: const CircleAvatar(
              //   backgroundColor: AppColors.surface,
              //   child: Icon(Icons.person, color: AppColors.success),
              // ),
            ),
          ),
        ],
      ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<Map<String, double>>(
                future: FinanceService.fetchLiveRates(),
                builder: (context, snapshot) {
                  Map<String, double> rates =
                      snapshot.data ??
                      {'USD': 46.5, 'EUR': 54.2, 'GOLD': 6650.0};
                  String tickerText =
                      "🇺🇸 USD: ${rates['USD']!.toStringAsFixed(2)} TL    •    "
                      "🇪🇺 EUR: ${rates['EUR']!.toStringAsFixed(2)} TL    •    "
                      "🟡 GRAM ALTIN: ${rates['GOLD']!.toStringAsFixed(0)} TL    •    ";
                  String repeatedText = tickerText * 12;

                  return Container(
                    width: double.infinity,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: AppColors.gold.withRed(40),
                          width: 0.5,
                        ),
                      ),
                    ),
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
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
                      const Text(
                        "Koleksiyon Galerisi",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 1, //Silinmedi. İsteğe bağlı bırakıldı.
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          height: 1.5,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.gold,
                          decorationThickness: 2,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Palatino',
                        ),
                      ),
                      const SizedBox(height: 15),
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

  Widget buildCard(
    BuildContext context,
    String title,
    IconData icon, {
    bool isAdminCard = false,
  }) {
    return GestureDetector(
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
      child: Container(
        decoration: BoxDecoration(
          color: isAdminCard
              ? AppColors.surfaceVariant.withAlpha(220)
              : AppColors.surface.withBlue(10),
          borderRadius: BorderRadius.circular(34),
          border: Border.all(
            color: isAdminCard ? AppColors.info : AppColors.gold.withBlue(5),
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
              child: Icon(icon, color: AppColors.gold, size: 40),
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
