import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../models/collection_item.dart';

// --- ENTEGRE FİNANS SERVİSİ ---
class FinanceService {
  static const String _apiUrl = "https://open.er-api.com/v6/latest/USD";

  static Future<Map<String, double>> fetchLiveRates() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;

        double usdToTry = rates['TRY']?.toDouble() ?? 34.50;
        double usdToEur = rates['EUR']?.toDouble() ?? 0.92;
        double eurToTry = usdToTry / usdToEur;

        // Altın hesaplama ve sıfır olma koruması
        double usdToXau = rates['XAU']?.toDouble() ?? 0.0;
        double gramGoldToTry =
            6650.0; // Eğer servis hata verirse kullanılacak yedek fiyat

        // Eğer gelen XAU değeri sıfırdan büyük ve mantıklı bir değerse hesapla
        if (usdToXau > 0 && usdToXau < 1) {
          double onsPriceUsd = 1 / usdToXau;
          double hesaplananAltin = (onsPriceUsd / 31.1035) * usdToTry;

          if (hesaplananAltin > 1000) {
            gramGoldToTry = hesaplananAltin;
          }
        }
        return {'USD': usdToTry, 'EUR': eurToTry, 'GOLD': gramGoldToTry};
      }
      throw Exception("Kurlar alınamadı");
    } catch (e) {
      // İnternet tamamen kesikse veya api çöktüyse varsayılan kurlar
      return {'USD': 46.50, 'EUR': 54.20, 'GOLD': 6650.0};
    }
  }
}

