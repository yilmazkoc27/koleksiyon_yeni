import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/collection_item.dart';
import '../../core/theme/app_colors.dart';

class ItemDetailScreen extends StatelessWidget {
  final CollectionItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage =
        item.imagePath.startsWith('http') || item.imagePath.startsWith('https');

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //-----------------------
            // FOTOĞRAF
            //-----------------------
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: AppColors.cardBlack,
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: item.imagePath.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: isNetworkImage
                          ? Image.network(
                              item.imagePath,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }

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
                                    size: 60,
                                    color: Colors.white30,
                                  ),
                                );
                              },
                            )
                          : Image.file(
                              File(item.imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 60,
                                    color: Colors.white30,
                                  ),
                                );
                              },
                            ),
                    )
                  : const Center(
                      child: Icon(Icons.image, size: 80, color: AppColors.gold),
                    ),
            ),

            const SizedBox(height: 25),

            //-----------------------
            // BAŞLIK
            //-----------------------
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),

            const SizedBox(height: 25),

            buildInfo("Yıl", item.year.toString()),
            buildInfo("Nadirlik", item.rarity),
            buildInfo("Kondisyon", item.condition),
            buildInfo("Materyal / Renk", item.material),
            buildInfo("Tahmini Değer", "${item.value} TL"),

            if (item.carat > 0) buildInfo("Karat", item.carat.toString()),
            if (item.processType.isNotEmpty)
              buildInfo("İşlenme Türü", item.processType),
            if (item.damage.isNotEmpty) buildInfo("Hasar Durumu", item.damage),
            const SizedBox(height: 25),
            const Text(
              "Açıklama",
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              item.description.isEmpty
                  ? "Açıklama bulunmuyor."
                  : item.description,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title : ",
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
