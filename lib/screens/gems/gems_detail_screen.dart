import 'package:flutter/material.dart';
import '../../models/collection_item.dart';

class GemsDetailScreen extends StatelessWidget {
  final CollectionItem item;

  const GemsDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              item.name,

              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            const Text("Taş Bilgileri", style: TextStyle(fontSize: 22)),

            const SizedBox(height: 20),

            Text("Açıklama:\n${item.description}"),

            const SizedBox(height: 15),

            Text("Nadirlik: ${item.rarity}"),

            Text("Berraklık: ${item.condition}"),

            Text("Renk Kalitesi: ${item.material}"),

            const SizedBox(height: 20),

            Text(
              "Tahmini Değer: ${item.value} TL",

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
