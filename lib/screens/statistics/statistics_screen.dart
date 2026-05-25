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

    return Scaffold(
      appBar: AppBar(title: const Text("İstatistikler")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            buildCard("Toplam Koleksiyon", totalCollection.toString()),

            buildCard("Toplam Değer", "$totalValue TL"),

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
