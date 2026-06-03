import 'package:flutter/material.dart';
import '../../models/collection_item.dart';
import '../../core/theme/app_colors.dart';

class CoinDetailScreen extends StatelessWidget {
  final CollectionItem coin;

  const CoinDetailScreen({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(coin.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Geliştirilmiş Görsel Alanı
            Center(
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withAlpha(30),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: _buildDetailImage(coin.imagePath),
                ),
              ),
            ),
            const SizedBox(height: 35),

            if (coin.description.isNotEmpty) ...[
              const Text(
                "Para Açıklaması",
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                coin.description,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 25),
            ],

            const Text(
              "Koleksiyon Detayları",
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildDetailCard(
              "Darphane Yılı",
              coin.year.toString(),
              Icons.calendar_today,
            ),
            _buildDetailCard("Kondisyon / Durum", coin.condition, Icons.grade),
            _buildDetailCard("Metal / Materyal", coin.material, Icons.category),
            _buildDetailCard(
              "Nadirliği",
              coin.rarity,
              Icons.star_purple500_outlined,
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.cardBlack, AppColors.gold.withAlpha(20)],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.gold.withAlpha(80)),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.gold,
                ),
                title: const Text(
                  "Tahmini Değer",
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Text(
                  "${coin.value} TL",
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Detay ekranı için güvenli resim yükleyici
  Widget _buildDetailImage(String path) {
    if (path.isEmpty) {
      return Container(
        color: Colors.black26,
        child: Icon(Icons.monetization_on, color: AppColors.gold, size: 120),
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.black45,
            padding: const EdgeInsets.all(15),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off, color: Colors.orangeAccent, size: 50),
                SizedBox(height: 8),
                Text(
                  "Resim Linki Geçersiz",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          );
        },
      );
    }
    // Eğer internet linki değilse varsayılan ikon göster
    return Container(
      color: Colors.black26,
      child: Icon(Icons.monetization_on, color: AppColors.gold, size: 120),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBlack,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white54, size: 22),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
