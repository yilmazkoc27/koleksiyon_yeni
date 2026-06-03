import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/collection_item.dart';

class GemsDetailScreen extends StatelessWidget {
  final CollectionItem item;

  const GemsDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Temaya uygun koyu arka plan
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //-----------------------
            // ***** BÜYÜK FOTOĞRAF ALANI ****
            //-----------------------
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardBlack,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.gold.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: item.imagePath.isNotEmpty
                  ? Image.network(
                      item.imagePath,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white30,
                            size: 60,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.diamond,
                        color: AppColors.gold,
                        size: 80,
                      ),
                    ),
            ),

            //-----------------------
            // ***** BİLGİ VE DETAYLAR ALANI ****
            //-----------------------
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Tahmini Değer: ${item.value} TL",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    "Taş Bilgileri",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 20),

                  // Bilgileri düzenli bir kart yapısı (Tile) içinde gösteriyoruz
                  _buildDetailTile(
                    Icons.info_outline,
                    "Açıklama",
                    item.description.isEmpty
                        ? "Açıklama belirtilmemiş."
                        : item.description,
                  ),
                  _buildDetailTile(
                    Icons.star_border,
                    "Nadirlik Durumu",
                    item.rarity,
                  ),
                  _buildDetailTile(
                    Icons.layers_outlined,
                    "Berraklık (Clarity)",
                    item.condition,
                  ),
                  _buildDetailTile(
                    Icons.palette_outlined,
                    "Renk Kalitesi",
                    item.material,
                  ),
                  _buildDetailTile(
                    Icons.fitness_center,
                    "Karat / Boyut Değeri",
                    "${item.year} Ct",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Detay satırlarını şık göstermek için yardımcı Widget
  Widget _buildDetailTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.gold, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
