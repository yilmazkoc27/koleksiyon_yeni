import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/collection_item.dart';
import 'coin_detail_screen.dart';
import 'dart:io';

class CoinAlbumScreen extends StatelessWidget {
  final List<CollectionItem> coins;

  const CoinAlbumScreen({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hatıra Para Albümü")),

      body: ListView.builder(
        scrollDirection: Axis.horizontal,

        itemCount: coins.length,

        itemBuilder: (context, index) {
          final item = coins[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => CoinDetailScreen(coin: item)),
              );
            },

            child: Container(
              width: 260,

              margin: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: AppColors.cardBlack,

                borderRadius: BorderRadius.circular(30),

                boxShadow: [
                  BoxShadow(color: AppColors.gold.withBlue(2), blurRadius: 20),
                ],
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Container(
                    height: 200,
                    width: 200,

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
                            Icons.monetization_on,
                            color: AppColors.gold,
                            size: 90,
                          ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    item.name,

                    style: const TextStyle(
                      fontSize: 22,

                      color: Colors.white,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${item.year}",

                    style: const TextStyle(color: AppColors.gold, fontSize: 18),
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
