import 'package:flutter/material.dart';
import '../../models/collection_item.dart';
import '../../core/theme/app_colors.dart';
import 'stamp_detail_screen.dart';
import 'dart:io';

class StampAlbumScreen extends StatelessWidget {
  final List<CollectionItem> stampList;

  const StampAlbumScreen({super.key, required this.stampList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pul Albümü")),
      // Eğer liste boşsa kullanıcıya bilgi veriyoruz, doluysa albümü diziyoruz
      body: stampList.isEmpty
          ? const Center(
              child: Text(
                "Albümde henüz pul bulunmuyor.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stampList.length,
              itemBuilder: (context, index) {
                final item = stampList[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StampDetailScreen(item: item),
                      ),
                    );
                  },
                  child: Container(
                    width: 250,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBlack,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withAlpha(5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black26,
                          ),
                          child: item.imagePath.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(
                                    File(item.imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .mail_outline, // Para ikonu yerine pulu andıran zarf/posta ikonu
                                  color: AppColors.gold,
                                  size: 90,
                                ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "${item.value} TL",
                          style: const TextStyle(color: AppColors.gold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
