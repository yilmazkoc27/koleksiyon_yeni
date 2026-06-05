import 'package:flutter/material.dart';
import '../../models/collection_item.dart';
import '../../core/theme/app_colors.dart';
import 'stamp_detail_screen.dart';

class StampAlbumScreen extends StatelessWidget {
  final List<CollectionItem> stampList;

  const StampAlbumScreen({super.key, required this.stampList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pul Albümü")),
      body: stampList.isEmpty
          ? const Center(
              child: Text(
                "Albümde henüz pul bulunmuyor.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              // Yan yana 2 kart göstermek için SliverGridDelegate kullanıyoruz
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Yan yana kaç kart olacak
                crossAxisSpacing: 12, // Kartlar arası yatay boşluk
                mainAxisSpacing: 12, // Kartlar arası dikey boşluk
                childAspectRatio:
                    0.75, // Kartların en/boy oranı (Genişlik / Yükseklik)
              ),
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
                    // GridView içinde width/height zorunlu olmadığından kaldırıldı, oran childAspectRatio ile yönetiliyor
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
                        Expanded(
                          // Resmin kart içinde taşmasını önler ve düzgün yayılmasını sağlar
                          child: Container(
                            margin: const EdgeInsets.only(
                              top: 12,
                              left: 12,
                              right: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black26,
                            ),
                            child: item.imagePath.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      item.imagePath,
                                      fit: BoxFit.cover,
                                      width: double
                                          .infinity, // Kapsayıcıyı doldursun
                                      height: double.infinity,
                                      // Resim yüklenirken dönen yükleme ikonu:
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.gold,
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.redAccent,
                                                size: 40,
                                              ),
                                            );
                                          },
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.mail_outline,
                                      color: AppColors.gold,
                                      size: 50,
                                    ),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                          child: Column(
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow
                                    .ellipsis, // Uzun isimler kartı patlatmasın
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${item.value} TL",
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
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
