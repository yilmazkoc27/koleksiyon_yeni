import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/collection_item.dart';
import '../../core/theme/app_colors.dart';

class ItemDetailScreen extends StatelessWidget {
  final CollectionItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              height: 250,
              width: double.infinity,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),

                color: AppColors.cardBlack,
              ),

              child: item.imagePath.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25),

                      child: Image.file(
                        File(item.imagePath),

                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.image, size: 80),
            ),

            const SizedBox(height: 25),

            Text(
              item.name,

              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,

                color: AppColors.gold,
              ),
            ),

            const SizedBox(height: 20),

            buildInfo("Yıl", item.year.toString()),

            buildInfo("Nadirlik", item.rarity),

            buildInfo("Kondisyon", item.condition),

            buildInfo("Materyal", item.material),

            buildInfo("Değer", "${item.value} TL"),

            const SizedBox(height: 25),

            const Text(
              "Açıklama",

              style: TextStyle(color: AppColors.gold, fontSize: 22),
            ),

            const SizedBox(height: 10),

            Text(item.description),
          ],
        ),
      ),
    );
  }

  Widget buildInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        children: [
          Text(
            "$title : ",

            style: const TextStyle(
              color: AppColors.gold,

              fontWeight: FontWeight.bold,
            ),
          ),

          Text(value),
        ],
      ),
    );
  }
}
