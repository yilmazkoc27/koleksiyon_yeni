import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/user_role.dart';

class BidsListScreen extends StatefulWidget {
  const BidsListScreen({super.key});

  @override
  State<BidsListScreen> createState() => _BidsListScreenState();
}

class _BidsListScreenState extends State<BidsListScreen> {
  // Seçili kategori filtresi: 'Tümü', 'Paralar', 'Pullar', 'Taşlar'
  String _selectedCategory = 'Tümü';

  // Firestore'daki ana koleksiyon haritası ve arayüz etiketleri
  final Map<String, String> _collections = {
    'Paralar': 'Paralar',
    'Pullar': 'Pullar',
    'Taşlar': 'gems', // Veritabanındaki ismi 'gems'
  };

  Future<List<Map<String, dynamic>>> _fetchAllBids() async {
    List<Map<String, dynamic>> allBids = [];
    List<Future<QuerySnapshot>> futures = [];
    List<String> sourceCategories = [];

    for (var entry in _collections.entries) {
      final categoryLabel = entry.key; // Örn: 'Paralar'
      final collectionName = entry.value; // Örn: 'Paralar' veya 'gems'

      final mainSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .get();

      for (var doc in mainSnapshot.docs) {
        futures.add(doc.reference.collection('Teklifler').get());
        sourceCategories.add(categoryLabel);
      }
    }
    final biddingsSnapshots = await Future.wait(futures);

    for (int i = 0; i < biddingsSnapshots.length; i++) {
      final snap = biddingsSnapshots[i];
      final currentCategory = sourceCategories[i];

      for (var doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        allBids.add({
          'docId': doc.id,
          'koleksiyonKategorisi': currentCategory,
          ...data,
        });
      }
    }

    return allBids;
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.gold),
        title: Text(
          UserRole.isAdmin ? "Yönetici Teklif Paneli" : "Verdiğim Teklifler",
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withAlpha(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(12),
                    blurRadius: 90,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchAllBids(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            "Veritabanı alanları taranırken bir senkronizasyon hatası oluştu.\nHata: ${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.gold),
                      );
                    }

                    List<Map<String, dynamic>> allBids = snapshot.data ?? [];
                    List<Map<String, dynamic>> filteredBids = [];
                    if (UserRole.isAdmin) {
                      filteredBids = allBids;
                    } else {
                      filteredBids = allBids
                          .where((bid) => bid['kullaniciId'] == currentUserId)
                          .toList();
                    }
                    if (_selectedCategory != 'Tümü') {
                      filteredBids = filteredBids
                          .where(
                            (bid) =>
                                bid['koleksiyonKategorisi'] ==
                                _selectedCategory,
                          )
                          .toList();
                    }
                    if (filteredBids.isNotEmpty) {
                      filteredBids.sort((a, b) {
                        final Timestamp aTime =
                            a['tarih'] ?? a['teklifTarihi'] ?? Timestamp.now();
                        final Timestamp bTime =
                            b['tarih'] ?? b['teklifTarihi'] ?? Timestamp.now();
                        return bTime.compareTo(
                          aTime,
                        ); // En yeni teklif en üstte
                      });
                    }

                    if (filteredBids.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filteredBids.length,
                      itemBuilder: (context, index) {
                        final bid = filteredBids[index];
                        final String itemName =
                            bid['gemName'] ??
                            bid['tasAdi'] ??
                            bid['pulAdi'] ??
                            bid['paraAdi'] ??
                            'Bilinmeyen Eser';
                        final String itemImage =
                            bid['gemImage'] ??
                            bid['tasResmi'] ??
                            bid['imagePath'] ??
                            '';
                        final String bidAmount =
                            (bid['teklifMiktari'] ?? bid['miktar'] ?? 0)
                                .toString();
                        final String userName =
                            bid['kullaniciAdi'] ??
                            bid['isim'] ??
                            'Koleksiyoner';
                        final String userEmail = bid['kullaniciEmail'] ?? '';
                        final String category =
                            bid['koleksiyonKategorisi'] ?? '';

                        String dateStr = "Tarih Belirtilmedi";
                        final Timestamp? timestamp =
                            bid['tarih'] as Timestamp? ??
                            bid['teklifTarihi'] as Timestamp?;
                        if (timestamp != null) {
                          final DateTime dateTime = timestamp.toDate();
                          dateStr =
                              "${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141414),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.gold.withAlpha(25),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                childrenPadding: const EdgeInsets.all(16),
                                leading: _buildItemImage(itemImage),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        itemName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildCategoryBadge(category),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    UserRole.isAdmin
                                        ? "Teklif: $userName"
                                        : dateStr,
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF261D03),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.gold.withAlpha(80),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    "$bidAmount TL",
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    color: const Color(0xFF1A1A1A),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (UserRole.isAdmin &&
                                            userEmail.isNotEmpty) ...[
                                          _buildDetailRow(
                                            Icons.email_outlined,
                                            "E-Posta: ",
                                            userEmail,
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                        _buildDetailRow(
                                          Icons.access_time_rounded,
                                          "Teklif Zamanı: ",
                                          dateStr,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildDetailRow(
                                          Icons.folder_open_rounded,
                                          "Kategori Grubu: ",
                                          "$category Koleksiyonu",
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final categories = ['Tümü', 'Paralar', 'Pullar', 'Taşlar'];
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.gold : const Color(0xFF161616),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white10,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withAlpha(60),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    Color badgeColor;
    switch (category) {
      case 'Paralar':
        badgeColor = Colors.teal;
        break;
      case 'Pullar':
        badgeColor = Colors.blueAccent;
        break;
      default:
        badgeColor = Colors.purpleAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withAlpha(100), width: 0.5),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildItemImage(String imagePath) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.gold.withAlpha(15),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold.withAlpha(40), width: 1),
      ),
      child: imagePath.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.gavel_rounded,
                  color: AppColors.gold,
                  size: 18,
                ),
              ),
            )
          : const Icon(Icons.gavel_rounded, color: AppColors.gold, size: 18),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gold),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white24,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.gavel_rounded,
            size: 64,
            color: Colors.white.withAlpha(20),
          ),
          const SizedBox(height: 16),
          Text(
            UserRole.isAdmin
                ? "Seçili kategoride henüz hiç teklif yok."
                : "Bu kategoride henüz bir teklifiniz bulunmuyor.",
            style: const TextStyle(color: Colors.white38, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
