import 'package:flutter/material.dart';
import 'package:koleksiyon_yeni/screens/gems/gems_screen.dart';
import '../../core/theme/app_colors.dart';
import '../coins/coin_screen.dart';
import '../stamps/stamp_screen.dart';
import '../statistics/statistics_screen.dart';
import '../favorites/favorites_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collectify"),

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),

            child: CircleAvatar(
              backgroundColor: AppColors.gold,

              child: Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 140,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),

                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
                ),
              ),

              child: const Center(
                child: Text(
                  "Toplam Koleksiyon\n127",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.black,

                    fontSize: 24,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,

                crossAxisSpacing: 15,

                mainAxisSpacing: 15,

                children: [
                  buildCard(context, "Hatıra Para", Icons.monetization_on),
                  buildCard(context, "Pul", Icons.mail),
                  buildCard(context, "Değerli Taşlar", Icons.diamond),
                  buildCard(context, "İstatistik", Icons.bar_chart),
                  buildCard(context, "Favoriler", Icons.star),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (title == "Hatıra Para") {
          Navigator.push(
            context,

            MaterialPageRoute(builder: (_) => const CoinScreen()),
          );
        } else if (title == "Pul") {
          Navigator.push(
            context,

            MaterialPageRoute(builder: (_) => const StampScreen()),
          );
        } else if (title == "Değerli Taşlar") {
          Navigator.push(
            context,

            MaterialPageRoute(builder: (_) => const GemsScreen()),
          );
        } else if (title == "İstatistik") {
          Navigator.push(
            context,

            MaterialPageRoute(builder: (_) => const StatisticsScreen()),
          );
        } else if (title == "Favoriler") {
          Navigator.push(
            context,

            MaterialPageRoute(builder: (_) => const FavoritesScreen()),
          );
        }
      },

      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBlack,

          borderRadius: BorderRadius.circular(25),

          boxShadow: [
            BoxShadow(color: AppColors.gold.withBlue(2), blurRadius: 18),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, color: AppColors.gold, size: 50),

            const SizedBox(height: 15),

            Text(
              title,

              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
