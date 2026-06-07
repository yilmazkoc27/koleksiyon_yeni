import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../models/collection_item.dart';
import '../../core/services/user_role.dart';

class GemsDetailScreen extends StatefulWidget {
  final CollectionItem item;

  const GemsDetailScreen({super.key, required this.item});

  @override
  State<GemsDetailScreen> createState() => _GemsDetailScreenState();
}

class _GemsDetailScreenState extends State<GemsDetailScreen> {
  final TextEditingController _bidController = TextEditingController();
  bool _isBidLoading = false;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Maskeleme Fonksiyonu:kullanıcı e-postalarını gizleme
  String _maskEmail(String? email) {
    if (email == null || !email.contains('@')) return 'Bilinmeyen Kullanıcı';
    final parts = email.split('@');
    if (parts[0].length <= 1) return email;
    return "${parts[0][0]}***@${parts[1]}";
  }

  //Teklif Verme Fonksiyonu
  Future<void> _placeBid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("Lütfen önce giriş yapın!", AppColors.error);
      return;
    }

    if (widget.item.docId == null || widget.item.docId!.isEmpty) {
      _showSnackBar("Hata: Ürünün veritabanı ID'si eksik!", AppColors.error);
      return;
    }

    final String bidText = _bidController.text.trim();
    if (bidText.isEmpty) {
      _showSnackBar(
        "Lütfen geçerli bir teklif miktarı girin!",
        AppColors.amber,
      );
      return;
    }

    final double? bidAmount = double.tryParse(bidText);
    if (bidAmount == null || bidAmount <= 0) {
      _showSnackBar("Lütfen pozitif bir sayı giriniz!", AppColors.amber);
      return;
    }

    setState(() {
      _isBidLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('gems')
          .doc(widget.item.docId)
          .collection('Teklifler')
          .add({
            'kullaniciId': user.uid,
            'kullaniciEmail': user.email,
            'teklifMiktari': bidAmount,
            'gemName': widget.item.name,
            'gemImage': widget.item.imagePath,
            'tarih': FieldValue.serverTimestamp(),
            'teklifTarihi': FieldValue.serverTimestamp(),
          });

      _bidController.clear();
      FocusScope.of(context).unfocus();
      _showSnackBar("🎯 Teklifiniz başarıyla iletildi!", AppColors.success);
    } catch (e) {
      _showSnackBar("Teklif verilirken hata oluştu: $e", AppColors.error);
    } finally {
      if (mounted) {
        setState(() {
          _isBidLoading = false;
        });
      }
    }
  }

  // Teklif Silme Fonksiyonu
  Future<void> _deleteBid(String bidId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        title: const Text(
          "Teklifi Sil",
          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Bu teklifi geri çekmek istediğinize emin misiniz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Vazgeç",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text("Sil"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('gems')
            .doc(widget.item.docId)
            .collection('Teklifler')
            .doc(bidId)
            .delete();
        _showSnackBar("🗑️ Teklifiniz başarıyla silindi.", AppColors.success);
      } catch (e) {
        _showSnackBar("Teklif silinirken hata oluştu: $e", AppColors.error);
      }
    }
  }

  // Teklif Düzenleme (Güncelleme) Fonksiyonu
  void _editBid(String bidId, double currentAmount) {
    final TextEditingController editController = TextEditingController(
      text: currentAmount.toStringAsFixed(0),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Teklifinizi Güncelleyin",
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: editController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: "Yeni teklif miktarı (TL)",
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "İptal",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final String newText = editController.text.trim();
                      final double? newAmount = double.tryParse(newText);

                      if (newAmount == null || newAmount <= 0) {
                        _showSnackBar(
                          "Lütfen geçerli bir miktar girin!",
                          AppColors.amber,
                        );
                        return;
                      }

                      Navigator.pop(context); // Paneli kapat

                      try {
                        await FirebaseFirestore.instance
                            .collection('gems')
                            .doc(widget.item.docId)
                            .collection('Teklifler')
                            .doc(bidId)
                            .update({
                              'teklifMiktari': newAmount,
                              'tarih':
                                  FieldValue.serverTimestamp(), // Güncellenme tarihini yeniler
                            });
                        _showSnackBar(
                          "✏️ Teklifiniz başarıyla güncellendi.",
                          AppColors.success,
                        );
                      } catch (e) {
                        _showSnackBar(
                          "Güncelleme başarısız: $e",
                          AppColors.error,
                        );
                      }
                    },
                    child: const Text("Güncelle"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.item.name),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.gold,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ PREMIUM FOTOĞRAF ALANI
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.gold.withAlpha(40),
                    width: 1,
                  ),
                ),
              ),
              child: widget.item.imagePath.isNotEmpty
                  ? Image.network(
                      widget.item.imagePath,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: AppColors.textMuted,
                            size: 60,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.diamond,
                        color: AppColors.gold,
                        size: 80,
                      ),
                    ),
            ),

            // BİLGİ VE DETAYLAR ALANI
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Tahmini Değer: ${widget.item.value} TL",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32), // Güven veren lüks yeşil
                    ),
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    "Taş Bilgileri",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 20),

                  _buildDetailTile(
                    Icons.info_outline,
                    "Açıklama",
                    widget.item.description.isEmpty
                        ? "Açıklama belirtilmemiş."
                        : widget.item.description,
                  ),
                  _buildDetailTile(
                    Icons.star_border,
                    "Nadirlik Durumu",
                    widget.item.rarity,
                  ),
                  _buildDetailTile(
                    Icons.layers_outlined,
                    "Berraklık (Clarity)",
                    widget.item.condition,
                  ),
                  _buildDetailTile(
                    Icons.palette_outlined,
                    "Renk Kalitesi",
                    widget.item.material,
                  ),
                  _buildDetailTile(
                    Icons.fitness_center,
                    "Karat / Boyut Değeri",
                    "${widget.item.carat} Ct",
                  ),

                  const SizedBox(height: 35),

                  // TEKLİF & DEĞERLEME LİSTESİ ALANI
                  const Text(
                    "Verilen Teklifler ve Değerlemeler",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 20),

                  if (widget.item.docId == null ||
                      widget.item.docId!.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withAlpha(60),
                        ),
                      ),
                      child: const Text(
                        "⚠️ Veritabanı Hatası: Ürünün 'docId' değeri bulunamadı!",
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('gems')
                            .doc(widget.item.docId)
                            .collection('Teklifler')
                            .orderBy(
                              'teklifMiktari',
                              descending: true,
                            ) // Teklifleri yüksekten düşüğe dizer
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                              "Hata oluştu: ${snapshot.error}",
                              style: const TextStyle(color: AppColors.error),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.gold,
                              ),
                            );
                          }

                          final biddings = snapshot.data?.docs ?? [];

                          if (biddings.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text(
                                "Bu esere henüz bir teklif veya değer biçilmemiş. İlk teklifi siz verin!",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: biddings.length,
                            itemBuilder: (context, index) {
                              final doc = biddings[index];
                              final bidData =
                                  doc.data() as Map<String, dynamic>;
                              final String bidId = doc.id;

                              final String bidUserUid =
                                  bidData['kullaniciId'] ?? '';
                              final String userEmail = _maskEmail(
                                bidData['kullaniciEmail'],
                              );
                              final double amount =
                                  (bidData['teklifMiktari'] ?? 0.0).toDouble();

                              // Korumalı yetki kontrolü: Teklif sahibi mi veya Admin mi?
                              final bool isOwnerOrAdmin =
                                  (_currentUserId == bidUserUid) ||
                                  UserRole.isAdmin;
                              final bool isOnlyOwner =
                                  (_currentUserId == bidUserUid);

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(10),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  leading: const Icon(
                                    Icons.gavel_rounded,
                                    color: AppColors.gold,
                                    size: 20,
                                  ),
                                  title: Text(
                                    userEmail,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${amount.toStringAsFixed(0)} TL",
                                        style: const TextStyle(
                                          color: AppColors.gold,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (isOwnerOrAdmin) ...[
                                        const SizedBox(width: 8),
                                        // Sadece teklif sahibi güncelleyebilir
                                        if (isOnlyOwner)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_rounded,
                                              color: AppColors.textSecondary,
                                              size: 18,
                                            ),
                                            onPressed: () =>
                                                _editBid(bidId, amount),
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                          ),
                                        if (isOnlyOwner)
                                          const SizedBox(width: 10),
                                        // Teklif sahibi veya Admin silebilir
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: AppColors.error,
                                            size: 18,
                                          ),
                                          onPressed: () => _deleteBid(bidId),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _bidController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: "Teklif/Değer girin (TL)",
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isBidLoading ? null : _placeBid,
                            child: _isBidLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Teklif Ver"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.gold, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
