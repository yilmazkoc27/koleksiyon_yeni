import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../models/collection_item.dart';
import '../../core/services/user_role.dart';

class CoinDetailScreen extends StatefulWidget {
  final CollectionItem coin;

  const CoinDetailScreen({super.key, required this.coin});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  final TextEditingController _bidController = TextEditingController();
  bool _isBidLoading = false;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Maskeleme Fonksiyonu: Sunumda kullanıcı e-postalarını gizlemeye yarar.
  String _maskEmail(String? email) {
    if (email == null || !email.contains('@')) return 'Bilinmeyen Kullanıcı';
    final parts = email.split('@');
    if (parts[0].length <= 1) return email;
    return "${parts[0][0]}***@${parts[1]}";
  }

  //  Teklif Verme Fonksiyonu
  Future<void> _placeBid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("Lütfen önce giriş yapın!", AppColors.error);
      return;
    }

    if (widget.coin.docId == null || widget.coin.docId!.isEmpty) {
      _showSnackBar(
        "Hata: Ürünün veritabanı ID'si (docId) eksik!",
        AppColors.error,
      );
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
          .collection('Paralar')
          .doc(widget.coin.docId)
          .collection('Teklifler')
          .add({
            'kullaniciId': user.uid,
            'kullaniciEmail': user.email,
            'teklifMiktari': bidAmount,
            'gemName': widget.coin.name,
            'gemImage': widget.coin.imagePath,
            'tarih': FieldValue.serverTimestamp(),
          });

      _bidController.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
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

  //  Teklif Silme Fonksiyonu
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
            .collection('Paralar')
            .doc(widget.coin.docId)
            .collection('Teklifler')
            .doc(bidId)
            .delete();
        _showSnackBar("🗑️ Teklifiniz başarıyla silindi.", AppColors.success);
      } catch (e) {
        _showSnackBar("Teklif silinirken hata oluştu: $e", AppColors.error);
      }
    }
  }

  //  Teklif Düzenleme (Güncelleme) Fonksiyonu
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

                      Navigator.pop(context);

                      try {
                        await FirebaseFirestore.instance
                            .collection('Paralar')
                            .doc(widget.coin.docId)
                            .collection('Teklifler')
                            .doc(bidId)
                            .update({
                              'teklifMiktari': newAmount,
                              'tarih': FieldValue.serverTimestamp(),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withAlpha(100),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.gold,
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BÜYÜK FOTOĞRAF ALANI
            Container(
              height: 380,
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: widget.coin.imagePath.isNotEmpty
                        ? Image.network(
                            widget.coin.imagePath,
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
                                  Icons.broken_image_rounded,
                                  color: AppColors.textMuted,
                                  size: 60,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.monetization_on_rounded,
                              color: AppColors.gold,
                              size: 90,
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(80),
                            Colors.transparent,
                            Colors.black.withAlpha(180),
                            Colors.black,
                          ],
                          stops: const [0.0, 0.4, 0.85, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // BİLGİ VE DETAYLAR ALANI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    widget.coin.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF2E7D32).withAlpha(80),
                      ),
                    ),
                    child: Text(
                      "Tahmini Değer: ${widget.coin.value} TL",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // PARA BİLGİLERİ BAŞLIĞI
                  Row(
                    children: [
                      const Icon(
                        Icons.blur_on,
                        color: AppColors.gold,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Para Detayları".toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.white10,
                    height: 20,
                    thickness: 1,
                  ),
                  const SizedBox(height: 8),

                  _buildDetailTile(
                    Icons.info_outline_rounded,
                    "Açıklama",
                    widget.coin.description.isEmpty
                        ? "Açıklama belirtilmemiş."
                        : widget.coin.description,
                  ),
                  _buildDetailTile(
                    Icons.calendar_today_rounded,
                    "Darphane Yılı",
                    widget.coin.year.toString(),
                  ),
                  _buildDetailTile(
                    Icons.star_border_rounded,
                    "Nadirlik Durumu",
                    widget.coin.rarity,
                  ),
                  _buildDetailTile(
                    Icons.verified_outlined,
                    "Kondisyon / Durum",
                    widget.coin.condition,
                  ),
                  _buildDetailTile(
                    Icons.category_rounded,
                    "Metal / Materyal",
                    widget.coin.material,
                  ),

                  const SizedBox(height: 35),

                  // TEKLİF & DEĞERLEME SİSTEMİ ARAYÜZÜ
                  Row(
                    children: [
                      const Icon(
                        Icons.gavel_rounded,
                        color: AppColors.gold,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Verilen Teklifler".toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.white10,
                    height: 20,
                    thickness: 1,
                  ),
                  const SizedBox(height: 8),

                  if (widget.coin.docId == null ||
                      widget.coin.docId!.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withAlpha(70),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Veritabanı Hatası: 'docId' eksik.",
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Paralar')
                            .doc(widget.coin.docId)
                            .collection('Teklifler')
                            .orderBy('teklifMiktari', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            print("🔥 FIRESTORE HATASI: ${snapshot.error}");
                            return const Text(
                              "Teklifler yüklenirken teknik bir hata oluştu.",
                              style: TextStyle(color: AppColors.error),
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
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "Bu esere henüz bir teklif verilmemiş. İlk teklifi siz sunun!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
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

                              // Korumalı yetki kontrolü
                              final bool isOwnerOrAdmin =
                                  (_currentUserId == bidUserUid) ||
                                  UserRole.isAdmin;
                              final bool isOnlyOwner =
                                  (_currentUserId == bidUserUid);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
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

                  const SizedBox(height: 30),

                  // TEKLİF GİRİŞ PANELİ
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
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
                              hintText: "Teklif miktarını girin (TL)",
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isBidLoading ? null : _placeBid,
                            child: _isBidLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2.5,
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
