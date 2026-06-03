import 'package:flutter/material.dart';
import '../../models/collection_item.dart';
import '../../core/theme/app_colors.dart';

class StampDetailScreen extends StatelessWidget {
  final CollectionItem item;

  const StampDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // Varsa kendi arka plan rengini de verebilirsin
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Pul Görsel Alanı
              Center(
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardBlack,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: AppColors.gold.withAlpha(40),
                      width: 1,
                    ),
                  ),
                  child: item.imagePath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          // Image.file yerine Image.network kullanarak Firebase URL'lerini yüklüyoruz
                          child: Image.network(
                            item.imagePath,
                            fit: BoxFit
                                .contain, // Pulun formunu bozmamak için contain kalması harika bir tercih
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.redAccent,
                                  size: 60,
                                ),
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.mail_outline,
                          color: AppColors.gold,
                          size: 120,
                        ),
                ),
              ),
              const SizedBox(height: 25),

              // 2. Pul Adı
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              // 3. Değer Bilgisi (Öne Çıkan)
              Text(
                "${item.value} TL",
                style: const TextStyle(
                  fontSize: 22,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(color: Colors.grey, height: 30, thickness: 0.5),

              // 4. Özellikler Satırı (Nadirlik ve Kondisyon)
              Row(
                children: [
                  _buildInfoBadge("Nadirlik", item.rarity),
                  const SizedBox(width: 15),
                  _buildInfoBadge("Kondisyon", item.condition),
                ],
              ),
              const SizedBox(height: 25),

              // 5. Açıklama Alanı
              const Text(
                "Açıklama",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description.isNotEmpty
                    ? item.description
                    : "Açıklama belirtilmemiş.",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Özellikleri şık kutucuklar halinde göstermek için yardımcı fonksiyon
  Widget _buildInfoBadge(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBlack,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
