import 'package:flutter/material.dart';
import '../../models/collection_item.dart';
import '../../core/theme/app_colors.dart';
import 'gems_detail_screen.dart';
import 'dart:io';

class GemsAlbumScreen extends StatelessWidget {
  final List<CollectionItem> gemsList;

  const GemsAlbumScreen({super.key, required this.gemsList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Değerli Taş Albümü")),

      body: ListView.builder(
        scrollDirection: Axis.horizontal,

        itemCount: gemsList.length,

        itemBuilder: (context, index) {
          final item = gemsList[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => GemsDetailScreen(item: item)),
              );
            },

            child: Container(
              width: 250,

              margin: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: AppColors.cardBlack,

                borderRadius: BorderRadius.circular(25),

                boxShadow: [
                  BoxShadow(color: AppColors.gold.withGreen(3), blurRadius: 15),
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
                            Icons.monetization_on,
                            color: AppColors.gold,
                            size: 90,
                          ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    item.name,

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 22,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${item.value} TL",

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
