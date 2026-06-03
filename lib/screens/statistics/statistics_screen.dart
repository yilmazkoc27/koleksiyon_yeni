import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/coin_service.dart';
import '../../services/stamp_service.dart';
import '../../services/gem_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/collection_item.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int totalCoins = CoinService.coinList.length;
    int totalStamps = StampService.stampList.length;
    int totalGems = GemService.gemsList.length;
    int totalCollection = totalCoins + totalStamps + totalGems;

    List<CollectionItem> allItems = [
      ...CoinService.coinList,
      ...StampService.stampList,
      ...GemService.gemsList,
    ];
    List<CollectionItem> recentItems = allItems.reversed.take(5).toList();

    int favorites = allItems.where((e) => e.isFavorite).length;

    int totalValue = allItems.fold(0, (sum, item) => sum + item.value);

    CollectionItem? mostExpensive;

    if (allItems.isNotEmpty) {
      allItems.sort((a, b) => b.value.compareTo(a.value));

      mostExpensive = allItems.first;
    }

    String level = "Başlangıç";

    if (totalCollection >= 10) {
      level = "Koleksiyoner";
    }

    if (totalCollection >= 30) {
      level = "Uzman";
    }

    if (totalCollection >= 50) {
      level = "Efsane";
    }
    List<String> achievements = [];

    if (totalCollection >= 5) {
      achievements.add("🏆 İlk Koleksiyon");
    }

    if (totalCollection >= 10) {
      achievements.add("⭐ Koleksiyoner");
    }

    if (totalCollection >= 25) {
      achievements.add("🔥 Uzman Koleksiyoncu");
    }

    if (totalCollection >= 50) {
      achievements.add("👑 Efsane Koleksiyoncu");
    }

    if (totalValue >= 50000) {
      achievements.add("💰 Zengin Koleksiyon");
    }

    if (favorites >= 10) {
      achievements.add("❤️ Favori Ustası");
    }

    return Scaffold(
      appBar: AppBar(title: const Text("İstatistikler")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            buildCard("Toplam Koleksiyon", totalCollection.toString()),

            buildCard("Toplam Değer", "$totalValue TL"),

            const SizedBox(height: 10),

            Text(
              totalCollection < 10
                  ? "Koleksiyon büyümeye başladı 🚀"
                  : totalCollection < 30
                  ? "Harika ilerliyorsun ⭐"
                  : "Muhteşem koleksiyon 👑",

              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

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
              height: 250,

              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: totalCoins.toDouble(),
                      title: "Para",
                      radius: 80,
                    ),

                    PieChartSectionData(
                      value: totalStamps.toDouble(),
                      title: "Pul",
                      radius: 80,
                    ),

                    PieChartSectionData(
                      value: totalGems.toDouble(),
                      title: "Taş",
                      radius: 80,
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
              height: 250,

              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: favorites.toDouble(),
                      title: "Favori",
                      radius: 80,
                    ),

                    PieChartSectionData(
                      value: (totalCollection - favorites).toDouble(),
                      title: "Diğer",
                      radius: 80,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              "Kategori Değerleri",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),

            SizedBox(
              height: 300,

              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,

                      barRods: [
                        BarChartRodData(
                          toY: CoinService.coinList
                              .fold(0, (sum, item) => sum + item.value)
                              .toDouble(),
                        ),
                      ],
                    ),

                    BarChartGroupData(
                      x: 1,

                      barRods: [
                        BarChartRodData(
                          toY: StampService.stampList
                              .fold(0, (sum, item) => sum + item.value)
                              .toDouble(),
                        ),
                      ],
                    ),

                    BarChartGroupData(
                      x: 2,

                      barRods: [
                        BarChartRodData(
                          toY: GemService.gemsList
                              .fold(0, (sum, item) => sum + item.value)
                              .toDouble(),
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
              minHeight: 18,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 35),
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

            ListView.builder(
              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              itemCount: recentItems.length,

              itemBuilder: (context, index) {
                final item = recentItems[index];

                return Card(
                  color: AppColors.cardBlack,

                  child: ListTile(
                    leading: const Icon(Icons.history, color: AppColors.gold),

                    title: Text(item.name),

                    subtitle: Text("${item.value} TL"),
                  ),
                );
              },
            ),

            const Text(
              "Başarılar",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 100,

              child: ListView.builder(
                scrollDirection: Axis.horizontal,

                itemCount: achievements.length,

                itemBuilder: (context, index) {
                  return Container(
                    width: 180,

                    margin: const EdgeInsets.only(right: 15),

                    decoration: BoxDecoration(
                      color: AppColors.cardBlack,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),

                        child: Text(
                          achievements[index],
                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            Center(
              child: Text(
                "$level Seviyesi",
                style: const TextStyle(color: AppColors.gold, fontSize: 18),
              ),
            ),
          ],
        ),
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
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
