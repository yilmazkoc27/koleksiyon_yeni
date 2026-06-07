import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../models/collection_item.dart';
import '../detail/item_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Üç farklı kategori: Para, Pul, Taş
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            "Favorilerim",
            style: TextStyle(color: AppColors.gold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.monetization_on), text: "Paralar"),
              Tab(icon: Icon(Icons.mail), text: "Pullar"),
              Tab(icon: Icon(Icons.diamond), text: "Taşlar"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFavoriteList(
              collectionName: 'Paralar',
              fallbackIcon: Icons.monetization_on,
            ),
            _buildFavoriteList(
              collectionName: 'Pullar',
              fallbackIcon: Icons.mail,
            ),
            _buildFavoriteList(
              collectionName: 'gems',
              fallbackIcon: Icons.diamond,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteList({
    required String collectionName,
    required IconData fallbackIcon,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collectionName)
          .where('isFavorite', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Hata:\n${snapshot.error}",
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
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
              "Favori öge bulunamadı",
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final dataMap = doc.data() as Map<String, dynamic>;
            final item = CollectionItem.fromMap(dataMap, doc.id);

            return Card(
              color: AppColors.cardBlack,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: AppColors.gold.withOpacity(0.1)),
              ),
              child: ListTile(
                leading: item.imagePath.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imagePath,
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(fallbackIcon, color: AppColors.gold, size: 30),
                title: Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "${item.value} TL - Nadirlik: ${item.rarity}",
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.gold,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailScreen(item: item),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
