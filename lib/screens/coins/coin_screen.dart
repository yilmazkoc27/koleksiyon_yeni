import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import '../../core/theme/app_colors.dart';
import '../../core/utils/value_calculator.dart';
import '../../models/collection_item.dart';
import 'coin_album_screen.dart';
import '../../core/services/user_role.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'coin_detail_screen.dart'; // 👈 DOĞRU DETAY SAYFASI İMPORT EDİLDİ

class FirestoreCoinModel {
  final String docId;
  final CollectionItem coin;
  FirestoreCoinModel({required this.docId, required this.coin});
}

class CoinScreen extends StatefulWidget {
  const CoinScreen({super.key});

  @override
  State<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends State<CoinScreen> {
  int estimatedValue = 0;
  String? selectedDocId;
  int totalValue = 0;
  int averageValue = 0;
  bool ascending = true;
  bool _isUploading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  String rarity = "Orta";
  String condition = "Temiz";
  String material = "Gümüş";
  String filterRarity = "Tümü";
  String currentImageUrl = "";

  File? selectedImage;

  @override
  void dispose() {
    nameController.dispose();
    yearController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    try {
      String fileName = p.basename(imageFile.path);
      String uniqueFileName =
          "${DateTime.now().millisecondsSinceEpoch}_$fileName";

      Reference storageRef = FirebaseStorage.instance.ref().child(
        'madeni_paralar/$uniqueFileName',
      );
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Storage Yükleme Hatası: $e");
      return "";
    }
  }

  Future<void> _addCoinToFirestore() async {
    if (nameController.text.trim().isEmpty ||
        yearController.text.trim().isEmpty) {
      _showSnackBar("Lütfen isim ve yıl alanlarını doldurun!", Colors.orange);
      return;
    }

    setState(() => _isUploading = true);

    try {
      String uploadedUrl = "";
      if (selectedImage != null) {
        uploadedUrl = await _uploadImageToStorage(selectedImage!);
      }

      int year = int.tryParse(yearController.text) ?? 2023;

      await FirebaseFirestore.instance.collection('Paralar').add({
        'name': nameController.text.trim(),
        'year': year,
        'rarity': rarity,
        'condition': condition,
        'material': material,
        'value': estimatedValue,
        'description': descriptionController.text.trim(),
        'imagePath': uploadedUrl,
        'isFavorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _clearForm();
      _showSnackBar("Para başarıyla buluta eklendi!", Colors.green);
    } catch (e) {
      _showSnackBar("Ekleme hatası: $e", Colors.red);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _updateCoinInFirestore() async {
    if (selectedDocId == null) {
      _showSnackBar(
        "Lütfen listeden güncellenecek bir para seçin!",
        Colors.orange,
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String uploadedUrl = currentImageUrl;
      if (selectedImage != null) {
        uploadedUrl = await _uploadImageToStorage(selectedImage!);
      }

      int year = int.tryParse(yearController.text) ?? 2023;

      await FirebaseFirestore.instance
          .collection('Paralar')
          .doc(selectedDocId)
          .update({
            'name': nameController.text.trim(),
            'year': year,
            'rarity': rarity,
            'condition': condition,
            'material': material,
            'value': estimatedValue,
            'description': descriptionController.text.trim(),
            'imagePath': uploadedUrl,
          });

      _clearForm();
      _showSnackBar("Para başarıyla güncellendi!", Colors.green);
    } catch (e) {
      _showSnackBar("Güncelleme hatası: $e", Colors.red);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteCoinFromFirestore(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Paralar')
          .doc(docId)
          .delete();
      if (selectedDocId == docId) {
        _clearForm();
      }
      _showSnackBar("Para başarıyla silindi!", Colors.green);
    } catch (e) {
      _showSnackBar("Silme hatası: $e", Colors.red);
    }
  }

  void _clearForm() {
    setState(() {
      nameController.clear();
      yearController.clear();
      descriptionController.clear();
      selectedImage = null;
      currentImageUrl = "";
      rarity = "Orta";
      condition = "Temiz";
      material = "Gümüş";
      estimatedValue = 0;
      selectedDocId = null;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hatıra Paralar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_album),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CoinAlbumScreen()),
              );
            },
          ),
        ],
      ),
      body: _isUploading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Paralar')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Hata oluştu"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  );
                }

                List<FirestoreCoinModel> allCoins = [];
                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  // 🛠️ BURASI DÜZELDİ: doc.id parametresi model'e paslanıyor!
                  final item = CollectionItem.fromMap(data, doc.id);
                  allCoins.add(FirestoreCoinModel(docId: doc.id, coin: item));
                }

                List<FirestoreCoinModel> filteredList = allCoins.where((item) {
                  final matchesSearch = item.coin.name.toLowerCase().contains(
                    searchController.text.toLowerCase(),
                  );
                  final matchesRarity =
                      filterRarity == "Tümü" ||
                      item.coin.rarity == filterRarity;
                  return matchesSearch && matchesRarity;
                }).toList();

                filteredList.sort(
                  (a, b) => ascending
                      ? a.coin.value.compareTo(b.coin.value)
                      : b.coin.value.compareTo(a.coin.value),
                );

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.cardBlack,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withAlpha(40),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.monetization_on,
                          size: 70,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    if (UserRole.isAdmin) ...[
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.cardBlack,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.gold),
                          ),
                          child: selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : currentImageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    currentImageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: AppColors.gold,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Fotoğraf Seç",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(nameController, "Para Adı"),
                      const SizedBox(height: 15),
                      _buildTextField(yearController, "Yıl", isNumber: true),
                      const SizedBox(height: 15),
                      _buildTextField(
                        descriptionController,
                        "Açıklama",
                        maxLines: 3,
                      ),
                      const SizedBox(height: 15),
                      _buildDropdown(
                        "Nadirlik",
                        rarity,
                        ["Düşük", "Orta", "Yüksek"],
                        (v) {
                          setState(() => rarity = v!);
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildDropdown("Kondisyon", condition, [
                        "Çil",
                        "Çil altı",
                        "Çok çok temiz",
                        "Çok temiz",
                        "Temiz",
                        "Çok iyi",
                        "İyi",
                        "Orta",
                        "Zayıf",
                      ], (v) => setState(() => condition = v!)),
                      const SizedBox(height: 15),
                      _buildDropdown("Materyal", material, [
                        "Altın",
                        "Gümüş",
                        "Bronz",
                        "Pirinç",
                        "Alüminyum",
                        "Kâğıt",
                        "Bakır",
                      ], (v) => setState(() => material = v!)),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () {
                          int year = int.tryParse(yearController.text) ?? 2023;
                          setState(() {
                            estimatedValue = ValueCalculator.calculate(
                              year: year,
                              rarity: rarity,
                              condition: condition,
                              material: material,
                            );
                          });
                        },
                        child: const Text("Tahmini Değer Hesapla"),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: Text(
                          "Tahmini Değer: $estimatedValue TL",
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _addCoinToFirestore,
                            child: const Text("Ekle"),
                          ),
                          ElevatedButton(
                            onPressed: _updateCoinInFirestore,
                            child: const Text("Güncelle"),
                          ),
                          ElevatedButton(
                            onPressed: _clearForm,
                            child: const Text("Temizle"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              int total = 0;
                              for (var item in allCoins) {
                                total += item.coin.value;
                              }
                              setState(() {
                                totalValue = total;
                                averageValue = allCoins.isEmpty
                                    ? 0
                                    : (total / allCoins.length).round();
                              });
                            },
                            child: const Text("İstatistik Hesapla"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: AppColors.cardBlack,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Toplam Ürün: ${allCoins.length}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Toplam Değer: $totalValue TL",
                              style: const TextStyle(color: AppColors.gold),
                            ),
                            Text(
                              "Ortalama Değer: $averageValue TL",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],

                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Ürün Ara",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.gold,
                        ),
                        filled: true,
                        fillColor: AppColors.cardBlack,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildDropdown(
                      "Nadirlik Filtresi",
                      filterRarity,
                      ["Tümü", "Düşük", "Orta", "Yüksek"],
                      (v) {
                        setState(() => filterRarity = v!);
                      },
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => ascending = !ascending),
                      icon: Icon(
                        ascending ? Icons.arrow_upward : Icons.arrow_downward,
                      ),
                      label: Text(ascending ? "Değer: Artan" : "Değer: Azalan"),
                    ),
                    const SizedBox(height: 25),
                    const Center(
                      child: Text(
                        "Koleksiyon Listesi",
                        style: TextStyle(
                          fontSize: 22,
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (filteredList.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "Aranan kriterlere uygun para bulunamadı.",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                    else
                      ...filteredList.map((coinModel) {
                        final item = coinModel.coin;
                        final docId = coinModel.docId;
                        final isSelected = selectedDocId == docId;

                        return Card(
                          color: AppColors.cardBlack,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.gold
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: ListTile(
                            selected: isSelected,
                            onTap: () {
                              if (UserRole.isAdmin) {
                                setState(() {
                                  selectedDocId = docId;
                                  nameController.text = item.name;
                                  yearController.text = item.year.toString();
                                  descriptionController.text = item.description;
                                  rarity = item.rarity;
                                  condition = item.condition;
                                  material = item.material;
                                  estimatedValue = item.value;
                                  currentImageUrl = item.imagePath;
                                  selectedImage = null;
                                });
                              } else {
                                // 🛠️ BURASI DEĞİŞTİ: CoinDetailScreen sayfasına yönlendiriyor!
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CoinDetailScreen(coin: item),
                                  ),
                                );
                              }
                            },
                            leading: item.imagePath.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      item.imagePath,
                                    ),
                                  )
                                : const CircleAvatar(
                                    backgroundColor: Colors.black26,
                                    child: Icon(
                                      Icons.monetization_on,
                                      color: AppColors.gold,
                                    ),
                                  ),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${item.year} - ${item.material}\n${item.value} TL",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    item.isFavorite
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: AppColors.gold,
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      item.isFavorite = !item.isFavorite;
                                    });

                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('Paralar')
                                          .doc(docId)
                                          .update({
                                            'isFavorite': item.isFavorite,
                                          });
                                    } catch (e) {
                                      setState(() {
                                        item.isFavorite = !item.isFavorite;
                                      });
                                      _showSnackBar(
                                        "Favori güncellenemedi: $e",
                                        Colors.red,
                                      );
                                    }
                                  },
                                ),
                                if (UserRole.isAdmin)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _deleteCoinFromFirestore(docId),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.cardBlack,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.cardBlack,
      style: const TextStyle(color: Colors.white),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.cardBlack,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
