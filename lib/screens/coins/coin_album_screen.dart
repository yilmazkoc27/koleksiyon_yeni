import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../models/collection_item.dart';
import 'coin_detail_screen.dart';

class CoinAlbumScreen extends StatelessWidget {
  const CoinAlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF121212,
      ), // Sayfa arka planı siyah olmasın diye güvenli koyu renk
      appBar: AppBar(
        title: const Text(
          "Hatıra Para Albümü",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // NOT: Firestore'daki koleksiyon adının tam olarak 'Paralar' (büyük P ile) olduğundan emin ol!
        stream: FirebaseFirestore.instance.collection('Paralar').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Siyah ekranda kaybolmasın diye beyaz/kırmızı hata metni
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Firestore Hatası:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Albümde henüz para bulunmuyor.\n(Koleksiyon adını kontrol edin)",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.75,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              int parsedYear = 2023;
              if (data['year'] != null) {
                parsedYear = int.tryParse(data['year'].toString()) ?? 2023;
              }

              final item = CollectionItem(
                name: data['name'] ?? 'İsimsiz Para',
                year: parsedYear,
                rarity: data['rarity'] ?? 'Orta',
                condition: data['condition'] ?? 'Temiz',
                material: data['material'] ?? 'Gümüş',
                value: data['value'] ?? 0,
                description: data['description'] ?? data['detay'] ?? '',
                imagePath: data['imagePath'] ?? '',
                isFavorite: data['isFavorite'] ?? false,
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CoinDetailScreen(coin: item),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBlack,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withAlpha(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: _buildItemImage(item.imagePath),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${item.year} | ${item.value} TL",
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 13,
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
          );
        },
      ),
    );
  }

  // Görsel yükleme hatasını önleyen akıllı metot
  Widget _buildItemImage(String path) {
    if (path.isEmpty) {
      return Container(
        color: Colors.black26,
        child: Icon(Icons.monetization_on, color: AppColors.gold, size: 50),
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.black45,
          child: Icon(Icons.broken_image, color: Colors.orange, size: 40),
        ),
      );
    }
    return Container(
      color: Colors.black26,
      child: Icon(Icons.monetization_on, color: AppColors.gold, size: 50),
    );
  }
}
