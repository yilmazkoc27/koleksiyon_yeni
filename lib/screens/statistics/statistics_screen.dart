import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/collection_item.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  // Üç farklı koleksiyondan verileri asenkron olarak çeken yardımcı fonksiyon
  Future<Map<String, List<CollectionItem>>> _fetchAllData() async {
    final firestore = FirebaseFirestore.instance;

    final results = await Future.wait([
      firestore.collection('Paralar').get(),
      firestore.collection('Pullar').get(),
      firestore.collection('gems').get(),
    ]);

    // Satırlar aşağıya kırıldı ve Firestore verisi güvenli şekilde map edildi:
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
      backgroundColor: Colors.black, // Koyu tema uyumu için eklendi
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
                "Hata oluştu: ${snapshot.error}",
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

          // Veriler başarıyla geldi, listeleri eşitleyelim
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

          // Son eklenen 5 ürünü bulmak için (id veya eklenme sırasına göre) sıralama yapabilirsiniz
          List<CollectionItem> recentItems = allItems.reversed.take(5).toList();

          int favorites = allItems.where((e) => e.isFavorite).length;
          int totalValue = allItems.fold(0, (sum, item) => sum + item.value);

          CollectionItem? mostExpensive;
          if (allItems.isNotEmpty) {
            // Orijinal listeyi bozmamak için kopyasını sıralıyoruz
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

          return SingleChildScrollView(
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
                    color: Colors
                        .white70, // Siyah ekranda görünmesi için beyaza çekildi
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
                                value: (totalCollection - favorites).toDouble(),
                                title: "Diğer (${totalCollection - favorites})",
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
                      titlesData: const FlTitlesData(
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
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
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 25),

                const Text(
                  "Başarılar",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 15),
                achievements.isEmpty
                    ? const Text(
                        "Henüz kazanılan başarı yok.",
                        style: TextStyle(color: Colors.grey),
                      )
                    : SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: achievements.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              margin: const EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                color: AppColors.cardBlack,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Center(
                                child: Text(
                                  achievements[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                const SizedBox(height: 25),
                Center(
                  child: Text(
                    "$level Seviyesi",
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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
}
