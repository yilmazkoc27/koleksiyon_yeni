import 'package:flutter/material.dart';

import '../../models/collection_item.dart';

class StampDetailScreen extends StatelessWidget {
  final CollectionItem item;

  const StampDetailScreen({super.key, required this.item});

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

              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text("Açıklama:"),

            Text(item.description),

            const SizedBox(height: 15),

            Text("Nadirlik: ${item.rarity}"),

            Text("Kondisyon: ${item.condition}"),

            Text("Değer: ${item.value} TL"),
          ],
        ),
      ),
    );
  }
}