// --- İSTATİSTİK EKRANI ---
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  // Firestore verilerini çeken fonksiyon
  Future<Map<String, List<CollectionItem>>> _fetchAllData() async {
    final firestore = FirebaseFirestore.instance;

    final results = await Future.wait([
      firestore.collection('Paralar').get(),
      firestore.collection('Pullar').get(),
      firestore.collection('gems').get(),
    ]);

    final coins = results[0].docs.map((doc) {
      final Map<String, dynamic> data = doc.data();
      return CollectionItem.fromMap(data, doc.id);
    }).toList();

    final stamps = results[1].docs.map((doc) {
      final Map<String, dynamic> data = doc.data();
      return CollectionItem.fromMap(data, doc.id);
    }).toList();

    final gems = results[2].docs.map((doc) {
      final Map<String, dynamic> data = doc.data();
      return CollectionItem.fromMap(data, doc.id);
    }).toList();

    return {'coins': coins, 'stamps': stamps, 'gems': gems};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("İstatistikler")),
      body: FutureBuilder<Map<String, List<CollectionItem>>>(
        future: _fetchAllData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Veri Hatası: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "Veri bulunamadı.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final data = snapshot.data!;
          List<CollectionItem> coinList = data['coins']!;
          List<CollectionItem> stampList = data['stamps']!;
          List<CollectionItem> gemList = data['gems']!;

          int totalCoins = coinList.length;
          int totalStamps = stampList.length;
          int totalGems = gemList.length;
          int totalCollection = totalCoins + totalStamps + totalGems;

          List<CollectionItem> allItems = [
            ...coinList,
            ...stampList,
            ...gemList,
          ];
          List<CollectionItem> recentItems = allItems.reversed.take(5).toList();

          int favorites = allItems.where((e) => e.isFavorite).length;
          int totalValue = allItems.fold(0, (sum, item) => sum + item.value);

          CollectionItem? mostExpensive;
          if (allItems.isNotEmpty) {
            List<CollectionItem> sortedItems = List.from(allItems);
            sortedItems.sort((a, b) => b.value.compareTo(a.value));
            mostExpensive = sortedItems.first;
          }

          String level = "Başlangıç";
          if (totalCollection >= 10) level = "Koleksiyoner";
          if (totalCollection >= 30) level = "Uzman";
          if (totalCollection >= 50) level = "Efsane";

          List<String> achievements = [];
          if (totalCollection >= 5) achievements.add("🏆 İlk Koleksiyon");
          if (totalCollection >= 10) achievements.add("⭐ Koleksiyoner");
          if (totalCollection >= 25) achievements.add("🔥 Uzman Koleksiyoncu");
          if (totalCollection >= 50) achievements.add("👑 Efsane Koleksiyoncu");
          if (totalValue >= 50000) achievements.add("💰 Zengin Koleksiyon");
          if (favorites >= 10) achievements.add("❤️ Favori Ustası");

          return FutureBuilder<Map<String, double>>(
            future: FinanceService.fetchLiveRates(),
            builder: (context, financeSnapshot) {
              Map<String, double> rates =
                  financeSnapshot.data ??
                  {'USD': 34.5, 'EUR': 37.2, 'GOLD': 3150.0};

              double totalUsd = totalValue / rates['USD']!;
              double totalEur = totalValue / rates['EUR']!;
              double totalGold = totalValue / rates['GOLD']!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildCard("Toplam Koleksiyon", totalCollection.toString()),
                    buildCard("Toplam Değer", "$totalValue TL"),

                    const SizedBox(height: 5),
                    const Text(
                      "Koleksiyonun Döviz Karşılığı",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniFinanceCard(
                            "💵 Dolar",
                            "${totalUsd.toStringAsFixed(2)} \$",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMiniFinanceCard(
                            "💶 Euro",
                            "${totalEur.toStringAsFixed(2)} €",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMiniFinanceCard(
                            "👑 Altın (Gr)",
                            "${totalGold.toStringAsFixed(2)} Gr",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Canlı Piyasalar (Anlık)",
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBlack,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1. Eleman: USD
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: Text(
                                  "🇺🇸 USD: ${rates['USD']!.toStringAsFixed(2)} TL",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: Text(
                                  "🇪🇺 EUR: ${rates['EUR']!.toStringAsFixed(2)} TL",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: Text(
                                  "🟡 ALTIN: ${rates['GOLD']!.toStringAsFixed(0)} TL", // "GRAM" kelimesini alan kazanmak için kısalttık
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    Text(
                      totalCollection < 10
                          ? "Koleksiyon büyümeye başladı 🚀"
                          : totalCollection < 30
                          ? "Harika ilerliyorsun ⭐"
                          : "Muhteşem koleksiyon 👑",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    buildCard("Favoriler", favorites.toString()),
                    buildCard("Seviye", level),
                    const SizedBox(height: 30),

                    const Text(
                      "Koleksiyon Dağılımı",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: totalCollection == 0
                          ? const Center(
                              child: Text(
                                "Grafik için yeterli veri yok.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(
                                    value: totalCoins.toDouble(),
                                    title: "Para ($totalCoins)",
                                    color: Colors.blueAccent,
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: totalStamps.toDouble(),
                                    title: "Pul ($totalStamps)",
                                    color: AppColors.gold,
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: totalGems.toDouble(),
                                    title: "Taş ($totalGems)",
                                    color: Colors.purpleAccent,
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 40),

                    const Text(
                      "Favori Analizi",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: totalCollection == 0
                          ? const Center(
                              child: Text(
                                "Grafik için yeterli veri yok.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(
                                    value: favorites.toDouble(),
                                    title: "Favori ($favorites)",
                                    color: Colors.redAccent,
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: (totalCollection - favorites)
                                        .toDouble(),
                                    title:
                                        "Diğer (${totalCollection - favorites})",
                                    color: Colors.grey,
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 40),

                    const Text(
                      "Kategori Değerleri (TL)",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  String text = '';
                                  switch (value.toInt()) {
                                    case 0:
                                      text = 'Hatıra Para';
                                      break;
                                    case 1:
                                      text = 'Pul';
                                      break;
                                    case 2:
                                      text = 'Taşlar';
                                      break;
                                  }
                                  // SideTitleWidget yerine hata vermeyen standart Padding yapısı kullanıldı
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      top: 6.0,
                                    ), // Çubukla yazı arasındaki boşluk
                                    child: Text(
                                      text,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: coinList
                                      .fold(0, (sum, item) => sum + item.value)
                                      .toDouble(),
                                  color: Colors.blueAccent,
                                  width: 18,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: stampList
                                      .fold(0, (sum, item) => sum + item.value)
                                      .toDouble(),
                                  color: AppColors.gold,
                                  width: 18,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 2,
                              barRods: [
                                BarChartRodData(
                                  toY: gemList
                                      .fold(0, (sum, item) => sum + item.value)
                                      .toDouble(),
                                  color: Colors.purpleAccent,
                                  width: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),

                    if (mostExpensive != null)
                      buildCard(
                        "En Değerli Ürün",
                        "${mostExpensive.name} (${mostExpensive.value} TL)",
                      ),
                    const SizedBox(height: 20),

                    LinearProgressIndicator(
                      value: (totalCollection / 50).clamp(0, 1),
                      minHeight: 14,
                      backgroundColor: Colors.white10,
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    const SizedBox(height: 35),

                    const Text(
                      "Son Eklenenler",
                      style: TextStyle(
                        fontSize: 22,
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    recentItems.isEmpty
                        ? const Text(
                            "Henüz ürün eklenmemiş.",
                            style: TextStyle(color: Colors.grey),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recentItems.length,
                            itemBuilder: (context, index) {
                              final item = recentItems[index];
                              return Card(
                                color: AppColors.cardBlack,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.history,
                                    color: AppColors.gold,
                                  ),
                                  title: Text(
                                    item.name,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    "${item.value} TL",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 35),

                    const SizedBox(height: 15),

                    const SizedBox(height: 25),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildCard(String title, String value) {
    return Card(
      color: AppColors.cardBlack,
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Text(
          value,
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniFinanceCard(String title, String foreignValue) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBlack,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            foreignValue,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
