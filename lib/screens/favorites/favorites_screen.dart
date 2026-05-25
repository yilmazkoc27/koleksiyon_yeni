import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/collection_item.dart';

import '../../services/coin_service.dart';
import '../../services/stamp_service.dart';
import '../../services/gem_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  List<CollectionItem> getFavorites() {
    List<CollectionItem> favorites = [];

    favorites.addAll(CoinService.coinList.where((e) => e.isFavorite));

    favorites.addAll(StampService.stampList.where((e) => e.isFavorite));

    favorites.addAll(GemService.gemsList.where((e) => e.isFavorite));

    return favorites;
  }

  @override
  Widget build(BuildContext context) {
    final favorites = getFavorites();

    return Scaffold(
      appBar: AppBar(title: const Text("Favorilerim")),

      body: favorites.isEmpty
          ? const Center(
              child: Text(
                "Henüz favori yok",

                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),

              itemCount: favorites.length,

              itemBuilder: (context, index) {
                final item = favorites[index];

                return Card(
                  color: AppColors.cardBlack,

                  child: ListTile(
                    leading: const Icon(Icons.star, color: AppColors.gold),

                    title: Text(item.name),

                    subtitle: Text("${item.value} TL\n${item.rarity}"),
                  ),
                );
              },
            ),
    );
  }
}
