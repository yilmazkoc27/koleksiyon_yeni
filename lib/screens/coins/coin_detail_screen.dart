import 'package:flutter/material.dart';
import '../../models/collection_item.dart';
import '../../core/theme/app_colors.dart';

class CoinDetailScreen extends StatelessWidget {
  final CollectionItem coin;

  const CoinDetailScreen({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(coin.name)),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Icon(Icons.monetization_on, size: 130, color: AppColors.gold),

            const SizedBox(height: 30),

            Text(coin.description, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                title: Text("Yıl"),

                trailing: Text(coin.year.toString()),
              ),
            ),

            Card(
              child: ListTile(
                title: Text("Kondisyon"),

                trailing: Text(coin.condition),
              ),
            ),

            Card(
              child: ListTile(
                title: Text("Materyal"),

                trailing: Text(coin.material),
              ),
            ),

            Card(
              child: ListTile(
                title: Text("Tahmini Değer"),

                trailing: Text("${coin.value} TL"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
